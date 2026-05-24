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
| `appSettingsProvider` | StateNotifierProvider | `app_settings.dart` | Тема, профиль норм, lastDeviceId, флаг уведомлений. Persist через SharedPreferences. |
| `yinmikBleClientProvider` | Provider | `yinmik_client_provider.dart` | Singleton `YinmikBleClient` на всё приложение. |
| `bluetoothAdapterStateProvider` | StreamProvider | `bluetooth_state_provider.dart` | Состояние Bluetooth-адаптера (включён/выключен). UI реагирует на изменение в реальном времени. |
| `appDatabaseProvider` | Provider | `history_provider.dart` | Drift `AppDatabase` singleton. Закрывается через `ref.onDispose`. |
| `historyRepositoryProvider` | Provider | `history_provider.dart` | `HistoryRepository` — фасад над БД. |
| `recentMeasurementsProvider` | StreamProvider | `history_provider.dart` | Стрим последних измерений. Auto-rebuild списка истории при `insert`/`delete`. |
| `notificationServiceProvider` | Provider | `notification_provider.dart` | `NotificationService` с lazy-init (запрашивает разрешения, создаёт канал). |

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
- `settings.lastDeviceId` — string или null, BLE remoteId.
- `settings.notificationsEnabled` — bool.

Запись через `AppSettingsNotifier` синхронна для in-memory state, асинхронна для диска (`await _prefs.setX`). UI не ждёт диска — сразу видит изменения.

### Drift (SQLite)

История измерений — таблица `Measurements` в SQLite-файле `<app docs>/water_analyzer.sqlite`.

**Текущая schemaVersion = 2.** v2 добавила колонку `label TEXT NULL` для пользовательских меток замеров (например, «Москва, квартира»). Миграция выполняется автоматически при первом запуске после обновления:

```dart
MigrationStrategy get migration => MigrationStrategy(
      onUpgrade: (m, from, to) async {
        if (from < 2) {
          await m.addColumn(measurements, measurements.label);
        }
      },
    );
```

Схема — в `lib/history/database.dart`. После изменения схемы нужно:

1. Поднять `schemaVersion` в `AppDatabase` (например, до 3).
2. Добавить ветку миграции в `migration` getter: `if (from < 3) await m.addColumn(...)`.
3. Перегенерить через `dart run build_runner build --delete-conflicting-outputs`.

При откате версии БД (даунгрейд) drift не делает ничего — если установить старую версию приложения поверх новой схемы, она просто не увидит новые колонки. Безопасно.

Репозиторий `HistoryRepository` — единственная точка работы с БД из UI. Принимает доменные `YinmikReading`, скрывает drift-специфику. Это означает:

- UI зависит от `HistoryRepository`, а не от `AppDatabase` напрямую.
- В тестах можно подменить `historyRepositoryProvider` на мок.
- Замена drift на другую БД-библиотеку = переписывание `repository.dart`, не UI.

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
