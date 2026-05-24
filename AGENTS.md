# AGENTS.md

## Назначение

Этот файл помогает агенту (Claude Code и т.п.) или новому разработчику быстро войти в проект `SmartHomeWaterAnalyzer` — Flutter Android-приложение для тестера качества воды YINMIK BLE-C600.

## Перед началом работы

`AGENTS.md` — общий профиль. История изменений — в `git log master..` и в issues/PR на GitHub. Подробная архитектура — в `docs/`. Пользовательский гайд — в `README.md`.

## Снимок проекта

- Тип проекта: Flutter mobile app (Android-only target в MVP, архитектура совместима с iOS).
- Главный файл: `lib/main.dart`.
- Целевая платформа: Android 7.0+ (API 24).
- Bluetooth: `flutter_blue_plus` 1.32+.
- Разрешения: `permission_handler` 11.x.
- Зависимость от железа: YINMIK BLE-C600 (или совместимый BLE-YC01-family тестер).
- Связанный репозиторий: [`SmartHomeService`](https://github.com/EugeneSoftwareDeveloper/SmartHomeService) — .NET 10 сервис умного дома с такой же интеграцией BLE-C600 на стороне сервера. Декодер портирован один-в-один.

## Структура папок

```
lib/
├── main.dart                       # Entry + MaterialApp (Material 3 seedColor 0xFF1976D2)
├── yinmik/                         # Всё, что специфично для прибора BLE-C600
│   ├── reading.dart                # YinmikReading — модель одного декодированного кадра
│   ├── decoder.dart                # YinmikDecoder — порт C# алгоритма с FF02
│   ├── client.dart                 # YinmikBleClient — scan/connect/read/write через flutter_blue_plus
│   └── commands.dart               # YinmikCommands — байты команд управления (спекулятивные пока)
├── quality/                        # Доменная логика «качество воды»
│   ├── zone.dart                   # QualityZone + QualityCategory (5 категорий с цветами)
│   ├── parameter.dart              # WaterParameter — описание параметра + диапазон + зоны
│   ├── catalog.dart                # WaterParameterCatalog — 7 параметров с нормами питьевой воды
│   └── overview.dart               # WaterQualityOverview — сводная оценка по всем параметрам
└── ui/
    ├── home_page.dart              # Сканирование и список устройств
    ├── reading_page.dart           # Показания + управление
    └── widgets/
        ├── color_gauge.dart        # Анимированная цветная шкала с маркером и подписями
        ├── parameter_card.dart     # Карточка параметра (значение + бейдж + шкала + описание)
        ├── summary_header.dart     # Hero-карточка общей оценки + статус прибора
        └── control_panel.dart      # Секция управления (подсветка, HOLD)

test/
└── yinmik_decoder_test.dart        # Регрессия декодера на 5 эталонных кадрах

docs/
├── README.md                       # Индекс
├── 01-architecture.md              # Слои, точки расширения
├── 02-ble-protocol.md              # BLE-C600 GATT + декодер
├── 03-control-commands.md          # HCI snoop guide + commands.dart
└── 04-ui-design.md                 # Material 3, gauge, цвета, layout
```

## Архитектура в одном экране

Три слоя сверху вниз:

1. **UI** (`lib/ui/`) — Material 3 виджеты, `StatefulWidget` с локальным `setState`. Нет state-management библиотек (provider/riverpod). MVP-простота.
2. **Quality** (`lib/quality/`) — чистая Dart-логика. Без зависимостей от Flutter Material (только `Color` из `dart:ui` через `flutter/material.dart`). Описывает параметры и нормы. Не знает про BLE.
3. **Yinmik** (`lib/yinmik/`) — BLE-протокол. Декодер не зависит от `flutter_blue_plus` (только `dart:typed_data`). Клиент инкапсулирует все BLE-операции.

UI зависит от Quality + Yinmik. Quality не зависит от Yinmik. Yinmik (декодер) можно использовать standalone, например в тестах или CLI-утилите.

## Связь с SmartHomeService

Декодер `YinmikDecoder` — порт C# `YinmikBleC600FrameDecoder` из соседнего репозитория `SmartHomeService`. Если в SmartHomeService появляется правка декодера — повтори её здесь и наоборот. Тесты в `test/yinmik_decoder_test.dart` используют те же эталонные кадры, что и `SmartHomeService.Test/Devices/WaterQuality/Yinmik/WhenDecodingYinmikBleC600Frame.cs`.

Архитектурно приложение **независимо** от SmartHomeService: подключается к BLE-прибору напрямую, не требует сервера и не использует HTTP API SmartHomeService. Их можно запускать параллельно, но **не на одном приборе одновременно** — BLE-C600 держит одно соединение.

## Тестирование

Микроподход: тестируем только то, что можно тестировать без реального устройства.

- **Декодер** покрыт регрессией на 5 кадрах (`test/yinmik_decoder_test.dart`). Эталонные значения подтверждены сверкой с экраном прибора в SmartHomeService.
- **Quality** (zones, overview) — можно покрыть, если будет много правил. Пока нет.
- **UI** — не покрыто (golden-тесты, widget-тесты — есть инфраструктура `flutter_test`, добавить при росте).
- **BLE-клиент** — не тестируется в коде, только на железе. Реальные сценарии:
  - Прибор включён, доступен → читается кадр → видны значения
  - Прибор спит → timeout → UI показывает ошибку
  - Команда применена → бит статуса изменился на следующем чтении

### Команды запуска

```powershell
flutter pub get                                          # установка зависимостей
flutter analyze                                          # статический анализ
flutter test                                             # юнит-тесты декодера
flutter test test/yinmik_decoder_test.dart               # один файл
flutter run                                              # dev-запуск на подключённом устройстве
flutter build apk --release                              # release APK
```

## Зоны риска

- **`areCommandsKnown = true` при спекулятивных байтах**: текущие байты в `lib/yinmik/commands.dart` — обоснованная догадка, не подтверждены HCI snoop'ом. UI будет реально дёргать прибор. Худший наблюдаемый исход — кратковременное зависание BLE-соединения; прибор восстанавливается на следующем чтении. Если поведение странное — проверь альтернативные паттерны в шапке `commands.dart` или сними HCI snoop log по `docs/03-control-commands.md`.
- **Прибор держит только одно BLE-подключение**: официальное приложение YINMIK блокирует нашему подключение и наоборот. Закрывай официальное приложение перед тестированием своего.
- **Android 12+ permissions**: BLE сканирование требует `BLUETOOTH_SCAN` + `BLUETOOTH_CONNECT` (рантайм-запрос). Для старых Android — `ACCESS_FINE_LOCATION`. Манифест уже настроен.
- **Зоны качества рассчитаны на питьевую воду**. Для бассейна / аквариума нормы другие — это **запланированное** расширение (профили), но пока не сделано.
- **Battery percent — оценка**, рассчитан по формуле BLE-YC01 (3190 mV ≈ 100%, 1950 mV ≈ 0%). Для BLE-C600 точная калибровка не подтверждена.

## Практические советы

- **Конвенция «один класс на файл»**: повсеместно, кроме мелких приватных вспомогательных классов (`_GaugePainter`, `_ZoneBadge`).
- **Material 3 colorScheme — единственный источник цветов** для UI-хрома. Цвета зон качества (`QualityCategory.color`) — статика, не темизируются.
- **`flutter_blue_plus` стримы** требуют осторожной отписки. Смотри `HomePage._scanSubscription` как пример: всегда `cancel()` в `dispose()`.
- **`device.disconnect()` в `finally`** — даже на ошибке. Прибор иначе остаётся подключенным с т.з. Android stack, и следующее сканирование не находит его.
- **При добавлении параметра** правь только `lib/quality/catalog.dart` (новая `WaterParameter` константа + добавление в `all`) и `lib/ui/reading_page.dart` `_extractValues` (доставание значения из `YinmikReading`). UI подхватит автоматически.
- **При добавлении новой write-команды** добавь байты в `lib/yinmik/commands.dart`, factory-метод (`backlightCommand` / `holdCommand` стиль), и `_ControlTile` в `lib/ui/widgets/control_panel.dart`.

## Что не делать в первой версии

- **Не превращать в постоянно подключённое приложение**. Прибор — портативный, его выключают. Каждое чтение — новая сессия с явным disconnect.
- **Не копировать GPL-код** из открытых проектов (WaterQualityApp на GitLab) без отдельного решения по лицензии.
- **Не делать управление подсветкой обязательной фичей** — байты спекулятивные. UI должен корректно показывать ошибку, если прибор отверг write.
- **Не объявлять воду «безопасной для питья»** только по pH/TDS/EC/ORP/солености/температуре — это лабораторно недостаточно. Зоны качества — ориентир, не медицинское заключение.

## Соглашения коммитов

- Тема первой строки **без префикса `#NN`** — номера историй/issue не пишем (то же правило, что в SmartHomeService).
- Тело — что и зачем, а не дословный diff.
- Автор: `EugeneSoftwareDeveloper <jonjawa91@gmail.com>` (локальный `.git/config` уже выставлен).

## Хорошие цели для ближайшей чистки

- Снять HCI snoop log с официального YINMIK-приложения, заменить спекулятивные байты в `commands.dart` на реальные.
- Локальная история измерений в SQLite + графики `fl_chart`.
- Дополнительные профили норм (бассейн, аквариум) с выбором в настройках.
- Тёмная тема (Material 3 уже совместим, нужен только `darkTheme:` в `MaterialApp`).
- iOS-сборка: `flutter create --platforms=ios .` + Info.plist Bluetooth-разрешения.
- Golden-тесты для `ColorGauge` и `ParameterCard`.
