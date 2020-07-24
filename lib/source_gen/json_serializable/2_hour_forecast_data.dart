import 'package:json_annotation/json_annotation.dart';

part '2_hour_forecast_data.g.dart';

/// Model of the 2-hour forecast data as returned (in JSON) by the weather
/// service.
@JsonSerializable()
class X2HourForecastData {
  @JsonKey(name: 'area_metadata')
  final List<X2HourForecastDataAreaMetadata> areaMetadata;

  final List<X2HourForecastDataItem> items;

  @JsonKey(name: 'api_info')
  final X2HourForecastDataApiInfo apiInfo;

  X2HourForecastData({
    this.areaMetadata,
    this.items,
    this.apiInfo,
  });

  factory X2HourForecastData.fromJson(Map<String, dynamic> json) {
    return _$X2HourForecastDataFromJson(json);
  }
}

@JsonSerializable()
class X2HourForecastDataAreaMetadata {
  final String name;

  @JsonKey(name: 'label_location')
  final X2HourForecastDataLabelLocation labelLocation;

  X2HourForecastDataAreaMetadata({
    this.name,
    this.labelLocation,
  });

  factory X2HourForecastDataAreaMetadata.fromJson(Map<String, dynamic> json) {
    return _$X2HourForecastDataAreaMetadataFromJson(json);
  }
}

@JsonSerializable()
class X2HourForecastDataLabelLocation {
  final double latitude;

  final double longitude;

  X2HourForecastDataLabelLocation({
    this.latitude,
    this.longitude,
  });

  factory X2HourForecastDataLabelLocation.fromJson(Map<String, dynamic> json) {
    return _$X2HourForecastDataLabelLocationFromJson(json);
  }
}

@JsonSerializable()
class X2HourForecastDataItem {
  @JsonKey(name: 'update_timestamp')
  final DateTime updateTimestamp;

  final DateTime timestamp;

  @JsonKey(name: 'valid_period')
  final X2HourForecastDataValidPeriod validPeriod;

  final List<X2HourForecastDataForecast> forecasts;

  X2HourForecastDataItem({
    this.updateTimestamp,
    this.timestamp,
    this.validPeriod,
    this.forecasts,
  });

  factory X2HourForecastDataItem.fromJson(Map<String, dynamic> json) {
    return _$X2HourForecastDataItemFromJson(json);
  }
}

@JsonSerializable()
class X2HourForecastDataValidPeriod {
  final DateTime start;

  final DateTime end;

  X2HourForecastDataValidPeriod({
    this.start,
    this.end,
  });

  factory X2HourForecastDataValidPeriod.fromJson(Map<String, dynamic> json) {
    return _$X2HourForecastDataValidPeriodFromJson(json);
  }
}

@JsonSerializable()
class X2HourForecastDataForecast {
  final String area;

  final String forecast;

  X2HourForecastDataForecast({
    this.area,
    this.forecast,
  });

  factory X2HourForecastDataForecast.fromJson(Map<String, dynamic> json) {
    return _$X2HourForecastDataForecastFromJson(json);
  }
}

@JsonSerializable()
class X2HourForecastDataApiInfo {
  final String status;

  X2HourForecastDataApiInfo({this.status});

  factory X2HourForecastDataApiInfo.fromJson(Map<String, dynamic> json) {
    return _$X2HourForecastDataApiInfoFromJson(json);
  }
}
