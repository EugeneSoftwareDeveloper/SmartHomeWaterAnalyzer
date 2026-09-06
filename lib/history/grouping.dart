import 'package:intl/intl.dart';

import 'database.dart';
import 'measurement_place.dart';

/// Группа замеров, относящихся к одному календарному дню.
///
/// [label] — человеко-понятное название группы: «Сегодня», «Вчера» или дата
/// в формате `dd.MM.yyyy` для более старых.
/// [measurements] — список замеров этой группы, в том же порядке, в котором они
/// пришли во входной список (обычно `desc by observedAt`).
class MeasurementDayGroup {
  final String label;
  final List<Measurement> measurements;

  const MeasurementDayGroup({required this.label, required this.measurements});
}

/// Адреса, встречающиеся в переданных замерах, в порядке первого появления.
///
/// Нужен для фильтра графика: показывать в нём весь каталог бессмысленно —
/// выбор источника без замеров дал бы пустой график. Порядок «как в истории»
/// ставит недавно использованные первыми, потому что список отсортирован desc.
///
/// Различает адреса целиком, а не по имени источника: «Кран на кухне» дома и на
/// даче — разная вода, и сливать их в одну линию значило бы рисовать скачок
/// качества там, где просто сменили место. Ровно ради этого и заводилась
/// иерархия.
///
/// Записи до версии 1.4.0 остаются отдельными адресами из одного уровня — у них
/// известен только источник, и придумывать им место задним числом нельзя.
List<MeasurementPlace> placesInHistory(List<Measurement> rows) {
  final places = <MeasurementPlace>{};
  for (final row in rows) {
    final place = MeasurementPlace.normalized(
      siteName: row.siteName,
      roomName: row.roomName,
      sourceName: row.label,
    );
    if (place.isNotEmpty) places.add(place);
  }
  return places.toList(growable: false);
}

/// Относится ли замер к выбранному адресу.
///
/// Сравнение идёт по нормализованным именам, а не по сырым колонкам: раньше
/// фильтр сличал `label` точной строкой, тогда как список чипов строился с
/// `trim()`. Метка с крайними пробелами давала чип, который не совпадал ни с
/// одной точкой, и график молча оказывался пустым.
bool measurementIsAt(Measurement row, MeasurementPlace place) {
  return MeasurementPlace.normalized(
        siteName: row.siteName,
        roomName: row.roomName,
        sourceName: row.label,
      ) ==
      place;
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
List<MeasurementDayGroup> groupMeasurementsByDay(List<Measurement> rows, {DateTime? now}) {
  final reference = now ?? DateTime.now();
  final today = DateTime(reference.year, reference.month, reference.day);
  final dateFormat = DateFormat('dd.MM.yyyy');
  final buckets = <String, List<Measurement>>{};

  for (final row in rows) {
    final day = DateTime(row.observedAt.year, row.observedAt.month, row.observedAt.day);
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
