# 02. BLE-протокол BLE-C600

## Контекст

YINMIK BLE-C600 — портативный 7-in-1 тестер качества воды (pH, ORP, EC, TDS, соленость, S.G., температура). Производитель не публикует BLE-протокол. Алгоритм декодирования восстановлен через открытые проекты семейства BLE-YC01 + сверкой с экраном прибора и официальным приложением.

Подробное исследование — в [`SmartHomeService/docs/09-yinmik-ble-water-quality-protocol.md`](https://github.com/EugeneSoftwareDeveloper/SmartHomeService/blob/master/docs/09-yinmik-ble-water-quality-protocol.md).

## GATT-структура

| Элемент | UUID | Назначение | Свойства |
|---|---|---|---|
| Основной сервис | `0000ff01-0000-1000-8000-00805f9b34fb` | сервис данных | — |
| Характеристика измерений | `0000ff02-0000-1000-8000-00805f9b34fb` | чтение кадра измерений | `read` (у некоторых вариантов также `notify` и `write`) |
| Служебная характеристика (кандидат) | `0000ff15-0000-1000-8000-00805f9b34fb` | возможно write-команды (подсветка, HOLD) | `write` |

В `lib/yinmik/client.dart`:
```dart
static final Guid serviceUuid = Guid('0000ff01-0000-1000-8000-00805f9b34fb');
static final Guid measurementCharacteristicUuid = Guid('0000ff02-0000-1000-8000-00805f9b34fb');
```

В `lib/yinmik/commands.dart`:
```dart
static final Guid commandCharacteristicUuid = Guid('0000ff15-0000-1000-8000-00805f9b34fb');
```

## Жизненный цикл чтения

1. Найти устройство сканированием (фильтр по имени `BLE-C600` / `BLE-YC` / `YINMIK`).
2. `device.connect(timeout: 20s, autoConnect: false)`.
3. `device.discoverServices()`.
4. Найти сервис `FF01`.
5. Найти характеристику `FF02`.
6. `characteristic.read()` — вернёт 24 байта (обычно).
7. Декодировать кадр (см. ниже).
8. `device.disconnect()` — **обязательно** в `finally`. Прибор иначе остаётся подключенным на стороне Android.

Прибор держит **только одно** BLE-подключение. Перед использованием закрой официальное приложение YINMIK.

## Алгоритм декодирования

Сырой кадр перед разбором проходит **bit-swap семейства BLE-YC01**: идём от конца к началу, переставляем биты через маски `0x55` и `0xAA`. Алгоритм портирован один-в-один с C#-реализации `YinmikBleC600FrameDecoder` из SmartHomeService.

```dart
// lib/yinmik/decoder.dart
static Uint8List decodeBleYc01FamilyFrame(Uint8List rawFrame) {
  final decoded = Uint8List.fromList(rawFrame);

  for (var index = decoded.length - 1; index > 0; index--) {
    final current  = decoded[index];
    final currentHigh = (current  & 0x55) << 1;
    final currentLow  = (current  & 0xAA) >> 1;

    final previous = decoded[index - 1];
    final previousHigh = (previous & 0x55) << 1;
    final previousLow  = (previous & 0xAA) >> 1;

    decoded[index]     = (0xFF - (currentHigh  | previousLow)) & 0xFF;
    decoded[index - 1] = (0xFF - (previousHigh | currentLow))  & 0xFF;
  }

  return decoded;
}
```

После декодирования числовые поля читаются как **signed int16 big-endian** по фиксированным смещениям:

| Смещение | Поле | Преобразование |
|---|---|---|
| 3..4 | pH | `value / 100` |
| 5..6 | EC | `value` в µС/см |
| 7..8 | TDS | `value` в ppm |
| 9..10 | соленость (ppm) | `value` в ppm |
| 11..12 | соленость (%) | `value / 100` в % |
| 13..14 | температура | `value / 10` в °C |
| 15..16 | батарея | сырые миливольты (raw int16) |
| 17 | статус-байт | бит `0x08` = подсветка, бит `0x10` = HOLD |
| 18..19 | S.G. | `value / 1000` |
| 20..21 | ORP | `value` в мВ |
| 22..23 | хвост | **не разобран** — возможно счётчик/CRC, быстро меняется |

## Эталонные кадры

В `test/yinmik_decoder_test.dart` лежат 4 кадра, для которых известны ожидаемые значения (подтверждены сверкой с экраном прибора в SmartHomeService):

```text
Кадр (HEX, FF02 raw):
FF A9 FE 7A FC EC FF FF FF BF FF BD FF 75 FD 0E FA ED 75 FE AC DD BB 57

После decodeBleYc01FamilyFrame:
01 02 01 02 66 01 01 01 81 00 81 00 01 00 E7 0B 70 00 03 E7 00 89 13 00

Ожидаемые значения:
pH         = 6.10
EC         = 257  µС/см
TDS        = 128  ppm
SalinityPpm    = 128  ppm
SalinityPercent= 0.01 %
Temp           = 23.1 °C
Battery        = 2928 mV (raw)
StatusFlags    = 0x00 (подсветка OFF, HOLD OFF)
SpecificGravity= 0.999
ORP            = 137  mV
```

Для проверки декодера на новых кадрах:

```dart
final raw = YinmikDecoder.parseHexFrame('FF A9 FE 78 FC EE ...');
final reading = YinmikDecoder.decodeRawFrame(raw);
print(reading);
```

## Battery percent

YINMIK BLE-C600 отдаёт **сырые миливольты** батареи, а не процент. По формуле семейства BLE-YC01:

```dart
batteryPercent = 100 * (rawMv - 1950) / (3190 - 1950)
```

Это даёт примерное соответствие 1950 mV ≈ 0%, 3190 mV ≈ 100%. Для BLE-C600 калибровка не подтверждена, но порядок величин разумный.

Реализация — в `lib/yinmik/reading.dart`:
```dart
int get batteryPercentEstimate {
  const minMv = 1950;
  const maxMv = 3190;
  final clamped = batteryRawMillivolts.clamp(minMv, maxMv);
  return (100 * (clamped - minMv) / (maxMv - minMv)).round();
}
```

## Стабильность pH

pH «дрожит» сильнее остальных параметров — электрод стабилизируется во времени. Один кадр может отличаться от соседнего на ±0.1 даже в идеальной среде.

Для текущего UI это не проблема: пользователь видит мгновенное значение и понимает, что нужно подождать. Если в будущем понадобится сглаживание — варианты:

- Хранить N последних кадров, показывать медиану.
- «Стабильное значение»: показывать как-то отдельно, что значение не менялось более N кадров с дельтой меньше M.

В MVP не реализовано.

## Запись команд

См. отдельный документ [`03-control-commands.md`](./03-control-commands.md).
