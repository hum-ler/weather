import 'package:flutter/material.dart';

import 'package:weather_icons/weather_icons.dart';

import '../models/forecast_area.dart';
import '../models/forecast_region.dart';
import '../models/geoposition.dart';
import '../models/station.dart';
import '../pages/about.dart';
import '../services/geolocation.dart';
import '../services/weather.dart';
import '../utils/config.dart' as config;
import '../utils/date_time_ext.dart';
import '../utils/math_utils.dart';
import '../utils/string_ext.dart';
import '../widgets/reversed_expansion_panel_list.dart';

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
  NearestForecastRegion _region;

  /// Generate a key for the refresh indicator.
  ///
  /// Can be used to call [RefreshIndicator.show()] manually.
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  /// Indicates whether the details panel is expanded.
  bool _detailsPanelIsExpanded = false;

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
        title: Text('Weather · Right Here · Right Now'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.help),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => About()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: RefreshIndicator(
              key: _refreshIndicatorKey,
              onRefresh: () => _fetchData(),
              child: LayoutBuilder(
                builder: (context, constraints) => SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  child: Container(
                    height: MediaQuery.of(context).size.height -
                        Scaffold.of(context).appBarMaxHeight -
                        // TODO: Get the height of details panel header.
                        // May be impossible because it has not been built yet.
                        // Value here is from Flutter Inspector.
                        56,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    if (_airTemperature != null)
                                      Text(
                                        '${_airTemperature.airTemperature.round().toString()}°',
                                        style: _airTemperature.readingAnomaly ||
                                                _airTemperature
                                                    .timestampAnomaly ||
                                                _airTemperature.distanceAnomaly
                                            ? config.largeTextStyle.copyWith(
                                                color: config.anomalyHighlight)
                                            : config.largeTextStyle,
                                      ),
                                    if (_condition != null)
                                      BoxedIcon(
                                        _getConditionIcon(_condition.forecast),
                                        size: config.largeIconSize,
                                        color: _condition.forecastAnomaly ||
                                                _condition.timestampAnomaly ||
                                                _condition.distanceAnomaly
                                            ? config.anomalyHighlight
                                            : null,
                                      ),
                                  ],
                                ),
                                if (_region != null)
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: <Widget>[
                                      for (ForecastChunk forecastChunk
                                          in _region.forecastOrder)
                                        _ForecastChunk(
                                          icon: _getConditionIcon(
                                            _region.forecasts[forecastChunk],
                                          ),
                                          label: forecastChunk
                                              .toString()
                                              .asEnumLabel()
                                              .capitalize(),
                                          color: _region.forecastAnomaly ||
                                                  _region.distanceAnomaly ||
                                                  _region.timestampAnomaly
                                              ? config.anomalyHighlight
                                              : null,
                                        ),
                                    ],
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
          ),
          ReversedExpansionPanelList(
            expansionCallback: (int index, bool isExpanded) {
              setState(() {
                _detailsPanelIsExpanded = !isExpanded;
              });
            },
            expandedHeaderPadding: null,
            children: <ExpansionPanel>[
              ExpansionPanel(
                isExpanded: _detailsPanelIsExpanded,
                canTapOnHeader: true,
                headerBuilder: (BuildContext context, bool isExpanded) {
                  if (_fetchTimestamp == null) return Container();

                  return Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        _BoxedIcon(icon: Icons.schedule),
                        Text(
                          _fetchTimestamp
                              .toLocal()
                              .format(config.dateTimePattern),
                          style: config.smallTextStyle,
                        ),
                      ],
                    ),
                  );
                },
                body: Padding(
                  padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 20.0),
                  child: Column(
                    children: <Widget>[
                      if (_airTemperature != null)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            BoxedIcon(
                              WeatherIcons.thermometer,
                              size: config.smallIconSize,
                              color: _airTemperature.readingAnomaly
                                  ? config.anomalyHighlight
                                  : null,
                            ),
                            Text(
                              '${_airTemperature.airTemperature.toStringAsFixed(1)}${_airTemperature.airTemperatureUnit}',
                              style: _airTemperature.readingAnomaly
                                  ? config.smallTextStyle
                                      .copyWith(color: config.anomalyHighlight)
                                  : config.smallTextStyle,
                            ),
                            SizedBox(width: 4.0),
                            _BoxedIcon(
                              icon: Icons.place,
                              color: _airTemperature.distanceAnomaly
                                  ? config.anomalyHighlight
                                  : null,
                            ),
                            Text(
                              '${_airTemperature.name.truncate(config.maxStationAreaNameLength, ellipsis: "…")} (${_airTemperature.distance.toStringAsFixed(1)}${_airTemperature.distanceUnit})',
                              style: _airTemperature.distanceAnomaly
                                  ? config.smallTextStyle
                                      .copyWith(color: config.anomalyHighlight)
                                  : config.smallTextStyle,
                            ),
                            SizedBox(width: 4.0),
                            _BoxedIcon(
                              icon: Icons.schedule,
                              color: _airTemperature.timestampAnomaly
                                  ? config.anomalyHighlight
                                  : null,
                            ),
                            Text(
                              '${_airTemperature.airTemperatureTimestamp.toLocal().format(config.dateTimePattern)}',
                              style: _airTemperature.timestampAnomaly
                                  ? config.smallTextStyle
                                      .copyWith(color: config.anomalyHighlight)
                                  : config.smallTextStyle,
                            ),
                          ],
                        ),
                      if (_rainfall != null)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            BoxedIcon(
                              WeatherIcons.umbrella,
                              size: config.smallIconSize,
                              color: _rainfall.readingAnomaly
                                  ? config.anomalyHighlight
                                  : null,
                            ),
                            Text(
                              '${_rainfall.rainfall.toStringAsFixed(1)}${_rainfall.rainfallUnit}',
                              style: _rainfall.readingAnomaly
                                  ? config.smallTextStyle
                                      .copyWith(color: config.anomalyHighlight)
                                  : config.smallTextStyle,
                            ),
                            SizedBox(width: 4.0),
                            _BoxedIcon(
                              icon: Icons.place,
                              color: _rainfall.distanceAnomaly
                                  ? config.anomalyHighlight
                                  : null,
                            ),
                            Text(
                              '${_rainfall.name.truncate(config.maxStationAreaNameLength, ellipsis: "…")} (${_rainfall.distance.toStringAsFixed(1)}${_rainfall.distanceUnit})',
                              style: _rainfall.distanceAnomaly
                                  ? config.smallTextStyle
                                      .copyWith(color: config.anomalyHighlight)
                                  : config.smallTextStyle,
                            ),
                            SizedBox(width: 4.0),
                            _BoxedIcon(
                              icon: Icons.schedule,
                              color: _rainfall.timestampAnomaly
                                  ? config.anomalyHighlight
                                  : null,
                            ),
                            Text(
                              '${_rainfall.rainfallTimestamp.toLocal().format(config.dateTimePattern)}',
                              style: _rainfall.timestampAnomaly
                                  ? config.smallTextStyle
                                      .copyWith(color: config.anomalyHighlight)
                                  : config.smallTextStyle,
                            ),
                          ],
                        ),
                      if (_relativeHumidity != null)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            BoxedIcon(
                              WeatherIcons.raindrop,
                              size: config.smallIconSize,
                              color: _relativeHumidity.readingAnomaly
                                  ? config.anomalyHighlight
                                  : null,
                            ),
                            Text(
                              '${_relativeHumidity.relativeHumidity.toStringAsFixed(1)}${_relativeHumidity.relativeHumidityUnit}',
                              style: _relativeHumidity.readingAnomaly
                                  ? config.smallTextStyle
                                      .copyWith(color: config.anomalyHighlight)
                                  : config.smallTextStyle,
                            ),
                            SizedBox(width: 4.0),
                            _BoxedIcon(
                              icon: Icons.place,
                              color: _relativeHumidity.distanceAnomaly
                                  ? config.anomalyHighlight
                                  : null,
                            ),
                            Text(
                              '${_relativeHumidity.name.truncate(config.maxStationAreaNameLength, ellipsis: "…")} (${_relativeHumidity.distance.toStringAsFixed(1)}${_relativeHumidity.distanceUnit})',
                              style: _relativeHumidity.distanceAnomaly
                                  ? config.smallTextStyle
                                      .copyWith(color: config.anomalyHighlight)
                                  : config.smallTextStyle,
                            ),
                            SizedBox(width: 4.0),
                            _BoxedIcon(
                              icon: Icons.schedule,
                              color: _relativeHumidity.timestampAnomaly
                                  ? config.anomalyHighlight
                                  : null,
                            ),
                            Text(
                              '${_relativeHumidity.relativeHumidityTimestamp.toLocal().format(config.dateTimePattern)}',
                              style: _relativeHumidity.timestampAnomaly
                                  ? config.smallTextStyle
                                      .copyWith(color: config.anomalyHighlight)
                                  : config.smallTextStyle,
                            ),
                          ],
                        ),
                      if (_wind != null)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            BoxedIcon(
                              WeatherIcons.strong_wind,
                              size: config.smallIconSize,
                              color: _wind.readingAnomaly
                                  ? config.anomalyHighlight
                                  : null,
                            ),
                            Text(
                              '${_wind.windSpeed.toStringAsFixed(1)}${_wind.windSpeedUnit}',
                              style: _wind.readingAnomaly
                                  ? config.smallTextStyle
                                      .copyWith(color: config.anomalyHighlight)
                                  : config.smallTextStyle,
                            ),
                            SizedBox(width: 4.0),
                            _BoxedIcon(
                              icon: Icons.navigation,
                              rotation: degreesToRadians(
                                _wind.windDirection.toDouble(),
                              ),
                              color: _wind.readingAnomaly
                                  ? config.anomalyHighlight
                                  : null,
                            ),
                            Text(
                              '${_wind.windDirection.toString()}${_wind.windDirectionUnit}',
                              style: _wind.readingAnomaly
                                  ? config.smallTextStyle
                                      .copyWith(color: config.anomalyHighlight)
                                  : config.smallTextStyle,
                            ),
                            SizedBox(width: 4.0),
                            _BoxedIcon(
                              icon: Icons.place,
                              color: _wind.distanceAnomaly
                                  ? config.anomalyHighlight
                                  : null,
                            ),
                            Text(
                              '${_wind.name.truncate(config.maxStationAreaNameLength, ellipsis: "…")} (${_wind.distance.toStringAsFixed(1)}${_wind.distanceUnit})',
                              style: _wind.distanceAnomaly
                                  ? config.smallTextStyle
                                      .copyWith(color: config.anomalyHighlight)
                                  : config.smallTextStyle,
                            ),
                            SizedBox(width: 4.0),
                            _BoxedIcon(
                              icon: Icons.schedule,
                              color: _wind.timestampAnomaly
                                  ? config.anomalyHighlight
                                  : null,
                            ),
                            Text(
                              '${_wind.windSpeedTimestamp.toLocal().format(config.dateTimePattern)}',
                              style: _wind.timestampAnomaly
                                  ? config.smallTextStyle
                                      .copyWith(color: config.anomalyHighlight)
                                  : config.smallTextStyle,
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
                                  ? config.anomalyHighlight
                                  : null,
                            ),
                            Text(
                              _condition.forecast.truncate(
                                config.maxConditionLength,
                                ellipsis: '…',
                              ),
                              style: _condition.forecastAnomaly
                                  ? config.smallTextStyle
                                      .copyWith(color: config.anomalyHighlight)
                                  : config.smallTextStyle,
                            ),
                            SizedBox(width: 4.0),
                            _BoxedIcon(
                              icon: Icons.place,
                              color: _condition.distanceAnomaly
                                  ? config.anomalyHighlight
                                  : null,
                            ),
                            Text(
                              '${_condition.name.truncate(config.maxStationAreaNameLength, ellipsis: "…")} (${_condition.distance.toStringAsFixed(1)}${_condition.distanceUnit})',
                              style: _condition.distanceAnomaly
                                  ? config.smallTextStyle
                                      .copyWith(color: config.anomalyHighlight)
                                  : config.smallTextStyle,
                            ),
                            SizedBox(width: 4.0),
                            _BoxedIcon(
                              icon: Icons.schedule,
                              color: _condition.timestampAnomaly
                                  ? config.anomalyHighlight
                                  : null,
                            ),
                            Text(
                              '${_condition.forecastTimestamp.toLocal().format(config.dateTimePattern)}',
                              style: _condition.timestampAnomaly
                                  ? config.smallTextStyle
                                      .copyWith(color: config.anomalyHighlight)
                                  : config.smallTextStyle,
                            ),
                          ],
                        ),
                      if (_region != null)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            _BoxedIcon(
                              icon: Icons.language,
                              color: _region.forecastAnomaly
                                  ? config.anomalyHighlight
                                  : null,
                            ),
                            Text(
                              _region.overallForecast.truncate(
                                config.maxConditionLength,
                                ellipsis: '…',
                              ),
                              style: _region.forecastAnomaly
                                  ? config.smallTextStyle
                                      .copyWith(color: config.anomalyHighlight)
                                  : config.smallTextStyle,
                            ),
                            SizedBox(width: 4.0),
                            _BoxedIcon(
                              icon: Icons.place,
                              color: _region.distanceAnomaly
                                  ? config.anomalyHighlight
                                  : null,
                            ),
                            Text(
                              '${_region.name.capitalize()} (${_condition.distance.toStringAsFixed(1)}${_condition.distanceUnit})',
                              style: _region.distanceAnomaly
                                  ? config.smallTextStyle
                                      .copyWith(color: config.anomalyHighlight)
                                  : config.smallTextStyle,
                            ),
                            SizedBox(width: 4.0),
                            _BoxedIcon(
                              icon: Icons.schedule,
                              color: _region.timestampAnomaly
                                  ? config.anomalyHighlight
                                  : null,
                            ),
                            Text(
                              '${_region.timestamp.toLocal().format(config.dateTimePattern)}',
                              style: _region.timestampAnomaly
                                  ? config.smallTextStyle
                                      .copyWith(color: config.anomalyHighlight)
                                  : config.smallTextStyle,
                            ),
                          ],
                        ),
                      if (_region != null)
                        for (ForecastChunk forecastChunk
                            in _region.forecastOrder)
                          Row(
                            children: <Widget>[
                              _BoxedIcon(
                                icon: Icons.keyboard_arrow_right,
                                color: _region.forecastAnomaly
                                    ? config.anomalyHighlight
                                    : null,
                              ),
                              _BoxedIcon(
                                icon: Icons.schedule,
                                color: _region.forecastAnomaly
                                    ? config.anomalyHighlight
                                    : null,
                              ),
                              Text(
                                forecastChunk
                                    .toString()
                                    .asEnumLabel()
                                    .capitalize(),
                                style: _region.forecastAnomaly
                                    ? config.smallTextStyle.copyWith(
                                        color: config.anomalyHighlight,
                                      )
                                    : config.smallTextStyle,
                              ),
                              SizedBox(width: 4.0),
                              _BoxedIcon(
                                icon: Icons.language,
                                color: _region.forecastAnomaly
                                    ? config.anomalyHighlight
                                    : null,
                              ),
                              Text(
                                _region.forecasts[forecastChunk],
                                style: _region.forecastAnomaly
                                    ? config.smallTextStyle.copyWith(
                                        color: config.anomalyHighlight,
                                      )
                                    : config.smallTextStyle,
                              ),
                            ],
                          ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ],
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
      'Light Showers': WeatherIcons.showers,
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
            config.minFetchPeriod) {
      // Wipe the interface entirely except for the timestamp.
      setState(() {
        _airTemperature = null;
        _rainfall = null;
        _relativeHumidity = null;
        _wind = null;
        _condition = null;
        _region = null;
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
        _region = Weather().nearest24HourForecast(p);
      });
    }
  }
}

/// Displays the forecast for a [ForecastChunk].
class _ForecastChunk extends StatelessWidget {
  final IconData icon;

  final String label;

  final Color color;

  const _ForecastChunk({
    @required this.icon,
    @required this.label,
    this.color,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(minWidth: 74.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          BoxedIcon(
            icon,
            size: config.mediumIconSize,
            color: color,
          ),
          SizedBox(height: 4.0),
          Text(
            label,
            style: color != null
                ? config.mediumTextStyle.copyWith(color: color)
                : config.mediumTextStyle,
          ),
        ],
      ),
    );
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
    this.size = config.smallIconSize,
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
