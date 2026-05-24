import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:water_analyzer/quality/catalog.dart';
import 'package:water_analyzer/ui/widgets/color_gauge.dart';

void main() {
  testWidgets('ColorGauge рендерится для всех параметров без падений', (tester) async {
    for (final parameter in WaterParameterCatalog.all) {
      final value = (parameter.scaleMin + parameter.scaleMax) / 2;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ColorGauge(parameter: parameter, value: value),
          ),
        ),
      );

      // Метки концов шкалы должны быть на экране.
      expect(
        find.textContaining(parameter.scaleMin.toStringAsFixed(parameter.fractionDigits)),
        findsAtLeastNWidgets(1),
        reason: 'min boundary не нашёлся для ${parameter.key}',
      );
    }
  });

  testWidgets('ColorGauge клиппится при значении вне scaleMin/scaleMax', (tester) async {
    final parameter = WaterParameterCatalog.ph;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ColorGauge(parameter: parameter, value: 100), // далеко за scaleMax
        ),
      ),
    );
    // Не падает на overflow.
    expect(tester.takeException(), isNull);
  });
}
