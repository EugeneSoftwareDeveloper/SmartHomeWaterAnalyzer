import 'package:flutter_test/flutter_test.dart';
import 'package:water_analyzer/yinmik/decoder.dart';

/// Регрессионные тесты декодера BLE-C600. Кадры и ожидаемые значения портированы
/// один-в-один из `SmartHomeService.Test/Devices/WaterQuality/Yinmik/WhenDecodingYinmikBleC600Frame.cs`,
/// где они были подтверждены сверкой с экраном прибора и официальным приложением.
void main() {
  group('YinmikDecoder', () {
    test('measurement fields are decoded from raw BLE frame', () {
      final rawFrame = YinmikDecoder.parseHexFrame(
          'FF A9 FE 7A FC EC FF FF FF BF FF BD FF 75 FD 0E FA ED 75 FE AC DD BB 57');

      final reading = YinmikDecoder.decodeRawFrame(rawFrame);

      expect(reading.ph, closeTo(6.10, 0.001));
      expect(reading.electricalConductivityUsCm, 257);
      expect(reading.totalDissolvedSolidsPpm, 128);
      expect(reading.salinityPpm, 128);
      expect(reading.salinityPercent, closeTo(0.01, 0.001));
      expect(reading.temperatureCelsius, closeTo(23.1, 0.001));
      expect(reading.batteryRawMillivolts, 2928);
      expect(reading.statusFlags, 0);
      expect(reading.backlightOn, isFalse);
      expect(reading.holdReadingOn, isFalse);
      expect(reading.specificGravity, closeTo(0.999, 0.001));
      expect(reading.oxidationReductionPotentialMillivolts, 137);
    });

    test('backlight flag is decoded from status byte', () {
      final rawFrame = YinmikDecoder.parseHexFrame(
          'FF A9 FE 78 FC EE FF FF FF BF FF BD FF 7F FD 2B FA EC 71 FE AC DD BA 57');

      final reading = YinmikDecoder.decodeRawFrame(rawFrame);

      expect(reading.statusFlags, YinmikDecoder.backlightStatusFlag);
      expect(reading.backlightOn, isTrue);
      expect(reading.holdReadingOn, isFalse);
      expect(reading.oxidationReductionPotentialMillivolts, 139);
    });

    test('hold reading flag is decoded from status byte', () {
      final rawFrame = YinmikDecoder.parseHexFrame(
          'FF A9 FE 78 FC EC FF FC FF BD FF BD FF 77 FD 2B DA EC 75 FE 86 DD BA 57');

      final reading = YinmikDecoder.decodeRawFrame(rawFrame);

      expect(reading.statusFlags, YinmikDecoder.holdReadingStatusFlag);
      expect(reading.backlightOn, isFalse);
      expect(reading.holdReadingOn, isTrue);
      expect(reading.electricalConductivityUsCm, 259);
      expect(reading.oxidationReductionPotentialMillivolts, 158);
    });

    test('raw frame is decoded with BLE-YC01 family bit swap', () {
      final rawFrame = YinmikDecoder.parseHexFrame(
          'FF A9 FE 78 FC EC FF FC FF BD FF BD FF 77 FD 2B DA EC 75 FE 86 DD BA 57');

      final decoded = YinmikDecoder.decodeBleYc01FamilyFrame(rawFrame);

      expect(
        decoded,
        YinmikDecoder.parseHexFrame(
            '01 02 0B 02 63 01 03 00 81 00 81 00 01 00 EC 0B 62 10 03 E7 00 9E 13 00'),
      );
    });

    test('short frame throws FormatException', () {
      expect(
        () => YinmikDecoder.decodeDecodedFrame(YinmikDecoder.parseHexFrame('01 02 03')),
        throwsFormatException,
      );
    });
  });
}
