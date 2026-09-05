import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:water_analyzer/export/csv_export.dart';
import 'package:water_analyzer/history/database.dart';

Measurement _measurement({
  String? label,
  double? latitude,
  double? longitude,
  double? accuracy,
  DateTime? observedAt,
}) {
  return Measurement(
    id: 1,
    deviceId: 'AA:BB:CC:DD:EE:FF',
    label: label,
    observedAt: observedAt ?? DateTime(2026, 8, 31, 14, 30, 15),
    ph: 7.24,
    electricalConductivityUsCm: 250,
    totalDissolvedSolidsPpm: 125,
    salinityPpm: 60,
    salinityPercent: 0.006,
    temperatureCelsius: 21.5,
    specificGravity: 1.001,
    oxidationReductionPotentialMillivolts: 380,
    batteryRawMillivolts: 3050,
    backlightOn: false,
    holdReadingOn: false,
    latitude: latitude,
    longitude: longitude,
    locationAccuracyMeters: accuracy,
    normsProfile: null,
  );
}

List<String> _rowsOf(String csv) => csv.trim().split('\n').map((line) => line.trimRight()).toList();

void main() {
  group('buildMeasurementsCsv', () {
    test('заголовок совпадает со списком колонок', () {
      final csv = buildMeasurementsCsv([]);

      expect(_rowsOf(csv).single, csvColumns.join(','));
    });

    test('место и координаты попадают в файл', () {
      // Регрессия: экспорт отдавал 13 полей без label и координат — данные,
      // ради которых геометка и собиралась, терялись при выгрузке.
      final csv = buildMeasurementsCsv([
        _measurement(
          label: 'Кран на кухне',
          latitude: 55.7631176800056,
          longitude: 37.8282875782027,
          accuracy: 12.4,
        ),
      ]);

      final row = _rowsOf(csv)[1];
      expect(row, contains('Кран на кухне'));
      expect(row, contains('55.763118'));
      expect(row, contains('37.828288'));
      expect(row, contains('12.4'));
    });

    test('запятая в названии места экранируется кавычками', () {
      // Без экранирования «Дача, колодец» разъехалась бы на два столбца и
      // сдвинула всю строку.
      final csv = buildMeasurementsCsv([_measurement(label: 'Дача, колодец')]);

      final row = _rowsOf(csv)[1];
      expect(row, contains('"Дача, колодец"'));
      expect(
        row.split(',').length,
        csvColumns.length + 1,
        reason: 'экранированная запятая всё равно делит строку при наивном split',
      );
    });

    test('кавычка в названии удваивается', () {
      final csv = buildMeasurementsCsv([_measurement(label: 'Дом "У реки"')]);

      expect(_rowsOf(csv)[1], contains('"Дом ""У реки"""'));
    });

    test('перевод строки в названии экранируется', () {
      final csv = buildMeasurementsCsv([_measurement(label: 'Первая\nвторая')]);

      expect(csv, contains('"Первая\nвторая"'));
    });

    test('замер без места даёт пустую ячейку, а не «null»', () {
      final csv = buildMeasurementsCsv([_measurement()]);

      final cells = _rowsOf(csv)[1].split(',');
      expect(cells[csvColumns.indexOf('place')], isEmpty);
      expect(csv, isNot(contains('null')));
    });

    test('замер без геометки даёт пустые ячейки координат, а не нули', () {
      // Ноль — валидная координата (Гвинейский залив); путать её с «нет данных»
      // нельзя, иначе в выгрузке появятся замеры «в Атлантике».
      final csv = buildMeasurementsCsv([_measurement()]);

      final cells = _rowsOf(csv)[1].split(',');
      expect(cells[csvColumns.indexOf('latitude')], isEmpty);
      expect(cells[csvColumns.indexOf('longitude')], isEmpty);
      expect(cells[csvColumns.indexOf('location_accuracy_m')], isEmpty);
    });

    test('нулевые координаты сохраняются как 0, а не как пусто', () {
      final csv = buildMeasurementsCsv([_measurement(latitude: 0, longitude: 0)]);

      final cells = _rowsOf(csv)[1].split(',');
      expect(cells[csvColumns.indexOf('latitude')], '0.000000');
      expect(cells[csvColumns.indexOf('longitude')], '0.000000');
    });

    test('числа пишутся с точкой независимо от локали', () {
      final csv = buildMeasurementsCsv([_measurement()]);

      expect(csv, contains('7.24'));
      expect(csv, contains('21.5'));
      expect(csv, isNot(contains('7,24')));
    });

    test('каждый замер даёт ровно одну строку', () {
      final csv = buildMeasurementsCsv([
        _measurement(label: 'Первое'),
        _measurement(label: 'Второе'),
        _measurement(),
      ]);

      expect(_rowsOf(csv), hasLength(4)); // заголовок + три замера
    });

    test('порядок ячеек соответствует объявленным колонкам', () {
      final csv = buildMeasurementsCsv([_measurement(label: 'Кулер')]);

      final cells = _rowsOf(csv)[1].split(',');
      expect(cells[csvColumns.indexOf('device_id')], 'AA:BB:CC:DD:EE:FF');
      expect(cells[csvColumns.indexOf('ph')], '7.24');
      expect(cells[csvColumns.indexOf('place')], 'Кулер');
    });
  });

  group('Measurement.copyWith сохраняет новые поля', () {
    test('label меняется, координаты остаются', () {
      final original = _measurement(label: 'Старое', latitude: 55.76, longitude: 37.82);

      final updated = original.copyWith(label: const Value('Новое'));

      expect(updated.label, 'Новое');
      expect(updated.latitude, 55.76);
      expect(updated.longitude, 37.82);
    });
  });
}
