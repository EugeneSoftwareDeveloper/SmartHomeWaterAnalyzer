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
  static const VerificationMeta _siteNameMeta = const VerificationMeta(
    'siteName',
  );
  @override
  late final GeneratedColumn<String> siteName = GeneratedColumn<String>(
    'site_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _roomNameMeta = const VerificationMeta(
    'roomName',
  );
  @override
  late final GeneratedColumn<String> roomName = GeneratedColumn<String>(
    'room_name',
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
    siteName,
    roomName,
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
    if (data.containsKey('site_name')) {
      context.handle(
        _siteNameMeta,
        siteName.isAcceptableOrUnknown(data['site_name']!, _siteNameMeta),
      );
    }
    if (data.containsKey('room_name')) {
      context.handle(
        _roomNameMeta,
        roomName.isAcceptableOrUnknown(data['room_name']!, _roomNameMeta),
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
      siteName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}site_name'],
      ),
      roomName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}room_name'],
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

  /// Имя места (дом, дача, квартира), где сделан замер.
  ///
  /// Nullable по двум причинам сразу: у записей до версии 1.4.0 иерархии не было
  /// вовсе, и `null` здесь — признак «доиерархической» записи, по которому
  /// поиск базы тренда узнаёт старые замеры. Кроме того, замер можно сохранить
  /// вообще без выбранного источника.
  ///
  /// Как и [label], хранит **имя**, а не ссылку: переименование места не должно
  /// переписывать историю задним числом.
  final String? siteName;

  /// Имя комнаты внутри места. `null` — источник висит прямо на месте
  /// («Дача · Скважина»), это штатная ситуация, а не отсутствие данных:
  /// комната — необязательный уровень.
  final String? roomName;
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
    this.siteName,
    this.roomName,
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
    if (!nullToAbsent || siteName != null) {
      map['site_name'] = Variable<String>(siteName);
    }
    if (!nullToAbsent || roomName != null) {
      map['room_name'] = Variable<String>(roomName);
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
      siteName: siteName == null && nullToAbsent
          ? const Value.absent()
          : Value(siteName),
      roomName: roomName == null && nullToAbsent
          ? const Value.absent()
          : Value(roomName),
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
      siteName: serializer.fromJson<String?>(json['siteName']),
      roomName: serializer.fromJson<String?>(json['roomName']),
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
      'siteName': serializer.toJson<String?>(siteName),
      'roomName': serializer.toJson<String?>(roomName),
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
    Value<String?> siteName = const Value.absent(),
    Value<String?> roomName = const Value.absent(),
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
    siteName: siteName.present ? siteName.value : this.siteName,
    roomName: roomName.present ? roomName.value : this.roomName,
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
      siteName: data.siteName.present ? data.siteName.value : this.siteName,
      roomName: data.roomName.present ? data.roomName.value : this.roomName,
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
          ..write('normsProfile: $normsProfile, ')
          ..write('siteName: $siteName, ')
          ..write('roomName: $roomName')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
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
    siteName,
    roomName,
  ]);
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
          other.normsProfile == this.normsProfile &&
          other.siteName == this.siteName &&
          other.roomName == this.roomName);
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
  final Value<String?> siteName;
  final Value<String?> roomName;
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
    this.siteName = const Value.absent(),
    this.roomName = const Value.absent(),
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
    this.siteName = const Value.absent(),
    this.roomName = const Value.absent(),
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
    Expression<String>? siteName,
    Expression<String>? roomName,
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
      if (siteName != null) 'site_name': siteName,
      if (roomName != null) 'room_name': roomName,
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
    Value<String?>? siteName,
    Value<String?>? roomName,
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
      siteName: siteName ?? this.siteName,
      roomName: roomName ?? this.roomName,
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
    if (siteName.present) {
      map['site_name'] = Variable<String>(siteName.value);
    }
    if (roomName.present) {
      map['room_name'] = Variable<String>(roomName.value);
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
          ..write('normsProfile: $normsProfile, ')
          ..write('siteName: $siteName, ')
          ..write('roomName: $roomName')
          ..write(')'))
        .toString();
  }
}

class $SitesTable extends Sites with TableInfo<$SitesTable, Site> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SitesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _cityMeta = const VerificationMeta('city');
  @override
  late final GeneratedColumn<String> city = GeneratedColumn<String>(
    'city',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
  static const VerificationMeta _anchorAccuracyMetersMeta =
      const VerificationMeta('anchorAccuracyMeters');
  @override
  late final GeneratedColumn<double> anchorAccuracyMeters =
      GeneratedColumn<double>(
        'anchor_accuracy_meters',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _anchorSamplesMeta = const VerificationMeta(
    'anchorSamples',
  );
  @override
  late final GeneratedColumn<int> anchorSamples = GeneratedColumn<int>(
    'anchor_samples',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _radiusMetersMeta = const VerificationMeta(
    'radiusMeters',
  );
  @override
  late final GeneratedColumn<double> radiusMeters = GeneratedColumn<double>(
    'radius_meters',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(150),
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
  List<GeneratedColumn> get $columns => [
    id,
    name,
    city,
    latitude,
    longitude,
    anchorAccuracyMeters,
    anchorSamples,
    radiusMeters,
    createdAt,
    lastUsedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sites';
  @override
  VerificationContext validateIntegrity(
    Insertable<Site> instance, {
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
    if (data.containsKey('city')) {
      context.handle(
        _cityMeta,
        city.isAcceptableOrUnknown(data['city']!, _cityMeta),
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
    if (data.containsKey('anchor_accuracy_meters')) {
      context.handle(
        _anchorAccuracyMetersMeta,
        anchorAccuracyMeters.isAcceptableOrUnknown(
          data['anchor_accuracy_meters']!,
          _anchorAccuracyMetersMeta,
        ),
      );
    }
    if (data.containsKey('anchor_samples')) {
      context.handle(
        _anchorSamplesMeta,
        anchorSamples.isAcceptableOrUnknown(
          data['anchor_samples']!,
          _anchorSamplesMeta,
        ),
      );
    }
    if (data.containsKey('radius_meters')) {
      context.handle(
        _radiusMetersMeta,
        radiusMeters.isAcceptableOrUnknown(
          data['radius_meters']!,
          _radiusMetersMeta,
        ),
      );
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
  Site map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Site(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      city: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}city'],
      ),
      latitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}latitude'],
      ),
      longitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}longitude'],
      ),
      anchorAccuracyMeters: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}anchor_accuracy_meters'],
      ),
      anchorSamples: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}anchor_samples'],
      )!,
      radiusMeters: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}radius_meters'],
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
  $SitesTable createAlias(String alias) {
    return $SitesTable(attachedDatabase, alias);
  }
}

