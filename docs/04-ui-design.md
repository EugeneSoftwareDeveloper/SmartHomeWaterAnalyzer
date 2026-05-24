# 04. UI-дизайн и виджеты

## Общая концепция

Цель UI — заменить «цифры + бумажная таблица норм» на **наглядную сводку**, где ты сразу видишь:

1. **Общая оценка** в верхней hero-карточке (один взгляд → понятно, всё ОК или есть проблема).
2. **Каждый параметр** на отдельной карточке: текущее значение + цветная шкала с зонами + бейдж зоны.
3. **Управление прибором** — внизу: переключатели для подсветки и HOLD.

Сравнение с референсом (Intex Link app):
- Они показывают одно «hero»-число (температура) в центре + 3 цветные шкалы.
- Мы показываем 7 параметров с цветными шкалами + общую агрегированную оценку.

## Material 3

База — `ThemeData(useMaterial3: true)` с seed-цветом `0xFF1976D2` (синий, ассоциируется с водой). Цвета хрома (`AppBar`, `Card`, `outline`) берутся из `colorScheme` — это значит:

- Тёмная тема поддерживается «бесплатно», осталось добавить `darkTheme:` в `main.dart`.
- Динамический Material You (Android 12+) сейчас не используется, но `seedColor` можно заменить на `dynamic_color` package при желании.

## Цвета зон качества

Зоны качества **не темизируются** — у каждой категории фиксированный цвет в `lib/quality/zone.dart`:

```dart
enum QualityCategory {
  danger(Color(0xFFD32F2F), 'Опасно'),       // красный
  caution(Color(0xFFF57C00), 'Внимание'),     // оранжевый
  acceptable(Color(0xFFFBC02D), 'Приемлемо'), // жёлтый
  good(Color(0xFF388E3C), 'Хорошо'),          // зелёный
  excellent(Color(0xFF1976D2), 'Отлично');    // синий
}
```

Обоснование: эти цвета — семантика, а не оформление. Красный = плохо во всех темах. Они НЕ должны меняться от dark mode.

При наложении на UI цвета используются с прозрачностью:
- Заполнение шкалы — `color` (100%).
- Бейдж зоны (фон) — `color.withValues(alpha: 0.16)`.
- Бейдж зоны (граница) — `color.withValues(alpha: 0.5)`.
- Hero-карточка (градиент) — `color.withValues(alpha: 0.18)` → `0.06`.

## Hero-карточка (SummaryHeader)

`lib/ui/widgets/summary_header.dart`.

Структура:
- Градиентный фон от `worstCategory.color` (полупрозрачно).
- Слева — круглая иконка-аватар с цветом категории, внутри `Icon`:
  - `water_drop` для excellent
  - `check_circle` для good
  - `info_outline` для acceptable
  - `warning_amber` для caution
  - `error_outline` для danger
- Справа — заголовок («Отличное качество воды» и т.п.) + описание (какие параметры вне нормы).
- Снизу — статус-бар прибора: батарея (icon + %), чипы HOLD / LIGHT, если активны.

Логика выбора заголовка — в `WaterQualityOverview.headline`. Логика выбора иконки — в `SummaryHeader._iconFor`.

## ParameterCard

`lib/ui/widgets/parameter_card.dart`.

Структура:
```
┌──────────────────────────────────────────────────┐
│  pH                                  ●  Норма    │
│  7.24                                            │
│                                                  │
│  ─────[colored gauge with marker]──────          │
│  0.00 ─────────────────────────────── 14.00      │
│                                                  │
│  [expandable description, tap to reveal]         │
└──────────────────────────────────────────────────┘
```

Особенности:
- **Крупное значение** (`headlineMedium`) + единица справа маленьким текстом.
- **Бейдж зоны** в шапке: цветной круг + текст зоны на полупрозрачном фоне.
- **Цветная шкала** с подписями min/max под полосой.
- **Описание скрыто** в `AnimatedCrossFade`, открывается тапом по карточке.

Карточка — `StatefulWidget` только потому, что хранит `_expanded` (раскрыто ли описание). Чтобы не плодить state — нет.

