import 'package:flutter_test/flutter_test.dart';
import 'package:water_analyzer/history/database.dart';
import 'package:water_analyzer/history/grouping.dart';

/// Хелпер для создания тестового [Measurement]. Конкретные значения параметров
/// для группировки не важны — нам нужна только дата.
Measurement _at(DateTime when, {int id = 0}) {
  return Measurement(
    id: id,
    deviceId: 'AA:BB:CC:DD:EE:FF',
    label: null,
    observedAt: when,
    ph: 7.0,
    electricalConductivityUsCm: 100,
    totalDissolvedSolidsPpm: 50,
    salinityPpm: 25,
    salinityPercent: 0.0,
    temperatureCelsius: 20.0,
    specificGravity: 1.0,
    oxidationReductionPotentialMillivolts: 300,
    batteryRawMillivolts: 3000,
    backlightOn: false,
    holdReadingOn: false,
  );
}

void main() {
  group('groupMeasurementsByDay', () {
    test('пустой ввод — пустой список групп', () {
      expect(groupMeasurementsByDay(const []), isEmpty);
    });

    test('запись «сегодня» попадает в группу «Сегодня»', () {
      final now = DateTime(2026, 5, 24, 14, 30);
      final rows = [_at(DateTime(2026, 5, 24, 9, 0), id: 1)];

      final groups = groupMeasurementsByDay(rows, now: now);

      expect(groups, hasLength(1));
      expect(groups.first.label, 'Сегодня');
      expect(groups.first.measurements, hasLength(1));
    });

    test('запись «вчера» попадает в группу «Вчера»', () {
      final now = DateTime(2026, 5, 24, 14, 30);
      final rows = [_at(DateTime(2026, 5, 23, 18, 0), id: 1)];

      final groups = groupMeasurementsByDay(rows, now: now);

      expect(groups, hasLength(1));
      expect(groups.first.label, 'Вчера');
    });

    test('запись 2 дня назад попадает в группу с числовой датой', () {
      final now = DateTime(2026, 5, 24, 14, 30);
      final rows = [_at(DateTime(2026, 5, 22, 10, 0), id: 1)];

      final groups = groupMeasurementsByDay(rows, now: now);

      expect(groups, hasLength(1));
      expect(groups.first.label, '22.05.2026');
    });

    test('записи одного дня сливаются в одну группу', () {
      final now = DateTime(2026, 5, 24, 23, 59);
      final rows = [
        _at(DateTime(2026, 5, 24, 20, 0), id: 3),
        _at(DateTime(2026, 5, 24, 15, 0), id: 2),
        _at(DateTime(2026, 5, 24, 9, 0), id: 1),
      ];

      final groups = groupMeasurementsByDay(rows, now: now);

      expect(groups, hasLength(1));
      expect(groups.first.label, 'Сегодня');
      expect(groups.first.measurements.map((m) => m.id), [3, 2, 1]);
    });

    test('порядок групп — от первого появления записи каждого дня', () {
      // Имитируем реальный sort desc by observedAt: новые сверху.
      final now = DateTime(2026, 5, 24, 12, 0);
      final rows = [
        _at(DateTime(2026, 5, 24, 10, 0), id: 5), // сегодня
        _at(DateTime(2026, 5, 24, 9, 0), id: 4),  // сегодня
        _at(DateTime(2026, 5, 23, 18, 0), id: 3), // вчера
        _at(DateTime(2026, 5, 21, 10, 0), id: 2), // 21.05
        _at(DateTime(2026, 5, 21, 9, 0), id: 1),  // 21.05
      ];

      final groups = groupMeasurementsByDay(rows, now: now);

      expect(groups.map((g) => g.label).toList(),
          ['Сегодня', 'Вчера', '21.05.2026']);
    });

    test('записи каждой группы остаются в исходном порядке', () {
      final now = DateTime(2026, 5, 24, 12, 0);
      final rows = [
        _at(DateTime(2026, 5, 22, 18, 0), id: 30),
        _at(DateTime(2026, 5, 22, 10, 0), id: 20),
        _at(DateTime(2026, 5, 22, 5, 0), id: 10),
      ];

      final groups = groupMeasurementsByDay(rows, now: now);

      expect(groups, hasLength(1));
      expect(groups.first.measurements.map((m) => m.id), [30, 20, 10]);
    });

    test('границы дня: 23:59:59 и 00:00:00 — разные группы', () {
      final now = DateTime(2026, 5, 24, 12, 0);
      final rows = [
        _at(DateTime(2026, 5, 24, 0, 0, 0), id: 2),    // сегодня (полночь)
        _at(DateTime(2026, 5, 23, 23, 59, 59), id: 1), // вчера (последняя секунда)
      ];

      final groups = groupMeasurementsByDay(rows, now: now);

      expect(groups, hasLength(2));
      expect(groups[0].label, 'Сегодня');
      expect(groups[0].measurements.first.id, 2);
      expect(groups[1].label, 'Вчера');
      expect(groups[1].measurements.first.id, 1);
    });
  });
}