class Site extends DataClass implements Insertable<Site> {
  final int id;

  /// Название места. Уникально — два «Дома» в списке выбора бессмысленны.
  final String name;

  /// Город. Нужен, чтобы различать одинаково названные места («Дом» в двух
  /// городах) в списке выбора; на логику не влияет.
  final String? city;

  /// Якорь привязки — точка, к которой место считается «рядом».
  ///
  /// Nullable: место без якоря просто не участвует в автовыборе. Якорь
  /// появляется либо из первого сохранённого здесь замера, либо вручную.
  final double? latitude;
  final double? longitude;

  /// Точность якоря в метрах — взвешенная по вкладам фиксов, из которых он
  /// сложился. Хранится, чтобы новые фиксы уточняли якорь тем сильнее, чем они
  /// точнее: фикс по сети с погрешностью 500 м не должен сдвигать якорь так же,
  /// как фикс по спутникам с погрешностью 5 м.
  final double? anchorAccuracyMeters;

  /// Сколько фиксов уже вошло в якорь. Ноль означает «якоря нет».
  final int anchorSamples;

  /// Радиус, в пределах которого координаты считаются принадлежащими этому месту.
  /// Дефолт покрывает участок с постройками и типичную городскую погрешность.
  final double radiusMeters;
  final DateTime createdAt;