## ColorGauge

`lib/ui/widgets/color_gauge.dart`.

`CustomPaint`-виджет:
- Полоса с зонами (каждая зона — цветной `Rect`).
- Скруглённые углы через `clipRRect`.
- Обводка `outlineVariant`.
- Маркер — треугольник снизу с **тенью** (`MaskFilter.blur`) и вертикальной риской.
- Анимация маркера через `TweenAnimationBuilder` (350ms easeOut) — плавное скольжение при обновлении.
- Подписи концов шкалы (`scaleMin`, `scaleMax`) под полосой.

Кастомизация:
- `barHeight` (default 22) — толщина полосы.
- `showScaleLabels` (default true) — показывать ли подписи min/max.

## ControlPanel

`lib/ui/widgets/control_panel.dart`.

Структура:
```
Управление прибором  [BETA]
┌──────────────────────────────────────┐
│  💡  Подсветка                  [×]  │
│      Включить экран прибора          │
├──────────────────────────────────────┤
│  🔒  Удержание показаний (HOLD) [×]  │
│      Зафиксировать текущие значения  │
└──────────────────────────────────────┘
```

- Иконка меняется в зависимости от состояния (`lightbulb_outline` ↔ `lightbulb`).
- Цвет иконки: `primary` если ON, `onSurfaceVariant` если OFF.
- `Switch` — стандартный Material 3.
- Тап по строке или переключателю — отправка команды через `YinmikBleClient.sendCommandAndRead`.
- Во время отправки — переключатели заблокированы (`enabled: !_sending`).
- При успехе — `widget.onReadingUpdated(reading)` обновляет всё дерево актуальным состоянием.
- При ошибке `UnknownCommandException` — диалог-инструкция (сейчас не показывается, т.к. флаг `true`).
- При другой ошибке — SnackBar с текстом.

Бейдж `[BETA]` отображается, пока `YinmikCommands.areCommandsKnown == false`. Сейчас флаг `true` → бейджа нет.

## Layout reading_page

```
SafeArea
└─ Scaffold(AppBar + body)
   └─ RefreshIndicator
      └─ ListView
         ├─ SummaryHeader
         ├─ ParameterCard (pH)
         ├─ ParameterCard (ORP)
         ├─ ParameterCard (EC)
         ├─ ParameterCard (TDS)
         ├─ ParameterCard (Salinity)
         ├─ ParameterCard (Temperature)
         ├─ ParameterCard (S.G.)
         └─ ControlPanel
```

Pull-to-refresh повторяет чтение FF02 и обновляет всё. Refresh-кнопка в AppBar делает то же самое.

## Адаптивность

Сейчас вёрстка — **только portrait phone**. Для tablet/landscape потребуется:
- Двух-колоночный layout на широких экранах (cards в Row).
- Hero-карточка с дополнительной информацией справа.
- `MediaQuery.of(context).size.width` или `LayoutBuilder` как точка ветвления.

В MVP не реализовано.

## Производительность

- `ColorGauge` использует `TweenAnimationBuilder` — это создаёт `AnimationController` под капотом. Не критично для 7 одновременных gauge, но при росте до 20+ может стать заметно. Тогда — общий `AnimationController` на странице.
- `ListView` не использует `ListView.builder` (список из 9 фиксированных элементов). Если будет много карточек или динамический список — переходить на `builder`.
- Все цвета вычисляются на каждый `build`. Это нормально для Flutter, но `withValues(alpha:...)` создаёт новый `Color`-объект. Если стает узким местом — извлекать в `static const` или кэшировать.

## Доступность

Сейчас базовая:
- Контраст цветов зон — проверен на белом фоне (WCAG AA).
- `Switch` — стандартный Material, поддерживает TalkBack/VoiceOver.
- Все интерактивные элементы — `InkWell` или Material-родственные виджеты, имеют ripple.

Не реализовано:
- Semantic labels для шкал и значений — нужны для скринридеров.
- Динамический размер шрифта (`MediaQuery.textScaleFactor`) проверен только на 1.0 — на 1.5+ может рваться вёрстка.
