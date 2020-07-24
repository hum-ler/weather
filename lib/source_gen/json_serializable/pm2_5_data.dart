import 'package:json_annotation/json_annotation.dart';

part 'pm2_5_data.g.dart';

/// Model of the PM2.5 data as returned (in JSON) by the weather service.
@JsonSerializable()
class PM25Data {
  @JsonKey(name: 'region_metadata')
  final List<PM25DataRegionMetadata> regionMetadata;

  final List<PM25DataItem> items;

  @JsonKey(name: 'api_info')
  final PM25DataApiInfo apiInfo;

  PM25Data({
    this.regionMetadata,
    this.items,
    this.apiInfo,
  });

  factory PM25Data.fromJson(Map<String, dynamic> json) {
    return _$PM25DataFromJson(json);
  }
}

@JsonSerializable()
class PM25DataRegionMetadata {
  final String name;

  @JsonKey(name: 'label_location')
  final PM25DataLabelLocation labelLocation;

  PM25DataRegionMetadata({
    this.name,
    this.labelLocation,
  });

  factory PM25DataRegionMetadata.fromJson(Map<String, dynamic> json) {
    return _$PM25DataRegionMetadataFromJson(json);
  }
}

@JsonSerializable()
class PM25DataLabelLocation {
  final double latitude;

  final double longitude;

  PM25DataLabelLocation({
    this.latitude,
    this.longitude,
  });

  factory PM25DataLabelLocation.fromJson(Map<String, dynamic> json) {
    return _$PM25DataLabelLocationFromJson(json);
  }
}

@JsonSerializable()
class PM25DataItem {
  final DateTime timestamp;

  @JsonKey(name: 'update_timestamp')
  final DateTime updateTimestamp;

  final PM25DataReadings readings;

  PM25DataItem({
    this.timestamp,
    this.updateTimestamp,
    this.readings,
  });

  factory PM25DataItem.fromJson(Map<String, dynamic> json) {
    return _$PM25DataItemFromJson(json);
  }
}

@JsonSerializable()
class PM25DataReadings {
  @JsonKey(name: 'pm25_one_hourly')
  final Map<String, int> pm2_5OneHourly;

  PM25DataReadings({this.pm2_5OneHourly});

  factory PM25DataReadings.fromJson(Map<String, dynamic> json) {
    return _$PM25DataReadingsFromJson(json);
  }
}

@JsonSerializable()
class PM25DataApiInfo {
  final String status;

  PM25DataApiInfo({this.status});

  factory PM25DataApiInfo.fromJson(Map<String, dynamic> json) {
    return _$PM25DataApiInfoFromJson(json);
  }
}
