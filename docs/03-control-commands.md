# 03. Команды управления и HCI snoop log

## Текущее состояние

В `lib/yinmik/commands.dart` лежат **спекулятивные байты** команд подсветки и HOLD. Это обоснованная догадка, основанная на:

1. В кадре FF02 байт статуса по смещению 17 имеет бит `0x08` для подсветки и `0x10` для HOLD.
2. Самый простой паттерн дешёвых BLE-устройств — «write один байт = целевое значение бита».

```dart
static final Uint8List _backlightOn  = Uint8List.fromList([0x08]);
static final Uint8List _backlightOff = Uint8List.fromList([0x00]);
static final Uint8List _holdOn       = Uint8List.fromList([0x10]);
static final Uint8List _holdOff      = Uint8List.fromList([0x00]);

static const bool areCommandsKnown = true;  // спекулятивно, но реально пишет в FF15
```

**Если эти байты не сработают** — это нормально. Дальше — как добыть правильные.

## Альтернативные паттерны, которые можно попробовать сразу

Замени значения в `commands.dart`, пересобери, проверь на приборе. Если на тапе по переключателю значение в `FF02` после команды совпало с целевым — паттерн сработал.

| Паттерн | backlight ON | backlight OFF | HOLD ON | HOLD OFF |
|---|---|---|---|---|
| Текущий (single bit) | `[0x08]` | `[0x00]` | `[0x10]` | `[0x00]` |
| Opcode + flag | `[0x01, 0x01]` | `[0x01, 0x00]` | `[0x02, 0x01]` | `[0x02, 0x00]` |
| Полный статус-байт | `[0x08]` | `[0x00]` | `[0x10]` | `[0x00]` |
| Toggle (одинаковый) | `[0xAA]` | `[0xAA]` | `[0xBB]` | `[0xBB]` |
| Префикс + бит | `[0xA5, 0x08]` | `[0xA5, 0x00]` | `[0xA5, 0x10]` | `[0xA5, 0x00]` |

Также проверь:

- **withoutResponse**: в `lib/yinmik/client.dart` `sendCommandAndRead` сейчас `withoutResponse: false`. Поменяй на `true` если ошибка GATT.
- **UUID характеристики**: `YinmikCommands.commandCharacteristicUuid` сейчас FF15. Попробуй FF02 (он же характеристика измерений) — у некоторых вариантов он также writable.

## Как добыть точные байты: HCI snoop log

Гарантированный способ — записать BLE-трафик официального приложения YINMIK при переключении подсветки, и извлечь оттуда write-команды.

### 1. Включить запись HCI snoop на телефоне

Android: `Настройки → Параметры разработчика → Bluetooth HCI snoop log` → **ВКЛ**.

> «Параметры разработчика» появляются, если 7 раз тапнуть «Номер сборки» в `Настройки → О телефоне`.

После включения **перезапусти Bluetooth** (выключи и включи) — без этого новый трафик в лог не пишется.

### 2. Записать трафик

1. Открой официальное приложение **YINMIK** на телефоне.
2. Подключи прибор как обычно.
3. **Переключи подсветку**: тапни ON → подожди 2 секунды → тапни OFF → подожди 2 секунды.
4. **Переключи HOLD**: тапни ON → подожди 2 секунды → тапни OFF.
5. **Сразу force-stop приложение YINMIK** через долгий тап на иконку → «О приложении» → «Остановить». Это нужно, чтобы Android сбросил буфер лога на диск.

### 3. Извлечь btsnoop_hci.log

Подключи телефон по USB с включённым ADB:

```powershell
adb bugreport bug.zip
```

Внутри `bug.zip` распакуй и найди файл `FS/data/misc/bluetooth/logs/btsnoop_hci.log` (точный путь зависит от Android-версии и производителя).

Альтернативно — если у тебя root или прямой доступ:

```powershell
adb pull /sdcard/btsnoop_hci.log
# или
adb pull /data/misc/bluetooth/logs/btsnoop_hci.log
```

