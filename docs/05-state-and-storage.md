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
| `appSettingsProvider` | StateNotifierProvider | `app_settings.dart` | Тема, профиль норм, lastDeviceId + lastDeviceName, флаг уведомлений. Persist через SharedPreferences. |
| `yinmikBleClientProvider` | Provider | `yinmik_client_provider.dart` | Singleton `YinmikBleClient` на всё приложение. |
| `bluetoothAdapterStateProvider` | StreamProvider | `bluetooth_state_provider.dart` | Состояние Bluetooth-адаптера (включён/выключен). UI реагирует на изменение в реальном времени. |
| `appDatabaseProvider` | Provider | `history_provider.dart` | Drift `AppDatabase` singleton. Закрывается через `ref.onDispose`. |
| `historyRepositoryProvider` | Provider | `history_provider.dart` | `HistoryRepository` — фасад над БД. |
| `recentMeasurementsProvider` | StreamProvider | `history_provider.dart` | Стрим последних измерений. Auto-rebuild списка истории при `insert`/`delete`. |
| `notificationServiceProvider` | Provider | `notification_provider.dart` | `NotificationService` с lazy-init (запрашивает разрешения, создаёт канал). |
| `placesRepositoryProvider` | Provider | `history_provider.dart` | `PlacesRepository` — каталог мест замера. |
| `placesProvider` | StreamProvider | `history_provider.dart` | Стрим каталога мест: недавно использованные сверху, остальные по алфавиту. |
| `locationServiceProvider` | Provider | `location_provider.dart` | `LocationService` поверх `geolocator`. Состояния не имеет — в провайдере только ради подмены в тестах. |

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
- `settings.currentLabel` — string или null, выбранное место замера. Подставляется в `label` каждой сохраняемой записи. Хранится именно имя, а не id места — см. «Каталог мест и денормализация» ниже.
- `settings.saveLocationEnabled` — bool, прикреплять ли координаты к замерам. По умолчанию `true`.

Запись через `AppSettingsNotifier` синхронна для in-memory state, асинхронна для диска (`await _prefs.setX`). UI не ждёт диска — сразу видит изменения.

### Drift (SQLite)

История измерений — таблица `Measurements` в SQLite-файле `<app docs>/water_analyzer.sqlite`.

**Текущая schemaVersion = 4.** История версий:

| Версия | Что появилось |
|---|---|
| v2 | `label TEXT NULL` — пользовательская метка замера |
| v3 | `latitude` / `longitude` / `locationAccuracyMeters` (все `REAL NULL`) — геометка |
| v4 | таблица `Places` — каталог мест замера |
| v5 | `normsProfile TEXT NULL` — профиль норм, по которому оценивался замер |

Миграции выполняются автоматически при первом запуске после обновления:

```dart
MigrationStrategy get migration => MigrationStrategy(
      onCreate: (m) async {
        await m.createAll();
        await _seedDefaultPlaces();   // иначе на свежей установке каталог пуст
      },
      onUpgrade: (m, from, to) async {
        if (from < 2) await m.addColumn(measurements, measurements.label);
        if (from < 3) {
          await m.addColumn(measurements, measurements.latitude);
          await m.addColumn(measurements, measurements.longitude);
          await m.addColumn(measurements, measurements.locationAccuracyMeters);
        }
        if (from < 4) {
          await m.createTable(places);
          await _importPlacesFromExistingLabels();  // ДО сидирования, см. ниже
          await _seedDefaultPlaces();
        }
        if (from < 5) {
          await m.addColumn(measurements, measurements.normsProfile);
        }
      },
    );
```

Порядок в ветке v4 значим. Обе вставки идут через `insertOrIgnore`, то есть выигрывает пришедшая первой. Метка пользователя несёт `lastUsedAt` (время его последнего замера), дефолт — нет. При обратном порядке метка «Аквариум» была бы отброшена как дубликат уже вставленного дефолта, потеряла бы `lastUsedAt` и уехала в конец списка ниже мест, которыми не пользовались ни разу. Совпадение вероятно: дефолты названы типовыми словами.

### Профиль норм в замере

`Measurements.normsProfile` хранит имя значения `NormsProfile` и может быть `null` — так выглядят записи, сделанные до версии 1.2.0.

Разбор всегда идёт через `NormsProfile.resolve(storedName, fallback: текущийПрофиль)`: он возвращает `fallback` и для `null`, и для незнакомого имени (запись из более новой версии приложения, где профилей стало больше). Прямой `NormsProfile.values.byName(...)` в этом месте бросил бы исключение и уронил экран истории.

Зачем это нужно: «опасно / норма» — свойство замера, а не текущей настройки. Без хранения профиля замер в бассейне после переключения на питьевую воду задним числом краснел бы.

