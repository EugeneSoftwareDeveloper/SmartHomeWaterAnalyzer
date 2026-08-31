// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $MeasurementsTable extends Measurements
    with TableInfo<$MeasurementsTable, Measurement> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MeasurementsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _observedAtMeta = const VerificationMeta(
    'observedAt',
  );
  @override
  late final GeneratedColumn<DateTime> observedAt = GeneratedColumn<DateTime>(
    'observed_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _phMeta = const VerificationMeta('ph');
  @override
  late final GeneratedColumn<double> ph = GeneratedColumn<double>(
    'ph',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _electricalConductivityUsCmMeta =
      const VerificationMeta('electricalConductivityUsCm');
  @override
  late final GeneratedColumn<int> electricalConductivityUsCm =
      GeneratedColumn<int>(
        'electrical_conductivity_us_cm',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _totalDissolvedSolidsPpmMeta =
      const VerificationMeta('totalDissolvedSolidsPpm');
  @override
  late final GeneratedColumn<int> totalDissolvedSolidsPpm =
      GeneratedColumn<int>(
        'total_dissolved_solids_ppm',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _salinityPpmMeta = const VerificationMeta(
    'salinityPpm',
  );
  @override
  late final GeneratedColumn<int> salinityPpm = GeneratedColumn<int>(
    'salinity_ppm',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _salinityPercentMeta = const VerificationMeta(
    'salinityPercent',
  );
  @override
  late final GeneratedColumn<double> salinityPercent = GeneratedColumn<double>(
    'salinity_percent',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _temperatureCelsiusMeta =
      const VerificationMeta('temperatureCelsius');
  @override
  late final GeneratedColumn<double> temperatureCelsius =
      GeneratedColumn<double>(
        'temperature_celsius',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _specificGravityMeta = const VerificationMeta(
    'specificGravity',
  );
  @override
  late final GeneratedColumn<double> specificGravity = GeneratedColumn<double>(
    'specific_gravity',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _oxidationReductionPotentialMillivoltsMeta =
      const VerificationMeta('oxidationReductionPotentialMillivolts');
  @override
  late final GeneratedColumn<int> oxidationReductionPotentialMillivolts =
      GeneratedColumn<int>(
        'oxidation_reduction_potential_millivolts',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _batteryRawMillivoltsMeta =
      const VerificationMeta('batteryRawMillivolts');
  @override
  late final GeneratedColumn<int> batteryRawMillivolts = GeneratedColumn<int>(
    'battery_raw_millivolts',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _backlightOnMeta = const VerificationMeta(
    'backlightOn',
  );
  @override
  late final GeneratedColumn<bool> backlightOn = GeneratedColumn<bool>(
    'backlight_on',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("backlight_on" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _holdReadingOnMeta = const VerificationMeta(
    'holdReadingOn',
  );
  @override
  late final GeneratedColumn<bool> holdReadingOn = GeneratedColumn<bool>(
    'hold_reading_on',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("hold_reading_on" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _latitudeMeta = const VerificationMeta(
    'latitude',
  );
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
    'latitude',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _longitudeMeta = const VerificationMeta(
    'longitude',
  );
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
    'longitude',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _locationAccuracyMetersMeta =
      const VerificationMeta('locationAccuracyMeters');
  @override
  late final GeneratedColumn<double> locationAccuracyMeters =
      GeneratedColumn<double>(
        'location_accuracy_meters',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _normsProfileMeta = const VerificationMeta(
    'normsProfile',
  );
  @override
  late final GeneratedColumn<String> normsProfile = GeneratedColumn<String>(
    'norms_profile',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    deviceId,
    label,
    observedAt,
    ph,
    electricalConductivityUsCm,
    totalDissolvedSolidsPpm,
    salinityPpm,
    salinityPercent,
    temperatureCelsius,
    specificGravity,
    oxidationReductionPotentialMillivolts,
    batteryRawMillivolts,
    backlightOn,
    holdReadingOn,
    latitude,
    longitude,
    locationAccuracyMeters,
    normsProfile,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'measurements';
  @override
  VerificationContext validateIntegrity(
    Insertable<Measurement> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    }
    if (data.containsKey('observed_at')) {
      context.handle(
        _observedAtMeta,
        observedAt.isAcceptableOrUnknown(data['observed_at']!, _observedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_observedAtMeta);
    }
    if (data.containsKey('ph')) {
      context.handle(_phMeta, ph.isAcceptableOrUnknown(data['ph']!, _phMeta));
    } else if (isInserting) {
      context.missing(_phMeta);
    }
    if (data.containsKey('electrical_conductivity_us_cm')) {
      context.handle(
        _electricalConductivityUsCmMeta,
        electricalConductivityUsCm.isAcceptableOrUnknown(
          data['electrical_conductivity_us_cm']!,
          _electricalConductivityUsCmMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_electricalConductivityUsCmMeta);
    }
    if (data.containsKey('total_dissolved_solids_ppm')) {
      context.handle(
        _totalDissolvedSolidsPpmMeta,
        totalDissolvedSolidsPpm.isAcceptableOrUnknown(
          data['total_dissolved_solids_ppm']!,
          _totalDissolvedSolidsPpmMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_totalDissolvedSolidsPpmMeta);
    }
    if (data.containsKey('salinity_ppm')) {
      context.handle(
        _salinityPpmMeta,
        salinityPpm.isAcceptableOrUnknown(
          data['salinity_ppm']!,
          _salinityPpmMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_salinityPpmMeta);
    }
    if (data.containsKey('salinity_percent')) {
      context.handle(
        _salinityPercentMeta,
        salinityPercent.isAcceptableOrUnknown(
          data['salinity_percent']!,
          _salinityPercentMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_salinityPercentMeta);
    }
    if (data.containsKey('temperature_celsius')) {
      context.handle(
        _temperatureCelsiusMeta,
        temperatureCelsius.isAcceptableOrUnknown(
          data['temperature_celsius']!,
          _temperatureCelsiusMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_temperatureCelsiusMeta);
    }
    if (data.containsKey('specific_gravity')) {
      context.handle(
        _specificGravityMeta,
        specificGravity.isAcceptableOrUnknown(
          data['specific_gravity']!,
          _specificGravityMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_specificGravityMeta);
    }
    if (data.containsKey('oxidation_reduction_potential_millivolts')) {
      context.handle(
        _oxidationReductionPotentialMillivoltsMeta,
        oxidationReductionPotentialMillivolts.isAcceptableOrUnknown(
          data['oxidation_reduction_potential_millivolts']!,
          _oxidationReductionPotentialMillivoltsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_oxidationReductionPotentialMillivoltsMeta);
    }
    if (data.containsKey('battery_raw_millivolts')) {
      context.handle(
        _batteryRawMillivoltsMeta,
        batteryRawMillivolts.isAcceptableOrUnknown(
          data['battery_raw_millivolts']!,
          _batteryRawMillivoltsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_batteryRawMillivoltsMeta);
    }
    if (data.containsKey('backlight_on')) {
      context.handle(
        _backlightOnMeta,
        backlightOn.isAcceptableOrUnknown(
          data['backlight_on']!,
          _backlightOnMeta,
        ),
      );
    }
    if (data.containsKey('hold_reading_on')) {
      context.handle(
        _holdReadingOnMeta,
        holdReadingOn.isAcceptableOrUnknown(
          data['hold_reading_on']!,
          _holdReadingOnMeta,
        ),
      );
    }
    if (data.containsKey('latitude')) {
      context.handle(
        _latitudeMeta,
        latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta),
      );
    }
    if (data.containsKey('longitude')) {
      context.handle(
        _longitudeMeta,
        longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta),
      );
    }
    if (data.containsKey('location_accuracy_meters')) {
      context.handle(
        _locationAccuracyMetersMeta,
        locationAccuracyMeters.isAcceptableOrUnknown(
          data['location_accuracy_meters']!,
          _locationAccuracyMetersMeta,
        ),
      );
    }
    if (data.containsKey('norms_profile')) {
      context.handle(
        _normsProfileMeta,
        normsProfile.isAcceptableOrUnknown(
          data['norms_profile']!,
          _normsProfileMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Measurement map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Measurement(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      ),
      observedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}observed_at'],
      )!,
      ph: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}ph'],
      )!,
      electricalConductivityUsCm: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}electrical_conductivity_us_cm'],
      )!,
      totalDissolvedSolidsPpm: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_dissolved_solids_ppm'],
      )!,
      salinityPpm: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}salinity_ppm'],
      )!,
      salinityPercent: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}salinity_percent'],
      )!,
      temperatureCelsius: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}temperature_celsius'],
      )!,
      specificGravity: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}specific_gravity'],
      )!,
      oxidationReductionPotentialMillivolts: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}oxidation_reduction_potential_millivolts'],
      )!,
      batteryRawMillivolts: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}battery_raw_millivolts'],
      )!,
      backlightOn: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}backlight_on'],
      )!,
      holdReadingOn: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}hold_reading_on'],
      )!,
      latitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}latitude'],
      ),
      longitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}longitude'],
      ),
      locationAccuracyMeters: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}location_accuracy_meters'],
      ),
      normsProfile: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}norms_profile'],
      ),
    );
  }

  @override
  $MeasurementsTable createAlias(String alias) {
    return $MeasurementsTable(attachedDatabase, alias);
  }
}

