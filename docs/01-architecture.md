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

3. Добавь параметр во все профили в `WaterParameterCatalog.forProfile(...)` (внутри `lib/quality/catalog.dart`) — у каждого профиля свой набор зон.
4. В `lib/yinmik/reading_values.dart` дополни `readingValues` и `measurementValues` — это **single source of truth** маппинга «домен/БД-запись → `Map<key, value>`»:

   ```dart
   'fc': reading.freeChlorinePpm,
   ```

5. В `lib/help/parameter_help.dart` добавь подробную справку с тонкой градацией зон для нового параметра.
6. Если параметр должен сохраняться в БД — поднять `schemaVersion` в `AppDatabase`, добавить колонку + ветку миграции, перегенерить drift.

Карточка появится автоматически на ReadingPage, HistoryDetailPage, а график получит новую опцию в `DropdownButton` (берётся из `WaterParameterCatalog.forProfile`).

### Новая чистая логика (например, новый способ группировки истории)

Если хочется протестировать функцию, не делай её private методом UI-виджета — вынеси top-level в `lib/`. Так уже сделано для:

- `groupMeasurementsByDay` (`lib/history/grouping.dart`) — группировка списка измерений по календарной дате. Принимает опциональный `now` параметр для детерминированности в тестах.
- `niceAxisInterval`, `formatChartAxisLabel` (`lib/ui/widgets/chart_axis.dart`) — подбор шага и формата меток оси y графика.

Тесты на оба — `test/measurement_grouping_test.dart`, `test/chart_axis_test.dart`. Берите эти файлы за шаблон при добавлении новой helper-логики.

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

### Production
- `flutter_blue_plus` ^1.32.12 — BLE.
- `permission_handler` ^11.3.1 — рантайм-разрешения.
- `flutter_riverpod` ^2.6.1 — state management + DI.
- `go_router` ^14.6.2 — навигация.
- `drift` ^2.21.0 + `sqlite3_flutter_libs` — локальная БД истории.
- `fl_chart` ^0.69.2 — графики.
- `shared_preferences` ^2.3.3 — настройки.
- `flutter_local_notifications` ^18.0.1 — уведомления при выходе из нормы.
- `share_plus` ^10.1.2 — экспорт CSV.
- `intl` ^0.20.2 + `flutter_localizations` — локализация.
- `path_provider` + `path` — пути для drift.

### Dev
- `flutter_lints` + `flutter_test` — стандартный комплект.
- `build_runner` + `drift_dev` — code generation для drift.
- `flutter_launcher_icons` + `flutter_native_splash` — сборка иконок/splash.
- `mocktail` — мок-инфраструктура для тестов.
- `integration_test` — e2e-сценарии.

Минимальный Dart SDK: 3.11.5.

## State management

Используется **`flutter_riverpod` 2.x**. Полный обзор провайдеров — в `docs/05-state-and-storage.md`.

Краткая карта:

| Слой | Что | Где |
|---|---|---|
| Singleton-сервисы | `YinmikBleClient`, `AppDatabase`, `NotificationService` | `lib/providers/` |
| Persisted state | `AppSettings` (тема, профиль, lastDevice, currentLabel) | `app_settings.dart` |
| Стримы платформы | `bluetoothAdapterStateProvider` | `bluetooth_state_provider.dart` |
| Стримы БД | `recentMeasurementsProvider` | `history_provider.dart` |

Локальное эфемерное состояние (loading flag, текущая страница) остаётся в `StatefulWidget` с `setState` — не выносится в провайдеры без необходимости.
