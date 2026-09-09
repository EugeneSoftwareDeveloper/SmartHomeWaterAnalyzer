import '../l10n/generated/app_localizations.dart';

/// Каталог, который создаётся при первом запуске и при переезде плоских мест
/// в иерархию.
///
/// Приходит извне, а не лежит константой в базе, потому что это **данные**, а
/// не подписи интерфейса: замер хранит имя источника, и однажды записанное
/// «Кран на кухне» останется в истории навсегда. Перевести его задним числом
/// уже нельзя — значит, раздать имена нужно один раз и сразу на языке
/// пользователя.
class CatalogSeed {
  /// Место, которое создаётся первым. «Дом» — самый вероятный вариант для
  /// первого объекта; переименовать его можно в один тап.
  final String siteName;

  /// Источники, которые предлагаются при первом запуске. Подобраны под реальные
  /// сценарии бытового тестера и профили норм: питьевая вода (кран / фильтр /
  /// кулер / бутилированная), автономные источники (скважина, колодец, родник),
  /// аквариум и бассейн. Лишние пользователь удалит, свои добавит.
  final List<String> sourceNames;

  const CatalogSeed({required this.siteName, required this.sourceNames});

  CatalogSeed.from(AppL10n l10n)
    : siteName = l10n.seedSiteHome,
      sourceNames = [
        l10n.seedSourceKitchenTap,
        l10n.seedSourceAfterFilter,
        l10n.seedSourceCooler,
        l10n.seedSourceBottled,
        l10n.seedSourceBorehole,
        l10n.seedSourceWell,
        l10n.seedSourceSpring,
        l10n.seedSourceAquarium,
        l10n.seedSourcePool,
      ];
}