Схема — в `lib/history/database.dart`. После изменения схемы нужно:

1. Поднять `schemaVersion` в `AppDatabase` (например, до 5).
2. Добавить ветку миграции в `migration` getter.
3. Перегенерить через `dart run build_runner build --delete-conflicting-outputs`.
4. Написать тест на миграцию по образцу `test/places_migration_test.dart` — он поднимает **настоящий файл БД** в старом состоянии (raw SQL + `PRAGMA user_version`), открывает его через `AppDatabase.forTesting(NativeDatabase(file))` и проверяет, что данные пользователя пережили обновление. In-memory база для этого не подходит: она пересоздаётся на каждое соединение.

При откате версии БД (даунгрейд) drift не делает ничего — если установить старую версию приложения поверх новой схемы, она просто не увидит новые колонки. Безопасно.

### Каталог мест и денормализация

`Measurements.label` хранит **имя** места строкой, а не внешний ключ на `Places`. Это сделано намеренно: переименование или удаление места не должно переписывать историю задним числом — записанное «Кран на кухне» остаётся тем, чем было в момент замера. `Places` нужна только для списка выбора.

Следствие: `PlacesRepository.deleteById` не трогает историю, а `markUsed` для отсутствующего в каталоге имени просто возвращает 0 затронутых строк.

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
| `save(deviceId, reading, observedAt, {label})` | Вставка новой записи | `int` — id вставленной строки. Нужен для undo. |
| `recent({deviceId, limit})` | Список последних, `desc by observedAt`. | `List<Measurement>` |
| `watchRecent({deviceId, limit})` | Стрим последних с реактивным обновлением при insert/delete. | `Stream<List<Measurement>>` |
| `updateLabel(id, label)` | Меняет только колонку `label`. Пустая строка из пробелов автоматически становится `null`. | `int` — затронутых строк (0 / 1). |
| `deleteById(id)` | Удаляет одну запись. | `int` — затронутых строк (0 / 1). |
| `restoreFromMeasurement(m)` | Восстанавливает удалённую запись с её исходным id через `InsertMode.insertOrReplace`. Используется в undo для swipe-to-delete и FAB «Сохранить → Отменить». | `int` — затронутых строк. |
| `clear({deviceId})` | Полная очистка таблицы. | `Future<void>` |

**Тесты CRUD-операций** — в `test/history_repository_test.dart`. Используется `AppDatabase.forTesting(NativeDatabase.memory())` — drift работает без файла и без `sqlite3_flutter_libs` инициализации (на Windows и Linux нативный sqlite подбирается автоматически).

### Группировка по дням

`groupMeasurementsByDay(rows, {now})` в `lib/history/grouping.dart` — top-level функция, отдельная от UI. Принимает список `Measurement` (предполагается `desc by observedAt`), возвращает `List<MeasurementDayGroup>` в порядке первого появления каждого дня.

Названия групп: «Сегодня» (diff=0), «Вчера» (diff=1), `dd.MM.yyyy` (остальные). Параметр `now` опциональный — в production не передаётся, в тестах фиксируется для детерминированности.

Тесты — в `test/measurement_grouping_test.dart` (8 случаев: пустой ввод, граница 23:59→00:00, порядок групп и т.д.).

### Реактивность

`HistoryRepository.watchRecent()` возвращает `Stream<List<Measurement>>`. Drift отслеживает изменения в таблице и пуш-ит новый список каждый раз, когда выполняется insert/delete на этой таблице. Это значит:

- После записи `repository.save(...)` UI экрана истории мгновенно увидит новую строку без явного refresh.
- `recentMeasurementsProvider` в Riverpod обёрнут как `StreamProvider`, поэтому виджет `ConsumerWidget` автоматически перерисовывается через `ref.watch`.

## Локализация

Через `flutter_localizations` + ARB-файлы в `lib/l10n/`:
- `app_ru.arb` — основная локаль.
- `app_en.arb` — английский перевод.

Конфигурация — `l10n.yaml` в корне. Генерация — `flutter gen-l10n` (запускается автоматически при `flutter run`/`flutter build` благодаря `generate: true` в pubspec).

Использование в UI:

```dart
final l10n = AppL10n.of(context);
Text(l10n.appTitle);
Text(l10n.summaryProblematic(names: 'pH, TDS'));
```

Чтобы добавить новый язык:
1. Создай `lib/l10n/app_<code>.arb`.
2. Скопируй ключи из `app_ru.arb`, переведи значения.
3. Запусти `flutter gen-l10n` (или просто `flutter run`).

## Навигация

`go_router` 14.x. Конфиг — `lib/router.dart`:

```
/                  HomePage (сканирование)
/device  → extra=BluetoothDevice → ShellPage с 3 вкладками
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
