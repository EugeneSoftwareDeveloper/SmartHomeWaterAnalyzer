import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../location/measurement_location.dart';

/// Карточка с геометкой замера: координаты, точность и кнопки «на карте» / «копировать».
///
/// Показывается только у замеров, сохранённых с координатами — у остальных
/// (геометка выключена, нет разрешения, GPS не взял фикс) карточки просто нет.
class LocationCard extends StatelessWidget {
  final MeasurementLocation location;

  /// Подпись точки на карте — обычно место замера («Кран на кухне»).
  final String? label;

  const LocationCard({super.key, required this.location, this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accuracy = location.formattedAccuracy;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.place_outlined, size: 20, color: theme.colorScheme.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Где сделан замер',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          location.formatted,
                          style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        if (accuracy != null)
                          Text(
                            'Точность $accuracy',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () => _copyCoordinates(context),
                    icon: const Icon(Icons.copy, size: 18),
                    label: const Text('Копировать'),
                  ),
                  const SizedBox(width: 4),
                  FilledButton.tonalIcon(
                    onPressed: () => _openInMaps(context),
                    icon: const Icon(Icons.map_outlined, size: 18),
                    label: const Text('На карте'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _copyCoordinates(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    await Clipboard.setData(ClipboardData(text: location.formatted));
    messenger.showSnackBar(const SnackBar(content: Text('Координаты скопированы')));
  }

  Future<void> _openInMaps(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    for (final uri in mapUris(location, label: label)) {
      try {
        if (await launchUrl(uri, mode: LaunchMode.externalApplication)) return;
      } on Object {
        // Пробуем следующий вариант — например, если geo:-интент никто не принял.
      }
    }
    messenger.showSnackBar(const SnackBar(content: Text('Не нашлось приложения для карт')));
  }
}

/// Ссылки на карту в порядке предпочтения.
///
/// Сначала `geo:` — системный интент, его подхватит любое установленное
/// картографическое приложение (Яндекс.Карты, Google Maps, OsmAnd, 2ГИС).
/// Если такого приложения нет — https-ссылка откроется в браузере.
///
/// Координаты форматируются с точкой как десятичным разделителем независимо от
/// локали устройства: `geo:55,76` вместо `geo:55.76` сломал бы разбор ссылки.
List<Uri> mapUris(MeasurementLocation location, {String? label}) {
  final latitude = location.latitude.toStringAsFixed(6);
  final longitude = location.longitude.toStringAsFixed(6);
  final point = '$latitude,$longitude';
  final trimmedLabel = label?.trim();
  final hasLabel = trimmedLabel != null && trimmedLabel.isNotEmpty;

  final query = hasLabel ? '$point(${Uri.encodeComponent(trimmedLabel)})' : point;

  return [
    Uri.parse('geo:$point?q=$query'),
    Uri.parse('https://www.google.com/maps/search/?api=1&query=$point'),
  ];
}
