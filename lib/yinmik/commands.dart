import 'dart:typed_data';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';

/// Команды управления YINMIK BLE-C600.
///
/// **Состояние протокола: СПЕКУЛЯТИВНОЕ.**
///
/// Производитель не публикует протокол команд. Эти байты — обоснованная догадка, основанная
/// на следующих наблюдениях:
///
/// - Кадр FF02 содержит байт статуса по смещению 17, где **бит 0x08** = подсветка, **бит 0x10** = HOLD
///   (подтверждено сверкой с экраном прибора, см. SmartHomeService/docs/09).
/// - Для семейства BLE-YC01 в открытых проектах встречается служебная характеристика **FF15**
///   с поддержкой write.
/// - Самый простой и распространённый паттерн в дешёвых white-label BLE-устройствах —
///   «write единственный байт, соответствующий целевому биту статуса». Если прошивка
///   действительно проверяет тот же бит на запись, что и при чтении — паттерн сработает.
///
/// Если эти байты **не сработают** — это нормально. Замени значения константами, полученными
/// через HCI snoop log от официального приложения YINMIK (см. `docs/03-control-commands.md`).
///
/// **Альтернативные паттерны, которые стоит попробовать** при неудаче текущего:
/// 1. Двухбайтные `[0x01, 0x01]` / `[0x01, 0x00]` — opcode + флаг
/// 2. Полный статус-байт `[0x18]` (подсветка+HOLD), `[0x08]`, `[0x10]`, `[0x00]`
/// 3. Запись в FF02 (не FF15) — у некоторых вариантов это та же характеристика
/// 4. Запись с `withoutResponse: true` вместо `false`
abstract final class YinmikCommands {
  /// Кандидат на служебную характеристику команд.
  /// Если не сработает — попробуй основную характеристику данных:
  /// `Guid('0000ff02-0000-1000-8000-00805f9b34fb')`.
  static final Guid commandCharacteristicUuid =
      Guid('0000ff15-0000-1000-8000-00805f9b34fb');

  /// Включает попытки реальной записи. Поскольку байты спекулятивные, UI будет дёргать прибор
  /// и показывать ошибку через SnackBar, если прибор отвергает write — это безопасно.
  /// Худший наблюдаемый исход на BLE-C600 — кратковременное зависание соединения (по протокол-доку);
  /// прибор восстанавливается на следующем цикле опроса.
  static const bool areCommandsKnown = true;

  /// Подсветка ON: один байт, совпадающий с битом подсветки в status-байте.
  static final Uint8List _backlightOn = Uint8List.fromList([0x08]);

  /// Подсветка OFF: нулевой байт, что обычно эквивалентно «сбросить флаг».
  static final Uint8List _backlightOff = Uint8List.fromList([0x00]);

  /// HOLD ON: один байт, совпадающий с битом HOLD.
  static final Uint8List _holdOn = Uint8List.fromList([0x10]);

  /// HOLD OFF.
  static final Uint8List _holdOff = Uint8List.fromList([0x00]);

  static Uint8List backlightCommand({required bool on}) => on ? _backlightOn : _backlightOff;

  static Uint8List holdCommand({required bool on}) => on ? _holdOn : _holdOff;
}

/// Исключение для команды, чьи байты ещё не известны. Не используется, пока
/// [YinmikCommands.areCommandsKnown] = true, но оставлено для будущей реализации
/// per-команда-флага.
class UnknownCommandException implements Exception {
  final String commandName;

  UnknownCommandException(this.commandName);

  @override
  String toString() =>
      'Команда "$commandName" пока не реализована: байты протокола не подтверждены. '
      'См. docs/03-control-commands.md, раздел "Сбор HCI snoop log".';
}
