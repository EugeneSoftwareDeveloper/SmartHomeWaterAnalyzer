# 05. State management и хранение данных

## State management: Riverpod

Приложение использует [`flutter_riverpod`](https://riverpod.dev) 2.x для управления состоянием и DI. Это значит:

- Singleton-сервисы (BLE-клиент, БД, сервис уведомлений) — `Provider`.
- Изменяемое состояние с persist (настройки) — `StateNotifierProvider`.
- Стримы от платформы (Bluetooth-adapter state) — `StreamProvider`.
- Реактивная история из БД — `StreamProvider`.

Все провайдеры лежат в `lib/providers/`.

### Карта провайдеров

| Провайдер | Тип | Файл | Что делает |
|---|---|---|---|
| `sharedPreferencesProvider` | Provider (override) | `preferences_provider.dart` | Доступ к `SharedPreferences`. Override-нут в `main.dart` после `await SharedPreferences.getInstance()`. |
| `appSettingsProvider` | StateNotifierProvider | `app_settings.dart` | Тема, язык, профиль норм, выбранный источник, lastDeviceId + lastDeviceName, флаги уведомлений и геометки. Persist через SharedPreferences. |
| `yinmikBleClientProvider` | Provider | `yinmik_client_provider.dart` | Singleton `YinmikBleClient` на всё приложение. |
| `bluetoothAdapterStateProvider` | StreamProvider | `bluetooth_state_provider.dart` | Состояние Bluetooth-адаптера (включён/выключен). UI реагирует на изменение в реальном времени. |
| `appDatabaseProvider` | Provider | `history_provider.dart` | Drift `AppDatabase` singleton. Закрывается через `ref.onDispose`. Стартовый каталог (`CatalogSeed`) собирает на языке пользователя — выбранном в настройках, а при автоопределении системном: имена уходят в историю и потом не переводятся. |
| `historyRepositoryProvider` | Provider | `history_provider.dart` | `HistoryRepository` — фасад над БД. |
| `recentMeasurementsProvider` | StreamProvider | `history_provider.dart` | Стрим последних измерений. Auto-rebuild списка истории при `insert`/`delete`. |
| `notificationServiceProvider` | Provider | `notification_provider.dart` | `NotificationService` с lazy-init (запрашивает разрешения, создаёт канал). |
| `placeCatalogProvider` | Provider | `history_provider.dart` | `PlaceCatalogRepository` — каталог мест, комнат и источников. |
| `sitesProvider` / `roomsProvider` / `sourcesProvider` | StreamProvider | `history_provider.dart` | Три уровня каталога отдельными стримами: недавно использованные сверху, остальные по алфавиту. |
| `placeCatalogViewProvider` | Provider | `history_provider.dart` | Сводит три стрима в `PlaceCatalog` — связку, которая умеет собрать полный адрес источника. Ошибка любого из трёх становится ошибкой целого, загрузка любого — загрузкой целого: подменять недогруженный стрим пустым списком нельзя, список выбора показал бы «мест нет» там, где они просто не приехали. |
| `locationServiceProvider` | Provider | `location_provider.dart` | `LocationService` поверх `geolocator`. Состояния не имеет — в провайдере только ради подмены в тестах. |
| `appVersionProvider` | FutureProvider | `app_version_provider.dart` | Версия вида «1.5.0 (8)» из метаданных сборки — для «О приложении». Константой её не держат: зашитая строка расходится с `pubspec.yaml` после каждого релиза. |

### Как добавить новый провайдер

1. Создай файл в `lib/providers/`.
2. Опиши тип (`Provider`/`StateNotifierProvider`/`StreamProvider`/`FutureProvider`).
3. Используй в виджете через `ref.watch(...)` (для подписки) или `ref.read(...)` (для one-shot).
4. В `ConsumerWidget`/`ConsumerStatefulWidget` — `WidgetRef ref` приходит как параметр.

### Что НЕ использует Riverpod

- Локальное эфемерное состояние (loading flag, текущая страница в ListView) остаётся в `StatefulWidget` через `setState`. Это нормально и проще.
- Глобальный navigation state — управляется `go_router`, не Riverpod.

## Локальное хранение

### SharedPreferences

`AppSettings` хранятся в системном KV-сторе через `shared_preferences`. Ключи:
- `settings.themeMode` — string, имя enum-значения `ThemeMode`.
- `settings.normsProfile` — string, имя enum-значения `NormsProfile`.
- `settings.lastDeviceId` — string или null, BLE remoteId. Используется кнопкой быстрого переподключения на HomePage: `BluetoothDevice.fromId(id)` минует скан.
- `settings.lastDeviceName` — string или null, имя прибора на момент подключения. Только для подписи кнопки; настройки версий ≤ 1.1.x без этого ключа читаются как null, и кнопка показывает MAC.
- `settings.notificationsEnabled` — bool.
- `settings.currentSourceId` — int или null, выбранный источник. Здесь ссылка уместна, в отличие от сохранённого замера: это «что выбрано прямо сейчас», а не исторический факт, и удаление источника должно сбрасывать выбор, а не оставлять указатель на несуществующее имя.
- `settings.currentLabel` — string или null, **наследие версий до 1.4.0**: плоское имя места. Читается один раз при первом открытии экрана показаний, резолвится в источник по `legacyLabel` и удаляется.
- `settings.locale` — string или null, код выбранного языка. `null` означает «определять по системе», и это не то же самое, что «выбран ровно системный язык»: в первом случае смена языка телефона меняет и язык приложения, во втором — нет. Код языка, который приложение больше не поддерживает, читается как `null`.
- `settings.saveLocationEnabled` — bool, прикреплять ли координаты к замерам. По умолчанию `true`.

Запись через `AppSettingsNotifier` синхронна для in-memory state, асинхронна для диска (`await _prefs.setX`). UI не ждёт диска — сразу видит изменения.

### Drift (SQLite)

История измерений — таблица `Measurements` в SQLite-файле `<app docs>/water_analyzer.sqlite`.

**Текущая schemaVersion = 6.** История версий:

| Версия | Что появилось |
|---|---|
| v2 | `label TEXT NULL` — пользовательская метка замера |
| v3 | `latitude` / `longitude` / `locationAccuracyMeters` (все `REAL NULL`) — геометка |
| v4 | таблица `places` — плоский каталог мест (удалена в v6) |
| v5 | `normsProfile TEXT NULL` — профиль норм, по которому оценивался замер |
| v6 | таблицы `Sites`, `Rooms`, `SamplingPoints` — иерархия «место → комната → источник»; колонки замера `siteName` и `roomName` |

Миграции выполняются автоматически при первом запуске после обновления:

```dart
MigrationStrategy get migration => MigrationStrategy(
      onCreate: (m) async {
        await m.createAll();
        await _createSamplingPointIndexes();
        await _seedDefaultCatalog();   // «Дом» и стартовые источники из CatalogSeed
      },
      onUpgrade: (m, from, to) async {
        if (from < 2) await m.addColumn(measurements, measurements.label);
        if (from < 3) { /* latitude, longitude, locationAccuracyMeters */ }
        if (from < 4) {
          await _createLegacyPlacesTable();       // сырым SQL: таблицы уже нет в схеме
          await _importLegacyPlacesFromLabels();  // ДО сидирования, см. ниже
          await _seedLegacyPlaces();
        }
        if (from < 5) await m.addColumn(measurements, measurements.normsProfile);
        if (from < 6) {
          await m.createTable(sites);
          await m.createTable(rooms);
          await m.createTable(samplingPoints);
          await _createSamplingPointIndexes();
          await m.addColumn(measurements, measurements.siteName);
          await m.addColumn(measurements, measurements.roomName);
          await _migrateLegacyPlacesIntoHierarchy();  // places → источники под «Домом»
        }
      },
    );
```

**Ветка v4 написана сырым SQL**, а не через drift-таблицу: в v6 таблица `places` удаляется и из схемы приложения ушла. Миграция обязана уметь пройти путь пользователя целиком — с версии 3 до 6 за один запуск, — даже если структуры, которую она создаёт по дороге, в текущем коде уже нет.

Порядок в ветке v4 значим. Обе вставки идут через `insertOrIgnore`, то есть выигрывает пришедшая первой. Метка пользователя несёт `lastUsedAt` (время его последнего замера), дефолт — нет. При обратном порядке метка «Аквариум» была бы отброшена как дубликат уже вставленного дефолта, потеряла бы `lastUsedAt` и уехала в конец списка ниже мест, которыми не пользовались ни разу. Совпадение вероятно: дефолты названы типовыми словами.

### Профиль норм в замере

`Measurements.normsProfile` хранит имя значения `NormsProfile` и может быть `null` — так выглядят записи, сделанные до версии 1.2.0.

Разбор всегда идёт через `NormsProfile.resolve(storedName, fallback: текущийПрофиль)`: он возвращает `fallback` и для `null`, и для незнакомого имени (запись из более новой версии приложения, где профилей стало больше). Прямой `NormsProfile.values.byName(...)` в этом месте бросил бы исключение и уронил экран истории.

Зачем это нужно: «опасно / норма» — свойство замера, а не текущей настройки. Без хранения профиля замер в бассейне после переключения на питьевую воду задним числом краснел бы.

Схема — в `lib/history/database.dart`. После изменения схемы нужно:

1. Поднять `schemaVersion` в `AppDatabase` (следующая — 7).
2. Добавить ветку миграции в `migration` getter.
3. Перегенерить через `dart run build_runner build --delete-conflicting-outputs`.
4. Написать тест на миграцию по образцу `test/places_migration_test.dart` — он поднимает **настоящий файл БД** в старом состоянии (raw SQL + `PRAGMA user_version`), открывает его через `AppDatabase.forTesting(NativeDatabase(file))` и проверяет, что данные пользователя пережили обновление. In-memory база для этого не подходит: она пересоздаётся на каждое соединение.

При откате версии БД (даунгрейд) drift не делает ничего — если установить старую версию приложения поверх новой схемы, она просто не увидит новые колонки. Безопасно.

### Каталог мест и денормализация

Замер хранит **имена** своего адреса, а не внешние ключи на каталог. Это сделано намеренно: переименование или удаление в каталоге не должно переписывать историю задним числом — записанное «Кран на кухне» остаётся тем, чем было в момент замера. Каталог нужен только для выбора адреса перед замером.

Следствие: удаление места, комнаты или источника не трогает историю — сохранённые замеры держат **имена** всех трёх уровней в своих колонках. `markSourceUsed` для отсутствующего источника просто ничего не делает.

Начиная со схемы v6 адрес замера разложен по трём колонкам: `siteName`, `roomName` и `label`. Последняя означает **источник** и сохранила прежний смысл — если бы в неё писался весь путь, на границе обновления строка изменилась бы и разорвала тренды с фильтром графика.

### Таблицы каталога (v6)

| Таблица | Ключевые колонки | Заметки |
|---|---|---|
| `Sites` — места | `name` UNIQUE, `city`, `latitude` / `longitude`, `anchorAccuracyMeters`, `anchorSamples`, `radiusMeters` (по умолчанию 150), `lastUsedAt` | Координаты — «якорь» места для автоподстановки; пустые, пока место не привязано. |
| `Rooms` — комнаты | `siteId`, `name`, `lastUsedAt`; UNIQUE(`siteId`, `name`) | Уровень необязательный. |
| `SamplingPoints` — источники | `siteId`, `roomId` (NULL — источник прямо на месте), `name`, `legacyLabel`, `lastUsedAt` | `legacyLabel` заполняет только миграция v6 — см. ниже. |

**Уникальность источника — двумя частичными индексами, а не `UNIQUE(...)`.** В SQLite `NULL` в составном уникальном ключе считаются различными, и две «Скважины» без комнаты под одним местом прошли бы обе:

```sql
CREATE UNIQUE INDEX ux_sampling_points_room ON sampling_points (site_id, room_id, name) WHERE room_id IS NOT NULL;
CREATE UNIQUE INDEX ux_sampling_points_site ON sampling_points (site_id, name)          WHERE room_id IS NULL;
```

**Вставка — `insertOrIgnore` с последующим чтением**, а не «сначала проверить, потом вставить»: между проверкой и вставкой успевает пролезть второй вызов (кнопка «+» и submit с клавиатуры срабатывают почти одновременно), и база отвечает `UNIQUE constraint failed`.

**Удаление — явной транзакцией**, а не `ON DELETE CASCADE`: каскад в SQLite работает только при `PRAGMA foreign_keys = ON`, а включать его для всей базы ради одной операции значит заодно поменять поведение всех остальных таблиц.

**`legacyLabel` склеивает историю через границу 1.4.0.** У замеров до неё `siteName` пуст, и по структуре они не найдутся как база сравнения. Поэтому `latestForPlace` для мигрировавшего источника дополнительно ищет замеры с `siteName IS NULL` и `label = legacyLabel`. У созданных вручную источников поле обязано оставаться пустым — иначе новый «Дача · Фильтр» присвоил бы себе историю старого «Фильтра», сделанного дома.

### Привязка мест к координатам

Автоподстановка места собрана из трёх чистых функций в `lib/location/` — без `geolocator`, без drift и без Flutter, поэтому проверяются в `test/geo_matching_test.dart` без устройства.

| Функция | Файл | Правило |
|---|---|---|
| `distanceMeters` | `geo_distance.dart` | Гаверсинус через `atan2`, радиус Земли 6 371 008.8 м. |
| `matchSite` | `site_match.dart` | Место — кандидат, если расстояние до якоря ≤ `radiusMeters` + погрешность фикса. Из нескольких кандидатов ближайший выбирается, только если следующий **вдвое** дальше; иначе не выбирается никто. |
| `updateAnchor` | `site_anchor.dart` | Первый фикс становится якорем. Следующие усредняются с весом 1/погрешность², погрешность ограничена снизу 5 м. Фикс дальше `max(3 × радиус, 500 м)` отбрасывается как выброс. |
| `anchorFromFixes` | `site_anchor.dart` | Одноразовый якорь из истории при миграции v6 — только если ≥ 80 % фиксов лежат в 200 м от медианы. |

Почему именно так:

- **Погрешность фикса прибавляется к радиусу.** При точности в сотню метров требовать попадания в 150 м значило бы не срабатывать ровно там, где подстановка нужнее всего, — в помещении.
- **Неоднозначность — это отказ, а не выбор наугад.** Две квартиры в соседних домах не должны молча подменять друг друга: ошибка подстановки дороже её отсутствия, потому что замер уходит в историю не туда.
- **Пол точности 5 м.** Платформа иногда рапортует единицы метров и даже ноль; без пола вес такого фикса ушёл бы в бесконечность, и один случайный замер намертво зафиксировал бы якорь.
- **Медиана, а не среднее, при миграции.** У пользователя, мерившего и дома, и на даче, центроид оказался бы посреди поля между ними. Медиана позволяет распознать такой разброс и не привязывать место вовсе — якорь появится сам при первом сохранении.

Якорь учится при каждом сохранении замера с координатами (`ReadingPage._learnAnchor`). Сама подстановка берёт координаты через `LocationService.currentLocationIfGranted`: этот метод **никогда** не показывает системный диалог разрешений — иначе диалог переехал бы с осознанного «Сохранить» на простое открытие экрана.

Сортировка каталога — недавно использованные сверху, затем по алфавиту:

```dart
..orderBy([
  (t) => OrderingTerm.desc(t.lastUsedAt),
  (t) => OrderingTerm.asc(t.name),
])
```

В SQLite `NULL` меньше любого значения, поэтому при `DESC` места, которыми ещё не пользовались, естественным образом уходят в хвост — отдельный `NULLS LAST` не нужен.

Репозиторий `HistoryRepository` — единственная точка работы с БД из UI. Принимает доменные `YinmikReading`, скрывает drift-специфику. Это означает:

- UI зависит от `HistoryRepository`, а не от `AppDatabase` напрямую.
- В тестах можно подменить `historyRepositoryProvider` на мок, или (предпочтительнее для CRUD-тестов) запустить настоящий репозиторий поверх in-memory drift через `AppDatabase.forTesting(NativeDatabase.memory())`.
- Замена drift на другую БД-библиотеку = переписывание `repository.dart`, не UI.

### Методы HistoryRepository

| Метод | Что делает | Возвращает |
|---|---|---|
| `save(deviceId, reading, observedAt, {place, location, normsProfile})` | Вставка новой записи. Адрес раскладывается по `siteName` / `roomName` / `label` после нормализации имён. | `int` — id вставленной строки. Нужен для undo. |
| `recent({deviceId, limit})` | Список последних, `desc by observedAt`. | `List<Measurement>` |
| `watchRecent({deviceId, limit})` | Стрим последних с реактивным обновлением при insert/delete. | `Stream<List<Measurement>>` |
| `latestForPlace(deviceId, place, {legacyLabel})` | Последний замер этого прибора по этому адресу — база для сравнения «стало / было» на экране показаний. Имена нормализуются тем же правилом, что при записи; пустой уровень ищется через `IS NULL`. `legacyLabel` подтягивает замеры до 1.4.0 — см. «Таблицы каталога». | `Measurement?` |
| `updatePlace(id, place)` | Меняет адрес у сохранённой записи — из детального просмотра, через тот же каталог, что и экран показаний. | `int` — затронутых строк (0 / 1). |
| `deleteById(id)` | Удаляет одну запись. | `int` — затронутых строк (0 / 1). |
| `restoreFromMeasurement(m)` | Восстанавливает удалённую запись с её исходным id через `InsertMode.insertOrReplace`. Используется в undo для swipe-to-delete и FAB «Сохранить → Отменить». | `int` — затронутых строк. |
| `clear({deviceId})` | Полная очистка таблицы. | `Future<void>` |

### Методы PlaceCatalogRepository

Каталог мест живёт в том же файле `repository.dart` и работает через тот же `AppDatabase`.

| Метод | Что делает |
|---|---|
| `watchSites()` / `watchRooms()` / `watchSources()` | Три уровня каталога стримами — для `sitesProvider` и соседей. Недавно использованные сверху. |
| `addSite(name, {city})` / `addRoom(siteId, name)` / `addSource(siteId, name, {roomId})` | Добавить или вернуть существующее с тем же именем. Пустое имя — `ArgumentError`: до базы оно доходить не должно, UI отсекает его раньше. |
| `renameSite` / `renameRoom` / `renameSource` | Переименование. История не меняется — в ней имена на момент замера. |
| `markSourceUsed(id)` | Поднимает источник в начало списка вместе с его комнатой и местом. Для удалённого источника ничего не делает. |
| `setSiteAnchor(siteId, anchor)` | Записать якорь места или стереть его (`null`) — ручная привязка и сброс. |
| `sourceByLegacyLabel(label)` | Найти мигрировавший источник по плоскому имени — для переноса выбора из настроек версий до 1.4.0. |
| `deleteSite` / `deleteRoom` | Удаление явной транзакцией вместе с вложенными уровнями. |
| `deleteSource` | Удаление одного источника — вложенного у него нет. |

Тесты — в `test/place_catalog_repository_test.dart`.

**Тесты CRUD-операций** — в `test/history_repository_test.dart`. Используется `AppDatabase.forTesting(NativeDatabase.memory())` — drift работает без файла и без `sqlite3_flutter_libs` инициализации (на Windows и Linux нативный sqlite подбирается автоматически).

### Группировка по дням

`groupMeasurementsByDay(rows, l10n, {now})` в `lib/history/grouping.dart` — top-level функция, отдельная от UI. Принимает список `Measurement` (предполагается `desc by observedAt`), возвращает `List<MeasurementDayGroup>` в порядке первого появления каждого дня.

Названия групп: «Сегодня» (diff=0), «Вчера» (diff=1), `dd.MM.yyyy` (остальные); первые два берутся из словаря. Параметр `now` опциональный — в production не передаётся, в тестах фиксируется для детерминированности.

Тесты — в `test/measurement_grouping_test.dart`: пустой ввод, граница 23:59→00:00, порядок групп и соседние случаи.

### Реактивность

`HistoryRepository.watchRecent()` возвращает `Stream<List<Measurement>>`. Drift отслеживает изменения в таблице и пуш-ит новый список каждый раз, когда выполняется insert/delete на этой таблице. Это значит:

- После записи `repository.save(...)` UI экрана истории мгновенно увидит новую строку без явного refresh.
- `recentMeasurementsProvider` в Riverpod обёрнут как `StreamProvider`, поэтому виджет `ConsumerWidget` автоматически перерисовывается через `ref.watch`.

## Локализация

Русский и английский. Конфигурация — `l10n.yaml` в корне; генерация запускается сама при `flutter run` / `flutter build` благодаря `generate: true` в pubspec, вручную — `flutter gen-l10n`.

### Выбор языка

`MaterialApp.locale` получает `settings.locale`. `null` отдаёт выбор Flutter'у: он подберёт поддерживаемый язык по языкам системы, а если ни один не подошёл — возьмёт **первый** из `supportedLocales`. Английский стоит там первым намеренно: пользователь с немецким телефоном получит английский, а не русский.

Названия языков в списке настроек (`lib/l10n/language_names.dart`) сознательно не переводятся. Это единственное место, куда приходит человек, случайно включивший язык, которого не знает.

### Где что лежит

| Что | Где | Почему так |
|---|---|---|
| Подписи интерфейса | `lib/l10n/app_<code>.arb` | Короткие независимые строки — ровно то, для чего ARB и сделан. |
| Справка по параметрам | `lib/help/parameter_help_<code>.dart` | У каждой градации есть числовая граница, цвет и пояснение; двести ключей вида `helpPhPoolRange3Note` сделали бы нечитаемыми и словарь, и код. |
| Стартовый каталог мест | `lib/history/catalog_seed.dart` | Это **данные**, а не подписи: замер хранит имя источника, и однажды записанное имя перевести задним числом уже нельзя. |

### Доменные модули

Каталог параметров, оценка качества и уведомления живут вне дерева виджетов, поэтому получают `AppL10n` параметром, а не через `AppL10n.of(context)`:

```dart
WaterParameterCatalog.forProfile(profile, l10n);
WaterQualityOverview.compute(values, profile: profile, l10n: l10n);
```

Подписи `enum`-ов заведены расширениями (`QualityCategoryText.label`, `LocationFailureText.message`, `PermissionResultText.message`): `enum` — это константы, а перевод выбирается в рантайме. Расширение видно только при прямом импорте объявляющего файла — при `show`-импорте его нужно перечислить явно.

### Чтобы добавить язык

1. `lib/l10n/app_<code>.arb` — скопировать ключи из `app_ru.arb` и перевести.
2. `lib/help/parameter_help_<code>.dart` — скопировать структуру из русского файла и перевести подписи; числа и цвета не трогать.
3. `lib/help/parameter_help.dart` — добавить язык в диспетчер `ParameterHelpCatalog`.
4. `lib/l10n/language_names.dart` — вписать название языка на нём самом.
5. `flutter gen-l10n` и `flutter test`.

Тесты `test/l10n_test.dart` и `test/parameter_help_test.dart` проверяют, что языки не разъехались: совпадают наборы ключей и объявления подстановок, а у справки — параметры, разделы, числовые границы и цвета.

## Навигация

`go_router` 14.x. Конфиг — `lib/router.dart`:

```
/                  HomePage — сканирование
/device            ShellPage с 3 вкладками (показания · история · настройки); extra = BluetoothDevice
/history           HistoryPage отдельным экраном — история без подключения к прибору
/history/detail    HistoryDetailPage — свайп между записями; extra = HistoryDetailArgs
/places            PlacesPage — места, комнаты, источники и привязка к координатам
/help              HelpPage — справка; extra = ключ параметра для фокуса (необязательно)
/debug-commands    DebugCommandsPage — подбор байтов команд; extra = BluetoothDevice
```

Переход на устройство — `context.push('/device', extra: device)`. Внутри `ShellPage` — `IndexedStack` с табами; смена таба — `setState`, не маршрутизация (быстрее, сохраняет state экранов).

Если позже понадобятся deep links или web URL — табы переедут в отдельные подмаршруты.

## Глобальный error handler

Все необработанные исключения ловятся в `lib/bootstrap.dart`:

```dart
FlutterError.onError = ...;            // Flutter framework errors
PlatformDispatcher.instance.onError = ...;  // Async errors из platform thread
runZonedGuarded(...)                   // Дополнительный safety net
```

В debug-mode пишет stack trace в консоль. В release ошибки молча подавляются, чтобы не валить UI. Для production стоит подключить Sentry/Crashlytics — в `bootstrap.dart` есть комментарий-инструкция, куда вставлять `Sentry.captureException`.
