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

class _HomeState extends State<Home> with WidgetsBindingObserver {
  /// The timestamp of the last [_fetchData()] call.
  DateTime _fetchTimestamp;

  NearestStation _airTemperature;
  NearestStation _rainfall;
  NearestStation _relativeHumidity;
  NearestStation _wind;
  NearestForecastArea _condition;

  /// Generate a key for the refresh indicator.
  ///
  /// Can be used to call [RefreshIndicator.show()] manually.
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
      ..addObserver(this)
      ..addPostFrameCallback((_) => _refreshIndicatorKey.currentState.show());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed) {
      _refreshIndicatorKey.currentState.show();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Weather — Right Here, Right Now'),
      ),
      body: RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: () => _fetchData(),
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: Container(
              height: MediaQuery.of(context).size.height -
                  Scaffold.of(context).appBarMaxHeight,
              child: Padding(
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
                                  ? constants.largeTextStyle.copyWith(
                                      color: constants.anomalyHighlight)
                                  : constants.largeTextStyle,
                            ),
                          if (_condition != null)
                            BoxedIcon(
                              _getConditionIcon(_condition.forecast),
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
                            '${_airTemperature.name.truncate(constants.maxStationAreaNameLength, ellipsis: "…")} (${_airTemperature.distance.toStringAsFixed(1)}${_airTemperature.distanceUnit})',
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
                            '${_rainfall.name.truncate(constants.maxStationAreaNameLength, ellipsis: "…")} (${_rainfall.distance.toStringAsFixed(1)}${_rainfall.distanceUnit})',
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
                            '${_relativeHumidity.name.truncate(constants.maxStationAreaNameLength, ellipsis: "…")} (${_relativeHumidity.distance.toStringAsFixed(1)}${_relativeHumidity.distanceUnit})',
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
                            rotation: degreesToRadians(
                                _wind.windDirection.toDouble()),
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
                            '${_wind.name.truncate(constants.maxStationAreaNameLength, ellipsis: "…")} (${_wind.distance.toStringAsFixed(1)}${_wind.distanceUnit})',
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
                            _condition.forecast.truncate(
                              constants.maxConditionLength,
                              ellipsis: '…',
                            ),
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
                            '${_condition.name.truncate(constants.maxStationAreaNameLength, ellipsis: "…")} (${_condition.distance.toStringAsFixed(1)}${_condition.distanceUnit})',
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
            ),
          ),
        ),
      ),
    );
  }

  /// Gets the graphic representation of [condition].
  IconData _getConditionIcon(String condition) {
    Map<String, IconData> conditionIcons = {
      'Cloudy': WeatherIcons.cloudy,
      'Fair (Day)': WeatherIcons.day_sunny,
      'Fair (Night)': WeatherIcons.night_clear,
      'Hazy': WeatherIcons.dust,
      'Hazy (Day)': WeatherIcons.day_haze,
      'Hazy (Night)': WeatherIcons.dust,
      'Heavy Thundery Showers': WeatherIcons.storm_showers,
      'Heavy Thundery Showers with Gusty Winds': WeatherIcons.storm_showers,
      'Light Rain': WeatherIcons.rain,
      'Moderate Rain': WeatherIcons.rain,
      'Overcast': WeatherIcons.cloudy,
      'Partly Cloudy': WeatherIcons.cloud,
      'Partly Cloudy (Day)': WeatherIcons.day_sunny_overcast,
      'Partly Cloudy (Night)': WeatherIcons.night_alt_partly_cloudy,
      'Rain': WeatherIcons.rain,
      'Rain (Day)': WeatherIcons.day_rain,
      'Rain (Night)': WeatherIcons.night_alt_rain,
      'Showers': WeatherIcons.showers,
      'Showers (Day)': WeatherIcons.day_showers,
      'Showers (Night)': WeatherIcons.night_alt_showers,
      'Thundery Showers': WeatherIcons.storm_showers,
      'Thundery Showers (Day)': WeatherIcons.day_storm_showers,
      'Thundery Showers (Night)': WeatherIcons.night_alt_storm_showers,
      'Windy': WeatherIcons.strong_wind,
    };

    if (conditionIcons.containsKey(condition)) return conditionIcons[condition];

    return WeatherIcons.na;
  }

  Future<void> _fetchData() async {
    // Perform a fetch only if we meet minFetchPeriod.
    if (_fetchTimestamp == null ||
        DateTime.now().difference(_fetchTimestamp).abs() >
            constants.minFetchPeriod) {
      // Wipe the interface entirely except for the timestamp.
      setState(() {
        _airTemperature = null;
        _rainfall = null;
        _relativeHumidity = null;
        _wind = null;
        _condition = null;
        _fetchTimestamp = DateTime.now();
      });

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

  /// The angle of rotation in radians.
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
