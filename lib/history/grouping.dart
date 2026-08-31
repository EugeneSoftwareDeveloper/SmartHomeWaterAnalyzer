import 'package:intl/intl.dart';

import 'database.dart';

/// Группа замеров, относящихся к одному календарному дню.
///
/// [label] — человеко-понятное название группы: «Сегодня», «Вчера» или дата
/// в формате `dd.MM.yyyy` для более старых.
/// [measurements] — список замеров этой группы, в том же порядке, в котором они
/// пришли во входной список (обычно `desc by observedAt`).
class MeasurementDayGroup {
  final String label;
  final List<Measurement> measurements;

  const MeasurementDayGroup({
    required this.label,
    required this.measurements,
  });
}

/// Места, встречающиеся в переданных замерах, в порядке первого появления.
///
/// Нужен для фильтра графика: показывать в нём весь каталог мест бессмысленно —
/// выбор места без замеров дал бы пустой график. Порядок «как в истории» ставит
/// недавно использованные места первыми, потому что список отсортирован desc.
List<String> placesInHistory(List<Measurement> rows) {
  final places = <String>{};
  for (final row in rows) {
    final label = row.label?.trim();
    if (label != null && label.isNotEmpty) places.add(label);
  }
  return places.toList(growable: false);
}

/// Группирует список измерений по календарной дате наблюдения.
///
/// Параметр [now] — точка отсчёта для «Сегодня/Вчера». В production его не
/// передают (берётся `DateTime.now()`), в тестах — фиксированная дата, чтобы
/// результат был детерминированным.
///
/// Возвращает список групп в порядке первого появления записи каждого дня
/// во входном списке. Если `rows` отсортирован `desc by observedAt`, то первая
/// группа — самая свежая.
List<MeasurementDayGroup> groupMeasurementsByDay(
  List<Measurement> rows, {
  DateTime? now,
}) {
  final reference = now ?? DateTime.now();
  final today = DateTime(reference.year, reference.month, reference.day);
  final dateFormat = DateFormat('dd.MM.yyyy');
  final buckets = <String, List<Measurement>>{};

  for (final row in rows) {
    final day = DateTime(
      row.observedAt.year,
      row.observedAt.month,
      row.observedAt.day,
    );
    final diff = today.difference(day).inDays;
    final String label;
    if (diff == 0) {
      label = 'Сегодня';
    } else if (diff == 1) {
      label = 'Вчера';
    } else {
      label = dateFormat.format(day);
    }
    buckets.putIfAbsent(label, () => <Measurement>[]).add(row);
  }

  return [
    for (final entry in buckets.entries)
      MeasurementDayGroup(label: entry.key, measurements: entry.value),
  ];
}
