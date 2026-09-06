import 'package:flutter_test/flutter_test.dart';
import 'package:water_analyzer/history/measurement_place.dart';
import 'package:water_analyzer/history/place_name.dart';
import 'package:water_analyzer/ui/widgets/place_picker.dart';

/// Нормализация имени места. Функция маленькая, но стоит на стыке двух версий:
/// до 1.2.0 место было свободным вводом, и в `SharedPreferences` могла остаться
/// строка из пробелов. Без приведения к `null` поле показывало бы пустоту,
/// в списке не был бы отмечен ни один пункт, а замер сохранялся бы с
/// «пробельным» местом, которое UI считает названным.
void main() {
  group('normalizePlaceName', () {
    test('обычное имя не меняется', () {
      expect(normalizePlaceName('Кран на кухне'), 'Кран на кухне');
    });

    test('null остаётся null', () {
      expect(normalizePlaceName(null), isNull);
    });

    test('пустая строка становится null', () {
      expect(normalizePlaceName(''), isNull);
    });

    test('строка из пробелов становится null', () {
      expect(normalizePlaceName('   '), isNull);
    });

    test('табуляция и перевод строки тоже считаются пустотой', () {
      expect(normalizePlaceName('\t\n '), isNull);
    });

    test('пробелы по краям обрезаются', () {
      expect(normalizePlaceName('  Аквариум  '), 'Аквариум');
    });

    test('пробелы внутри названия сохраняются', () {
      expect(normalizePlaceName('  Дача, дальний колодец  '), 'Дача, дальний колодец');
    });

    test('нормализация идемпотентна', () {
      final once = normalizePlaceName('  Кулер  ');
      expect(normalizePlaceName(once), once);
    });
  });

  group('PlaceSelection', () {
    test('различает «выбрано без адреса» и «ничего не выбрано»', () {
      // Именно ради этого различия заведён отдельный тип: null-результат
      // showPlacePicker означает «лист закрыли», а PlaceSelection.none —
      // «пользователь осознанно выбрал „Без адреса“».
      expect(PlaceSelection.none.sourceId, isNull);
      expect(PlaceSelection.none.place.isEmpty, isTrue);
    });

    test('несёт ссылку на источник и его адрес', () {
      const selection = PlaceSelection(
        sourceId: 7,
        place: MeasurementPlace(siteName: 'Дача', sourceName: 'Скважина'),
      );

      expect(selection.sourceId, 7);
      expect(selection.place.formatted, 'Дача · Скважина');
    });
  });

  group('MeasurementPlace.formatted', () {
    test('полный путь из трёх уровней', () {
      const place = MeasurementPlace(siteName: 'Дом', roomName: 'Кухня', sourceName: 'Фильтр');

      expect(place.formatted, 'Дом · Кухня · Фильтр');
    });

    test('без комнаты уровень просто пропускается, а не пустует', () {
      // Комната — необязательный уровень, и её отсутствие не должно оставлять
      // в пути дыру вида «Дача ·  · Скважина».
      const place = MeasurementPlace(siteName: 'Дача', sourceName: 'Скважина');

      expect(place.formatted, 'Дача · Скважина');
    });

    test('запись до появления иерархии показывает одно имя источника', () {
      const place = MeasurementPlace(sourceName: 'Кран на кухне');

      expect(place.formatted, 'Кран на кухне');
      expect(place.isLegacy, isTrue);
    });

    test('пустой адрес не даёт ни разделителей, ни пробелов', () {
      expect(MeasurementPlace.none.formatted, isEmpty);
      expect(MeasurementPlace.none.isEmpty, isTrue);
    });

    test('короткий вид опускает комнату', () {
      const place = MeasurementPlace(siteName: 'Дом', roomName: 'Кухня', sourceName: 'Фильтр');

      expect(place.short, 'Дом · Фильтр');
    });

    test('нормализация обрезает пробелы на всех уровнях', () {
      final place = MeasurementPlace.normalized(
        siteName: '  Дача  ',
        roomName: '   ',
        sourceName: ' Скважина ',
      );

      expect(place.siteName, 'Дача');
      expect(place.roomName, isNull, reason: 'пробельная комната — это её отсутствие');
      expect(place.sourceName, 'Скважина');
    });

    test('одинаковые адреса равны', () {
      const a = MeasurementPlace(siteName: 'Дом', sourceName: 'Кулер');
      const b = MeasurementPlace(siteName: 'Дом', sourceName: 'Кулер');

      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });

    test('один и тот же источник в разных местах — разные адреса', () {
      // Ради этого различия вся иерархия и затевалась: «Кран на кухне» дома и
      // на даче — разная вода.
      const home = MeasurementPlace(siteName: 'Дом', sourceName: 'Кран на кухне');
      const dacha = MeasurementPlace(siteName: 'Дача', sourceName: 'Кран на кухне');

      expect(home, isNot(dacha));
    });
  });
}
