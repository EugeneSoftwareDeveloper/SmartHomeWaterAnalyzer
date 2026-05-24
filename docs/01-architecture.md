# 01. Архитектура

## Слоистая структура

Приложение разбито на три слоя сверху вниз:

```
┌────────────────────────────────────────────────────────────┐
│  UI (lib/ui/)                                              │
│  Flutter Material 3 виджеты, StatefulWidget, setState      │
│  Зависит от: Quality + Yinmik                              │
└──────────────────────┬─────────────────────────────────────┘
                       │
        ┌──────────────┴──────────────┐
        ▼                             ▼
┌──────────────────────┐    ┌────────────────────────────┐
│  Quality             │    │  Yinmik                    │
│  lib/quality/        │    │  lib/yinmik/               │
│  Чистая Dart-логика  │    │  BLE-протокол              │
│  Параметры, нормы,   │    │  Декодер, клиент, команды  │
│  цветовые зоны       │    │                            │
│                      │    │                            │
│  Не знает про BLE    │    │  Декодер не зависит от     │
│  Не знает про Flutter│    │  flutter_blue_plus         │
│  виджеты (только Color│   │  (только dart:typed_data)  │
│  из dart:ui)         │    │                            │
└──────────────────────┘    └────────────────────────────┘
```

Правила:

- **Yinmik не зависит от Quality** — декодер просто возвращает числа.
- **Quality не зависит от Yinmik** — оценка качества работает на любом числе с подходящей размерностью.
- **UI зависит от обоих** — соединяет: берёт чтение из Yinmik, прогоняет через Quality, показывает виджетами.

Это позволяет:

- Декодер использовать в CLI-утилите, юнит-тестах, серверной части — без Flutter.
- Quality-каталог расширять без правки BLE-кода.
- Менять UI (например, перейти на другой state-management) без касания доменной логики.

## Точки расширения

### Новый параметр измерения

Сценарий: добавить, например, «остаточный хлор» (FC), если он появится в кадре или мы его вычислим.

1. **Если параметр приходит в кадре FF02** — добавь поле в `lib/yinmik/reading.dart` и декодинг в `lib/yinmik/decoder.dart`. Тесты в `test/yinmik_decoder_test.dart` обновить с эталонным значением.
2. Добавь константу `WaterParameter` в `lib/quality/catalog.dart`:

   ```dart
   static const WaterParameter freeChlorine = WaterParameter(
     key: 'fc',
     label: 'Хлор',
     unit: 'ppm',
     scaleMin: 0,
     scaleMax: 5,
     fractionDigits: 1,
     description: 'Остаточный хлор. Для питьевой воды до 0.5 ppm.',
     zones: [
       QualityZone(min: 0,   max: 0.3, category: QualityCategory.excellent, label: 'Норма'),
       QualityZone(min: 0.3, max: 1.0, category: QualityCategory.acceptable, label: 'Приемлемо'),
       QualityZone(min: 1.0, max: 5.0, category: QualityCategory.caution,   label: 'Высоко'),
     ],
   );
   ```

3. Добавь в `WaterParameterCatalog.all`.
4. В `lib/ui/reading_page.dart` метод `_extractValues` — достань значение из `YinmikReading`:

   ```dart
   WaterParameterCatalog.freeChlorine.key: reading.freeChlorinePpm,
   ```

Карточка появится автоматически.

### Новый профиль норм (бассейн / аквариум)

Сейчас `WaterParameterCatalog` — статика для питьевой воды. Чтобы добавить переключаемые профили:

1. Преврати `WaterParameterCatalog` в фабрику или enum с разными наборами зон для каждого профиля:

   ```dart
   enum NormsProfile { drinking, pool, aquariumFreshwater }

   abstract final class WaterParameterCatalog {
     static List<WaterParameter> forProfile(NormsProfile profile) { ... }
   }
   ```

2. Прокинь выбранный профиль через UI (например, `Provider` или `InheritedWidget`, или просто prop).
3. `WaterQualityOverview.compute` уже принимает `Map<String, double>` — менять не надо.

### Новая команда управления

См. `docs/03-control-commands.md`.

### Новый BLE-прибор (не YINMIK)

Сейчас `YinmikBleClient` и `YinmikDecoder` жёстко привязаны к BLE-C600. Чтобы поддержать второе семейство:

1. Сделай интерфейс `WaterQualityReader` в `lib/yinmik/`:

   ```dart
   abstract interface class WaterQualityReader {
     Future<YinmikReading> readOnce(BluetoothDevice device);
     // ... scan, sendCommand
   }
   ```

2. Перенеси текущий `YinmikBleClient` в реализацию `BleC600Reader` (`implements WaterQualityReader`).
3. Добавь вторую реализацию `BleYc01Reader` со своими UUID и декодером.
4. Перенеси выбор реализации либо на этап scan (по имени устройства), либо в UI как переключатель.

Для MVP это **не нужно**; флаг архитектурной готовности — что декодер и клиент уже разделены.

## Зависимости

- `flutter_blue_plus` ^1.32.12 — BLE.
- `permission_handler` ^11.3.1 — рантайм-разрешения.
- `cupertino_icons` ^1.0.8 — иконки (стандартно из flutter create).
- `flutter_lints` ^6.0.0 — правила линтера (dev).
- `flutter_test` — юнит-тесты (dev, SDK-бандл).

Минимальный Dart SDK: 3.11.5.

## State management

Сейчас — **локальный `setState`** в `StatefulWidget`. Никаких provider/riverpod/bloc.

Обоснование: приложение однопоточное логически, экранов мало (2), shared state — только `YinmikBleClient` экземпляр (один на HomePage, передаётся в ReadingPage пропом). Зачем тащить library для одного scoped object.

Если экранов станет много или появится фоновая логика (cron-опрос, история) — реальный кандидат для введения — `riverpod`. Тогда:

- `yinmikClientProvider` (singleton)
- `connectionStateProvider` (текущее устройство)
- `readingProvider` (последний кадр)
- `normsProfileProvider` (выбранный профиль)

Сейчас рано.
