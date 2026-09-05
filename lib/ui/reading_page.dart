import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../history/database.dart';
import '../history/place_name.dart';
import '../providers/app_settings.dart';
import '../providers/history_provider.dart';
import '../providers/location_provider.dart';
import '../providers/notification_provider.dart';
import '../providers/yinmik_client_provider.dart';
import '../quality/catalog.dart';
import '../quality/overview.dart';
import '../quality/parameter.dart';
import '../quality/trend.dart';
import '../yinmik/reading.dart';
import '../yinmik/reading_values.dart';
import 'widgets/control_panel.dart';
import 'widgets/parameter_card.dart';
import 'widgets/place_picker.dart';
import 'widgets/summary_header.dart';

/// Экран показаний подключённого BLE-C600. Делает одно чтение при открытии и при тапе на
/// «Обновить» или pull-to-refresh.
///
/// Замеры **не сохраняются автоматически** — для записи в историю пользователь должен
/// нажать FAB «Сохранить». Это сознательное решение, чтобы случайные/тестовые чтения
/// (например, при подборе байтов на debug-странице или при первом разогреве электрода
/// pH) не засоряли историю и графики.
class ReadingPage extends ConsumerStatefulWidget {
  final BluetoothDevice device;

  const ReadingPage({super.key, required this.device});

  @override
  ConsumerState<ReadingPage> createState() => _ReadingPageState();
}

class _ReadingPageState extends ConsumerState<ReadingPage> {
  YinmikReading? _reading;
  String? _error;
  bool _loading = false;
  bool _saving = false;

  /// Ссылка на YinmikReading, который уже был сохранён в историю. Сравнивается с текущим
  /// `_reading` через `identical(...)`, чтобы заблокировать повторное сохранение того же
  /// самого кадра. Сбрасывается при каждом новом `_refresh()` или после команды управления.
  YinmikReading? _savedReading;

  /// Подсказку «замер сохранён без координат» показываем один раз за сессию:
  /// после первого объяснения повторять её при каждом сохранении — это шум.
  bool _locationFailureReported = false;

  /// Прошлый сохранённый замер в выбранном месте — с ним сравниваются свежие
  /// показания. `null` при [_baselineLoaded] = true означает «здесь ещё не
  /// сохраняли», и это разные состояния: пока база не загружена, дельту
  /// показывать нельзя, иначе первое, что увидит пользователь, — «изменений нет».
  Measurement? _baseline;
  bool _baselineLoaded = false;

  /// Место, для которого запрошена [_baseline]. Нужно, чтобы ответ устаревшего
  /// запроса не перетёр базу: пока БД отвечает, пользователь успевает сменить
  /// место в списке, и тогда пришедший результат относится уже не к тому месту.
  String? _baselineRequestedFor;

