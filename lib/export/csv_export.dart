import 'dart:io';

import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../history/database.dart';

/// Экспорт истории измерений в CSV-файл + системный share-sheet.
abstract final class CsvExporter {
  /// Сохраняет [rows] в CSV-файл и открывает share-sheet. Возвращает путь к файлу для UI.
  static Future<String> shareMeasurementsCsv(List<Measurement> rows) async {
    final temp = await getTemporaryDirectory();
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final file = File(p.join(temp.path, 'water_analyzer_$timestamp.csv'));

    final buffer = StringBuffer()
      ..writeln(
        'timestamp,device_id,ph,ec_us_cm,tds_ppm,salinity_ppm,salinity_percent,'
        'temperature_c,sg,orp_mv,battery_mv,backlight,hold',
      );

    final isoFormat = DateFormat("yyyy-MM-dd'T'HH:mm:ss");
    for (final row in rows) {
      buffer
        ..write(isoFormat.format(row.observedAt))
        ..write(',')
        ..write(row.deviceId)
        ..write(',')
        ..write(row.ph.toStringAsFixed(2))
        ..write(',')
        ..write(row.electricalConductivityUsCm)
        ..write(',')
        ..write(row.totalDissolvedSolidsPpm)
        ..write(',')
        ..write(row.salinityPpm)
        ..write(',')
        ..write(row.salinityPercent.toStringAsFixed(2))
        ..write(',')
        ..write(row.temperatureCelsius.toStringAsFixed(1))
        ..write(',')
        ..write(row.specificGravity.toStringAsFixed(3))
        ..write(',')
        ..write(row.oxidationReductionPotentialMillivolts)
        ..write(',')
        ..write(row.batteryRawMillivolts)
        ..write(',')
        ..write(row.backlightOn ? 1 : 0)
        ..write(',')
        ..writeln(row.holdReadingOn ? 1 : 0);
    }

    await file.writeAsString(buffer.toString());

    await Share.shareXFiles(
      [XFile(file.path, mimeType: 'text/csv')],
      subject: 'Water Analyzer history',
    );

    return file.path;
  }
}
