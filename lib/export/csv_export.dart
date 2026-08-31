import 'dart:io';

import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../history/database.dart';

/// Колонки CSV-экспорта. Держим отдельной константой, чтобы заголовок и порядок
/// полей в строках нельзя было расстроить независимо друг от друга.
const List<String> csvColumns = <String>[
  'timestamp',
  'place',
  'device_id',
  'ph',
  'ec_us_cm',
  'tds_ppm',
  'salinity_ppm',
  'salinity_percent',
  'temperature_c',
  'sg',
  'orp_mv',
  'battery_mv',
  'backlight',
  'hold',
  'latitude',
  'longitude',
  'location_accuracy_m',
];

/// Собирает CSV-содержимое из записей истории.
///
/// Вынесено из [CsvExporter] отдельной чистой функцией, чтобы формат можно было
/// проверять тестами без файловой системы и share-sheet.
///
/// Числа форматируются через `toStringAsFixed`, а не `toString`: на русской
/// локали разделителем стала бы запятая, и строка разъехалась бы по столбцам.
String buildMeasurementsCsv(List<Measurement> rows) {
  final isoFormat = DateFormat("yyyy-MM-dd'T'HH:mm:ss");
  final buffer = StringBuffer()..writeln(csvColumns.join(','));

  for (final row in rows) {
    buffer.writeln(
      <String>[
        isoFormat.format(row.observedAt),
        _csvField(row.label ?? ''),
        _csvField(row.deviceId),
        row.ph.toStringAsFixed(2),
        '${row.electricalConductivityUsCm}',
        '${row.totalDissolvedSolidsPpm}',
        '${row.salinityPpm}',
        row.salinityPercent.toStringAsFixed(2),
        row.temperatureCelsius.toStringAsFixed(1),
        row.specificGravity.toStringAsFixed(3),
        '${row.oxidationReductionPotentialMillivolts}',
        '${row.batteryRawMillivolts}',
        row.backlightOn ? '1' : '0',
        row.holdReadingOn ? '1' : '0',
        // Замер без геометки даёт пустые ячейки, а не «0» — ноль это валидная
        // координата (Гвинейский залив), и путать её с «нет данных» нельзя.
        row.latitude?.toStringAsFixed(6) ?? '',
        row.longitude?.toStringAsFixed(6) ?? '',
        row.locationAccuracyMeters?.toStringAsFixed(1) ?? '',
      ].join(','),
    );
  }

  return buffer.toString();
}

/// Экранирование поля по RFC 4180: значение с запятой, кавычкой или переводом
/// строки заворачивается в кавычки, внутренние кавычки удваиваются.
///
/// Нужно прежде всего для названий мест: «Дача, колодец» без экранирования
/// разъехалось бы на два столбца и сдвинуло всю строку.
String _csvField(String value) {
  final needsQuoting = value.contains(',') ||
      value.contains('"') ||
      value.contains('\n') ||
      value.contains('\r');
  if (!needsQuoting) return value;

  return '"${value.replaceAll('"', '""')}"';
}

/// Экспорт истории измерений в CSV-файл + системный share-sheet.
abstract final class CsvExporter {
  /// Сохраняет [rows] в CSV-файл и открывает share-sheet. Возвращает путь к файлу для UI.
  static Future<String> shareMeasurementsCsv(List<Measurement> rows) async {
    final temp = await getTemporaryDirectory();
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final file = File(p.join(temp.path, 'water_analyzer_$timestamp.csv'));

    await file.writeAsString(buildMeasurementsCsv(rows));

    await Share.shareXFiles(
      [XFile(file.path, mimeType: 'text/csv')],
      subject: 'Water Analyzer history',
    );

    return file.path;
  }
}
