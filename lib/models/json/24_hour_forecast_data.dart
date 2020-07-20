import 'package:json_annotation/json_annotation.dart';

part '24_hour_forecast_data.g.dart';

/// Model of the 24-hour forecast data as returned (in JSON) by the weather
/// service.
@JsonSerializable()
class X24HourForecastData {
  final List<X24HourForecastDataItem> items;

  @JsonKey(name: 'api_info')
  final X24HourForecastDataApiInfo apiInfo;

  X24HourForecastData({
    this.items,
    this.apiInfo,
  });

  factory X24HourForecastData.fromJson(Map<String, dynamic> json) {
    return _$X24HourForecastDataFromJson(json);
  }
}

@JsonSerializable()
class X24HourForecastDataItem {
  @JsonKey(name: 'update_timestamp')
  final DateTime updateTimestamp;

  final DateTime timestamp;

  @JsonKey(name: 'valid_period')
  final X24HourForecastDataStartEnd validPeriod;

  final X24HourForecastDataGeneral general;

  final List<X24HourForecastDataPeriod> periods;

  X24HourForecastDataItem({
    this.updateTimestamp,
    this.timestamp,
    this.validPeriod,
    this.general,
    this.periods,
  });

  factory X24HourForecastDataItem.fromJson(Map<String, dynamic> json) {
    return _$X24HourForecastDataItemFromJson(json);
  }
}

@JsonSerializable()
class X24HourForecastDataStartEnd {
  final DateTime start;

  final DateTime end;

  X24HourForecastDataStartEnd({
    this.start,
    this.end,
  });

  factory X24HourForecastDataStartEnd.fromJson(Map<String, dynamic> json) {
    return _$X24HourForecastDataStartEndFromJson(json);
  }
}

@JsonSerializable()
class X24HourForecastDataGeneral {
  final String forecast;

  @JsonKey(name: 'relative_humidity')
  final X24HourForecastDataLowHigh relativeHumidity;

  final X24HourForecastDataLowHigh temperature;

  final X24HourForecastDataWind wind;

  X24HourForecastDataGeneral({
    this.forecast,
    this.relativeHumidity,
    this.temperature,
    this.wind,
  });

  factory X24HourForecastDataGeneral.fromJson(Map<String, dynamic> json) {
    return _$X24HourForecastDataGeneralFromJson(json);
  }
}

@JsonSerializable()
class X24HourForecastDataLowHigh {
  final int low;

  final int high;

  X24HourForecastDataLowHigh({
    this.low,
    this.high,
  });

  factory X24HourForecastDataLowHigh.fromJson(Map<String, dynamic> json) {
    return _$X24HourForecastDataLowHighFromJson(json);
  }
}

@JsonSerializable()
class X24HourForecastDataWind {
  final X24HourForecastDataLowHigh speed;

  final String direction;

  X24HourForecastDataWind({
    this.speed,
    this.direction,
  });

  factory X24HourForecastDataWind.fromJson(Map<String, dynamic> json) {
    return _$X24HourForecastDataWindFromJson(json);
  }
}

@JsonSerializable()
class X24HourForecastDataPeriod {
  final X24HourForecastDataStartEnd time;

  final Map<String, String> regions;

  X24HourForecastDataPeriod({
    this.time,
    this.regions,
  });

  factory X24HourForecastDataPeriod.fromJson(Map<String, dynamic> json) {
    return _$X24HourForecastDataPeriodFromJson(json);
  }
}

@JsonSerializable()
class X24HourForecastDataApiInfo {
  final String status;

  X24HourForecastDataApiInfo({this.status});

  factory X24HourForecastDataApiInfo.fromJson(Map<String, dynamic> json) {
    return _$X24HourForecastDataApiInfoFromJson(json);
  }
}
