import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../history/database.dart';
import '../providers/app_settings.dart';
import '../quality/catalog.dart';
import '../quality/overview.dart';
import '../yinmik/reading_values.dart';
import 'widgets/parameter_card.dart';
import 'widgets/summary_header.dart';

/// Детальный просмотр одного замера из истории с возможностью свайпа влево/вправо
/// для сравнения с соседними замерами.
class HistoryDetailPage extends ConsumerStatefulWidget {
  final List<Measurement> measurements;
  final int initialIndex;

  const HistoryDetailPage({
    super.key,
    required this.measurements,
    required this.initialIndex,
  });

  @override
  ConsumerState<HistoryDetailPage> createState() => _HistoryDetailPageState();
}

class _HistoryDetailPageState extends ConsumerState<HistoryDetailPage> {
  // Локаль-нейтральный формат — не требует initializeDateFormatting и не падает на устройствах
  // без российских locale data.
  static final _timeFormat = DateFormat('dd.MM.yyyy HH:mm');

  late int _currentIndex = widget.initialIndex;
  late final PageController _pageController =
      PageController(initialPage: widget.initialIndex);

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final current = widget.measurements[_currentIndex];
    final hasLabel = current.label?.isNotEmpty == true;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              hasLabel ? current.label! : 'Замер',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              _timeFormat.format(current.observedAt),
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Center(
              child: Text(
                '${_currentIndex + 1} / ${widget.measurements.length}',
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ),
          ),
        ],
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.measurements.length,
        onPageChanged: (index) => setState(() => _currentIndex = index),
        itemBuilder: (context, index) =>
            _MeasurementDetailView(measurement: widget.measurements[index]),
      ),
    );
  }
}

class _MeasurementDetailView extends ConsumerWidget {
  final Measurement measurement;

  const _MeasurementDetailView({required this.measurement});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(appSettingsProvider).normsProfile;
    final parameters = WaterParameterCatalog.forProfile(profile);
    final values = measurementValues(measurement);
    final overview = WaterQualityOverview.compute(values, profile: profile);
    final reading = readingFromMeasurement(measurement);

    return ListView(
      children: [
        SummaryHeader(overview: overview, reading: reading),
        for (final parameter in parameters)
          if (values[parameter.key] != null)
            ParameterCard(parameter: parameter, value: values[parameter.key]!),
        const SizedBox(height: 24),
      ],
    );
  }
}
