import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../location/location_service.dart';

/// Singleton [LocationService]. Состояния не имеет — вынесен в провайдер только
/// ради подмены в тестах через `overrideWithValue`.
final locationServiceProvider = Provider<LocationService>(
  (ref) => const LocationService(),
);
