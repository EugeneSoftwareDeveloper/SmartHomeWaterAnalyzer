# AGENTS.md

## Назначение

Этот файл помогает агенту (Claude Code и т.п.) или новому разработчику быстро войти в `SmartHomeWaterAnalyzer` — Flutter Android-приложение для тестера качества воды YINMIK BLE-C600.

## Перед началом работы

`AGENTS.md` — общий профиль. История изменений — в `CHANGELOG.md`, `git log master..` и в issues/PR на GitHub. Подробная архитектура — в `docs/`. Пользовательский гайд — в `README.md`.

## Снимок проекта

- Тип: Flutter mobile app (Android-only target в MVP, архитектура совместима с iOS).
- Целевая платформа: Android 7.0+ (API 24).
- Flutter: 3.41+, Dart: 3.11+.
- State management: `flutter_riverpod` 2.x.
- Навигация: `go_router` 14.x.
- Локальное хранение: `shared_preferences` + `drift` (SQLite через типобезопасный wrapper).
- Графики: `fl_chart`.
- BLE: `flutter_blue_plus` 1.32+, `permission_handler` 11.x.
- Уведомления: `flutter_local_notifications` 18.x.
- Локализация: `flutter_localizations` + ARB-файлы в `lib/l10n/` (русский + английский).
- Связанный репозиторий: [`SmartHomeService`](https://github.com/EugeneSoftwareDeveloper/SmartHomeService) — .NET 10 сервис умного дома с такой же интеграцией BLE-C600. Декодер портирован 1-в-1.

## Структура папок

```
lib/
├── main.dart                       # bootstrap() + ProviderScope + override SharedPreferences
├── bootstrap.dart                  # FlutterError.onError + runZonedGuarded + PlatformDispatcher
├── app.dart                        # WaterAnalyzerApp — ConsumerWidget с MaterialApp.router
├── router.dart                     # go_router конфиг: / + /device
├── theme/
│   └── app_theme.dart              # Material 3, светлая + тёмная темы из одного seed-цвета
├── l10n/                           # ARB-файлы + сгенерированные классы
│   ├── app_ru.arb
│   ├── app_en.arb
│   └── generated/                  # auto-generated, не редактировать
├── providers/                      # Riverpod-провайдеры
│   ├── preferences_provider.dart
│   ├── app_settings.dart           # тема, профиль, lastDevice, notifications
│   ├── yinmik_client_provider.dart
│   ├── bluetooth_state_provider.dart
│   ├── history_provider.dart       # AppDatabase + HistoryRepository + recentMeasurementsProvider
│   └── notification_provider.dart
├── yinmik/                         # BLE-протокол YINMIK BLE-C600
│   ├── reading.dart                # YinmikReading — модель одного декодированного кадра
│   ├── decoder.dart                # Порт C# алгоритма (bit-swap + offset map)
│   ├── client.dart                 # scan/connect/read/write с retry, MTU, scan-фильтром
│   └── commands.dart               # Спекулятивные байты команд + UUID FF15
├── quality/                        # Доменная логика «качество воды»
│   ├── zone.dart                   # QualityZone + QualityCategory (5 категорий, фиксированные цвета)
│   ├── parameter.dart              # WaterParameter (имя, единица, диапазон, зоны)
│   ├── profile.dart                # NormsProfile enum: drinking/pool/aquariumFresh/hydroponics
│   ├── catalog.dart                # WaterParameterCatalog.forProfile(profile) — параметры под профиль
│   └── overview.dart               # WaterQualityOverview.compute(values, profile:) — сводная оценка
├── history/                        # Локальное хранение измерений
│   ├── database.dart               # Drift schema + @DriftDatabase
│   ├── database.g.dart             # Auto-generated, не редактировать
│   └── repository.dart             # HistoryRepository — фасад над БД
├── export/
│   └── csv_export.dart             # CsvExporter.shareMeasurementsCsv → CSV в /temp + share-sheet
├── notifications/
│   └── notification_service.dart   # NotificationService.notifyIfOutOfRange(overview)
└── ui/
    ├── home_page.dart              # Сканирование + список устройств + BT state
    ├── shell_page.dart             # NavigationBar с 3 вкладками
    ├── reading_page.dart           # Текущие показания + ControlPanel
    ├── history_page.dart           # График pH + список + меню «экспорт/очистка»
    ├── settings_page.dart          # Тема + профиль + уведомления + О приложении
    └── widgets/
        ├── color_gauge.dart        # Анимированная цветная шкала + метки концов
        ├── parameter_card.dart     # Карточка параметра с expandable описанием
        ├── summary_header.dart     # Hero-карточка общей оценки + статус прибора
        └── control_panel.dart      # Секция управления (подсветка, HOLD)

test/
├── yinmik_decoder_test.dart        # 5 регрессионных тестов декодера
├── quality_overview_test.dart      # 7 тестов на сводную оценку и профили
├── catalog_profiles_test.dart      # 5 тестов на зоны для разных профилей
└── widgets/
    └── color_gauge_test.dart       # Smoke-тесты рендеринга шкалы

docs/
├── README.md                       # Индекс
├── 01-architecture.md              # Слои, точки расширения, паттерны
├── 02-ble-protocol.md              # BLE-C600 GATT + декодер + эталонные кадры
├── 03-control-commands.md          # HCI snoop guide + commands.dart
├── 04-ui-design.md                 # Material 3, виджеты, темы
└── 05-state-and-storage.md         # Riverpod, drift, SharedPreferences, l10n, навигация

android/
├── key.properties.example          # Шаблон для release-подписи
└── app/build.gradle.kts            # Подписан release-ключом, если key.properties существует;
                                    # иначе fallback на debug-ключ

.github/workflows/
└── ci.yml                          # CI: analyze + test + build APK
```

## Архитектура в одном экране

Три слоя сверху вниз:

1. **UI** (`lib/ui/`) — Material 3, `ConsumerWidget`/`ConsumerStatefulWidget`, Riverpod providers через `ref.watch`/`ref.read`.
2. **Quality + History** (`lib/quality/`, `lib/history/`) — доменная логика. Не зависят от Flutter Material.
3. **Yinmik** (`lib/yinmik/`) — BLE-протокол. Декодер не зависит от `flutter_blue_plus`. Client инкапсулирует все BLE-операции с retry, MTU, scan-фильтром.

UI зависит от Quality + Yinmik + History (через providers). Quality не знает про Yinmik. История не знает про BLE.

## Связь с SmartHomeService

`YinmikDecoder` — порт C# `YinmikBleC600FrameDecoder` из соседнего репозитория `SmartHomeService`. Эталонные кадры в `test/yinmik_decoder_test.dart` — те же, что использовались для проверки C#-варианта.

Архитектурно приложение **независимо** от SmartHomeService — подключается к BLE напрямую.

## Тестирование

### Что покрыто
- **Декодер** — 5 тестов на эталонных кадрах с известными ожидаемыми значениями.
- **Quality overview** — 7 тестов на агрегацию (всё хорошо / есть проблема / разные профили).
- **Catalog profiles** — 5 тестов на корректность зон для каждого профиля.
- **ColorGauge** — smoke-тесты рендеринга для всех параметров, проверка clipping вне диапазона.

### Что НЕ покрыто
- Виджеты `ParameterCard`, `SummaryHeader`, `ControlPanel` — golden или widget-тесты.
- `HomePage`/`ReadingPage` — нужны mocks для `YinmikBleClient` через `mocktail`.
- BLE-клиент — тестируется только на железе.

### Команды
```powershell
flutter pub get
flutter gen-l10n                                         # генерация l10n классов
dart run build_runner build --delete-conflicting-outputs # генерация drift
flutter analyze
flutter test
flutter run                                              # dev-запуск
flutter build apk --release                              # release APK
```

## Зоны риска

- **`areCommandsKnown = true` при спекулятивных байтах**: команды подсветки/HOLD в `lib/yinmik/commands.dart` — это догадка. На большинстве партий BLE-C600 должны работать; если нет — снять HCI snoop и подставить реальные байты (см. `docs/03-control-commands.md`).
- **Прибор держит одно BLE-подключение** — официальное приложение YINMIK блокирует наше и наоборот.
- **Android 12+ permissions** — `BLUETOOTH_SCAN` + `BLUETOOTH_CONNECT` с `neverForLocation`. На Android ≤11 — `ACCESS_FINE_LOCATION`. Manifest уже корректен.
- **POST_NOTIFICATIONS на Android 13+** — рантайм-запрос делает `NotificationService.init()` при первом использовании.
- **Drift schema version** — при изменении таблицы `Measurements` поднять `schemaVersion` и добавить миграцию.
- **Battery percent — оценка** по формуле BLE-YC01 (1950–3190 mV → 0–100%). Для BLE-C600 калибровка не подтверждена.
- **Core library desugaring** включён в `android/app/build.gradle.kts` — нужно для `flutter_local_notifications`. Не отключать.
- **Release signing** — `android/key.properties` в `.gitignore`. Если файл отсутствует, build падает обратно на debug-ключ. Для production-релиза создай keystore и заполни `key.properties` (шаблон в `key.properties.example`).

## Практические советы

- **Конвенция «один класс на файл»** соблюдается везде, кроме мелких приватных виджетов (`_GaugePainter`, `_ZoneBadge`).
- **Material 3 colorScheme** — единственный источник цветов хрома. Цвета зон качества (`QualityCategory.color`) — статика.
- **`ref.read()` vs `ref.watch()`**: `read` для one-shot (внутри callbacks), `watch` для подписки (внутри `build`).
- **`flutter_blue_plus` стримы** требуют отписки. `_scanSubscription` в `HomePage` отписывается в `dispose`.
- **`device.disconnect()` в `finally`** — даже на ошибке (см. `_safeDisconnect` в `client.dart`).
- **При добавлении параметра** правь `lib/quality/catalog.dart` (новый параметр для каждого профиля) и `_extractValues` в `lib/ui/reading_page.dart`.
- **При изменении схемы БД** — schemaVersion + миграция + `dart run build_runner build`.

## Что не делать в первой версии

- **Не превращать в постоянно подключённое приложение**. Прибор — портативный. Каждое чтение — новая сессия.
- **Не копировать GPL-код** из открытых проектов (WaterQualityApp на GitLab) без отдельного решения по лицензии.
- **Не объявлять воду «безопасной для питья»** только по pH/TDS/EC/ORP/солености/температуры — это лабораторно недостаточно.

## Соглашения коммитов

- Тема первой строки **без префикса `#NN`**.
- Тело — что и зачем.
- Автор: `EugeneSoftwareDeveloper <jonjawa91@gmail.com>` (локальный `.git/config` уже выставлен).

## Хорошие цели для следующих сессий

- **Снять HCI snoop log** с официального YINMIK-приложения, заменить спекулятивные байты команд на реальные.
- **App icon + splash screen** — заменить `assets/icon/README.md` на реальные PNG и запустить `dart run flutter_launcher_icons` / `dart run flutter_native_splash:create`.
- **Golden-тесты** для `ParameterCard`, `SummaryHeader`, `ColorGauge`.
- **Mock-based тесты** `HomePage`/`ReadingPage` через `mocktail`.
- **Sentry / Firebase Crashlytics** — подключение в `bootstrap.dart` (есть TODO-комментарий).
- **iOS-сборка** — `flutter create --platforms=ios .` + Info.plist Bluetooth-разрешения.
- **Фоновый опрос** через `workmanager` (опционально, осторожно — Android battery optimization).
