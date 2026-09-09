import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:water_analyzer/history/catalog_seed.dart';
import 'package:water_analyzer/history/database.dart';
import 'package:water_analyzer/history/grouping.dart';
import 'package:water_analyzer/history/measurement_place.dart';
import 'package:water_analyzer/l10n/generated/app_localizations.dart';

/// Хелпер для создания тестового [Measurement]. Конкретные значения параметров
/// для группировки не важны — нам нужна только дата.
Measurement _at(DateTime when, {int id = 0, String? label, String? siteName, String? roomName}) {
  return Measurement(
    id: id,
    deviceId: 'AA:BB:CC:DD:EE:FF',
    label: label,
    siteName: siteName,
    roomName: roomName,
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

/// Стартовый каталог задаётся явно: в тестах проверяются знакомые русские имена,
/// а язык машины, на которой их запускают, к делу отношения не имеет.
final l10n = lookupAppL10n(const Locale('ru'));
final seed = CatalogSeed.from(l10n);

void main() {
  group('placesInHistory', () {
    test('пустая история — пустой список адресов', () {
      expect(placesInHistory(const []), isEmpty);
    });

    test('собирает уникальные адреса', () {
      final places = placesInHistory([
        _at(DateTime(2026, 9, 3), id: 1, siteName: 'Дом', label: 'Кулер'),
        _at(DateTime(2026, 9, 2), id: 2, siteName: 'Дом', label: 'Кулер'),
        _at(DateTime(2026, 9, 1), id: 3, siteName: 'Дача', label: 'Скважина'),
      ]);

      expect(places.map((p) => p.formatted), ['Дом · Кулер', 'Дача · Скважина']);
    });

    test('один источник в разных местах — разные адреса', () {
      // Ради этого случая фильтр и переписан: раньше кран дома и на даче
      // сливались в одну линию графика и выглядели как скачок качества воды.
      final places = placesInHistory([
        _at(DateTime(2026, 9, 2), id: 1, siteName: 'Дом', label: 'Кран на кухне'),
        _at(DateTime(2026, 9, 1), id: 2, siteName: 'Дача', label: 'Кран на кухне'),
      ]);

      expect(places, hasLength(2));
    });

    test('комната различает адреса внутри одного места', () {
      final places = placesInHistory([
        _at(DateTime(2026, 9, 2), id: 1, siteName: 'Дом', roomName: 'Кухня', label: 'Кран'),
        _at(DateTime(2026, 9, 1), id: 2, siteName: 'Дом', roomName: 'Ванная', label: 'Кран'),
      ]);

      expect(places, hasLength(2));
      expect(places.map((p) => p.formatted), ['Дом · Кухня · Кран', 'Дом · Ванная · Кран']);
    });

    test('порядок — от свежих замеров к старым', () {
      final places = placesInHistory([
        _at(DateTime(2026, 9, 3), id: 1, siteName: 'Дача', label: 'Скважина'),
        _at(DateTime(2026, 9, 1), id: 2, siteName: 'Дом', label: 'Кулер'),
      ]);

      expect(places.first.formatted, 'Дача · Скважина');
    });

    test('замеры без адреса в фильтр не попадают', () {
      final places = placesInHistory([
        _at(DateTime(2026, 9, 2), id: 1),
        _at(DateTime(2026, 9, 1), id: 2, siteName: 'Дом', label: 'Кулер'),
      ]);

      expect(places.map((p) => p.formatted), ['Дом · Кулер']);
    });

    test('пробельные имена игнорируются', () {
      final places = placesInHistory([_at(DateTime(2026, 9, 1), id: 1, label: '   ')]);

      expect(places, isEmpty);
    });

    test('адреса, различающиеся крайними пробелами, считаются одним', () {
      final places = placesInHistory([
        _at(DateTime(2026, 9, 2), id: 1, siteName: 'Дом ', label: ' Кулер'),
        _at(DateTime(2026, 9, 1), id: 2, siteName: 'Дом', label: 'Кулер'),
      ]);

      expect(places, hasLength(1));
    });

    test('записи до иерархии остаются отдельными адресами из одного уровня', () {
      final places = placesInHistory([
        _at(DateTime(2026, 9, 2), id: 1, label: 'Кран на кухне'),
        _at(DateTime(2026, 9, 1), id: 2, siteName: 'Дом', label: 'Кран на кухне'),
      ]);

      // Придумывать старой записи место задним числом нельзя — она честно
      // остаётся отдельной строкой фильтра.
      expect(places, hasLength(2));
      expect(places.first.formatted, 'Кран на кухне');
    });
  });

  group('measurementIsAt', () {
    test('замер относится к своему адресу', () {
      final row = _at(DateTime(2026, 9, 1), siteName: 'Дача', label: 'Скважина');

      expect(
        measurementIsAt(row, const MeasurementPlace(siteName: 'Дача', sourceName: 'Скважина')),
        isTrue,
      );
    });

    test('тот же источник в другом месте не подходит', () {
      final row = _at(DateTime(2026, 9, 1), siteName: 'Дом', label: 'Кран');

      expect(
        measurementIsAt(row, const MeasurementPlace(siteName: 'Дача', sourceName: 'Кран')),
        isFalse,
      );
    });

    test('крайние пробелы в базе не мешают совпадению', () {
      // Раньше чипы строились с trim(), а фильтрация сравнивала сырую строку:
      // метка с пробелами давала чип, который не совпадал ни с одной точкой,
      // и график молча оказывался пустым.
      final row = _at(DateTime(2026, 9, 1), siteName: ' Дом ', label: ' Кулер ');

      expect(
        measurementIsAt(row, const MeasurementPlace(siteName: 'Дом', sourceName: 'Кулер')),
        isTrue,
      );
    });

    test('комната участвует в сравнении', () {
      final row = _at(DateTime(2026, 9, 1), siteName: 'Дом', roomName: 'Кухня', label: 'Кран');

      expect(
        measurementIsAt(
          row,
          const MeasurementPlace(siteName: 'Дом', roomName: 'Ванная', sourceName: 'Кран'),
        ),
        isFalse,
      );
    });
  });

  group('groupMeasurementsByDay', () {
    test('пустой ввод — пустой список групп', () {
      expect(groupMeasurementsByDay(const [], l10n), isEmpty);
    });

    test('запись «сегодня» попадает в группу «Сегодня»', () {
      final now = DateTime(2026, 5, 24, 14, 30);
      final rows = [_at(DateTime(2026, 5, 24, 9, 0), id: 1)];

      final groups = groupMeasurementsByDay(rows, l10n, now: now);

      expect(groups, hasLength(1));
      expect(groups.first.label, 'Сегодня');
      expect(groups.first.measurements, hasLength(1));
    });

    test('запись «вчера» попадает в группу «Вчера»', () {
      final now = DateTime(2026, 5, 24, 14, 30);
      final rows = [_at(DateTime(2026, 5, 23, 18, 0), id: 1)];

      final groups = groupMeasurementsByDay(rows, l10n, now: now);

      expect(groups, hasLength(1));
      expect(groups.first.label, 'Вчера');
    });

    test('запись 2 дня назад попадает в группу с числовой датой', () {
      final now = DateTime(2026, 5, 24, 14, 30);
      final rows = [_at(DateTime(2026, 5, 22, 10, 0), id: 1)];

      final groups = groupMeasurementsByDay(rows, l10n, now: now);

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

      final groups = groupMeasurementsByDay(rows, l10n, now: now);

      expect(groups, hasLength(1));
      expect(groups.first.label, 'Сегодня');
      expect(groups.first.measurements.map((m) => m.id), [3, 2, 1]);
    });

    test('порядок групп — от первого появления записи каждого дня', () {
      // Имитируем реальный sort desc by observedAt: новые сверху.
      final now = DateTime(2026, 5, 24, 12, 0);
      final rows = [
        _at(DateTime(2026, 5, 24, 10, 0), id: 5), // сегодня
        _at(DateTime(2026, 5, 24, 9, 0), id: 4), // сегодня
        _at(DateTime(2026, 5, 23, 18, 0), id: 3), // вчера
        _at(DateTime(2026, 5, 21, 10, 0), id: 2), // 21.05
        _at(DateTime(2026, 5, 21, 9, 0), id: 1), // 21.05
      ];

      final groups = groupMeasurementsByDay(rows, l10n, now: now);

      expect(groups.map((g) => g.label).toList(), ['Сегодня', 'Вчера', '21.05.2026']);
    });

    test('записи каждой группы остаются в исходном порядке', () {
      final now = DateTime(2026, 5, 24, 12, 0);
      final rows = [
        _at(DateTime(2026, 5, 22, 18, 0), id: 30),
        _at(DateTime(2026, 5, 22, 10, 0), id: 20),
        _at(DateTime(2026, 5, 22, 5, 0), id: 10),
      ];

      final groups = groupMeasurementsByDay(rows, l10n, now: now);

      expect(groups, hasLength(1));
      expect(groups.first.measurements.map((m) => m.id), [30, 20, 10]);
    });

    test('границы дня: 23:59:59 и 00:00:00 — разные группы', () {
      final now = DateTime(2026, 5, 24, 12, 0);
      final rows = [
        _at(DateTime(2026, 5, 24, 0, 0, 0), id: 2), // сегодня (полночь)
        _at(DateTime(2026, 5, 23, 23, 59, 59), id: 1), // вчера (последняя секунда)
      ];

      final groups = groupMeasurementsByDay(rows, l10n, now: now);

      expect(groups, hasLength(2));
      expect(groups[0].label, 'Сегодня');
      expect(groups[0].measurements.first.id, 2);
      expect(groups[1].label, 'Вчера');
      expect(groups[1].measurements.first.id, 1);
    });
  });
}