class Measurement extends DataClass implements Insertable<Measurement> {
  final int id;

  /// BLE-remoteId прибора, который выдал кадр.
  final String deviceId;

  /// Пользовательский ярлык замера (например, «Москва, квартира»). Необязательно.
  final String? label;
  final DateTime observedAt;
  final double ph;
  final int electricalConductivityUsCm;
  final int totalDissolvedSolidsPpm;
  final int salinityPpm;
  final double salinityPercent;
  final double temperatureCelsius;
  final double specificGravity;
  final int oxidationReductionPotentialMillivolts;
  final int batteryRawMillivolts;
  final bool backlightOn;
  final bool holdReadingOn;

  /// Геометка замера — где физически находился телефон в момент сохранения.
  /// Nullable по трём причинам: пользователь мог выключить геометку в настройках,
  /// отказать в разрешении, или GPS не успел взять фикс (в помещении это норма).
  /// Отсутствие координат никогда не мешает сохранить замер.
  final double? latitude;
  final double? longitude;

  /// Радиус погрешности в метрах, как его сообщил геолокатор. Нужен, чтобы
  /// в UI не показывать «точку на карте» там, где на самом деле известен только
  /// район (по сети это сотни метров).
  final double? locationAccuracyMeters;

  /// Профиль норм, по которому замер оценивался в момент сохранения (имя
  /// значения `NormsProfile`).
  ///
  /// Хранится в самой записи, потому что «опасно / норма» — свойство замера, а
  /// не текущей настройки приложения. Без этого замер в бассейне, просмотренный
  /// после переключения профиля на питьевую воду, задним числом краснел бы.
  ///
  /// Nullable: у записей, сделанных до версии 1.2.0, профиль неизвестен — для
  /// них UI берёт текущий из настроек, то есть ведёт себя как раньше.
  final String? normsProfile;
  const Measurement({
    required this.id,
    required this.deviceId,
    this.label,
    required this.observedAt,
    required this.ph,
    required this.electricalConductivityUsCm,
    required this.totalDissolvedSolidsPpm,
    required this.salinityPpm,
    required this.salinityPercent,
    required this.temperatureCelsius,
    required this.specificGravity,
    required this.oxidationReductionPotentialMillivolts,
    required this.batteryRawMillivolts,
    required this.backlightOn,
    required this.holdReadingOn,
    this.latitude,
    this.longitude,
    this.locationAccuracyMeters,
    this.normsProfile,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['device_id'] = Variable<String>(deviceId);
    if (!nullToAbsent || label != null) {
      map['label'] = Variable<String>(label);
    }
    map['observed_at'] = Variable<DateTime>(observedAt);
    map['ph'] = Variable<double>(ph);
    map['electrical_conductivity_us_cm'] = Variable<int>(
      electricalConductivityUsCm,
    );
    map['total_dissolved_solids_ppm'] = Variable<int>(totalDissolvedSolidsPpm);
    map['salinity_ppm'] = Variable<int>(salinityPpm);
    map['salinity_percent'] = Variable<double>(salinityPercent);
    map['temperature_celsius'] = Variable<double>(temperatureCelsius);
    map['specific_gravity'] = Variable<double>(specificGravity);
    map['oxidation_reduction_potential_millivolts'] = Variable<int>(
      oxidationReductionPotentialMillivolts,
    );
    map['battery_raw_millivolts'] = Variable<int>(batteryRawMillivolts);
    map['backlight_on'] = Variable<bool>(backlightOn);
    map['hold_reading_on'] = Variable<bool>(holdReadingOn);
    if (!nullToAbsent || latitude != null) {
      map['latitude'] = Variable<double>(latitude);
    }
    if (!nullToAbsent || longitude != null) {
      map['longitude'] = Variable<double>(longitude);
    }
    if (!nullToAbsent || locationAccuracyMeters != null) {
      map['location_accuracy_meters'] = Variable<double>(
        locationAccuracyMeters,
      );
    }
    if (!nullToAbsent || normsProfile != null) {
      map['norms_profile'] = Variable<String>(normsProfile);
    }
    return map;
  }

  MeasurementsCompanion toCompanion(bool nullToAbsent) {
    return MeasurementsCompanion(
      id: Value(id),
      deviceId: Value(deviceId),
      label: label == null && nullToAbsent
          ? const Value.absent()
          : Value(label),
      observedAt: Value(observedAt),
      ph: Value(ph),
      electricalConductivityUsCm: Value(electricalConductivityUsCm),
      totalDissolvedSolidsPpm: Value(totalDissolvedSolidsPpm),
      salinityPpm: Value(salinityPpm),
      salinityPercent: Value(salinityPercent),
      temperatureCelsius: Value(temperatureCelsius),
      specificGravity: Value(specificGravity),
      oxidationReductionPotentialMillivolts: Value(
        oxidationReductionPotentialMillivolts,
      ),
      batteryRawMillivolts: Value(batteryRawMillivolts),
      backlightOn: Value(backlightOn),
      holdReadingOn: Value(holdReadingOn),
      latitude: latitude == null && nullToAbsent
          ? const Value.absent()
          : Value(latitude),
      longitude: longitude == null && nullToAbsent
          ? const Value.absent()
          : Value(longitude),
      locationAccuracyMeters: locationAccuracyMeters == null && nullToAbsent
          ? const Value.absent()
          : Value(locationAccuracyMeters),
      normsProfile: normsProfile == null && nullToAbsent
          ? const Value.absent()
          : Value(normsProfile),
    );
  }

  factory Measurement.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Measurement(
      id: serializer.fromJson<int>(json['id']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      label: serializer.fromJson<String?>(json['label']),
      observedAt: serializer.fromJson<DateTime>(json['observedAt']),
      ph: serializer.fromJson<double>(json['ph']),
      electricalConductivityUsCm: serializer.fromJson<int>(
        json['electricalConductivityUsCm'],
      ),
      totalDissolvedSolidsPpm: serializer.fromJson<int>(
        json['totalDissolvedSolidsPpm'],
      ),
      salinityPpm: serializer.fromJson<int>(json['salinityPpm']),
      salinityPercent: serializer.fromJson<double>(json['salinityPercent']),
      temperatureCelsius: serializer.fromJson<double>(
        json['temperatureCelsius'],
      ),
      specificGravity: serializer.fromJson<double>(json['specificGravity']),
      oxidationReductionPotentialMillivolts: serializer.fromJson<int>(
        json['oxidationReductionPotentialMillivolts'],
      ),
      batteryRawMillivolts: serializer.fromJson<int>(
        json['batteryRawMillivolts'],
      ),
      backlightOn: serializer.fromJson<bool>(json['backlightOn']),
      holdReadingOn: serializer.fromJson<bool>(json['holdReadingOn']),
      latitude: serializer.fromJson<double?>(json['latitude']),
      longitude: serializer.fromJson<double?>(json['longitude']),
      locationAccuracyMeters: serializer.fromJson<double?>(
        json['locationAccuracyMeters'],
      ),
      normsProfile: serializer.fromJson<String?>(json['normsProfile']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'deviceId': serializer.toJson<String>(deviceId),
      'label': serializer.toJson<String?>(label),
      'observedAt': serializer.toJson<DateTime>(observedAt),
      'ph': serializer.toJson<double>(ph),
      'electricalConductivityUsCm': serializer.toJson<int>(
        electricalConductivityUsCm,
      ),
      'totalDissolvedSolidsPpm': serializer.toJson<int>(
        totalDissolvedSolidsPpm,
      ),
      'salinityPpm': serializer.toJson<int>(salinityPpm),
      'salinityPercent': serializer.toJson<double>(salinityPercent),
      'temperatureCelsius': serializer.toJson<double>(temperatureCelsius),
      'specificGravity': serializer.toJson<double>(specificGravity),
      'oxidationReductionPotentialMillivolts': serializer.toJson<int>(
        oxidationReductionPotentialMillivolts,
      ),
      'batteryRawMillivolts': serializer.toJson<int>(batteryRawMillivolts),
      'backlightOn': serializer.toJson<bool>(backlightOn),
      'holdReadingOn': serializer.toJson<bool>(holdReadingOn),
      'latitude': serializer.toJson<double?>(latitude),
      'longitude': serializer.toJson<double?>(longitude),
      'locationAccuracyMeters': serializer.toJson<double?>(
        locationAccuracyMeters,
      ),
      'normsProfile': serializer.toJson<String?>(normsProfile),
    };
  }

  Measurement copyWith({
    int? id,
    String? deviceId,
    Value<String?> label = const Value.absent(),
    DateTime? observedAt,
    double? ph,
    int? electricalConductivityUsCm,
    int? totalDissolvedSolidsPpm,
    int? salinityPpm,
    double? salinityPercent,
    double? temperatureCelsius,
    double? specificGravity,
    int? oxidationReductionPotentialMillivolts,
    int? batteryRawMillivolts,
    bool? backlightOn,
    bool? holdReadingOn,
    Value<double?> latitude = const Value.absent(),
    Value<double?> longitude = const Value.absent(),
    Value<double?> locationAccuracyMeters = const Value.absent(),
    Value<String?> normsProfile = const Value.absent(),
  }) => Measurement(
    id: id ?? this.id,
    deviceId: deviceId ?? this.deviceId,
    label: label.present ? label.value : this.label,
    observedAt: observedAt ?? this.observedAt,
    ph: ph ?? this.ph,
    electricalConductivityUsCm:
        electricalConductivityUsCm ?? this.electricalConductivityUsCm,
    totalDissolvedSolidsPpm:
        totalDissolvedSolidsPpm ?? this.totalDissolvedSolidsPpm,
    salinityPpm: salinityPpm ?? this.salinityPpm,
    salinityPercent: salinityPercent ?? this.salinityPercent,
    temperatureCelsius: temperatureCelsius ?? this.temperatureCelsius,
    specificGravity: specificGravity ?? this.specificGravity,
    oxidationReductionPotentialMillivolts:
        oxidationReductionPotentialMillivolts ??
        this.oxidationReductionPotentialMillivolts,
    batteryRawMillivolts: batteryRawMillivolts ?? this.batteryRawMillivolts,
    backlightOn: backlightOn ?? this.backlightOn,
    holdReadingOn: holdReadingOn ?? this.holdReadingOn,
    latitude: latitude.present ? latitude.value : this.latitude,
    longitude: longitude.present ? longitude.value : this.longitude,
    locationAccuracyMeters: locationAccuracyMeters.present
        ? locationAccuracyMeters.value
        : this.locationAccuracyMeters,
    normsProfile: normsProfile.present ? normsProfile.value : this.normsProfile,
  );
  Measurement copyWithCompanion(MeasurementsCompanion data) {
    return Measurement(
      id: data.id.present ? data.id.value : this.id,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      label: data.label.present ? data.label.value : this.label,
      observedAt: data.observedAt.present
          ? data.observedAt.value
          : this.observedAt,
      ph: data.ph.present ? data.ph.value : this.ph,
      electricalConductivityUsCm: data.electricalConductivityUsCm.present
          ? data.electricalConductivityUsCm.value
          : this.electricalConductivityUsCm,
      totalDissolvedSolidsPpm: data.totalDissolvedSolidsPpm.present
          ? data.totalDissolvedSolidsPpm.value
          : this.totalDissolvedSolidsPpm,
      salinityPpm: data.salinityPpm.present
          ? data.salinityPpm.value
          : this.salinityPpm,
      salinityPercent: data.salinityPercent.present
          ? data.salinityPercent.value
          : this.salinityPercent,
      temperatureCelsius: data.temperatureCelsius.present
          ? data.temperatureCelsius.value
          : this.temperatureCelsius,
      specificGravity: data.specificGravity.present
          ? data.specificGravity.value
          : this.specificGravity,
      oxidationReductionPotentialMillivolts:
          data.oxidationReductionPotentialMillivolts.present
          ? data.oxidationReductionPotentialMillivolts.value
          : this.oxidationReductionPotentialMillivolts,
      batteryRawMillivolts: data.batteryRawMillivolts.present
          ? data.batteryRawMillivolts.value
          : this.batteryRawMillivolts,
      backlightOn: data.backlightOn.present
          ? data.backlightOn.value
          : this.backlightOn,
      holdReadingOn: data.holdReadingOn.present
          ? data.holdReadingOn.value
          : this.holdReadingOn,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      locationAccuracyMeters: data.locationAccuracyMeters.present
          ? data.locationAccuracyMeters.value
          : this.locationAccuracyMeters,
      normsProfile: data.normsProfile.present
          ? data.normsProfile.value
          : this.normsProfile,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Measurement(')
          ..write('id: $id, ')
          ..write('deviceId: $deviceId, ')
          ..write('label: $label, ')
          ..write('observedAt: $observedAt, ')
          ..write('ph: $ph, ')
          ..write('electricalConductivityUsCm: $electricalConductivityUsCm, ')
          ..write('totalDissolvedSolidsPpm: $totalDissolvedSolidsPpm, ')
          ..write('salinityPpm: $salinityPpm, ')
          ..write('salinityPercent: $salinityPercent, ')
          ..write('temperatureCelsius: $temperatureCelsius, ')
          ..write('specificGravity: $specificGravity, ')
          ..write(
            'oxidationReductionPotentialMillivolts: $oxidationReductionPotentialMillivolts, ',
          )
          ..write('batteryRawMillivolts: $batteryRawMillivolts, ')
          ..write('backlightOn: $backlightOn, ')
          ..write('holdReadingOn: $holdReadingOn, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('locationAccuracyMeters: $locationAccuracyMeters, ')
          ..write('normsProfile: $normsProfile')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    deviceId,
    label,
    observedAt,
    ph,
    electricalConductivityUsCm,
    totalDissolvedSolidsPpm,
    salinityPpm,
    salinityPercent,
    temperatureCelsius,
    specificGravity,
    oxidationReductionPotentialMillivolts,
    batteryRawMillivolts,
    backlightOn,
    holdReadingOn,
    latitude,
    longitude,
    locationAccuracyMeters,
    normsProfile,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Measurement &&
          other.id == this.id &&
          other.deviceId == this.deviceId &&
          other.label == this.label &&
          other.observedAt == this.observedAt &&
          other.ph == this.ph &&
          other.electricalConductivityUsCm == this.electricalConductivityUsCm &&
          other.totalDissolvedSolidsPpm == this.totalDissolvedSolidsPpm &&
          other.salinityPpm == this.salinityPpm &&
          other.salinityPercent == this.salinityPercent &&
          other.temperatureCelsius == this.temperatureCelsius &&
          other.specificGravity == this.specificGravity &&
          other.oxidationReductionPotentialMillivolts ==
              this.oxidationReductionPotentialMillivolts &&
          other.batteryRawMillivolts == this.batteryRawMillivolts &&
          other.backlightOn == this.backlightOn &&
          other.holdReadingOn == this.holdReadingOn &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.locationAccuracyMeters == this.locationAccuracyMeters &&
          other.normsProfile == this.normsProfile);
}

class MeasurementsCompanion extends UpdateCompanion<Measurement> {
  final Value<int> id;
  final Value<String> deviceId;
  final Value<String?> label;
  final Value<DateTime> observedAt;
  final Value<double> ph;
  final Value<int> electricalConductivityUsCm;
  final Value<int> totalDissolvedSolidsPpm;
  final Value<int> salinityPpm;
  final Value<double> salinityPercent;
  final Value<double> temperatureCelsius;
  final Value<double> specificGravity;
  final Value<int> oxidationReductionPotentialMillivolts;
  final Value<int> batteryRawMillivolts;
  final Value<bool> backlightOn;
  final Value<bool> holdReadingOn;
  final Value<double?> latitude;
  final Value<double?> longitude;
  final Value<double?> locationAccuracyMeters;
  final Value<String?> normsProfile;
  const MeasurementsCompanion({
    this.id = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.label = const Value.absent(),
    this.observedAt = const Value.absent(),
    this.ph = const Value.absent(),
    this.electricalConductivityUsCm = const Value.absent(),
    this.totalDissolvedSolidsPpm = const Value.absent(),
    this.salinityPpm = const Value.absent(),
    this.salinityPercent = const Value.absent(),
    this.temperatureCelsius = const Value.absent(),
    this.specificGravity = const Value.absent(),
    this.oxidationReductionPotentialMillivolts = const Value.absent(),
    this.batteryRawMillivolts = const Value.absent(),
    this.backlightOn = const Value.absent(),
    this.holdReadingOn = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.locationAccuracyMeters = const Value.absent(),
    this.normsProfile = const Value.absent(),
  });
  MeasurementsCompanion.insert({
    this.id = const Value.absent(),
    required String deviceId,
    this.label = const Value.absent(),
    required DateTime observedAt,
    required double ph,
    required int electricalConductivityUsCm,
    required int totalDissolvedSolidsPpm,
    required int salinityPpm,
    required double salinityPercent,
    required double temperatureCelsius,
    required double specificGravity,
    required int oxidationReductionPotentialMillivolts,
    required int batteryRawMillivolts,
    this.backlightOn = const Value.absent(),
    this.holdReadingOn = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.locationAccuracyMeters = const Value.absent(),
    this.normsProfile = const Value.absent(),
  }) : deviceId = Value(deviceId),
       observedAt = Value(observedAt),
       ph = Value(ph),
       electricalConductivityUsCm = Value(electricalConductivityUsCm),
       totalDissolvedSolidsPpm = Value(totalDissolvedSolidsPpm),
       salinityPpm = Value(salinityPpm),
       salinityPercent = Value(salinityPercent),
       temperatureCelsius = Value(temperatureCelsius),
       specificGravity = Value(specificGravity),
       oxidationReductionPotentialMillivolts = Value(
         oxidationReductionPotentialMillivolts,
       ),
       batteryRawMillivolts = Value(batteryRawMillivolts);
  static Insertable<Measurement> custom({
    Expression<int>? id,
    Expression<String>? deviceId,
    Expression<String>? label,
    Expression<DateTime>? observedAt,
    Expression<double>? ph,
    Expression<int>? electricalConductivityUsCm,
    Expression<int>? totalDissolvedSolidsPpm,
    Expression<int>? salinityPpm,
    Expression<double>? salinityPercent,
    Expression<double>? temperatureCelsius,
    Expression<double>? specificGravity,
    Expression<int>? oxidationReductionPotentialMillivolts,
    Expression<int>? batteryRawMillivolts,
    Expression<bool>? backlightOn,
    Expression<bool>? holdReadingOn,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<double>? locationAccuracyMeters,
    Expression<String>? normsProfile,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (deviceId != null) 'device_id': deviceId,
      if (label != null) 'label': label,
      if (observedAt != null) 'observed_at': observedAt,
      if (ph != null) 'ph': ph,
      if (electricalConductivityUsCm != null)
        'electrical_conductivity_us_cm': electricalConductivityUsCm,
      if (totalDissolvedSolidsPpm != null)
        'total_dissolved_solids_ppm': totalDissolvedSolidsPpm,
      if (salinityPpm != null) 'salinity_ppm': salinityPpm,
      if (salinityPercent != null) 'salinity_percent': salinityPercent,
      if (temperatureCelsius != null) 'temperature_celsius': temperatureCelsius,
      if (specificGravity != null) 'specific_gravity': specificGravity,
      if (oxidationReductionPotentialMillivolts != null)
        'oxidation_reduction_potential_millivolts':
            oxidationReductionPotentialMillivolts,
      if (batteryRawMillivolts != null)
        'battery_raw_millivolts': batteryRawMillivolts,
      if (backlightOn != null) 'backlight_on': backlightOn,
      if (holdReadingOn != null) 'hold_reading_on': holdReadingOn,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (locationAccuracyMeters != null)
        'location_accuracy_meters': locationAccuracyMeters,
      if (normsProfile != null) 'norms_profile': normsProfile,
    });
  }

  MeasurementsCompanion copyWith({
    Value<int>? id,
    Value<String>? deviceId,
    Value<String?>? label,
    Value<DateTime>? observedAt,
    Value<double>? ph,
    Value<int>? electricalConductivityUsCm,
    Value<int>? totalDissolvedSolidsPpm,
    Value<int>? salinityPpm,
    Value<double>? salinityPercent,
    Value<double>? temperatureCelsius,
    Value<double>? specificGravity,
    Value<int>? oxidationReductionPotentialMillivolts,
    Value<int>? batteryRawMillivolts,
    Value<bool>? backlightOn,
    Value<bool>? holdReadingOn,
    Value<double?>? latitude,
    Value<double?>? longitude,
    Value<double?>? locationAccuracyMeters,
    Value<String?>? normsProfile,
  }) {
    return MeasurementsCompanion(
      id: id ?? this.id,
      deviceId: deviceId ?? this.deviceId,
      label: label ?? this.label,
      observedAt: observedAt ?? this.observedAt,
      ph: ph ?? this.ph,
      electricalConductivityUsCm:
          electricalConductivityUsCm ?? this.electricalConductivityUsCm,
      totalDissolvedSolidsPpm:
          totalDissolvedSolidsPpm ?? this.totalDissolvedSolidsPpm,
      salinityPpm: salinityPpm ?? this.salinityPpm,
      salinityPercent: salinityPercent ?? this.salinityPercent,
      temperatureCelsius: temperatureCelsius ?? this.temperatureCelsius,
      specificGravity: specificGravity ?? this.specificGravity,
      oxidationReductionPotentialMillivolts:
          oxidationReductionPotentialMillivolts ??
          this.oxidationReductionPotentialMillivolts,
      batteryRawMillivolts: batteryRawMillivolts ?? this.batteryRawMillivolts,
      backlightOn: backlightOn ?? this.backlightOn,
      holdReadingOn: holdReadingOn ?? this.holdReadingOn,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      locationAccuracyMeters:
          locationAccuracyMeters ?? this.locationAccuracyMeters,
      normsProfile: normsProfile ?? this.normsProfile,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (observedAt.present) {
      map['observed_at'] = Variable<DateTime>(observedAt.value);
    }
    if (ph.present) {
      map['ph'] = Variable<double>(ph.value);
    }
    if (electricalConductivityUsCm.present) {
      map['electrical_conductivity_us_cm'] = Variable<int>(
        electricalConductivityUsCm.value,
      );
    }
    if (totalDissolvedSolidsPpm.present) {
      map['total_dissolved_solids_ppm'] = Variable<int>(
        totalDissolvedSolidsPpm.value,
      );
    }
    if (salinityPpm.present) {
      map['salinity_ppm'] = Variable<int>(salinityPpm.value);
    }
    if (salinityPercent.present) {
      map['salinity_percent'] = Variable<double>(salinityPercent.value);
    }
    if (temperatureCelsius.present) {
      map['temperature_celsius'] = Variable<double>(temperatureCelsius.value);
    }
    if (specificGravity.present) {
      map['specific_gravity'] = Variable<double>(specificGravity.value);
    }
    if (oxidationReductionPotentialMillivolts.present) {
      map['oxidation_reduction_potential_millivolts'] = Variable<int>(
        oxidationReductionPotentialMillivolts.value,
      );
    }
    if (batteryRawMillivolts.present) {
      map['battery_raw_millivolts'] = Variable<int>(batteryRawMillivolts.value);
    }
    if (backlightOn.present) {
      map['backlight_on'] = Variable<bool>(backlightOn.value);
    }
    if (holdReadingOn.present) {
      map['hold_reading_on'] = Variable<bool>(holdReadingOn.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (locationAccuracyMeters.present) {
      map['location_accuracy_meters'] = Variable<double>(
        locationAccuracyMeters.value,
      );
    }
    if (normsProfile.present) {
      map['norms_profile'] = Variable<String>(normsProfile.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MeasurementsCompanion(')
          ..write('id: $id, ')
          ..write('deviceId: $deviceId, ')
          ..write('label: $label, ')
          ..write('observedAt: $observedAt, ')
          ..write('ph: $ph, ')
          ..write('electricalConductivityUsCm: $electricalConductivityUsCm, ')
          ..write('totalDissolvedSolidsPpm: $totalDissolvedSolidsPpm, ')
          ..write('salinityPpm: $salinityPpm, ')
          ..write('salinityPercent: $salinityPercent, ')
          ..write('temperatureCelsius: $temperatureCelsius, ')
          ..write('specificGravity: $specificGravity, ')
          ..write(
            'oxidationReductionPotentialMillivolts: $oxidationReductionPotentialMillivolts, ',
          )
          ..write('batteryRawMillivolts: $batteryRawMillivolts, ')
          ..write('backlightOn: $backlightOn, ')
          ..write('holdReadingOn: $holdReadingOn, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('locationAccuracyMeters: $locationAccuracyMeters, ')
          ..write('normsProfile: $normsProfile')
          ..write(')'))
        .toString();
  }
}

class $PlacesTable extends Places with TableInfo<$PlacesTable, Place> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlacesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastUsedAtMeta = const VerificationMeta(
    'lastUsedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastUsedAt = GeneratedColumn<DateTime>(
    'last_used_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, createdAt, lastUsedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'places';
  @override
  VerificationContext validateIntegrity(
    Insertable<Place> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('last_used_at')) {
      context.handle(
        _lastUsedAtMeta,
        lastUsedAt.isAcceptableOrUnknown(
          data['last_used_at']!,
          _lastUsedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Place map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Place(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      lastUsedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_used_at'],
      ),
    );
  }

  @override
  $PlacesTable createAlias(String alias) {
    return $PlacesTable(attachedDatabase, alias);
  }
}

class Place extends DataClass implements Insertable<Place> {
  final int id;

  /// Название места. Уникально — два одинаковых пункта в списке выбора бессмысленны.
  final String name;
  final DateTime createdAt;

  /// Когда местом пользовались в последний раз. Недавние поднимаются в начало
  /// списка выбора: на практике человек меряет 2-3 точки, остальные — редкий хвост.
  final DateTime? lastUsedAt;
  const Place({
    required this.id,
    required this.name,
    required this.createdAt,
    this.lastUsedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || lastUsedAt != null) {
      map['last_used_at'] = Variable<DateTime>(lastUsedAt);
    }
    return map;
  }

  PlacesCompanion toCompanion(bool nullToAbsent) {
    return PlacesCompanion(
      id: Value(id),
      name: Value(name),
      createdAt: Value(createdAt),
      lastUsedAt: lastUsedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastUsedAt),
    );
  }

  factory Place.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Place(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      lastUsedAt: serializer.fromJson<DateTime?>(json['lastUsedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'lastUsedAt': serializer.toJson<DateTime?>(lastUsedAt),
    };
  }

  Place copyWith({
    int? id,
    String? name,
    DateTime? createdAt,
    Value<DateTime?> lastUsedAt = const Value.absent(),
  }) => Place(
    id: id ?? this.id,
    name: name ?? this.name,
    createdAt: createdAt ?? this.createdAt,
    lastUsedAt: lastUsedAt.present ? lastUsedAt.value : this.lastUsedAt,
  );
  Place copyWithCompanion(PlacesCompanion data) {
    return Place(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      lastUsedAt: data.lastUsedAt.present
          ? data.lastUsedAt.value
          : this.lastUsedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Place(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastUsedAt: $lastUsedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, createdAt, lastUsedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Place &&
          other.id == this.id &&
          other.name == this.name &&
          other.createdAt == this.createdAt &&
          other.lastUsedAt == this.lastUsedAt);
}

class PlacesCompanion extends UpdateCompanion<Place> {
  final Value<int> id;
  final Value<String> name;
  final Value<DateTime> createdAt;
  final Value<DateTime?> lastUsedAt;
  const PlacesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.lastUsedAt = const Value.absent(),
  });
  PlacesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required DateTime createdAt,
    this.lastUsedAt = const Value.absent(),
  }) : name = Value(name),
       createdAt = Value(createdAt);
  static Insertable<Place> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? lastUsedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (createdAt != null) 'created_at': createdAt,
      if (lastUsedAt != null) 'last_used_at': lastUsedAt,
    });
  }

  PlacesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<DateTime>? createdAt,
    Value<DateTime?>? lastUsedAt,
  }) {
    return PlacesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      lastUsedAt: lastUsedAt ?? this.lastUsedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (lastUsedAt.present) {
      map['last_used_at'] = Variable<DateTime>(lastUsedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlacesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastUsedAt: $lastUsedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $MeasurementsTable measurements = $MeasurementsTable(this);
  late final $PlacesTable places = $PlacesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [measurements, places];
}

typedef $$MeasurementsTableCreateCompanionBuilder =
    MeasurementsCompanion Function({
      Value<int> id,
      required String deviceId,
      Value<String?> label,
      required DateTime observedAt,
      required double ph,
      required int electricalConductivityUsCm,
      required int totalDissolvedSolidsPpm,
      required int salinityPpm,
      required double salinityPercent,
      required double temperatureCelsius,
      required double specificGravity,
      required int oxidationReductionPotentialMillivolts,
      required int batteryRawMillivolts,
      Value<bool> backlightOn,
      Value<bool> holdReadingOn,
      Value<double?> latitude,
      Value<double?> longitude,
      Value<double?> locationAccuracyMeters,
      Value<String?> normsProfile,
    });
typedef $$MeasurementsTableUpdateCompanionBuilder =
    MeasurementsCompanion Function({
      Value<int> id,
      Value<String> deviceId,
      Value<String?> label,
      Value<DateTime> observedAt,
      Value<double> ph,
      Value<int> electricalConductivityUsCm,
      Value<int> totalDissolvedSolidsPpm,
      Value<int> salinityPpm,
      Value<double> salinityPercent,
      Value<double> temperatureCelsius,
      Value<double> specificGravity,
      Value<int> oxidationReductionPotentialMillivolts,
      Value<int> batteryRawMillivolts,
      Value<bool> backlightOn,
      Value<bool> holdReadingOn,
      Value<double?> latitude,
      Value<double?> longitude,
      Value<double?> locationAccuracyMeters,
      Value<String?> normsProfile,
    });

class $$MeasurementsTableFilterComposer
    extends Composer<_$AppDatabase, $MeasurementsTable> {
  $$MeasurementsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get observedAt => $composableBuilder(
    column: $table.observedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get ph => $composableBuilder(
    column: $table.ph,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get electricalConductivityUsCm => $composableBuilder(
    column: $table.electricalConductivityUsCm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalDissolvedSolidsPpm => $composableBuilder(
    column: $table.totalDissolvedSolidsPpm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get salinityPpm => $composableBuilder(
    column: $table.salinityPpm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get salinityPercent => $composableBuilder(
    column: $table.salinityPercent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get temperatureCelsius => $composableBuilder(
    column: $table.temperatureCelsius,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get specificGravity => $composableBuilder(
    column: $table.specificGravity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get oxidationReductionPotentialMillivolts =>
      $composableBuilder(
        column: $table.oxidationReductionPotentialMillivolts,
        builder: (column) => ColumnFilters(column),
      );

  ColumnFilters<int> get batteryRawMillivolts => $composableBuilder(
    column: $table.batteryRawMillivolts,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get backlightOn => $composableBuilder(
    column: $table.backlightOn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get holdReadingOn => $composableBuilder(
    column: $table.holdReadingOn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get locationAccuracyMeters => $composableBuilder(
    column: $table.locationAccuracyMeters,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get normsProfile => $composableBuilder(
    column: $table.normsProfile,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MeasurementsTableOrderingComposer
    extends Composer<_$AppDatabase, $MeasurementsTable> {
  $$MeasurementsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get observedAt => $composableBuilder(
    column: $table.observedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get ph => $composableBuilder(
    column: $table.ph,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get electricalConductivityUsCm => $composableBuilder(
    column: $table.electricalConductivityUsCm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalDissolvedSolidsPpm => $composableBuilder(
    column: $table.totalDissolvedSolidsPpm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get salinityPpm => $composableBuilder(
    column: $table.salinityPpm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get salinityPercent => $composableBuilder(
    column: $table.salinityPercent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get temperatureCelsius => $composableBuilder(
    column: $table.temperatureCelsius,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get specificGravity => $composableBuilder(
    column: $table.specificGravity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get oxidationReductionPotentialMillivolts =>
      $composableBuilder(
        column: $table.oxidationReductionPotentialMillivolts,
        builder: (column) => ColumnOrderings(column),
      );

  ColumnOrderings<int> get batteryRawMillivolts => $composableBuilder(
    column: $table.batteryRawMillivolts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get backlightOn => $composableBuilder(
    column: $table.backlightOn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get holdReadingOn => $composableBuilder(
    column: $table.holdReadingOn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get locationAccuracyMeters => $composableBuilder(
    column: $table.locationAccuracyMeters,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get normsProfile => $composableBuilder(
    column: $table.normsProfile,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MeasurementsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MeasurementsTable> {
  $$MeasurementsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<DateTime> get observedAt => $composableBuilder(
    column: $table.observedAt,
    builder: (column) => column,
  );

  GeneratedColumn<double> get ph =>
      $composableBuilder(column: $table.ph, builder: (column) => column);

  GeneratedColumn<int> get electricalConductivityUsCm => $composableBuilder(
    column: $table.electricalConductivityUsCm,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalDissolvedSolidsPpm => $composableBuilder(
    column: $table.totalDissolvedSolidsPpm,
    builder: (column) => column,
  );

  GeneratedColumn<int> get salinityPpm => $composableBuilder(
    column: $table.salinityPpm,
    builder: (column) => column,
  );

  GeneratedColumn<double> get salinityPercent => $composableBuilder(
    column: $table.salinityPercent,
    builder: (column) => column,
  );

  GeneratedColumn<double> get temperatureCelsius => $composableBuilder(
    column: $table.temperatureCelsius,
    builder: (column) => column,
  );

  GeneratedColumn<double> get specificGravity => $composableBuilder(
    column: $table.specificGravity,
    builder: (column) => column,
  );

  GeneratedColumn<int> get oxidationReductionPotentialMillivolts =>
      $composableBuilder(
        column: $table.oxidationReductionPotentialMillivolts,
        builder: (column) => column,
      );

  GeneratedColumn<int> get batteryRawMillivolts => $composableBuilder(
    column: $table.batteryRawMillivolts,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get backlightOn => $composableBuilder(
    column: $table.backlightOn,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get holdReadingOn => $composableBuilder(
    column: $table.holdReadingOn,
    builder: (column) => column,
  );

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumn<double> get locationAccuracyMeters => $composableBuilder(
    column: $table.locationAccuracyMeters,
    builder: (column) => column,
  );

  GeneratedColumn<String> get normsProfile => $composableBuilder(
    column: $table.normsProfile,
    builder: (column) => column,
  );
}

class $$MeasurementsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MeasurementsTable,
          Measurement,
          $$MeasurementsTableFilterComposer,
          $$MeasurementsTableOrderingComposer,
          $$MeasurementsTableAnnotationComposer,
          $$MeasurementsTableCreateCompanionBuilder,
          $$MeasurementsTableUpdateCompanionBuilder,
          (
            Measurement,
            BaseReferences<_$AppDatabase, $MeasurementsTable, Measurement>,
          ),
          Measurement,
          PrefetchHooks Function()
        > {
  $$MeasurementsTableTableManager(_$AppDatabase db, $MeasurementsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MeasurementsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MeasurementsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MeasurementsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<String?> label = const Value.absent(),
                Value<DateTime> observedAt = const Value.absent(),
                Value<double> ph = const Value.absent(),
                Value<int> electricalConductivityUsCm = const Value.absent(),
                Value<int> totalDissolvedSolidsPpm = const Value.absent(),
                Value<int> salinityPpm = const Value.absent(),
                Value<double> salinityPercent = const Value.absent(),
                Value<double> temperatureCelsius = const Value.absent(),
                Value<double> specificGravity = const Value.absent(),
                Value<int> oxidationReductionPotentialMillivolts =
                    const Value.absent(),
                Value<int> batteryRawMillivolts = const Value.absent(),
                Value<bool> backlightOn = const Value.absent(),
                Value<bool> holdReadingOn = const Value.absent(),
                Value<double?> latitude = const Value.absent(),
                Value<double?> longitude = const Value.absent(),
                Value<double?> locationAccuracyMeters = const Value.absent(),
                Value<String?> normsProfile = const Value.absent(),
              }) => MeasurementsCompanion(
                id: id,
                deviceId: deviceId,
                label: label,
                observedAt: observedAt,
                ph: ph,
                electricalConductivityUsCm: electricalConductivityUsCm,
                totalDissolvedSolidsPpm: totalDissolvedSolidsPpm,
                salinityPpm: salinityPpm,
                salinityPercent: salinityPercent,
                temperatureCelsius: temperatureCelsius,
                specificGravity: specificGravity,
                oxidationReductionPotentialMillivolts:
                    oxidationReductionPotentialMillivolts,
                batteryRawMillivolts: batteryRawMillivolts,
                backlightOn: backlightOn,
                holdReadingOn: holdReadingOn,
                latitude: latitude,
                longitude: longitude,
                locationAccuracyMeters: locationAccuracyMeters,
                normsProfile: normsProfile,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String deviceId,
                Value<String?> label = const Value.absent(),
                required DateTime observedAt,
                required double ph,
                required int electricalConductivityUsCm,
                required int totalDissolvedSolidsPpm,
                required int salinityPpm,
                required double salinityPercent,
                required double temperatureCelsius,
                required double specificGravity,
                required int oxidationReductionPotentialMillivolts,
                required int batteryRawMillivolts,
                Value<bool> backlightOn = const Value.absent(),
                Value<bool> holdReadingOn = const Value.absent(),
                Value<double?> latitude = const Value.absent(),
                Value<double?> longitude = const Value.absent(),
                Value<double?> locationAccuracyMeters = const Value.absent(),
                Value<String?> normsProfile = const Value.absent(),
              }) => MeasurementsCompanion.insert(
                id: id,
                deviceId: deviceId,
                label: label,
                observedAt: observedAt,
                ph: ph,
                electricalConductivityUsCm: electricalConductivityUsCm,
                totalDissolvedSolidsPpm: totalDissolvedSolidsPpm,
                salinityPpm: salinityPpm,
                salinityPercent: salinityPercent,
                temperatureCelsius: temperatureCelsius,
                specificGravity: specificGravity,
                oxidationReductionPotentialMillivolts:
                    oxidationReductionPotentialMillivolts,
                batteryRawMillivolts: batteryRawMillivolts,
                backlightOn: backlightOn,
                holdReadingOn: holdReadingOn,
                latitude: latitude,
                longitude: longitude,
                locationAccuracyMeters: locationAccuracyMeters,
                normsProfile: normsProfile,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MeasurementsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MeasurementsTable,
      Measurement,
      $$MeasurementsTableFilterComposer,
      $$MeasurementsTableOrderingComposer,
      $$MeasurementsTableAnnotationComposer,
      $$MeasurementsTableCreateCompanionBuilder,
      $$MeasurementsTableUpdateCompanionBuilder,
      (
        Measurement,
        BaseReferences<_$AppDatabase, $MeasurementsTable, Measurement>,
      ),
      Measurement,
      PrefetchHooks Function()
    >;
typedef $$PlacesTableCreateCompanionBuilder =
    PlacesCompanion Function({
      Value<int> id,
      required String name,
      required DateTime createdAt,
      Value<DateTime?> lastUsedAt,
    });
typedef $$PlacesTableUpdateCompanionBuilder =
    PlacesCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<DateTime> createdAt,
      Value<DateTime?> lastUsedAt,
    });

class $$PlacesTableFilterComposer
    extends Composer<_$AppDatabase, $PlacesTable> {
  $$PlacesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastUsedAt => $composableBuilder(
    column: $table.lastUsedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PlacesTableOrderingComposer
    extends Composer<_$AppDatabase, $PlacesTable> {
  $$PlacesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastUsedAt => $composableBuilder(
    column: $table.lastUsedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PlacesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlacesTable> {
  $$PlacesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastUsedAt => $composableBuilder(
    column: $table.lastUsedAt,
    builder: (column) => column,
  );
}

class $$PlacesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlacesTable,
          Place,
          $$PlacesTableFilterComposer,
          $$PlacesTableOrderingComposer,
          $$PlacesTableAnnotationComposer,
          $$PlacesTableCreateCompanionBuilder,
          $$PlacesTableUpdateCompanionBuilder,
          (Place, BaseReferences<_$AppDatabase, $PlacesTable, Place>),
          Place,
          PrefetchHooks Function()
        > {
  $$PlacesTableTableManager(_$AppDatabase db, $PlacesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlacesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlacesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlacesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> lastUsedAt = const Value.absent(),
              }) => PlacesCompanion(
                id: id,
                name: name,
                createdAt: createdAt,
                lastUsedAt: lastUsedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required DateTime createdAt,
                Value<DateTime?> lastUsedAt = const Value.absent(),
              }) => PlacesCompanion.insert(
                id: id,
                name: name,
                createdAt: createdAt,
                lastUsedAt: lastUsedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PlacesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlacesTable,
      Place,
      $$PlacesTableFilterComposer,
      $$PlacesTableOrderingComposer,
      $$PlacesTableAnnotationComposer,
      $$PlacesTableCreateCompanionBuilder,
      $$PlacesTableUpdateCompanionBuilder,
      (Place, BaseReferences<_$AppDatabase, $PlacesTable, Place>),
      Place,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$MeasurementsTableTableManager get measurements =>
      $$MeasurementsTableTableManager(_db, _db.measurements);
  $$PlacesTableTableManager get places =>
      $$PlacesTableTableManager(_db, _db.places);
}
