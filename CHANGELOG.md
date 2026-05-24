# Changelog

Все заметные изменения проекта документируются здесь.

Формат основан на [Keep a Changelog](https://keepachangelog.com/ru/1.0.0/), версионирование — [Semantic Versioning](https://semver.org/lang/ru/spec/v2.0.0.html).

## [Unreleased]

### Добавлено
- Тёмная тема (Material 3 с тем же seed-цветом для светлой и тёмной).
- Локализация: русский (основной) + английский (через ARB-файлы в `lib/l10n/`).
- Профили норм качества воды: питьевая, бассейн, аквариум (пресный), гидропоника — переключаются в настройках.
- История измерений в локальной SQLite-БД через drift.
- Экран истории с графиком pH во времени (`fl_chart`) и списком последних 200 измерений.
- Экспорт истории в CSV-файл + системный share-sheet.
- Локальные уведомления при выходе параметров из нормы (опционально включаются в настройках).
- Запоминание последнего подключённого устройства в `SharedPreferences`.
- Bottom navigation: Показания / История / Настройки.
- Глобальный error handler через `FlutterError.onError` + `PlatformDispatcher.onError`.
- Реакция UI на выключение Bluetooth — отдельный экран «Bluetooth выключен».
- Haptic feedback на переключателях управления и при ошибках.
- BLE retry: 3 попытки с 2-секундной паузой на транзиентных сбоях.
- MTU negotiation (request 247) при подключении.
- Платформенный scan filter по UUID сервиса BLE-C600.
- Strict-mode статический анализатор: prefer_single_quotes, require_trailing_commas, avoid_dynamic_calls и др.
- Release signing scaffold через `android/key.properties` + fallback на debug-ключ.
- GitHub Actions CI: lint + test + сборка APK артефакта.

### Изменено
- Полный рефактор UI на `flutter_riverpod`: providers вместо singleton'ов, ConsumerWidget везде.
- Навигация на `go_router`.
- WaterParameterCatalog теперь возвращает разные зоны качества в зависимости от выбранного профиля.
- `YinmikBleClient` инкапсулирует MTU + retry + scan filter; стрим scan'а правильно отписывается.

### Исправлено
- Permission check для Android 12+: больше не требует геолокацию, корректно различает Android 11- и 12+.
- Stack-trace проблема при отсутствии прав — теперь UI показывает конкретную причину + кнопку «Открыть настройки».

## [1.0.0] - 2026-05-23

### Добавлено
- Первая версия приложения: сканирование BLE-C600, подключение, чтение FF02, декодирование 7 параметров.
- Цветные шкалы качества с зонами «опасно / норма / отлично» для каждого параметра.
- Hero summary card с общей оценкой воды.
- Управление подсветкой и HOLD (спекулятивные байты `0x08`/`0x10`).
- Документация: README, AGENTS.md, docs/{architecture, ble-protocol, control-commands, ui-design}.md.
- 5 регрессионных тестов декодера на эталонных кадрах.
