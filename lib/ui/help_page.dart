import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../help/parameter_help.dart';
import '../providers/app_settings.dart';

/// Экран справки. Может показывать один параметр (если передан [focusedKey])
/// или список всех параметров с раскрытием.
class HelpPage extends ConsumerWidget {
  final String? focusedKey;

  const HelpPage({super.key, this.focusedKey});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(appSettingsProvider).normsProfile;
    final entries = focusedKey != null
        ? [ParameterHelpCatalog.byKey(focusedKey!, profile)]
        : ParameterHelpCatalog.all(profile);

    return Scaffold(
      appBar: AppBar(
        title: Text(focusedKey != null ? entries.first.title : 'Справка по параметрам'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        itemCount: entries.length,
        itemBuilder: (context, index) => _HelpCard(
          help: entries[index],
          initiallyExpanded: focusedKey != null,
        ),
      ),
    );
  }
}

class _HelpCard extends StatelessWidget {
  final ParameterHelp help;
  final bool initiallyExpanded;

  const _HelpCard({required this.help, required this.initiallyExpanded});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ExpansionTile(
        title: Text(
          help.title,
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            help.summary,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        initiallyExpanded: initiallyExpanded,
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          for (final section in help.sections) _HelpSectionView(section: section),
        ],
      ),
    );
  }
}

class _HelpSectionView extends StatelessWidget {
  final HelpSection section;

  const _HelpSectionView({required this.section});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            section.title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 6),
          if (section.text != null) Text(section.text!, style: theme.textTheme.bodyMedium),
          if (section.ranges != null) ...[
            const SizedBox(height: 4),
            for (final range in section.ranges!) _RangeRow(range: range),
          ],
        ],
      ),
    );
  }
}

class _RangeRow extends StatelessWidget {
  final HelpRange range;

  const _RangeRow({required this.range});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6,
            margin: const EdgeInsets.only(top: 4, right: 12),
            height: 36,
            decoration: BoxDecoration(
              color: range.color,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      range.label,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      range.range,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
                Text(
                  range.note,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
