// Рендер интерфейса в PNG без устройства и без сборки APK.
//
// Зачем. Половина интерфейса здесь — цвет: зоны шкалы, окраска карточки
// по зоне, знак и цвет дельты. Проверить это по коду нельзя, а собрать
// APK и поставить на телефон — минуты. Инструмент рисует те же виджеты
// одной командой, в обеих темах сразу.
//
// Запускается через `flutter test`, потому что рендер виджетов требует
// его окружения. Файл лежит в tools/, а не в test/, поэтому в обычный
// прогон `flutter test` не попадает и время CI не тратит.
//
//   flutter test tools/preview/render_preview.dart --update-goldens
//   flutter test tools/preview/render_preview.dart --update-goldens \
//       --dart-define=SCENE=gauges
//
// Результат — build/preview/<сцена>.png. Каталог build/ не
// версионируется, картинки в репозиторий не попадают.
//
// Сцены:
//   cards (по умолчанию) — карточки параметров в трёх зонах;
//   gauges              — шкалы одного параметра по всему диапазону.
//
// Это НЕ golden-тест: он ничего не сравнивает и ни от чего не защищает,
// только рисует. Настоящие golden-и на цветной графике нестабильны
// между платформами, а смысл здесь в том, чтобы человек посмотрел.
//
// ignore_for_file: avoid_print — CLI-инструмент, путь к картинке и есть
// его вывод.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:water_analyzer/quality/catalog.dart';
import 'package:water_analyzer/quality/parameter.dart';
import 'package:water_analyzer/quality/trend.dart';
import 'package:water_analyzer/ui/widgets/color_gauge.dart';
import 'package:water_analyzer/ui/widgets/parameter_card.dart';

const _scene = String.fromEnvironment('SCENE', defaultValue: 'cards');

/// Значения внутри диапазона параметра: у нижней границы, посередине и
/// у верхней. Зоны у параметров разные, поэтому берём точки шкалы, а не
/// выдуманные числа — так одна и та же тройка осмысленна для pH, ORP и
/// температуры одновременно.
List<double> _samples(WaterParameter p) {
  final span = p.scaleMax - p.scaleMin;
  return [
    p.scaleMin + span * 0.1,
    p.scaleMin + span * 0.5,
    p.scaleMin + span * 0.9,
  ];
}

Widget _themed(Brightness brightness, Widget child) {
  return Theme(
    data: ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF2F6FD0),
        brightness: brightness,
      ),
      useMaterial3: true,
    ),
    child: Builder(
      builder: (context) => ColoredBox(
        color: Theme.of(context).colorScheme.surface,
        child: Padding(padding: const EdgeInsets.all(12), child: child),
      ),
    ),
  );
}

Future<void> _shoot(
  WidgetTester tester,
  Widget child,
  String name,
  Size size,
) async {
  // Поверхность теста по умолчанию 800x600: содержимое в неё не влезает
  // и рендер падает с overflow, а мелкие сцены приезжают с полями.
  await tester.binding.setSurfaceSize(size);
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    Directionality(textDirection: TextDirection.ltr, child: child),
  );
  await expectLater(
    find.byType(Directionality),
    matchesGoldenFile('../../build/preview/$name.png'),
  );
  print('готово: build/preview/$name.png');
}

void main() {
  testWidgets('preview: $_scene', (tester) async {
    final parameters = WaterParameterCatalog.all;

    switch (_scene) {
      case 'gauges':
        final parameter = parameters.first;
        await _shoot(
          tester,
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final brightness in Brightness.values)
                _themed(
                  brightness,
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (final value in _samples(parameter))
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: ColorGauge(
                            parameter: parameter,
                            value: value,
                          ),
                        ),
                    ],
                  ),
                ),
            ],
          ),
          'gauges',
          const Size(420, 520),
        );

      default:
        // Карточки всех параметров при среднем значении шкалы плюс одна
        // с дельтой — чтобы было видно и цвет зоны, и оформление тренда.
        // Ширина колонки — телефонная: карточка свёрстана под неё, и в
        // сетке пошире её содержимое рвётся. Темы идут рядом, чтобы
        // сравнивать цвета зон в один взгляд.
        await _shoot(
          tester,
          Row(
            children: [
              for (final brightness in Brightness.values)
                SizedBox(
                  width: 470,
                  child: _themed(
                    brightness,
                    ListView(
                      children: [
                        for (final parameter in parameters)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: ParameterCard(
                              parameter: parameter,
                              value: _samples(parameter)[1],
                              trend: parameter == parameters.first
                                  ? const ParameterTrend(
                                      delta: 0.4,
                                      direction: TrendDirection.up,
                                      impact: TrendImpact.worsened,
                                    )
                                  : null,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          'cards',
          const Size(940, 940),
        );
    }
  });
}