### 4. Открыть в Wireshark

[Wireshark](https://www.wireshark.org/) → `File → Open → btsnoop_hci.log`.

Фильтр для write-команд в нашем приборе:

```text
btatt.opcode.method == 0x12
```

(`0x12` — Write Request).

Также полезные фильтры:

```text
btatt                           # все ATT-пакеты
btatt.handle == 0x000c          # конкретный handle (узнаешь из лога)
bluetooth.dst.bd_addr == aa:bb:cc:dd:ee:ff  # фильтр по MAC прибора
```

### 5. Найти команду

В отфильтрованном списке найди пакеты, временно близкие к моменту переключения подсветки. Колонка **«Info»** покажет что-то вроде:

```text
Sent Write Request, Handle: 0x000c (Unknown: Vendor Specific), Value: 08
```

Это:
- **Handle** — внутренний BLE-handle характеристики. По нему можно найти UUID: ищи в логе ранее «Read By Type Response» с этим handle, там будет UUID.
- **Value** — байты команды. В примере выше — `0x08` (один байт, что точно совпало бы с нашей спекуляцией).

Запиши:

```text
Backlight ON:  Handle=0x000c, UUID=ff15, Value=08
Backlight OFF: Handle=0x000c, UUID=ff15, Value=00
HOLD ON:       Handle=0x000c, UUID=ff15, Value=10
HOLD OFF:      Handle=0x000c, UUID=ff15, Value=00
```

(пример; в реальности может быть другая последовательность).

### 6. Подставить в commands.dart

Открой `lib/yinmik/commands.dart` и замени значения констант:

```dart
static final Uint8List _backlightOn  = Uint8List.fromList([0x08]);     // <-- сюда
static final Uint8List _backlightOff = Uint8List.fromList([0x00]);
static final Uint8List _holdOn       = Uint8List.fromList([0x10]);
static final Uint8List _holdOff      = Uint8List.fromList([0x00]);
```

Если UUID не FF15:

```dart
static final Guid commandCharacteristicUuid = Guid('0000ff??-0000-1000-8000-00805f9b34fb');
```

Пересобери:

```powershell
flutter run
```

И проверь, что после переключения переключателя `reading.backlightOn` действительно меняется.

## Добавление новой команды

Например, появится команда «авто-выключение»:

1. В `commands.dart` добавь поля:
   ```dart
   static final Uint8List _autoOffOn  = Uint8List.fromList([...]);
   static final Uint8List _autoOffOff = Uint8List.fromList([...]);
   static Uint8List autoOffCommand({required bool on}) => on ? _autoOffOn : _autoOffOff;
   ```
2. Если состояние читается из FF02 — добавь поле в `YinmikReading` и декодер.
3. В `lib/ui/widgets/control_panel.dart` добавь `_ControlTile`:
   ```dart
   _ControlTile(
     icon: Icons.timer,
     activeIcon: Icons.timer_outlined,
     title: 'Авто-выключение',
     subtitle: 'Прибор выключится через N минут',
     value: widget.reading.autoOffOn,
     enabled: !_sending,
     onChanged: (on) => _toggleAutoOff(on),
   ),
   ```
4. Метод `_toggleAutoOff` по аналогии с `_toggleBacklight`.

## Безопасность спекулятивных команд

Худший наблюдаемый исход некорректной команды на BLE-C600 — кратковременное зависание BLE-соединения. Прибор восстанавливается на следующем чтении или после извлечения батарей.

В коде нет команд «обновить прошивку», «стереть калибровку» или подобных деструктивных операций. Спекулятивные write в FF15 короткими байтами должны быть безопасны.

Тем не менее, при первом запуске на новом приборе:

1. Сначала только **читать** (несколько раз `Refresh` без касания переключателей).
2. Затем попробовать переключатель **подсветки** — это видимый эффект на экране прибора, легко проверить.
3. Только потом HOLD.
