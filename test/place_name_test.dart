import 'package:flutter_test/flutter_test.dart';
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
    test('различает «выбрано без места» и «ничего не выбрано»', () {
      // Именно ради этого различия заведён отдельный тип: null-результат
      // showPlacePicker означает «лист закрыли», а PlaceSelection(null) —
      // «пользователь осознанно выбрал „Без места“».
      const noPlace = PlaceSelection(null);

      expect(noPlace.name, isNull);
      expect(noPlace, isA<PlaceSelection>());
    });

    test('несёт выбранное имя', () {
      expect(const PlaceSelection('Родник').name, 'Родник');
    });
  });
}
