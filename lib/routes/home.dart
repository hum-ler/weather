import 'package:flutter/material.dart';

import 'package:weather_icons/weather_icons.dart';

import '../models/condition.dart';
import '../models/forecast.dart';
import '../models/geoposition.dart';
import '../models/reading.dart';
import '../routes/about.dart';
import '../services/geolocation.dart';
import '../services/weather.dart';
import '../themes/styles.dart';
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

  /// The nearest temperature reading.
  Reading _temperature;

  /// The nearest rainfall reading.
  Reading _rainfall;

  /// The nearest relative humidity reading.
  Reading _humidity;

  /// The nearest wind speed reading.
  Reading _windSpeed;

  /// The nearest wind direction reading.
  Reading _windDirection;

  /// The nearest PM2.5 reading.
  Reading _pm2_5;

  /// The nearest weather condition.
  Condition _condition;

  /// The nearest 24-hour forecast.
  List<Forecast> _forecasts;

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
                  child: AnimatedContainer(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/images/kucinta.jpg'),
                        fit: BoxFit.cover,
                        colorFilter: ColorFilter.mode(
                          Theme.of(context).brightness == Brightness.dark
                              ? Colors.black.withOpacity(0.5)
                              : Colors.white.withOpacity(0.75),
                          BlendMode.srcATop,
                        ),
                      ),
                    ),
                    height: MediaQuery.of(context).size.height -
                        Scaffold.of(context).appBarMaxHeight -
                        _getDetailsPanelHeight(),
                    duration: kThemeAnimationDuration,
                    curve: Curves.fastOutSlowIn,
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
                                    if (_temperature != null)
                                      Text(
                                        '${_temperature.value.round().toString()}°',
                                        style: _temperature.isValid
                                            ? largeTextStyle
                                            : (_temperature.isExpired
                                                ? largeTextStyle.copyWith(
                                                    color: outOfDateColor,
                                                  )
                                                : largeTextStyle.copyWith(
                                                    color: errorColor,
                                                  )),
                                      ),
                                    if (_condition != null)
                                      BoxedIcon(
                                        _condition.icon,
                                        size: largeIconSize,
                                        color: _condition.isValid
                                            ? null
                                            : _condition.isExpired
                                                ? outOfDateColor
                                                : errorColor,
                                      ),
                                  ],
                                ),
                                if (_forecasts != null)
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: <Widget>[
                                      for (Forecast forecast in _forecasts)
                                        _ForecastTile(
                                          icon: forecast.icon,
                                          label: forecast.type
                                              .toString()
                                              .asEnumLabel()
                                              .capitalize(),
                                          color: forecast.isValid
                                              ? null
                                              : forecast.isExpired
                                                  ? outOfDateColor
                                                  : errorColor,
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
              setState(() => _detailsPanelIsExpanded = !isExpanded);
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
                          _fetchTimestamp.toLocal().format(dateTimePattern),
                          style: smallTextStyle,
                        ),
                      ],
                    ),
                  );
                },
                body: Padding(
                  padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 20.0),
                  child: Column(
                    children: <Widget>[
                      if (_temperature != null)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            BoxedIcon(
                              WeatherIcons.thermometer,
                              size: smallIconSize,
                              color:
                                  _temperature.isInBounds ? null : errorColor,
                            ),
                            Text(
                              '${_temperature.value.toStringAsFixed(1)}${_temperature.unit}',
                              style: _temperature.isInBounds
                                  ? smallTextStyle
                                  : smallTextStyle.copyWith(color: errorColor),
                            ),
                            SizedBox(width: 4.0),
                            _BoxedIcon(
                              icon: Icons.place,
                              color: _temperature.isNearby ? null : errorColor,
                            ),
                            Text(
                              '${_temperature.provider.name.truncate(maxProviderNameLength, ellipsis: "…")} (${_temperature.distance.toStringAsFixed(1)}${_temperature.distanceUnit})',
                              style: _temperature.isNearby
                                  ? smallTextStyle
                                  : smallTextStyle.copyWith(color: errorColor),
                            ),
                            SizedBox(width: 4.0),
                            _BoxedIcon(
                              icon: Icons.schedule,
                              color: _temperature.isExpired ? errorColor : null,
                            ),
                            Text(
                              _temperature.creation.format(dateTimePattern),
                              style: _temperature.isExpired
                                  ? smallTextStyle.copyWith(color: errorColor)
                                  : smallTextStyle,
                            ),
                          ],
                        ),
                      if (_rainfall != null)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            BoxedIcon(
                              WeatherIcons.umbrella,
                              size: smallIconSize,
                              color: _rainfall.isInBounds ? null : errorColor,
                            ),
                            Text(
                              '${_rainfall.value.toStringAsFixed(1)}${_rainfall.unit}',
                              style: _rainfall.isInBounds
                                  ? smallTextStyle
                                  : smallTextStyle.copyWith(color: errorColor),
                            ),
                            SizedBox(width: 4.0),
                            _BoxedIcon(
                              icon: Icons.place,
                              color: _rainfall.isNearby ? null : errorColor,
                            ),
                            Text(
                              '${_rainfall.provider.name.truncate(maxProviderNameLength, ellipsis: "…")} (${_rainfall.distance.toStringAsFixed(1)}${_rainfall.distanceUnit})',
                              style: _rainfall.isNearby
                                  ? smallTextStyle
                                  : smallTextStyle.copyWith(color: errorColor),
                            ),
                            SizedBox(width: 4.0),
                            _BoxedIcon(
                              icon: Icons.schedule,
                              color: _rainfall.isExpired ? errorColor : null,
                            ),
                            Text(
                              _rainfall.creation.format(dateTimePattern),
                              style: _rainfall.isExpired
                                  ? smallTextStyle.copyWith(color: errorColor)
                                  : smallTextStyle,
                            ),
                          ],
                        ),
                      if (_humidity != null)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            BoxedIcon(
                              WeatherIcons.raindrop,
                              size: smallIconSize,
                              color: _humidity.isInBounds ? null : errorColor,
                            ),
                            Text(
                              '${_humidity.value.toStringAsFixed(1)}${_humidity.unit}',
                              style: _humidity.isInBounds
                                  ? smallTextStyle
                                  : smallTextStyle.copyWith(color: errorColor),
                            ),
                            SizedBox(width: 4.0),
                            _BoxedIcon(
                              icon: Icons.place,
                              color: _humidity.isNearby ? null : errorColor,
                            ),
                            Text(
                              '${_humidity.provider.name.truncate(maxProviderNameLength, ellipsis: "…")} (${_humidity.distance.toStringAsFixed(1)}${_humidity.distanceUnit})',
                              style: _humidity.isNearby
                                  ? smallTextStyle
                                  : smallTextStyle.copyWith(color: errorColor),
                            ),
                            SizedBox(width: 4.0),
                            _BoxedIcon(
                              icon: Icons.schedule,
                              color: _humidity.isExpired ? errorColor : null,
                            ),
                            Text(
                              _humidity.creation.format(dateTimePattern),
                              style: _humidity.isExpired
                                  ? smallTextStyle.copyWith(color: errorColor)
                                  : smallTextStyle,
                            ),
                          ],
                        ),
                      if (_windSpeed != null)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            BoxedIcon(
                              WeatherIcons.strong_wind,
                              size: smallIconSize,
                              color: _windSpeed.isInBounds ? null : errorColor,
                            ),
                            Text(
                                '${_windSpeed.value.toStringAsFixed(1)}${_windSpeed.unit}',
                                style: _windSpeed.isInBounds
                                    ? smallTextStyle
                                    : smallTextStyle.copyWith(
                                        color: errorColor)),
                            SizedBox(width: 4.0),
                            _BoxedIcon(
                              icon: Icons.place,
                              color: _windSpeed.isNearby &&
                                      _windSpeed.provider.id ==
                                          _windDirection?.provider?.id
                                  ? null
                                  : errorColor,
                            ),
                            Text(
                              '${_windSpeed.provider.name.truncate(maxProviderNameLength, ellipsis: "…")} (${_windSpeed.distance.toStringAsFixed(1)}${_windSpeed.distanceUnit})',
                              style: _windSpeed.isNearby &&
                                      _windSpeed.provider.id ==
                                          _windDirection?.provider?.id
                                  ? smallTextStyle
                                  : smallTextStyle.copyWith(color: errorColor),
                            ),
                            SizedBox(width: 4.0),
                            _BoxedIcon(
                              icon: Icons.schedule,
                              color: _windSpeed.isExpired ? errorColor : null,
                            ),
                            Text(
                              _windSpeed.creation.format(dateTimePattern),
                              style: _windSpeed.isExpired
                                  ? smallTextStyle.copyWith(color: errorColor)
                                  : smallTextStyle,
                            ),
                          ],
                        ),
                      if (_windDirection != null)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            _BoxedIcon(
                              icon: Icons.navigation,
                              rotation: degreesToRadians(
                                _windDirection.value.toDouble(),
                              ),
                              color:
                                  _windDirection.isInBounds ? null : errorColor,
                            ),
                            Text(
                              '${_windDirection.value.toString()}${_windDirection.unit}',
                              style: _windDirection.isInBounds
                                  ? smallTextStyle
                                  : smallTextStyle.copyWith(color: errorColor),
                            ),
                            SizedBox(width: 4.0),
                            _BoxedIcon(
                              icon: Icons.place,
                              color: _windDirection.isNearby &&
                                      _windDirection.provider.id ==
                                          _windSpeed?.provider?.id
                                  ? null
                                  : errorColor,
                            ),
                            Text(
                              '${_windDirection.provider.name.truncate(maxProviderNameLength, ellipsis: "…")} (${_windDirection.distance.toStringAsFixed(1)}${_windDirection.distanceUnit})',
                              style: _windDirection.isNearby &&
                                      _windDirection.provider.id ==
                                          _windSpeed?.provider?.id
                                  ? smallTextStyle
                                  : smallTextStyle.copyWith(color: errorColor),
                            ),
                            SizedBox(width: 4.0),
                            _BoxedIcon(
                              icon: Icons.schedule,
                              color:
                                  _windDirection.isExpired ? errorColor : null,
                            ),
                            Text(
                              _windDirection.creation.format(dateTimePattern),
                              style: _windDirection.isExpired
                                  ? smallTextStyle.copyWith(color: errorColor)
                                  : smallTextStyle,
                            ),
                          ],
                        ),
                      if (_pm2_5 != null)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            _BoxedIcon(
                              icon: Icons.grain,
                              size: smallIconSize,
                              color: _pm2_5.isInBounds ? null : errorColor,
                            ),
                            Text(
                              '${_pm2_5.value.toString()}${_pm2_5.unit}',
                              style: _pm2_5.isInBounds
                                  ? smallTextStyle
                                  : smallTextStyle.copyWith(color: errorColor),
                            ),
                            SizedBox(width: 4.0),
                            _BoxedIcon(
                              icon: Icons.place,
                              color: _pm2_5.isNearby ? null : errorColor,
                            ),
                            Text(
                              '${_pm2_5.provider.name.capitalize()} (${_pm2_5.distance.toStringAsFixed(1)}${_pm2_5.distanceUnit})',
                              style: _pm2_5.isNearby
                                  ? smallTextStyle
                                  : smallTextStyle.copyWith(color: errorColor),
                            ),
                            SizedBox(width: 4.0),
                            _BoxedIcon(
                              icon: Icons.schedule,
                              color: _pm2_5.isExpired ? errorColor : null,
                            ),
                            Text(
                              _pm2_5.creation.format(dateTimePattern),
                              style: _pm2_5.isExpired
                                  ? smallTextStyle.copyWith(color: errorColor)
                                  : smallTextStyle,
                            ),
                          ],
                        ),
                      if (_condition != null)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            _BoxedIcon(
                              icon: Icons.language,
                              color: _condition.icon == WeatherIcons.na
                                  ? errorColor
                                  : null,
                            ),
                            Text(
                              _condition.condition.truncate(
                                maxConditionLength,
                                ellipsis: '…',
                              ),
                              style: _condition.icon == WeatherIcons.na
                                  ? smallTextStyle.copyWith(color: errorColor)
                                  : smallTextStyle,
                            ),
                            SizedBox(width: 4.0),
                            _BoxedIcon(
                              icon: Icons.place,
                              color: _condition.isNearby ? null : errorColor,
                            ),
                            Text(
                              '${_condition.provider.name.truncate(maxProviderNameLength, ellipsis: "…")} (${_condition.distance.toStringAsFixed(1)}${_condition.distanceUnit})',
                              style: _condition.isNearby
                                  ? smallTextStyle
                                  : smallTextStyle.copyWith(color: errorColor),
                            ),
                            SizedBox(width: 4.0),
                            _BoxedIcon(
                              icon: Icons.schedule,
                              color: _condition.isExpired ? errorColor : null,
                            ),
                            Text(
                              _condition.creation.format(dateTimePattern),
                              style: _condition.isExpired
                                  ? smallTextStyle.copyWith(color: errorColor)
                                  : smallTextStyle,
                            ),
                          ],
                        ),
                      if (_forecasts != null)
                        for (Forecast forecast in _forecasts)
                          Row(
                            children: <Widget>[
                              _BoxedIcon(icon: Icons.schedule),
                              Text(
                                forecast.type
                                    .toString()
                                    .asEnumLabel()
                                    .capitalize(),
                                style: smallTextStyle,
                              ),
                              SizedBox(width: 4.0),
                              _BoxedIcon(
                                icon: Icons.language,
                                color: forecast.icon == WeatherIcons.na
                                    ? errorColor
                                    : null,
                              ),
                              Text(
                                forecast.condition.truncate(
                                  maxConditionLength,
                                  ellipsis: '…',
                                ),
                                style: forecast.icon == WeatherIcons.na
                                    ? smallTextStyle.copyWith(
                                        color: errorColor,
                                      )
                                    : smallTextStyle,
                              ),
                              SizedBox(width: 4.0),
                              _BoxedIcon(
                                icon: Icons.place,
                                color: forecast.isNearby ? null : errorColor,
                              ),
                              Text(
                                '${forecast.provider.name.capitalize()} (${forecast.distance.toStringAsFixed(1)}${forecast.distanceUnit})',
                                style: forecast.isNearby
                                    ? smallTextStyle
                                    : smallTextStyle.copyWith(
                                        color: errorColor,
                                      ),
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

  /// Fetches the weather data.
  Future<void> _fetchData() async {
    setState(() => _fetchTimestamp = DateTime.now());

    Geoposition userLocation = await Geolocation().getCurrentLocation();

    await Weather().fetchReadings(
      timestamp: _fetchTimestamp,
      userLocation: userLocation,
    );

    setState(() {
      _temperature = Weather().getNearestTemperatureReading();
      _rainfall = Weather().getNearestRainfallReading();
      _humidity = Weather().getNearestHumidityReading();
      _windSpeed = Weather().getNearestWindSpeedReading();
      _windDirection = Weather().getNearestWindDirectionReading();
      _pm2_5 = Weather().getNearestPM2_5Reading();
      _condition = Weather().getNearestCondition();
      _forecasts = Weather().getNearest24HourForecast();
    });
  }

  /// Gets the height of the details panel.
  ///
  /// This might be impossible to get programmatically the panel has not been
  /// built yet. The values here are observed from Flutter Inspector.
  int _getDetailsPanelHeight() => _detailsPanelIsExpanded ? 224 : 56;
}

/// Displays a [Forecast] with an icon and label.
class _ForecastTile extends StatelessWidget {
  final IconData icon;

  final String label;

  final Color color;

  const _ForecastTile({
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
            size: mediumIconSize,
            color: color,
          ),
          SizedBox(height: 4.0),
          Text(
            label,
            style: color != null
                ? mediumTextStyle.copyWith(color: color)
                : mediumTextStyle,
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
    this.size = smallIconSize,
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
