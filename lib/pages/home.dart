import 'package:flutter/material.dart';

import 'package:weather_icons/weather_icons.dart';

import 'package:weather/models/forecast_area.dart';
import 'package:weather/models/geoposition.dart';
import 'package:weather/models/station.dart';
import 'package:weather/services/geolocation.dart';
import 'package:weather/services/weather.dart';
import 'package:weather/utils/constants.dart' as constants;
import 'package:weather/utils/utils.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  DateTime _fetchTimestamp;
  NearestStation _airTemperature;
  NearestStation _rainfall;
  NearestStation _relativeHumidity;
  NearestStation _wind;
  NearestForecastArea _condition;

  @override
  void initState() {
    super.initState();

    _fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Weather — Right Here, Right Now'),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.refresh),
        onPressed: () => _fetchData(),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  if (_airTemperature != null)
                    Text(
                      '${_airTemperature.airTemperature.round().toString()}°',
                      style: _airTemperature.readingAnomaly ||
                              _airTemperature.timestampAnomaly ||
                              _airTemperature.distanceAnomaly
                          ? constants.largeTextStyle
                              .copyWith(color: constants.anomalyHighlight)
                          : constants.largeTextStyle,
                    ),
                  if (_condition != null)
                    BoxedIcon(
                      _getConditionIcon(),
                      size: constants.largeIconSize,
                      color: _condition.forecastAnomaly ||
                              _condition.timestampAnomaly ||
                              _condition.distanceAnomaly
                          ? constants.anomalyHighlight
                          : null,
                    ),
                ],
              ),
            ),
            if (_airTemperature != null)
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  BoxedIcon(
                    WeatherIcons.thermometer,
                    size: constants.smallIconSize,
                    color: _airTemperature.readingAnomaly
                        ? constants.anomalyHighlight
                        : null,
                  ),
                  Text(
                    '${_airTemperature.airTemperature.toStringAsFixed(1)}${_airTemperature.airTemperatureUnit}',
                    style: _airTemperature.readingAnomaly
                        ? constants.smallTextStyle
                            .copyWith(color: constants.anomalyHighlight)
                        : constants.smallTextStyle,
                  ),
                  SizedBox(width: 4.0),
                  _BoxedIcon(
                    icon: Icons.place,
                    color: _airTemperature.distanceAnomaly
                        ? constants.anomalyHighlight
                        : null,
                  ),
                  Text(
                    '${_airTemperature.name.truncate(6, ellipsis: "…")} (${_airTemperature.distance.toStringAsFixed(1)}${_airTemperature.distanceUnit})',
                    style: _airTemperature.distanceAnomaly
                        ? constants.smallTextStyle
                            .copyWith(color: constants.anomalyHighlight)
                        : constants.smallTextStyle,
                  ),
                  SizedBox(width: 4.0),
                  _BoxedIcon(
                    icon: Icons.schedule,
                    color: _airTemperature.timestampAnomaly
                        ? constants.anomalyHighlight
                        : null,
                  ),
                  Text(
                    '${_airTemperature.airTemperatureTimestamp.toLocal().format(constants.dateTimePattern)}',
                    style: _airTemperature.timestampAnomaly
                        ? constants.smallTextStyle
                            .copyWith(color: constants.anomalyHighlight)
                        : constants.smallTextStyle,
                  ),
                ],
              ),
            if (_rainfall != null)
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  BoxedIcon(
                    WeatherIcons.umbrella,
                    size: constants.smallIconSize,
                    color: _rainfall.readingAnomaly
                        ? constants.anomalyHighlight
                        : null,
                  ),
                  Text(
                    '${_rainfall.rainfall.toStringAsFixed(1)}${_rainfall.rainfallUnit}',
                    style: _rainfall.readingAnomaly
                        ? constants.smallTextStyle
                            .copyWith(color: constants.anomalyHighlight)
                        : constants.smallTextStyle,
                  ),
                  SizedBox(width: 4.0),
                  _BoxedIcon(
                    icon: Icons.place,
                    color: _rainfall.distanceAnomaly
                        ? constants.anomalyHighlight
                        : null,
                  ),
                  Text(
                    '${_rainfall.name.truncate(6, ellipsis: "…")} (${_rainfall.distance.toStringAsFixed(1)}${_rainfall.distanceUnit})',
                    style: _rainfall.distanceAnomaly
                        ? constants.smallTextStyle
                            .copyWith(color: constants.anomalyHighlight)
                        : constants.smallTextStyle,
                  ),
                  SizedBox(width: 4.0),
                  _BoxedIcon(
                    icon: Icons.schedule,
                    color: _rainfall.timestampAnomaly
                        ? constants.anomalyHighlight
                        : null,
                  ),
                  Text(
                    '${_rainfall.rainfallTimestamp.toLocal().format(constants.dateTimePattern)}',
                    style: _rainfall.timestampAnomaly
                        ? constants.smallTextStyle
                            .copyWith(color: constants.anomalyHighlight)
                        : constants.smallTextStyle,
                  ),
                ],
              ),
            if (_relativeHumidity != null)
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  BoxedIcon(
                    WeatherIcons.raindrop,
                    size: constants.smallIconSize,
                    color: _relativeHumidity.readingAnomaly
                        ? constants.anomalyHighlight
                        : null,
                  ),
                  Text(
                    '${_relativeHumidity.relativeHumidity.toStringAsFixed(1)}${_relativeHumidity.relativeHumidityUnit}',
                    style: _relativeHumidity.readingAnomaly
                        ? constants.smallTextStyle
                            .copyWith(color: constants.anomalyHighlight)
                        : constants.smallTextStyle,
                  ),
                  SizedBox(width: 4.0),
                  _BoxedIcon(
                    icon: Icons.place,
                    color: _relativeHumidity.distanceAnomaly
                        ? constants.anomalyHighlight
                        : null,
                  ),
                  Text(
                    '${_relativeHumidity.name.truncate(6, ellipsis: "…")} (${_relativeHumidity.distance.toStringAsFixed(1)}${_relativeHumidity.distanceUnit})',
                    style: _relativeHumidity.distanceAnomaly
                        ? constants.smallTextStyle
                            .copyWith(color: constants.anomalyHighlight)
                        : constants.smallTextStyle,
                  ),
                  SizedBox(width: 4.0),
                  _BoxedIcon(
                    icon: Icons.schedule,
                    color: _relativeHumidity.timestampAnomaly
                        ? constants.anomalyHighlight
                        : null,
                  ),
                  Text(
                    '${_relativeHumidity.relativeHumidityTimestamp.toLocal().format(constants.dateTimePattern)}',
                    style: _relativeHumidity.timestampAnomaly
                        ? constants.smallTextStyle
                            .copyWith(color: constants.anomalyHighlight)
                        : constants.smallTextStyle,
                  ),
                ],
              ),
            if (_wind != null)
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  BoxedIcon(
                    WeatherIcons.strong_wind,
                    size: constants.smallIconSize,
                    color: _wind.readingAnomaly
                        ? constants.anomalyHighlight
                        : null,
                  ),
                  Text(
                    '${_wind.windSpeed.toStringAsFixed(1)}${_wind.windSpeedUnit}',
                    style: _wind.readingAnomaly
                        ? constants.smallTextStyle
                            .copyWith(color: constants.anomalyHighlight)
                        : constants.smallTextStyle,
                  ),
                  SizedBox(width: 4.0),
                  _BoxedIcon(
                    icon: Icons.navigation,
                    rotation: degreesToRadians(_wind.windDirection.toDouble()),
                    color: _wind.readingAnomaly
                        ? constants.anomalyHighlight
                        : null,
                  ),
                  Text(
                    '${_wind.windDirection.toString()}${_wind.windDirectionUnit}',
                    style: _wind.readingAnomaly
                        ? constants.smallTextStyle
                            .copyWith(color: constants.anomalyHighlight)
                        : constants.smallTextStyle,
                  ),
                  SizedBox(width: 4.0),
                  _BoxedIcon(
                    icon: Icons.place,
                    color: _wind.distanceAnomaly
                        ? constants.anomalyHighlight
                        : null,
                  ),
                  Text(
                    '${_wind.name.truncate(6, ellipsis: "…")} (${_wind.distance.toStringAsFixed(1)}${_wind.distanceUnit})',
                    style: _wind.distanceAnomaly
                        ? constants.smallTextStyle
                            .copyWith(color: constants.anomalyHighlight)
                        : constants.smallTextStyle,
                  ),
                  SizedBox(width: 4.0),
                  _BoxedIcon(
                    icon: Icons.schedule,
                    color: _wind.timestampAnomaly
                        ? constants.anomalyHighlight
                        : null,
                  ),
                  Text(
                    '${_wind.windSpeedTimestamp.toLocal().format(constants.dateTimePattern)}',
                    style: _wind.timestampAnomaly
                        ? constants.smallTextStyle
                            .copyWith(color: constants.anomalyHighlight)
                        : constants.smallTextStyle,
                  ),
                ],
              ),
            if (_condition != null)
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  _BoxedIcon(
                    icon: Icons.language,
                    color: _condition.forecastAnomaly
                        ? constants.anomalyHighlight
                        : null,
                  ),
                  Text(
                    _condition.forecast,
                    style: _condition.forecastAnomaly
                        ? constants.smallTextStyle
                            .copyWith(color: constants.anomalyHighlight)
                        : constants.smallTextStyle,
                  ),
                  SizedBox(width: 4.0),
                  _BoxedIcon(
                    icon: Icons.place,
                    color: _condition.distanceAnomaly
                        ? constants.anomalyHighlight
                        : null,
                  ),
                  Text(
                    '${_condition.name.truncate(6, ellipsis: "…")} (${_condition.distance.toStringAsFixed(1)}${_condition.distanceUnit})',
                    style: _condition.distanceAnomaly
                        ? constants.smallTextStyle
                            .copyWith(color: constants.anomalyHighlight)
                        : constants.smallTextStyle,
                  ),
                  SizedBox(width: 4.0),
                  _BoxedIcon(
                    icon: Icons.schedule,
                    color: _condition.timestampAnomaly
                        ? constants.anomalyHighlight
                        : null,
                  ),
                  Text(
                    '${_condition.forecastTimestamp.toLocal().format(constants.dateTimePattern)}',
                    style: _condition.timestampAnomaly
                        ? constants.smallTextStyle
                            .copyWith(color: constants.anomalyHighlight)
                        : constants.smallTextStyle,
                  ),
                ],
              ),
            if (_fetchTimestamp != null)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    _BoxedIcon(icon: Icons.schedule),
                    Text(
                      _fetchTimestamp
                          .toLocal()
                          .format(constants.dateTimePattern),
                      style: constants.smallTextStyle,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  IconData _getConditionIcon() {
    switch (_condition.forecast) {
      case 'Rain (Day)':
        return WeatherIcons.day_rain;

      case 'Showers (Day)':
        return WeatherIcons.day_showers;

      case 'Thundery Showers (Day)':
        return WeatherIcons.day_storm_showers;

      case 'Fair (Day)':
        return WeatherIcons.day_sunny;

      case 'Hazy (Day)':
        return WeatherIcons.day_haze;

      case 'Partly Cloudy (Day)':
        return WeatherIcons.day_cloudy;

      case 'Cloudy':
        return WeatherIcons.cloud;

      case 'Overcast':
        return WeatherIcons.cloudy;

      case 'Rain (Night)':
        return WeatherIcons.night_alt_rain;

      case 'Showers (Night)':
        return WeatherIcons.night_alt_showers;

      case 'Thundery Showers (Night)':
        return WeatherIcons.night_alt_storm_showers;

      case 'Fair (Night)':
        return WeatherIcons.night_clear;

      case 'Hazy (Night)':
        return WeatherIcons.dust;

      case 'Partly Cloudy (Night)':
        return WeatherIcons.night_alt_cloudy;

      default:
        return WeatherIcons.na;
    }
  }

  Future<void> _fetchData() async {
    if (_fetchTimestamp == null ||
        DateTime.now().difference(_fetchTimestamp).abs() >
            constants.minFetchPeriod) {
      _fetchTimestamp = DateTime.now();

      Geoposition p = await Geolocation().getCurrentLocation();

      await Weather().fetchReadings(timestamp: _fetchTimestamp);

      setState(() {
        _airTemperature = Weather().nearestAirTemperature(p);
        _rainfall = Weather().nearestRainfall(p);
        _relativeHumidity = Weather().nearestRelativeHumidity(p);
        _wind = Weather().nearestWindDirectionWindSpeed(p);
        _condition = Weather().nearest2HourForecast(p);
      });
    }
  }
}

/// Wraps up an [Icon] in a similar fashion to [BoxedIcon].
class _BoxedIcon extends StatelessWidget {
  final IconData icon;

  final double size;

  final double rotation;

  final Color color;

  _BoxedIcon({
    @required this.icon,
    this.size = constants.smallIconSize,
    this.rotation,
    this.color,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size * 1.5,
      child: rotation != null
          ? Transform.rotate(
              angle: rotation,
              child: Icon(
                icon,
                size: size,
                color: color,
              ),
            )
          : Icon(
              icon,
              size: size,
              color: color,
            ),
    );
  }
}
