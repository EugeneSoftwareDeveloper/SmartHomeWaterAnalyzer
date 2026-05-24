import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../history/database.dart';
import '../providers/app_settings.dart';
import '../quality/catalog.dart';
import '../quality/overview.dart';
import '../yinmik/reading.dart';
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
    final timeFormat = DateFormat('dd MMM yyyy, HH:mm', 'ru');

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              current.label?.isNotEmpty == true ? current.label! : 'Замер',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              timeFormat.format(current.observedAt),
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
        itemBuilder: (context, index) {
          return _MeasurementDetailView(measurement: widget.measurements[index]);
        },
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
    final values = _extractValues(measurement);
    final overview = WaterQualityOverview.compute(values, profile: profile);

    final reading = _yinmikFromMeasurement(measurement);

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

  Map<String, double> _extractValues(Measurement m) {
    return {
      'ph': m.ph,
      'orp': m.oxidationReductionPotentialMillivolts.toDouble(),
      'ec': m.electricalConductivityUsCm.toDouble(),
      'tds': m.totalDissolvedSolidsPpm.toDouble(),
      'salinity': m.salinityPpm.toDouble(),
      'temperature': m.temperatureCelsius,
      'sg': m.specificGravity,
    };
  }
}

/// Собирает доменный `YinmikReading` из записи БД, чтобы переиспользовать `SummaryHeader`.
YinmikReading _yinmikFromMeasurement(Measurement m) {
  return YinmikReading(
    ph: m.ph,
    electricalConductivityUsCm: m.electricalConductivityUsCm,
    totalDissolvedSolidsPpm: m.totalDissolvedSolidsPpm,
    salinityPpm: m.salinityPpm,
    salinityPercent: m.salinityPercent,
    temperatureCelsius: m.temperatureCelsius,
    batteryRawMillivolts: m.batteryRawMillivolts,
    statusFlags: (m.backlightOn ? 0x08 : 0) | (m.holdReadingOn ? 0x10 : 0),
    backlightOn: m.backlightOn,
    holdReadingOn: m.holdReadingOn,
    specificGravity: m.specificGravity,
    oxidationReductionPotentialMillivolts: m.oxidationReductionPotentialMillivolts,
  );
}
