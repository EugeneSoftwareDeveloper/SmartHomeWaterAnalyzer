# AGENTS.md

## Назначение

Этот файл помогает агенту (Claude Code и т.п.) или новому разработчику быстро войти в `SmartHomeWaterAnalyzer` — Flutter Android-приложение для тестера качества воды YINMIK BLE-C600.

## Перед началом работы

`AGENTS.md` — общий профиль. История изменений — в `CHANGELOG.md`. Подробная архитектура — в `docs/`. Пользовательский гайд — в `README.md`.

Короткий свод обязательных правил — в [`CLAUDE.md`](./CLAUDE.md): инварианты, которые ломаются молча (ручное сохранение, адрес замера именами, профиль в замере, поведение геометки и автоподстановки места, стартовый каталог как данные, запиненная версия Flutter), и обязательные шаги при изменении схемы БД и состава модулей. Он специально держится коротким, потому что загружается в каждую сессию целиком; всё остальное — здесь и в `docs/`.

## Снимок проекта

- Тип: Flutter mobile app (Android-only target в MVP, архитектура совместима с iOS).
- Целевая платформа: Android 7.0+ (API 24).
- Flutter 3.47.2 (запинен в CI), Dart 3.13.
- State management: `flutter_riverpod` 2.x.
- Навигация: `go_router` 14.x.
- Локальное хранение: `shared_preferences` + `drift` (SQLite через типобезопасный wrapper) — schema v6.
- Геолокация: `geolocator` (геометка замера), `url_launcher` (открыть точку в картах).
- Графики: `fl_chart`.
- BLE: `flutter_blue_plus` 1.32+, `permission_handler` 11.x.
- Уведомления: `flutter_local_notifications` 18.x.
- Локализация: `flutter_localizations` + ARB-файлы в `lib/l10n/` (русский + английский). Язык выбирается в настройках, по умолчанию — по системе.
- Связанный репозиторий: [`SmartHomeService`](https://github.com/EugeneSoftwareDeveloper/SmartHomeService) — .NET 10 сервис умного дома с такой же интеграцией BLE-C600. Декодер портирован 1-в-1.

## Структура папок

```
lib/
├── main.dart                       # bootstrap() + ProviderScope с override SharedPreferences
├── bootstrap.dart                  # FlutterError.onError + runZonedGuarded + PlatformDispatcher
├── app.dart                        # WaterAnalyzerApp — MaterialApp.router; тема и язык из настроек
├── router.dart                     # go_router: /, /device, /history, /history/detail, /places, /help, /debug-commands
├── theme/
│   └── app_theme.dart              # Material 3, светлая + тёмная темы из одного seed-цвета
├── l10n/
│   ├── app_ru.arb                  # подписи интерфейса; оба языка обязаны быть полными
│   ├── app_en.arb
│   ├── language_names.dart         # «Русский», «English» — названия языков на них самих
│   └── generated/                  # auto-generated, не редактировать
├── providers/                      # Riverpod-провайдеры
│   ├── preferences_provider.dart
│   ├── app_settings.dart           # тема, язык, профиль, currentSourceId, lastDevice*, уведомления, геометка
│   ├── app_version_provider.dart   # версия из метаданных сборки — для «О приложении»
│   ├── yinmik_client_provider.dart
│   ├── bluetooth_state_provider.dart
│   ├── history_provider.dart       # AppDatabase (+ CatalogSeed), репозитории, стримы каталога мест
│   ├── location_provider.dart      # LocationService
│   └── notification_provider.dart
├── yinmik/                         # BLE-протокол YINMIK BLE-C600
│   ├── reading.dart                # YinmikReading — модель одного декодированного кадра
│   ├── decoder.dart                # Порт C# алгоритма (bit-swap + offset map)
│   ├── client.dart                 # scan/connect/read/write с retry, MTU + ScanState/PermissionResult
│   ├── commands.dart               # Спекулятивные байты команд + UUID FF15
│   └── reading_values.dart         # readingValues() / measurementValues() / readingFromMeasurement()
├── quality/                        # Доменная логика «качество воды»
│   ├── zone.dart                   # QualityZone + QualityCategory (цвет и порядок; подпись — расширением)
│   ├── parameter.dart              # WaterParameter (диапазон, зоны, порог шума, displayLabel)
│   ├── profile.dart                # NormsProfile: drinking/pool/aquariumFresh/hydroponics + resolve()
│   ├── catalog.dart                # WaterParameterCatalog.forProfile(profile, l10n)
│   ├── overview.dart               # WaterQualityOverview.compute(values, profile:, l10n:)
│   └── trend.dart                  # ParameterTrend: дельта к прошлому замеру с учётом порога шума
├── history/                        # Локальное хранение измерений и каталог мест
│   ├── database.dart               # Drift schema v6: Measurements, Sites, Rooms, SamplingPoints + миграции
│   ├── database.g.dart             # Auto-generated, не редактировать
│   ├── catalog_seed.dart           # Стартовый каталог на языке пользователя
│   ├── measurement_place.dart      # MeasurementPlace — адрес «место · комната · источник»
│   ├── place_catalog.dart          # PlaceCatalog — иерархия из трёх списков, полный путь источника
│   ├── place_name.dart             # normalizePlaceName — единственное правило нормализации имён
│   ├── grouping.dart               # groupMeasurementsByDay, placesInHistory, measurementIsAt
│   └── repository.dart             # HistoryRepository + PlaceCatalogRepository
├── location/                       # Геометка и привязка мест к координатам
│   ├── measurement_location.dart   # MeasurementLocation + LocationFailure (без зависимости от плагина)
│   ├── location_service.dart       # Единственный импорт geolocator: currentLocation / currentLocationIfGranted
│   ├── geo_distance.dart           # Расстояние по гаверсинусу
│   ├── site_match.dart             # matchSite — место по координатам, отказ при неоднозначности
│   └── site_anchor.dart            # updateAnchor / anchorFromFixes — обучение якоря места
├── help/
│   ├── parameter_help.dart         # Типы справки, HelpPalette, диспетчер по языку
│   ├── parameter_help_ru.dart      # Содержимое справки на русском
│   └── parameter_help_en.dart      # То же на английском — числа и цвета совпадают до символа
├── export/
│   └── csv_export.dart             # buildMeasurementsCsv + share-sheet; адрес тремя колонками site/room/source
├── notifications/
│   └── notification_service.dart   # NotificationService.notifyIfOutOfRange(overview, l10n)
└── ui/
    ├── home_page.dart              # Сканирование + список устройств + BT state + диагностика
    ├── shell_page.dart             # NavigationBar с 3 вкладками внутри подключённого устройства
    ├── reading_page.dart           # Показания + «Где мерим» с автоподстановкой места + ControlPanel
    ├── history_page.dart           # График с выбором параметра и фильтром по адресу + список по дням
    ├── history_detail_page.dart    # PageView со свайпом между записями, смена адреса, удаление
    ├── places_page.dart            # Места, комнаты, источники и привязка к координатам
    ├── help_page.dart              # Справка (одна или все, с тонкой градацией)
    ├── debug_commands_page.dart    # Пресеты + ручной hex для подбора команд + лог попыток
    ├── settings_page.dart          # Места, профиль, тема, язык, уведомления, координаты, справка
    └── widgets/
        ├── color_gauge.dart        # Анимированная цветная шкала + метки концов
        ├── chart_axis.dart         # niceAxisInterval + formatChartAxisLabel (testable helpers)
        ├── parameter_card.dart     # Карточка параметра с дельтой — тап ведёт в справку
        ├── summary_header.dart     # Hero-карточка общей оценки + статус прибора
        ├── location_card.dart      # Геометка замера + mapUris (geo:-интент, https-fallback)
        ├── place_picker.dart       # Поле «Где мерим» + иерархический лист выбора
        └── control_panel.dart      # Секция управления (подсветка, HOLD)

test/
├── yinmik_decoder_test.dart            # Регрессионные тесты декодера на эталонных кадрах
├── quality_overview_test.dart          # Сводная оценка и профили норм
├── catalog_profiles_test.dart          # Зоны качества для разных профилей
├── trend_test.dart                     # Дельты, порог шума, смена зоны
├── chart_axis_test.dart                # niceAxisInterval + formatChartAxisLabel
├── measurement_grouping_test.dart      # Группы по дням + адреса в истории
├── app_settings_test.dart              # Последний прибор, выбор языка
├── norms_profile_persistence_test.dart # Профиль норм в замере и его разбор
├── measurement_location_test.dart      # Формат координат, geo-ссылки, тексты отказов
├── location_service_test.dart          # Разрешения и таймауты через подменённый GeolocatorPlatform
├── geo_matching_test.dart              # Расстояние, распознавание места, обучение якоря
├── place_name_test.dart                # Нормализация имён
├── history_repository_test.dart        # CRUD истории через AppDatabase.forTesting(memory)
├── place_catalog_repository_test.dart  # Каталог: уникальность внутри места, стартовый набор, удаление
├── places_migration_test.dart          # v5 → v6 и v3 → v6 на настоящем файле БД
├── csv_export_test.dart                # Колонки и экранирование CSV
├── l10n_test.dart                      # Парность ARB: ключи, подстановки, плюралы
├── parameter_help_test.dart            # Парность справки: разделы, границы, цвета
└── widgets/
    ├── color_gauge_test.dart           # Smoke-тесты рендеринга шкалы
    ├── place_picker_test.dart          # Поле и лист выбора адреса
    ├── places_page_test.dart           # Экран «Места замеров»
    └── settings_language_test.dart     # Выбор языка и автоопределение

docs/
├── README.md                       # Индекс
├── 01-architecture.md              # Слои, правила зависимостей, поток данных, точки расширения
├── 02-ble-protocol.md              # BLE-C600 GATT + декодер + эталонные кадры
├── 03-control-commands.md          # HCI snoop guide + debug-страница workflow
├── 04-ui-design.md                 # Material 3, виджеты, экраны
├── 05-state-and-storage.md         # Riverpod, drift schema v6 и каталог мест, SharedPreferences, локализация, навигация
└── 06-roadmap.md                   # Приоритезированные планы

android/
├── key.properties.example          # Шаблон для release-подписи
└── app/
    ├── build.gradle.kts            # signing config + R8 minify + ABI split
    ├── proguard-rules.pro          # Keep-правила для рефлекшен-критичных пакетов
    └── src/main/AndroidManifest.xml  # BLE, геолокация, POST_NOTIFICATIONS

.github/workflows/
├── ci.yml                          # на каждый push: analyze + test; на push в master — build APK как artifact
└── release.yml                     # на push тега v*: analyze + test + build + GitHub Release с APK
```

## Схема архитектуры — поддерживать при доработках

Карта модулей, правила зависимостей и поток данных «прибор → история» живут в [`docs/01-architecture.md`](./docs/01-architecture.md) в виде Mermaid-диаграмм (рендерятся прямо на GitHub, диффятся как текст).

**Это часть контракта проекта, а не иллюстрация.** Меняешь состав слоёв, добавляешь модуль в `lib/` или заводишь новую зависимость между ними — обнови схему тем же коммитом. Схема, разошедшаяся с кодом, вреднее отсутствующей: по ней принимают решения о том, куда класть новый код.

Правки, которые обязаны отражаться в схеме:
- новая папка в `lib/` (новый модуль);
- новая стрелка зависимости между модулями (например, UI начал ходить в БД мимо репозитория — сначала подумай, не нарушение ли это правила 5);
- новый платформенный плагин;
- изменение потока сохранения замера.

## Архитектура в одном экране

Три слоя сверху вниз:

1. **UI** (`lib/ui/`) — Material 3, `ConsumerWidget`/`ConsumerStatefulWidget`, Riverpod через `ref.watch`/`ref.read`.
2. **Quality + History + Help** (`lib/quality/`, `lib/history/`, `lib/help/`) — доменная логика. Не зависят от Flutter Material: только от `Color` через `dart:ui` и от словаря `AppL10n`, который приходит параметром.
3. **Yinmik** (`lib/yinmik/`) — BLE-протокол. Декодер не зависит от `flutter_blue_plus`. Client инкапсулирует все BLE-операции.

UI зависит от Quality + Yinmik + History через providers. Quality не знает про Yinmik. История не знает про BLE.

## Связь с SmartHomeService

`YinmikDecoder` — порт C# `YinmikBleC600FrameDecoder` из соседнего репозитория. Если в SmartHomeService появляется правка декодера — повторить здесь и наоборот. Эталонные кадры в `test/yinmik_decoder_test.dart` — те же, что использовались для проверки C#-варианта.

Архитектурно приложение **независимо** от SmartHomeService.

## Команды

```powershell
flutter pub get
flutter gen-l10n                                         # генерация l10n классов
dart run build_runner build --delete-conflicting-outputs # генерация drift
flutter analyze
flutter test
flutter run                                              # dev-запуск
flutter build apk --release --split-per-abi              # release APK по архитектурам
```

Перед пушем и перед тегом — одной командой:

```powershell
python tools/ship.py --check        # те же проверки, что в CI, в том же порядке
python tools/ship.py --tag 1.5.0    # проверки, затем тег v1.5.0 и push
```

`ship.py` повторяет шаги `ci.yml` (зависимости, l10n, build_runner, формат с
теми же исключениями, анализатор, тесты) и ловит то, на чём релиз падал бы
через десять минут: замечание уровня `info` от анализатора (в CI это провал,
хотя код возврата бывает нулевой), версию в `pubspec.yaml`, разошедшуюся с
тегом, пустой раздел в `CHANGELOG.md`, грязное рабочее дерево. Отдельно
предупреждает, если локальный Flutter отличается от запиненного в CI — тогда
локальный прогон проверяет не то, что раннер, а `pub get` может переписать
`pubspec.lock`.

`tools/preview/render_preview.dart` рисует интерфейс в PNG без устройства и без
сборки APK:

```powershell
flutter test tools/preview/render_preview.dart --update-goldens
flutter test tools/preview/render_preview.dart --update-goldens --dart-define=SCENE=gauges
```

Половина интерфейса здесь — цвет: зоны шкалы, окраска карточки по зоне, знак и
цвет дельты. По коду это не проверить, а собрать APK и поставить на телефон —
минуты. Сцены: `cards` (карточки всех параметров каталога, обе темы рядом) и
`gauges` (шкала по всему диапазону). Картинки идут в `build/preview/`, в
репозиторий не попадают. Файл лежит в `tools/`, поэтому обычный `flutter test`
его не подхватывает.

Оговорка: **текст в этих картинках — не настоящий**. Widget-тесты рисуют
тестовым шрифтом, где каждый символ — квадрат, и он шире реального. Поэтому
колонки в сценах заметно шире телефонных: иначе раскладка рвётся по ширине.
Цвета, зоны и композиция достоверны, метрики текста — нет.

`tools/check_so_alignment.py` проверяет выравнивание нативных библиотек на
16 KB — требование Google Play к приложениям под Android 15+. Выравнивание даёт
тулчейн, а не код проекта, поэтому регрессия приезжает молча с обновлением
зависимости с нативной частью (у проекта это drift/sqlite3 и BLE). Шаг стоит в
`ci.yml` и `release.yml` после сборки APK; запустить руками —
`python tools/check_so_alignment.py <путь к apk>`.

## Зоны риска

- **`areCommandsKnown = true` при спекулятивных байтах**: команды подсветки/HOLD в `lib/yinmik/commands.dart` — это догадка. Если не работают, использовать debug-страницу в приложении (Reading → 🧪 в шапке) для подбора, или снять HCI snoop log (см. `docs/03-control-commands.md`).
- **Прибор держит одно BLE-подключение** — официальное приложение YINMIK блокирует наше и наоборот.
- **Android 12+ permissions** — `BLUETOOTH_SCAN` + `BLUETOOTH_CONNECT` с `neverForLocation`. Manifest уже корректен.
- **Drift schema v6** — v2 добавила `label`, v3 геометку, v4 плоский каталог `places`, v5 профиль норм, v6 иерархию `Sites` → `Rooms` → `SamplingPoints` и колонки замера `siteName`/`roomName`. Ветка v4 написана сырым SQL: таблицы `places` в текущей схеме нет, а пройти путь с версии 3 до 6 миграция обязана за один запуск. `onCreate` сидирует стартовый каталог из `CatalogSeed`, иначе на свежей установке выбирать было бы нечего. При следующем изменении схемы — `schemaVersion` 7, новая ветка и тест по образцу `test/places_migration_test.dart`: он поднимает настоящий файл БД в старом состоянии и проверяет, что данные пользователя пережили миграцию. Подробности — в `docs/05-state-and-storage.md`.
- **Замер хранит имена своего адреса, а не ссылки на каталог.** `siteName`, `roomName` и `label` (источник) — денормализованные строки; каталог нужен только для выбора. Не «чинить» это внешними ключами: тогда переименование или удаление в каталоге переписывало бы историю задним числом. По той же причине стартовый каталог создаётся сразу на языке пользователя — перевести имена, уже попавшие в историю, нельзя.
- **Battery percent — оценка** по формуле BLE-YC01 (1950–3190 mV → 0–100%). Для BLE-C600 калибровка не подтверждена.
- **Core library desugaring** включён в `android/app/build.gradle.kts` — нужно для `flutter_local_notifications`. Не отключать.
- **R8 минификация включена**: при добавлении нового пакета с reflection (например, `objectbox` или `json_serializable`) проверь, не нужны ли новые `-keep` правила в `proguard-rules.pro`.
- **Платформенный `withServices: [serviceUuid]` фильтр НЕ работает** с BLE-C600 — прибор не объявляет сервис FF01 в advertisement. Сканировать без фильтра + фильтровать по имени на клиенте.
- **`scanResults` стрим требует «прогрева»** — обязательно подписаться через `listen((_) {})` ДО `startScan`, иначе первые батчи могут потеряться (см. `YinmikBleClient.scan`).
- **Фильтр имени работает по `contains`, а не `startsWith`** (`knownNameKeywords` в `client.dart`). Дополнительно проверяется `advertisementData.advName` и есть fallback по сервису FF01 в advertisement. Если расширяешь список — добавляй короткие подстроки, которые гарантированно есть в имени всех вариантов прибора.
- **Stop → Start сканирования** требует отмены `StreamSubscription` ДО повторного `startScan`. Просто `FlutterBluePlus.stopScan()` без `cancel()` оставляет платформу в полу-остановленном состоянии и следующий `startScan` тихо игнорируется. См. `HomePage._stopScan` + 300 мс задержка в `YinmikBleClient.scan` между stop и start.
- **Release signing** — `android/key.properties` в `.gitignore`. Если файла нет, build падает на debug-ключ. Для production создай keystore и заполни `key.properties` (шаблон в `key.properties.example`).

## Практические советы

- **Конвенция «один класс на файл»** соблюдается везде, кроме мелких приватных виджетов (`_GaugePainter`, `_ZoneBadge`, `_SiteSection`).
- **Material 3 colorScheme** — единственный источник цветов хрома. Цвета зон качества (`QualityCategory.color`) — статика, не темизируются. В справке используется отдельная палитра `HelpPalette` с 7 оттенками для тонкой градации; она публичная, потому что её делят файлы содержимого на обоих языках.
- **`ref.read()` vs `ref.watch()`**: `read` для one-shot (внутри callbacks), `watch` для подписки (внутри `build`).
- **`flutter_blue_plus` стримы** требуют отписки. `_scanSubscription` в `HomePage` отписывается в `dispose`.
- **`device.disconnect()` в `finally`** — даже на ошибке.
- **При добавлении параметра** правь `lib/quality/catalog.dart` (новый параметр для каждого профиля), оба ARB-файла (название, описания, подписи зон), `lib/yinmik/reading_values.dart` (`readingValues` + `measurementValues`) и справку в `parameter_help_ru.dart` + `parameter_help_en.dart` с ключом в `parameterHelpKeys`. UI подхватит автоматически. Пошагово — в `docs/01-architecture.md`.
- **При изменении схемы БД** — schemaVersion + миграция в `onUpgrade` + `dart run build_runner build`.
- **Уведомления триггеры в `_refresh`, не в `build`** — иначе при ребилде дублируются.
- **Замеры сохраняются ТОЛЬКО при ручном нажатии FAB «Сохранить»** в `ReadingPage`. `_refresh()` и `ControlPanel.onReadingUpdated` обновляют только in-memory `_reading`. Если рефакторишь — не возвращай auto-save, это сознательное архитектурное решение.
- **Чистая логика → top-level helpers, а не private методы UI**. `groupMeasurementsByDay` (`lib/history/grouping.dart`), `niceAxisInterval`/`formatChartAxisLabel` (`lib/ui/widgets/chart_axis.dart`) вынесены из `history_page.dart` именно для unit-тестов. Любая чистая функция, которую захочется протестировать, должна оказаться в `lib/` отдельным top-level методом, а не `_методом` внутри `StatefulWidget`.
- **In-memory тесты БД**: используй `AppDatabase.forTesting(NativeDatabase.memory())`. Drift не требует sqlite-флага для тестов на Windows — работает «из коробки» (см. `test/history_repository_test.dart`).
- **Геометка не должна блокировать сохранение.** `LocationService` возвращает `LocationResult` с причиной отказа вместо исключения, таймаут 5 секунд жёсткий: в помещении фикс может не прийти вовсе, а замер важнее координат. Если добавляешь новые источники данных о местоположении — сохраняй это свойство.
- **Версия Flutter в CI запинена** (`flutter-version: 3.47.2` во всех job'ах `ci.yml` и `release.yml`). Не менять на плавающий `channel: stable`: на нём сборка уже ломалась, когда апстрим уехал на Dart 3.13, а транзитивный `analyzer` из `pubspec.lock` не знал новых AST-узлов. Поднимать версию — вместе с `flutter pub upgrade` и одинаково в `ci.yml` и `release.yml`.
- **`dart format` в CI блокирующий** — проект отформатирован целиком (коммит «Форматирование всего кода и строгая проверка в CI»). Прежняя запись про `continue-on-error` и 44 неотформатированных файла устарела. Проверяются `lib` и `test` за вычетом генерируемого (`*.g.dart`, `*.freezed.dart`, `lib/l10n/generated`): CI сначала гоняет `build_runner`, и без этих исключений шаг падал бы на выводе генератора.

## Что не делать в первой версии

- **Не превращать в постоянно подключённое приложение**. Прибор — портативный.
- **Не копировать GPL-код** из WaterQualityApp без отдельного решения по лицензии.
- **Не объявлять воду «безопасной для питья»** только по семи параметрам.

## Соглашения коммитов

- Тема первой строки **без префикса `#NN`**.
- Тело — что и зачем.
- Автор: `EugeneSoftwareDeveloper <jonjawa91@gmail.com>` (локальный `.git/config` уже выставлен).

## Хорошие цели для следующих сессий

Приоритезированный roadmap — в [`docs/06-roadmap.md`](./docs/06-roadmap.md). Топ-3 на сейчас:

1. **Реальные байты команд** (`commands.dart`) — через debug-страницу в Reading или HCI snoop. Самая близкая к пользе для пользователя дыра.
2. **Режим сравнения замеров** — поставить два-пять замеров рядом таблицей «параметр × замер» с окраской по зонам.
3. **Серия чтений со стабилизацией** — pH-электрод стабилизируется десятки секунд, одиночный кадр это случайная точка на кривой дрейфа.

Остальное (режим сравнения, iOS, Sentry, ...) — в roadmap по приоритетам.

После закрытия задачи: переноси её из `06-roadmap.md` в `CHANGELOG.md` (раздел `[Unreleased]`), не оставляй в обоих местах.
