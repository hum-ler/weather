import 'package:json_annotation/json_annotation.dart';

part 'reading_data.g.dart';

/// Model of the reading data as returned (in JSON) by the weather service.
@JsonSerializable()
class ReadingData {
  final ReadingDataMetadata metadata;

  final List<ReadingDataItem> items;

  @JsonKey(name: 'api_info')
  final ReadingDataApiInfo apiInfo;

  ReadingData({
    this.metadata,
    this.items,
    this.apiInfo,
  });

  factory ReadingData.fromJson(Map<String, dynamic> json) {
    return _$ReadingDataFromJson(json);
  }
}

@JsonSerializable()
class ReadingDataMetadata {
  final List<ReadingDataStation> stations;

  @JsonKey(name: 'reading_type')
  final String readingType;

  @JsonKey(name: 'reading_unit')
  final String readingUnit;

  ReadingDataMetadata({
    this.stations,
    this.readingType,
    this.readingUnit,
  });

  factory ReadingDataMetadata.fromJson(Map<String, dynamic> json) {
    return _$ReadingDataMetadataFromJson(json);
  }
}

@JsonSerializable()
class ReadingDataStation {
  final String id;

  @JsonKey(name: 'device_id')
  final String deviceId;

  final String name;

  final ReadingDataLocation location;

  ReadingDataStation({
    this.id,
    this.deviceId,
    this.name,
    this.location,
  });

  factory ReadingDataStation.fromJson(Map<String, dynamic> json) {
    return _$ReadingDataStationFromJson(json);
  }
}

@JsonSerializable()
class ReadingDataLocation {
  final double latitude;

  final double longitude;

  ReadingDataLocation({
    this.latitude,
    this.longitude,
  });

  factory ReadingDataLocation.fromJson(Map<String, dynamic> json) {
    return _$ReadingDataLocationFromJson(json);
  }
}

@JsonSerializable()
class ReadingDataItem {
  final DateTime timestamp;

  final List<ReadingDataReading> readings;

  ReadingDataItem({
    this.timestamp,
    this.readings,
  });

  factory ReadingDataItem.fromJson(Map<String, dynamic> json) {
    return _$ReadingDataItemFromJson(json);
  }
}

@JsonSerializable()
class ReadingDataReading {
  @JsonKey(name: 'station_id')
  final String stationId;

  final double value;

  ReadingDataReading({
    this.stationId,
    this.value,
  });

  factory ReadingDataReading.fromJson(Map<String, dynamic> json) {
    return _$ReadingDataReadingFromJson(json);
  }
}

@JsonSerializable()
class ReadingDataApiInfo {
  final String status;

  ReadingDataApiInfo({this.status});

  factory ReadingDataApiInfo.fromJson(Map<String, dynamic> json) {
    return _$ReadingDataApiInfoFromJson(json);
  }
}