  /// Место, которому принадлежит показываемая сейчас [_baseline]. Отдельно от
  /// [_baselineRequestedFor], потому что между запросом и ответом на экране всё
  /// ещё висит прежняя база: без этой пары дельты доли секунды считались бы
  /// против другого места, а подпись над карточками показывает только время
  /// и подмену не выдаёт.
  String? _baselineLoadedFor;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _refresh());
  }

  /// Перечитывает базу сравнения из истории.
  ///
  /// Вызывается при каждом чтении и при смене места, но **не после сохранения**:
  /// иначе только что записанный замер сам стал бы базой, и дельта, которую
  /// пользователь секунду назад видел, схлопнулась бы в ноль.
  Future<void> _loadBaseline() async {
    final place = normalizePlaceName(ref.read(appSettingsProvider).currentLabel);
    _baselineRequestedFor = place;

    // Сменилось место — показанная база относится к другому месту, и держать её
    // на экране нельзя даже те миллисекунды, пока идёт запрос: дельты считались
    // бы против крана, когда пользователь уже выбрал бассейн. Лучше короткая
    // пустота, чем короткая неправда. При обычном обновлении показаний место то
    // же, база остаётся на месте, и мигания нет.
    if (_baselineLoaded && _baselineLoadedFor != place) {
      setState(() {
        _baseline = null;
        _baselineLoaded = false;
      });
    }

    try {
      final found = await ref
          .read(historyRepositoryProvider)
          .latestForPlace(widget.device.remoteId.str, place);

      // Пока ждали БД, место могли сменить — ответ уже не про то место.
      if (!mounted || _baselineRequestedFor != place) return;
      setState(() {
        _baseline = found;
        _baselineLoaded = true;
        _baselineLoadedFor = place;
      });
    } on Object catch (_) {
      // Сравнение — украшение поверх показаний. Сбой чтения истории не должен
      // мешать смотреть свежий замер, поэтому просто остаёмся без дельт.
      if (!mounted || _baselineRequestedFor != place) return;
      setState(() {
        _baseline = null;
        _baselineLoaded = true;
        _baselineLoadedFor = place;
      });
    }
  }

  Future<void> _refresh() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    // База сравнения читается параллельно с прибором: она не нужна для показа
    // самих значений, и ждать SQLite перед BLE-чтением незачем.
    unawaited(_loadBaseline());

    final client = ref.read(yinmikBleClientProvider);

    try {
      final reading = await client.readOnce(widget.device);
      if (!mounted) return;
      setState(() {
        _reading = reading;
        _loading = false;
        _savedReading = null; // новое чтение — снова можно сохранять
      });

      // Уведомление — в _refresh, а не в build. В build setState может вызвать ребилды,
      // в которых notifier стрелял бы повторно.
      if (mounted) await _maybeNotify(reading);
    } on Object catch (error) {
      if (!mounted) return;
      await HapticFeedback.mediumImpact();
      setState(() {
        _error = '$error';
        _loading = false;
      });
    }
  }

  Future<void> _maybeNotify(YinmikReading reading) async {
    final settings = ref.read(appSettingsProvider);
    if (!settings.notificationsEnabled) return;

    final overview = WaterQualityOverview.compute(
      readingValues(reading),
      profile: settings.normsProfile,
    );
    if (overview.isAllGood) return;

    await ref.read(notificationServiceProvider).notifyIfOutOfRange(overview);
  }

  /// Сохранить текущий замер в историю + показать SnackBar с возможностью undo.
  /// Дубликат блокируется: повторный тап на тот же кадр ничего не делает.
  Future<void> _save() async {
    final reading = _reading;
    if (reading == null || _saving) return;

    if (identical(_savedReading, reading)) {
      _showSnackBar('Этот замер уже сохранён');
      return;
    }

    setState(() => _saving = true);
    try {
      final history = ref.read(historyRepositoryProvider);
      final settings = ref.read(appSettingsProvider);

      // Геометка — best-effort: отказ в разрешении, выключенный GPS или таймаут
      // не мешают сохранить замер, просто координат у него не будет.
      final locationResult = settings.saveLocationEnabled
          ? await ref.read(locationServiceProvider).currentLocation()
          : null;

      // Настройки перечитываем ПОСЛЕ ожидания координат: между тапом «Сохранить»
      // и этой точкой могло пройти до 30 секунд (медленный фикс, системный диалог
      // разрешений), и пользователь успел бы сменить место или профиль. Со старым
      // снапшотом замер ушёл бы с прежним местом.
      final current = ref.read(appSettingsProvider);
      final place = current.currentLabel;
      final id = await history.save(
        widget.device.remoteId.str,
        reading,
        DateTime.now(),
        label: place,
        location: locationResult?.location,
        normsProfile: current.normsProfile,
      );

      // Место поднимается в начало списка выбора — им только что пользовались.
      // Свой try/catch: замер уже записан, и сбой этого косметического шага не
      // должен выдаваться за неудачное сохранение — иначе пользователь нажал бы
      // «Сохранить» повторно и получил дубликат в истории.
      if (place != null && place.trim().isNotEmpty) {
        try {
          await ref.read(placesRepositoryProvider).markUsed(place);
        } on Object catch (_) {
          // Порядок списка мест — не то, ради чего стоит беспокоить пользователя.
        }
      }

      if (!mounted) return;
      setState(() {
        _saving = false;
        _savedReading = reading;
      });
      await HapticFeedback.lightImpact();

      _showSnackBar(
        'Замер сохранён',
        action: SnackBarAction(
          label: 'Отменить',
          onPressed: () async {
            await history.deleteById(id);
            if (!mounted) return;
            setState(() => _savedReading = null);
          },
        ),
      );

      // О причине отсутствия координат сообщаем один раз за сессию, чтобы
      // подсказка не превращалась в надоедливую после каждого замера.
      final failure = locationResult?.failure;
      if (failure != null && !_locationFailureReported) {
        _locationFailureReported = true;
        _showSnackBar(failure.message);
      }
    } on Object catch (error) {
      if (!mounted) return;
      setState(() => _saving = false);
      _showSnackBar('Не удалось сохранить: $error');
    }
  }

  void _showSnackBar(String message, {SnackBarAction? action}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), action: action));
  }

  @override
  Widget build(BuildContext context) {
    // Сменили место — сравнивать надо уже с историей нового места, иначе замер
    // на кухне сопоставлялся бы с прошлым замером в бассейне. Ровно та причина,
    // по которой у графика в 1.2.0 появился фильтр по месту.
    ref.listen<String?>(
      appSettingsProvider.select((settings) => settings.currentLabel),
      (_, _) => unawaited(_loadBaseline()),
    );

    final deviceName = widget.device.platformName.isEmpty
        ? widget.device.remoteId.str
        : widget.device.platformName;
    final hasReading = _reading != null;
    final isSavedAlready = identical(_savedReading, _reading) && _reading != null;
    final saveEnabled = hasReading && !_saving && !isSavedAlready && !_loading;

    return Scaffold(
      appBar: AppBar(
        title: Text(deviceName),
        actions: [
          IconButton(
            icon: const Icon(Icons.science_outlined),
            tooltip: 'Отладка команд',
            onPressed: () => context.push('/debug-commands', extra: widget.device),
          ),
          IconButton(
            icon: _loading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh),
            tooltip: 'Обновить',
            onPressed: _loading ? null : _refresh,
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: hasReading
          ? FloatingActionButton.extended(
              onPressed: saveEnabled ? _save : null,
              icon: _saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(isSavedAlready ? Icons.check : Icons.save_outlined),
              label: Text(isSavedAlready ? 'Сохранено' : 'Сохранить замер'),
              backgroundColor: isSavedAlready
                  ? Theme.of(context).colorScheme.surfaceContainerHigh
                  : null,
              foregroundColor: isSavedAlready
                  ? Theme.of(context).colorScheme.onSurfaceVariant
                  : null,
            )
          : null,
    );
  }

  /// Тренд по одному параметру. `null`, если базы нет или в ней нет этого
  /// параметра — карточка тогда просто не показывает дельту.
  ParameterTrend? _trendFor(
    WaterParameter parameter,
    Map<String, double> current,
    Map<String, double>? baseline,
  ) {
    final previous = baseline?[parameter.key];
    final value = current[parameter.key];
    if (previous == null || value == null) return null;

    return ParameterTrend.between(parameter: parameter, previous: previous, current: value);
  }

  Widget _buildBody() {
    if (_loading && _reading == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null && _reading == null) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
            const SizedBox(height: 12),
            const Text(
              'Не удалось прочитать показания',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(_error!, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(onPressed: _refresh, child: const Text('Повторить')),
          ],
        ),
      );
    }

    final reading = _reading;
    if (reading == null) return const SizedBox.shrink();

    final settings = ref.watch(appSettingsProvider);
    final profile = settings.normsProfile;
    final parameters = WaterParameterCatalog.forProfile(profile);
    final values = readingValues(reading);
    final overview = WaterQualityOverview.compute(values, profile: profile);

    // Значения базы берём тем же маппингом, что и свежий кадр, — иначе дельта
    // считалась бы между разными полями при добавлении нового параметра.
    final baseline = _baseline;
    final baselineValues = baseline == null ? null : measurementValues(baseline);

    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 96), // место под FAB
        children: [
          const PlacePickerField(),
          SummaryHeader(overview: overview, reading: reading),
          if (_baselineLoaded) _TrendBaselineNote(baseline: baseline),
          for (final parameter in parameters)
            if (values[parameter.key] != null)
              ParameterCard(
                parameter: parameter,
                value: values[parameter.key]!,
                trend: _trendFor(parameter, values, baselineValues),
              ),
          const SizedBox(height: 8),
          ControlPanel(
            device: widget.device,
            client: ref.read(yinmikBleClientProvider),
            reading: reading,
            onReadingUpdated: (updated) {
              // После переключения подсветки/HOLD прибор отдал свежий кадр.
              // Не сохраняем автоматически — пользователь сам решит, нужен ли
              // этот кадр в истории (например, тестовый HOLD-замер для сравнения).
              setState(() {
                _reading = updated;
                _savedReading = null; // изменился — снова можно сохранять
              });
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

/// Одна строка «с чем сравниваем» над карточками.
///
/// Стоит здесь, а не на каждой карточке: время базы одно на весь экран, и
/// повторять его семь раз — шум. Без этой строки дельты выглядели бы как
/// сравнение неизвестно с чем.
class _TrendBaselineNote extends StatelessWidget {
  /// Замер, взятый за базу. `null` — в этом месте ещё ничего не сохраняли.
  final Measurement? baseline;

  const _TrendBaselineNote({required this.baseline});

  // Локаль-нейтральный формат: не требует initializeDateFormatting и не падает
  // на устройствах без российских locale data.
  static final _dateFormat = DateFormat('dd.MM.yyyy HH:mm');
  static final _timeFormat = DateFormat('HH:mm');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final previous = baseline;

    final text = previous == null
        ? 'Первый замер в этом месте — сравнивать не с чем'
        : 'Сравнение с замером ${_describe(previous.observedAt)}';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
      child: Row(
        children: [
          Icon(Icons.history, size: 14, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              maxLines: 2,
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }

  /// «сегодня в 14:20» для замера того же дня, полная дата — для остальных.
  /// Перемер одной и той же воды в течение дня — самый частый сценарий, и
  /// «05.09.2026 14:20» в нём читается хуже.
  String _describe(DateTime moment) {
    final now = DateTime.now();
    final sameDay = moment.year == now.year && moment.month == now.month && moment.day == now.day;

    return sameDay ? 'сегодня в ${_timeFormat.format(moment)}' : _dateFormat.format(moment);
  }
}