  /// Когда местом пользовались в последний раз — недавние поднимаются в начало.
  final DateTime? lastUsedAt;
  const Site({
    required this.id,
    required this.name,
    this.city,
    this.latitude,
    this.longitude,
    this.anchorAccuracyMeters,
    required this.anchorSamples,
    required this.radiusMeters,
    required this.createdAt,
    this.lastUsedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || city != null) {
      map['city'] = Variable<String>(city);
    }
    if (!nullToAbsent || latitude != null) {
      map['latitude'] = Variable<double>(latitude);
    }
    if (!nullToAbsent || longitude != null) {
      map['longitude'] = Variable<double>(longitude);
    }
    if (!nullToAbsent || anchorAccuracyMeters != null) {
      map['anchor_accuracy_meters'] = Variable<double>(anchorAccuracyMeters);
    }
    map['anchor_samples'] = Variable<int>(anchorSamples);
    map['radius_meters'] = Variable<double>(radiusMeters);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || lastUsedAt != null) {
      map['last_used_at'] = Variable<DateTime>(lastUsedAt);
    }
    return map;
  }

  SitesCompanion toCompanion(bool nullToAbsent) {
    return SitesCompanion(
      id: Value(id),
      name: Value(name),
      city: city == null && nullToAbsent ? const Value.absent() : Value(city),
      latitude: latitude == null && nullToAbsent
          ? const Value.absent()
          : Value(latitude),
      longitude: longitude == null && nullToAbsent
          ? const Value.absent()
          : Value(longitude),
      anchorAccuracyMeters: anchorAccuracyMeters == null && nullToAbsent
          ? const Value.absent()
          : Value(anchorAccuracyMeters),
      anchorSamples: Value(anchorSamples),
      radiusMeters: Value(radiusMeters),
      createdAt: Value(createdAt),
      lastUsedAt: lastUsedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastUsedAt),
    );
  }

  factory Site.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Site(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      city: serializer.fromJson<String?>(json['city']),
      latitude: serializer.fromJson<double?>(json['latitude']),
      longitude: serializer.fromJson<double?>(json['longitude']),
      anchorAccuracyMeters: serializer.fromJson<double?>(
        json['anchorAccuracyMeters'],
      ),
      anchorSamples: serializer.fromJson<int>(json['anchorSamples']),
      radiusMeters: serializer.fromJson<double>(json['radiusMeters']),
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
      'city': serializer.toJson<String?>(city),
      'latitude': serializer.toJson<double?>(latitude),
      'longitude': serializer.toJson<double?>(longitude),
      'anchorAccuracyMeters': serializer.toJson<double?>(anchorAccuracyMeters),
      'anchorSamples': serializer.toJson<int>(anchorSamples),
      'radiusMeters': serializer.toJson<double>(radiusMeters),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'lastUsedAt': serializer.toJson<DateTime?>(lastUsedAt),
    };
  }

  Site copyWith({
    int? id,
    String? name,
    Value<String?> city = const Value.absent(),
    Value<double?> latitude = const Value.absent(),
    Value<double?> longitude = const Value.absent(),
    Value<double?> anchorAccuracyMeters = const Value.absent(),
    int? anchorSamples,
    double? radiusMeters,
    DateTime? createdAt,
    Value<DateTime?> lastUsedAt = const Value.absent(),
  }) => Site(
    id: id ?? this.id,
    name: name ?? this.name,
    city: city.present ? city.value : this.city,
    latitude: latitude.present ? latitude.value : this.latitude,
    longitude: longitude.present ? longitude.value : this.longitude,
    anchorAccuracyMeters: anchorAccuracyMeters.present
        ? anchorAccuracyMeters.value
        : this.anchorAccuracyMeters,
    anchorSamples: anchorSamples ?? this.anchorSamples,
    radiusMeters: radiusMeters ?? this.radiusMeters,
    createdAt: createdAt ?? this.createdAt,
    lastUsedAt: lastUsedAt.present ? lastUsedAt.value : this.lastUsedAt,
  );
  Site copyWithCompanion(SitesCompanion data) {
    return Site(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      city: data.city.present ? data.city.value : this.city,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      anchorAccuracyMeters: data.anchorAccuracyMeters.present
          ? data.anchorAccuracyMeters.value
          : this.anchorAccuracyMeters,
      anchorSamples: data.anchorSamples.present
          ? data.anchorSamples.value
          : this.anchorSamples,
      radiusMeters: data.radiusMeters.present
          ? data.radiusMeters.value
          : this.radiusMeters,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      lastUsedAt: data.lastUsedAt.present
          ? data.lastUsedAt.value
          : this.lastUsedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Site(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('city: $city, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('anchorAccuracyMeters: $anchorAccuracyMeters, ')
          ..write('anchorSamples: $anchorSamples, ')
          ..write('radiusMeters: $radiusMeters, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastUsedAt: $lastUsedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    city,
    latitude,
    longitude,
    anchorAccuracyMeters,
    anchorSamples,
    radiusMeters,
    createdAt,
    lastUsedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Site &&
          other.id == this.id &&
          other.name == this.name &&
          other.city == this.city &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.anchorAccuracyMeters == this.anchorAccuracyMeters &&
          other.anchorSamples == this.anchorSamples &&
          other.radiusMeters == this.radiusMeters &&
          other.createdAt == this.createdAt &&
          other.lastUsedAt == this.lastUsedAt);
}

class SitesCompanion extends UpdateCompanion<Site> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> city;
  final Value<double?> latitude;
  final Value<double?> longitude;
  final Value<double?> anchorAccuracyMeters;
  final Value<int> anchorSamples;
  final Value<double> radiusMeters;
  final Value<DateTime> createdAt;
  final Value<DateTime?> lastUsedAt;
  const SitesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.city = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.anchorAccuracyMeters = const Value.absent(),
    this.anchorSamples = const Value.absent(),
    this.radiusMeters = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.lastUsedAt = const Value.absent(),
  });
  SitesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.city = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.anchorAccuracyMeters = const Value.absent(),
    this.anchorSamples = const Value.absent(),
    this.radiusMeters = const Value.absent(),
    required DateTime createdAt,
    this.lastUsedAt = const Value.absent(),
  }) : name = Value(name),
       createdAt = Value(createdAt);
  static Insertable<Site> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? city,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<double>? anchorAccuracyMeters,
    Expression<int>? anchorSamples,
    Expression<double>? radiusMeters,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? lastUsedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (city != null) 'city': city,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (anchorAccuracyMeters != null)
        'anchor_accuracy_meters': anchorAccuracyMeters,
      if (anchorSamples != null) 'anchor_samples': anchorSamples,
      if (radiusMeters != null) 'radius_meters': radiusMeters,
      if (createdAt != null) 'created_at': createdAt,
      if (lastUsedAt != null) 'last_used_at': lastUsedAt,
    });
  }

  SitesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String?>? city,
    Value<double?>? latitude,
    Value<double?>? longitude,
    Value<double?>? anchorAccuracyMeters,
    Value<int>? anchorSamples,
    Value<double>? radiusMeters,
    Value<DateTime>? createdAt,
    Value<DateTime?>? lastUsedAt,
  }) {
    return SitesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      city: city ?? this.city,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      anchorAccuracyMeters: anchorAccuracyMeters ?? this.anchorAccuracyMeters,
      anchorSamples: anchorSamples ?? this.anchorSamples,
      radiusMeters: radiusMeters ?? this.radiusMeters,
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
    if (city.present) {
      map['city'] = Variable<String>(city.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (anchorAccuracyMeters.present) {
      map['anchor_accuracy_meters'] = Variable<double>(
        anchorAccuracyMeters.value,
      );
    }
    if (anchorSamples.present) {
      map['anchor_samples'] = Variable<int>(anchorSamples.value);
    }
    if (radiusMeters.present) {
      map['radius_meters'] = Variable<double>(radiusMeters.value);
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
    return (StringBuffer('SitesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('city: $city, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('anchorAccuracyMeters: $anchorAccuracyMeters, ')
          ..write('anchorSamples: $anchorSamples, ')
          ..write('radiusMeters: $radiusMeters, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastUsedAt: $lastUsedAt')
          ..write(')'))
        .toString();
  }
}

class $RoomsTable extends Rooms with TableInfo<$RoomsTable, Room> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RoomsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _siteIdMeta = const VerificationMeta('siteId');
  @override
  late final GeneratedColumn<int> siteId = GeneratedColumn<int>(
    'site_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  List<GeneratedColumn> get $columns => [
    id,
    siteId,
    name,
    createdAt,
    lastUsedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'rooms';
  @override
  VerificationContext validateIntegrity(
    Insertable<Room> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('site_id')) {
      context.handle(
        _siteIdMeta,
        siteId.isAcceptableOrUnknown(data['site_id']!, _siteIdMeta),
      );
    } else if (isInserting) {
      context.missing(_siteIdMeta);
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
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {siteId, name},
  ];
  @override
  Room map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Room(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      siteId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}site_id'],
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
  $RoomsTable createAlias(String alias) {
    return $RoomsTable(attachedDatabase, alias);
  }
}

class Room extends DataClass implements Insertable<Room> {
  final int id;
  final int siteId;
  final String name;
  final DateTime createdAt;
  final DateTime? lastUsedAt;
  const Room({
    required this.id,
    required this.siteId,
    required this.name,
    required this.createdAt,
    this.lastUsedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['site_id'] = Variable<int>(siteId);
    map['name'] = Variable<String>(name);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || lastUsedAt != null) {
      map['last_used_at'] = Variable<DateTime>(lastUsedAt);
    }
    return map;
  }

  RoomsCompanion toCompanion(bool nullToAbsent) {
    return RoomsCompanion(
      id: Value(id),
      siteId: Value(siteId),
      name: Value(name),
      createdAt: Value(createdAt),
      lastUsedAt: lastUsedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastUsedAt),
    );
  }

  factory Room.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Room(
      id: serializer.fromJson<int>(json['id']),
      siteId: serializer.fromJson<int>(json['siteId']),
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
      'siteId': serializer.toJson<int>(siteId),
      'name': serializer.toJson<String>(name),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'lastUsedAt': serializer.toJson<DateTime?>(lastUsedAt),
    };
  }

  Room copyWith({
    int? id,
    int? siteId,
    String? name,
    DateTime? createdAt,
    Value<DateTime?> lastUsedAt = const Value.absent(),
  }) => Room(
    id: id ?? this.id,
    siteId: siteId ?? this.siteId,
    name: name ?? this.name,
    createdAt: createdAt ?? this.createdAt,
    lastUsedAt: lastUsedAt.present ? lastUsedAt.value : this.lastUsedAt,
  );
  Room copyWithCompanion(RoomsCompanion data) {
    return Room(
      id: data.id.present ? data.id.value : this.id,
      siteId: data.siteId.present ? data.siteId.value : this.siteId,
      name: data.name.present ? data.name.value : this.name,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      lastUsedAt: data.lastUsedAt.present
          ? data.lastUsedAt.value
          : this.lastUsedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Room(')
          ..write('id: $id, ')
          ..write('siteId: $siteId, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastUsedAt: $lastUsedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, siteId, name, createdAt, lastUsedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Room &&
          other.id == this.id &&
          other.siteId == this.siteId &&
          other.name == this.name &&
          other.createdAt == this.createdAt &&
          other.lastUsedAt == this.lastUsedAt);
}

class RoomsCompanion extends UpdateCompanion<Room> {
  final Value<int> id;
  final Value<int> siteId;
  final Value<String> name;
  final Value<DateTime> createdAt;
  final Value<DateTime?> lastUsedAt;
  const RoomsCompanion({
    this.id = const Value.absent(),
    this.siteId = const Value.absent(),
    this.name = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.lastUsedAt = const Value.absent(),
  });
  RoomsCompanion.insert({
    this.id = const Value.absent(),
    required int siteId,
    required String name,
    required DateTime createdAt,
    this.lastUsedAt = const Value.absent(),
  }) : siteId = Value(siteId),
       name = Value(name),
       createdAt = Value(createdAt);
  static Insertable<Room> custom({
    Expression<int>? id,
    Expression<int>? siteId,
    Expression<String>? name,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? lastUsedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (siteId != null) 'site_id': siteId,
      if (name != null) 'name': name,
      if (createdAt != null) 'created_at': createdAt,
      if (lastUsedAt != null) 'last_used_at': lastUsedAt,
    });
  }

  RoomsCompanion copyWith({
    Value<int>? id,
    Value<int>? siteId,
    Value<String>? name,
    Value<DateTime>? createdAt,
    Value<DateTime?>? lastUsedAt,
  }) {
    return RoomsCompanion(
      id: id ?? this.id,
      siteId: siteId ?? this.siteId,
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
    if (siteId.present) {
      map['site_id'] = Variable<int>(siteId.value);
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
    return (StringBuffer('RoomsCompanion(')
          ..write('id: $id, ')
          ..write('siteId: $siteId, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastUsedAt: $lastUsedAt')
          ..write(')'))
        .toString();
  }
}

class $SamplingPointsTable extends SamplingPoints
    with TableInfo<$SamplingPointsTable, SamplingPoint> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SamplingPointsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _siteIdMeta = const VerificationMeta('siteId');
  @override
  late final GeneratedColumn<int> siteId = GeneratedColumn<int>(
    'site_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _roomIdMeta = const VerificationMeta('roomId');
  @override
  late final GeneratedColumn<int> roomId = GeneratedColumn<int>(
    'room_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _legacyLabelMeta = const VerificationMeta(
    'legacyLabel',
  );
  @override
  late final GeneratedColumn<String> legacyLabel = GeneratedColumn<String>(
    'legacy_label',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
  List<GeneratedColumn> get $columns => [
    id,
    siteId,
    roomId,
    name,
    legacyLabel,
    createdAt,
    lastUsedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sampling_points';
  @override
  VerificationContext validateIntegrity(
    Insertable<SamplingPoint> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('site_id')) {
      context.handle(
        _siteIdMeta,
        siteId.isAcceptableOrUnknown(data['site_id']!, _siteIdMeta),
      );
    } else if (isInserting) {
      context.missing(_siteIdMeta);
    }
    if (data.containsKey('room_id')) {
      context.handle(
        _roomIdMeta,
        roomId.isAcceptableOrUnknown(data['room_id']!, _roomIdMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('legacy_label')) {
      context.handle(
        _legacyLabelMeta,
        legacyLabel.isAcceptableOrUnknown(
          data['legacy_label']!,
          _legacyLabelMeta,
        ),
      );
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
  SamplingPoint map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SamplingPoint(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      siteId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}site_id'],
      )!,
      roomId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}room_id'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      legacyLabel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}legacy_label'],
      ),
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
  $SamplingPointsTable createAlias(String alias) {
    return $SamplingPointsTable(attachedDatabase, alias);
  }
}

class SamplingPoint extends DataClass implements Insertable<SamplingPoint> {
  final int id;
  final int siteId;
  final int? roomId;
  final String name;

  /// Плоское имя места из версий до 1.4.0, из которого этот источник мигрировал.
  ///
  /// Нужно ровно для одного: у замеров до обновления `siteName` пустой, и поиск
  /// базы тренда должен узнавать их по старому имени. Только для мигрировавших
  /// источников — иначе созданный вручную «Дача · Фильтр» унаследовал бы историю
  /// доиерархического «Фильтра», сделанного на самом деле дома.
  final String? legacyLabel;
  final DateTime createdAt;
  final DateTime? lastUsedAt;
  const SamplingPoint({
    required this.id,
    required this.siteId,
    this.roomId,
    required this.name,
    this.legacyLabel,
    required this.createdAt,
    this.lastUsedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['site_id'] = Variable<int>(siteId);
    if (!nullToAbsent || roomId != null) {
      map['room_id'] = Variable<int>(roomId);
    }
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || legacyLabel != null) {
      map['legacy_label'] = Variable<String>(legacyLabel);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || lastUsedAt != null) {
      map['last_used_at'] = Variable<DateTime>(lastUsedAt);
    }
    return map;
  }

  SamplingPointsCompanion toCompanion(bool nullToAbsent) {
    return SamplingPointsCompanion(
      id: Value(id),
      siteId: Value(siteId),
      roomId: roomId == null && nullToAbsent
          ? const Value.absent()
          : Value(roomId),
      name: Value(name),
      legacyLabel: legacyLabel == null && nullToAbsent
          ? const Value.absent()
          : Value(legacyLabel),
      createdAt: Value(createdAt),
      lastUsedAt: lastUsedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastUsedAt),
    );
  }

  factory SamplingPoint.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SamplingPoint(
      id: serializer.fromJson<int>(json['id']),
      siteId: serializer.fromJson<int>(json['siteId']),
      roomId: serializer.fromJson<int?>(json['roomId']),
      name: serializer.fromJson<String>(json['name']),
      legacyLabel: serializer.fromJson<String?>(json['legacyLabel']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      lastUsedAt: serializer.fromJson<DateTime?>(json['lastUsedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'siteId': serializer.toJson<int>(siteId),
      'roomId': serializer.toJson<int?>(roomId),
      'name': serializer.toJson<String>(name),
      'legacyLabel': serializer.toJson<String?>(legacyLabel),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'lastUsedAt': serializer.toJson<DateTime?>(lastUsedAt),
    };
  }

  SamplingPoint copyWith({
    int? id,
    int? siteId,
    Value<int?> roomId = const Value.absent(),
    String? name,
    Value<String?> legacyLabel = const Value.absent(),
    DateTime? createdAt,
    Value<DateTime?> lastUsedAt = const Value.absent(),
  }) => SamplingPoint(
    id: id ?? this.id,
    siteId: siteId ?? this.siteId,
    roomId: roomId.present ? roomId.value : this.roomId,
    name: name ?? this.name,
    legacyLabel: legacyLabel.present ? legacyLabel.value : this.legacyLabel,
    createdAt: createdAt ?? this.createdAt,
    lastUsedAt: lastUsedAt.present ? lastUsedAt.value : this.lastUsedAt,
  );
  SamplingPoint copyWithCompanion(SamplingPointsCompanion data) {
    return SamplingPoint(
      id: data.id.present ? data.id.value : this.id,
      siteId: data.siteId.present ? data.siteId.value : this.siteId,
      roomId: data.roomId.present ? data.roomId.value : this.roomId,
      name: data.name.present ? data.name.value : this.name,
      legacyLabel: data.legacyLabel.present
          ? data.legacyLabel.value
          : this.legacyLabel,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      lastUsedAt: data.lastUsedAt.present
          ? data.lastUsedAt.value
          : this.lastUsedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SamplingPoint(')
          ..write('id: $id, ')
          ..write('siteId: $siteId, ')
          ..write('roomId: $roomId, ')
          ..write('name: $name, ')
          ..write('legacyLabel: $legacyLabel, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastUsedAt: $lastUsedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, siteId, roomId, name, legacyLabel, createdAt, lastUsedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SamplingPoint &&
          other.id == this.id &&
          other.siteId == this.siteId &&
          other.roomId == this.roomId &&
          other.name == this.name &&
          other.legacyLabel == this.legacyLabel &&
          other.createdAt == this.createdAt &&
          other.lastUsedAt == this.lastUsedAt);
}

class SamplingPointsCompanion extends UpdateCompanion<SamplingPoint> {
  final Value<int> id;
  final Value<int> siteId;
  final Value<int?> roomId;
  final Value<String> name;
  final Value<String?> legacyLabel;
  final Value<DateTime> createdAt;
  final Value<DateTime?> lastUsedAt;
  const SamplingPointsCompanion({
    this.id = const Value.absent(),
    this.siteId = const Value.absent(),
    this.roomId = const Value.absent(),
    this.name = const Value.absent(),
    this.legacyLabel = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.lastUsedAt = const Value.absent(),
  });
  SamplingPointsCompanion.insert({
    this.id = const Value.absent(),
    required int siteId,
    this.roomId = const Value.absent(),
    required String name,
    this.legacyLabel = const Value.absent(),
    required DateTime createdAt,
    this.lastUsedAt = const Value.absent(),
  }) : siteId = Value(siteId),
       name = Value(name),
       createdAt = Value(createdAt);
  static Insertable<SamplingPoint> custom({
    Expression<int>? id,
    Expression<int>? siteId,
    Expression<int>? roomId,
    Expression<String>? name,
    Expression<String>? legacyLabel,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? lastUsedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (siteId != null) 'site_id': siteId,
      if (roomId != null) 'room_id': roomId,
      if (name != null) 'name': name,
      if (legacyLabel != null) 'legacy_label': legacyLabel,
      if (createdAt != null) 'created_at': createdAt,
      if (lastUsedAt != null) 'last_used_at': lastUsedAt,
    });
  }

  SamplingPointsCompanion copyWith({
    Value<int>? id,
    Value<int>? siteId,
    Value<int?>? roomId,
    Value<String>? name,
    Value<String?>? legacyLabel,
    Value<DateTime>? createdAt,
    Value<DateTime?>? lastUsedAt,
  }) {
    return SamplingPointsCompanion(
      id: id ?? this.id,
      siteId: siteId ?? this.siteId,
      roomId: roomId ?? this.roomId,
      name: name ?? this.name,
      legacyLabel: legacyLabel ?? this.legacyLabel,
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
    if (siteId.present) {
      map['site_id'] = Variable<int>(siteId.value);
    }
    if (roomId.present) {
      map['room_id'] = Variable<int>(roomId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (legacyLabel.present) {
      map['legacy_label'] = Variable<String>(legacyLabel.value);
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
    return (StringBuffer('SamplingPointsCompanion(')
          ..write('id: $id, ')
          ..write('siteId: $siteId, ')
          ..write('roomId: $roomId, ')
          ..write('name: $name, ')
          ..write('legacyLabel: $legacyLabel, ')
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
  late final $SitesTable sites = $SitesTable(this);
  late final $RoomsTable rooms = $RoomsTable(this);
  late final $SamplingPointsTable samplingPoints = $SamplingPointsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    measurements,
    sites,
    rooms,
    samplingPoints,
  ];
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
      Value<String?> siteName,
      Value<String?> roomName,
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
      Value<String?> siteName,
      Value<String?> roomName,
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

  ColumnFilters<String> get siteName => $composableBuilder(
    column: $table.siteName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get roomName => $composableBuilder(
    column: $table.roomName,
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

  ColumnOrderings<String> get siteName => $composableBuilder(
    column: $table.siteName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get roomName => $composableBuilder(
    column: $table.roomName,
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

  GeneratedColumn<String> get siteName =>
      $composableBuilder(column: $table.siteName, builder: (column) => column);

  GeneratedColumn<String> get roomName =>
      $composableBuilder(column: $table.roomName, builder: (column) => column);
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
                Value<String?> siteName = const Value.absent(),
                Value<String?> roomName = const Value.absent(),
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
                siteName: siteName,
                roomName: roomName,
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
                Value<String?> siteName = const Value.absent(),
                Value<String?> roomName = const Value.absent(),
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
                siteName: siteName,
                roomName: roomName,
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
typedef $$SitesTableCreateCompanionBuilder =
    SitesCompanion Function({
      Value<int> id,
      required String name,
      Value<String?> city,
      Value<double?> latitude,
      Value<double?> longitude,
      Value<double?> anchorAccuracyMeters,
      Value<int> anchorSamples,
      Value<double> radiusMeters,
      required DateTime createdAt,
      Value<DateTime?> lastUsedAt,
    });
typedef $$SitesTableUpdateCompanionBuilder =
    SitesCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String?> city,
      Value<double?> latitude,
      Value<double?> longitude,
      Value<double?> anchorAccuracyMeters,
      Value<int> anchorSamples,
      Value<double> radiusMeters,
      Value<DateTime> createdAt,
      Value<DateTime?> lastUsedAt,
    });

class $$SitesTableFilterComposer extends Composer<_$AppDatabase, $SitesTable> {
  $$SitesTableFilterComposer({
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

  ColumnFilters<String> get city => $composableBuilder(
    column: $table.city,
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

  ColumnFilters<double> get anchorAccuracyMeters => $composableBuilder(
    column: $table.anchorAccuracyMeters,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get anchorSamples => $composableBuilder(
    column: $table.anchorSamples,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get radiusMeters => $composableBuilder(
    column: $table.radiusMeters,
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

class $$SitesTableOrderingComposer
    extends Composer<_$AppDatabase, $SitesTable> {
  $$SitesTableOrderingComposer({
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

  ColumnOrderings<String> get city => $composableBuilder(
    column: $table.city,
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

  ColumnOrderings<double> get anchorAccuracyMeters => $composableBuilder(
    column: $table.anchorAccuracyMeters,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get anchorSamples => $composableBuilder(
    column: $table.anchorSamples,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get radiusMeters => $composableBuilder(
    column: $table.radiusMeters,
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

class $$SitesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SitesTable> {
  $$SitesTableAnnotationComposer({
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

  GeneratedColumn<String> get city =>
      $composableBuilder(column: $table.city, builder: (column) => column);

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumn<double> get anchorAccuracyMeters => $composableBuilder(
    column: $table.anchorAccuracyMeters,
    builder: (column) => column,
  );

  GeneratedColumn<int> get anchorSamples => $composableBuilder(
    column: $table.anchorSamples,
    builder: (column) => column,
  );

  GeneratedColumn<double> get radiusMeters => $composableBuilder(
    column: $table.radiusMeters,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastUsedAt => $composableBuilder(
    column: $table.lastUsedAt,
    builder: (column) => column,
  );
}

class $$SitesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SitesTable,
          Site,
          $$SitesTableFilterComposer,
          $$SitesTableOrderingComposer,
          $$SitesTableAnnotationComposer,
          $$SitesTableCreateCompanionBuilder,
          $$SitesTableUpdateCompanionBuilder,
          (Site, BaseReferences<_$AppDatabase, $SitesTable, Site>),
          Site,
          PrefetchHooks Function()
        > {
  $$SitesTableTableManager(_$AppDatabase db, $SitesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SitesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SitesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SitesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> city = const Value.absent(),
                Value<double?> latitude = const Value.absent(),
                Value<double?> longitude = const Value.absent(),
                Value<double?> anchorAccuracyMeters = const Value.absent(),
                Value<int> anchorSamples = const Value.absent(),
                Value<double> radiusMeters = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> lastUsedAt = const Value.absent(),
              }) => SitesCompanion(
                id: id,
                name: name,
                city: city,
                latitude: latitude,
                longitude: longitude,
                anchorAccuracyMeters: anchorAccuracyMeters,
                anchorSamples: anchorSamples,
                radiusMeters: radiusMeters,
                createdAt: createdAt,
                lastUsedAt: lastUsedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String?> city = const Value.absent(),
                Value<double?> latitude = const Value.absent(),
                Value<double?> longitude = const Value.absent(),
                Value<double?> anchorAccuracyMeters = const Value.absent(),
                Value<int> anchorSamples = const Value.absent(),
                Value<double> radiusMeters = const Value.absent(),
                required DateTime createdAt,
                Value<DateTime?> lastUsedAt = const Value.absent(),
              }) => SitesCompanion.insert(
                id: id,
                name: name,
                city: city,
                latitude: latitude,
                longitude: longitude,
                anchorAccuracyMeters: anchorAccuracyMeters,
                anchorSamples: anchorSamples,
                radiusMeters: radiusMeters,
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

typedef $$SitesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SitesTable,
      Site,
      $$SitesTableFilterComposer,
      $$SitesTableOrderingComposer,
      $$SitesTableAnnotationComposer,
      $$SitesTableCreateCompanionBuilder,
      $$SitesTableUpdateCompanionBuilder,
      (Site, BaseReferences<_$AppDatabase, $SitesTable, Site>),
      Site,
      PrefetchHooks Function()
    >;
typedef $$RoomsTableCreateCompanionBuilder =
    RoomsCompanion Function({
      Value<int> id,
      required int siteId,
      required String name,
      required DateTime createdAt,
      Value<DateTime?> lastUsedAt,
    });
typedef $$RoomsTableUpdateCompanionBuilder =
    RoomsCompanion Function({
      Value<int> id,
      Value<int> siteId,
      Value<String> name,
      Value<DateTime> createdAt,
      Value<DateTime?> lastUsedAt,
    });

class $$RoomsTableFilterComposer extends Composer<_$AppDatabase, $RoomsTable> {
  $$RoomsTableFilterComposer({
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

  ColumnFilters<int> get siteId => $composableBuilder(
    column: $table.siteId,
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

class $$RoomsTableOrderingComposer
    extends Composer<_$AppDatabase, $RoomsTable> {
  $$RoomsTableOrderingComposer({
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

  ColumnOrderings<int> get siteId => $composableBuilder(
    column: $table.siteId,
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

class $$RoomsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RoomsTable> {
  $$RoomsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get siteId =>
      $composableBuilder(column: $table.siteId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastUsedAt => $composableBuilder(
    column: $table.lastUsedAt,
    builder: (column) => column,
  );
}

class $$RoomsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RoomsTable,
          Room,
          $$RoomsTableFilterComposer,
          $$RoomsTableOrderingComposer,
          $$RoomsTableAnnotationComposer,
          $$RoomsTableCreateCompanionBuilder,
          $$RoomsTableUpdateCompanionBuilder,
          (Room, BaseReferences<_$AppDatabase, $RoomsTable, Room>),
          Room,
          PrefetchHooks Function()
        > {
  $$RoomsTableTableManager(_$AppDatabase db, $RoomsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RoomsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RoomsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RoomsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> siteId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> lastUsedAt = const Value.absent(),
              }) => RoomsCompanion(
                id: id,
                siteId: siteId,
                name: name,
                createdAt: createdAt,
                lastUsedAt: lastUsedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int siteId,
                required String name,
                required DateTime createdAt,
                Value<DateTime?> lastUsedAt = const Value.absent(),
              }) => RoomsCompanion.insert(
                id: id,
                siteId: siteId,
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

typedef $$RoomsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RoomsTable,
      Room,
      $$RoomsTableFilterComposer,
      $$RoomsTableOrderingComposer,
      $$RoomsTableAnnotationComposer,
      $$RoomsTableCreateCompanionBuilder,
      $$RoomsTableUpdateCompanionBuilder,
      (Room, BaseReferences<_$AppDatabase, $RoomsTable, Room>),
      Room,
      PrefetchHooks Function()
    >;
typedef $$SamplingPointsTableCreateCompanionBuilder =
    SamplingPointsCompanion Function({
      Value<int> id,
      required int siteId,
      Value<int?> roomId,
      required String name,
      Value<String?> legacyLabel,
      required DateTime createdAt,
      Value<DateTime?> lastUsedAt,
    });
typedef $$SamplingPointsTableUpdateCompanionBuilder =
    SamplingPointsCompanion Function({
      Value<int> id,
      Value<int> siteId,
      Value<int?> roomId,
      Value<String> name,
      Value<String?> legacyLabel,
      Value<DateTime> createdAt,
      Value<DateTime?> lastUsedAt,
    });

class $$SamplingPointsTableFilterComposer
    extends Composer<_$AppDatabase, $SamplingPointsTable> {
  $$SamplingPointsTableFilterComposer({
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

  ColumnFilters<int> get siteId => $composableBuilder(
    column: $table.siteId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get roomId => $composableBuilder(
    column: $table.roomId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get legacyLabel => $composableBuilder(
    column: $table.legacyLabel,
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

class $$SamplingPointsTableOrderingComposer
    extends Composer<_$AppDatabase, $SamplingPointsTable> {
  $$SamplingPointsTableOrderingComposer({
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

  ColumnOrderings<int> get siteId => $composableBuilder(
    column: $table.siteId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get roomId => $composableBuilder(
    column: $table.roomId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get legacyLabel => $composableBuilder(
    column: $table.legacyLabel,
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

class $$SamplingPointsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SamplingPointsTable> {
  $$SamplingPointsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get siteId =>
      $composableBuilder(column: $table.siteId, builder: (column) => column);

  GeneratedColumn<int> get roomId =>
      $composableBuilder(column: $table.roomId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get legacyLabel => $composableBuilder(
    column: $table.legacyLabel,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastUsedAt => $composableBuilder(
    column: $table.lastUsedAt,
    builder: (column) => column,
  );
}

class $$SamplingPointsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SamplingPointsTable,
          SamplingPoint,
          $$SamplingPointsTableFilterComposer,
          $$SamplingPointsTableOrderingComposer,
          $$SamplingPointsTableAnnotationComposer,
          $$SamplingPointsTableCreateCompanionBuilder,
          $$SamplingPointsTableUpdateCompanionBuilder,
          (
            SamplingPoint,
            BaseReferences<_$AppDatabase, $SamplingPointsTable, SamplingPoint>,
          ),
          SamplingPoint,
          PrefetchHooks Function()
        > {
  $$SamplingPointsTableTableManager(
    _$AppDatabase db,
    $SamplingPointsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SamplingPointsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SamplingPointsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SamplingPointsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> siteId = const Value.absent(),
                Value<int?> roomId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> legacyLabel = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> lastUsedAt = const Value.absent(),
              }) => SamplingPointsCompanion(
                id: id,
                siteId: siteId,
                roomId: roomId,
                name: name,
                legacyLabel: legacyLabel,
                createdAt: createdAt,
                lastUsedAt: lastUsedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int siteId,
                Value<int?> roomId = const Value.absent(),
                required String name,
                Value<String?> legacyLabel = const Value.absent(),
                required DateTime createdAt,
                Value<DateTime?> lastUsedAt = const Value.absent(),
              }) => SamplingPointsCompanion.insert(
                id: id,
                siteId: siteId,
                roomId: roomId,
                name: name,
                legacyLabel: legacyLabel,
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

typedef $$SamplingPointsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SamplingPointsTable,
      SamplingPoint,
      $$SamplingPointsTableFilterComposer,
      $$SamplingPointsTableOrderingComposer,
      $$SamplingPointsTableAnnotationComposer,
      $$SamplingPointsTableCreateCompanionBuilder,
      $$SamplingPointsTableUpdateCompanionBuilder,
      (
        SamplingPoint,
        BaseReferences<_$AppDatabase, $SamplingPointsTable, SamplingPoint>,
      ),
      SamplingPoint,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$MeasurementsTableTableManager get measurements =>
      $$MeasurementsTableTableManager(_db, _db.measurements);
  $$SitesTableTableManager get sites =>
      $$SitesTableTableManager(_db, _db.sites);
  $$RoomsTableTableManager get rooms =>
      $$RoomsTableTableManager(_db, _db.rooms);
  $$SamplingPointsTableTableManager get samplingPoints =>
      $$SamplingPointsTableTableManager(_db, _db.samplingPoints);
}
