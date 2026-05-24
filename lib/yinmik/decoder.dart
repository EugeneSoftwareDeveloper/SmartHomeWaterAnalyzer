import 'dart:typed_data';

import 'reading.dart';

/// Декодер сырого BLE-кадра YINMIK BLE-C600 (характеристика FF02 сервиса FF01).
///
/// Алгоритм портирован один-в-один с C#-реализации `YinmikBleC600FrameDecoder` из
/// репозитория `SmartHomeService` (`Domain/Devices/WaterQuality/Yinmik/`). Карта полей
/// подтверждена на реальном устройстве, см. `SmartHomeService/docs/09-yinmik-ble-water-quality-protocol.md`.
class YinmikDecoder {
  static const int backlightStatusFlag = 0x08;
  static const int holdReadingStatusFlag = 0x10;
  static const int minimumDecodedFrameLength = 22;

  /// Декодирует «сырой» кадр (после `decodeBleYc01FamilyFrame`) в [YinmikReading].
  static YinmikReading decodeRawFrame(Uint8List rawFrame) {
    final decoded = decodeBleYc01FamilyFrame(rawFrame);
    return decodeDecodedFrame(decoded);
  }

  /// Декодирует уже распакованный кадр. Бросает [FormatException] при коротком кадре.
  static YinmikReading decodeDecodedFrame(Uint8List decodedFrame) {
    if (decodedFrame.length < minimumDecodedFrameLength) {
      throw FormatException(
        'Decoded BLE-C600 frame must contain at least $minimumDecodedFrameLength bytes, got ${decodedFrame.length}.',
      );
    }

    final statusFlags = decodedFrame[17];

    return YinmikReading(
      ph: _readInt16BigEndian(decodedFrame, 3) / 100.0,
      electricalConductivityUsCm: _readInt16BigEndian(decodedFrame, 5),
      totalDissolvedSolidsPpm: _readInt16BigEndian(decodedFrame, 7),
      salinityPpm: _readInt16BigEndian(decodedFrame, 9),
      salinityPercent: _readInt16BigEndian(decodedFrame, 11) / 100.0,
      temperatureCelsius: _readInt16BigEndian(decodedFrame, 13) / 10.0,
      batteryRawMillivolts: _readInt16BigEndian(decodedFrame, 15),
      statusFlags: statusFlags,
      backlightOn: (statusFlags & backlightStatusFlag) != 0,
      holdReadingOn: (statusFlags & holdReadingStatusFlag) != 0,
      specificGravity: _readInt16BigEndian(decodedFrame, 18) / 1000.0,
      oxidationReductionPotentialMillivolts: _readInt16BigEndian(decodedFrame, 20),
    );
  }

  /// Алгоритм декодирования семейства BLE-YC01: идём от конца к началу, переставляем биты
  /// через маски 0x55 и 0xAA. Возвращает НОВЫЙ массив, исходный не модифицирует.
  ///
  /// Псевдокод:
  /// ```
  /// for i from length-1 down to 1:
  ///   current = frame[i]
  ///   currentHigh = (current & 0x55) << 1
  ///   currentLow  = (current & 0xAA) >> 1
  ///   previous = frame[i-1]
  ///   previousHigh = (previous & 0x55) << 1
  ///   previousLow  = (previous & 0xAA) >> 1
  ///   frame[i]   = 0xFF - (currentHigh  | previousLow)
  ///   frame[i-1] = 0xFF - (previousHigh | currentLow)
  /// ```
  static Uint8List decodeBleYc01FamilyFrame(Uint8List rawFrame) {
    final decoded = Uint8List.fromList(rawFrame);

    for (var index = decoded.length - 1; index > 0; index--) {
      final current = decoded[index];
      final currentHigh = (current & 0x55) << 1;
      final currentLow = (current & 0xAA) >> 1;

      final previous = decoded[index - 1];
      final previousHigh = (previous & 0x55) << 1;
      final previousLow = (previous & 0xAA) >> 1;

      decoded[index] = (0xFF - (currentHigh | previousLow)) & 0xFF;
      decoded[index - 1] = (0xFF - (previousHigh | currentLow)) & 0xFF;
    }

    return decoded;
  }

  /// Парсит строку hex-байтов через пробел: "12 34 5A FF" → Uint8List.
  static Uint8List parseHexFrame(String hex) {
    final tokens = hex
        .split(RegExp(r'\s+'))
        .where((item) => item.isNotEmpty)
        .toList(growable: false);
    final bytes = Uint8List(tokens.length);
    for (var index = 0; index < tokens.length; index++) {
      bytes[index] = int.parse(tokens[index], radix: 16);
    }
    return bytes;
  }

  /// Читает signed int16 big-endian с указанного смещения.
  static int _readInt16BigEndian(Uint8List frame, int offset) {
    final unsigned = (frame[offset] << 8) | frame[offset + 1];
    // signed cast: 0x8000+ → отрицательные.
    return unsigned >= 0x8000 ? unsigned - 0x10000 : unsigned;
  }
}
