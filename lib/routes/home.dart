import 'package:flutter/material.dart';

import 'package:rubber/rubber.dart';
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

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
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

  /// Generate a key for the scaffold.
  ///
  /// Can be used to show the snackbar.
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  /// Generate a key for the refresh indicator.
  ///
  /// Can be used to call [RefreshIndicator.show()] manually.
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  /// The size of the details layer handle.
  final double _detailsLayerHandleSize = 100.0;

  /// The height of the details layer when opened.
  final double _detailsLayerHeight = 280.0;

  /// The opacity of the summary layer.
  ///
  /// Used to soften the transition between changes.
  double _summaryLayerOpacity = 1.0;

  /// The animation controller for the bottom sheet.
  RubberAnimationController _animationController;

  /// The animation used by the rotating icon.
  Animation _animation;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance
      ..addObserver(this)
      ..addPostFrameCallback((_) {
        _initAnimation();
        _refreshIndicatorKey.currentState.show();
      });

    _animationController = RubberAnimationController(
      vsync: this,
      lowerBoundValue: AnimationControllerValue(pixel: _detailsLayerHandleSize),
      upperBoundValue: AnimationControllerValue(pixel: _detailsLayerHeight),
      springDescription: SpringDescription.withDampingRatio(
        mass: 1,
        stiffness: Stiffness.HIGH,
        ratio: DampingRatio.HIGH_BOUNCY,
      ),
      duration: const Duration(milliseconds: 300),
    );

    // Set up a dummy animation for now so that build() wouldn't crash.
    _animation = CurvedAnimation(
      curve: Curves.linear,
      parent: _animationController,
    );

    _summaryLayerOpacity = 0.0;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    if (_animationController != null) _animationController.dispose();

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
      key: _scaffoldKey,
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
      body: RubberBottomSheet(
        lowerLayer: _getSummaryLayer(),
        upperLayer: _getDetailsLayer(),
        animationController: _animationController,
      ),
    );
  }

  /// Gets the summary layer.
  ///
  /// Displays the main info with the background image.
  Widget _getSummaryLayer() {
    return RefreshIndicator(
      key: _refreshIndicatorKey,
      onRefresh: () => _fetchData(),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: _summaryLayerOpacity,
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(_getBackgroundAsset()),
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
                    Scaffold.of(context).appBarMaxHeight,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          if (_temperature != null)
                            Text(
                              '${_temperature.value.round()}°',
                              style: _temperature.isValid
                                  ? largeText
                                  : _temperature.isExpired
                                      ? largeTextWithOutOfDate
                                      : largeTextWithError,
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
                          crossAxisAlignment: CrossAxisAlignment.center,
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
                      SizedBox(height: Scaffold.of(context).appBarMaxHeight),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Gets the details layer.
  ///
  /// Goes into the bottom sheet.
  Widget _getDetailsLayer() {
    return ListView(
      padding: const EdgeInsets.all(8.0),
      physics: NeverScrollableScrollPhysics(),
      children: <Widget>[
        Container(
          height: _detailsLayerHandleSize,
          padding: const EdgeInsets.only(bottom: 8.0),
          alignment: Alignment.bottomCenter,
          child: RotationTransition(
            turns: _animation,
            child: Icon(
              Icons.keyboard_arrow_up,
              size: 32.0,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? Theme.of(context).canvasColor.withOpacity(0.75)
                : Theme.of(context).canvasColor.withOpacity(0.5),
            borderRadius: BorderRadius.all(Radius.circular(6.0)),
          ),
          child: Column(
            children: <Widget>[
              if (_temperature != null)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    BoxedIcon(
                      WeatherIcons.thermometer,
                      size: smallIconSize,
                      color: _temperature.isInBounds ? null : errorColor,
                    ),
                    Text(
                      '${_temperature.value.toStringAsFixed(1)}${_temperature.unit}',
                      style: _temperature.isInBounds
                          ? smallText
                          : smallTextWithError,
                    ),
                    SizedBox(width: 4.0),
                    _BoxedIcon(
                      icon: Icons.place,
                      color: _temperature.isNearby ? null : errorColor,
                    ),
                    Text(
                      '${_temperature.provider.name.truncate(maxProviderNameLength, ellipsis: "…")} (${_temperature.distance.toStringAsFixed(1)}${_temperature.distanceUnit})',
                      style: _temperature.isNearby
                          ? smallText
                          : smallTextWithError,
                    ),
                    SizedBox(width: 4.0),
                    _BoxedIcon(
                      icon: Icons.schedule,
                      color: _temperature.isExpired ? errorColor : null,
                    ),
                    Text(
                      _temperature.creation.format(dateTimePattern),
                      style: _temperature.isExpired
                          ? smallTextWithError
                          : smallText,
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
                      style:
                          _rainfall.isInBounds ? smallText : smallTextWithError,
                    ),
                    SizedBox(width: 4.0),
                    _BoxedIcon(
                      icon: Icons.place,
                      color: _rainfall.isNearby ? null : errorColor,
                    ),
                    Text(
                      '${_rainfall.provider.name.truncate(maxProviderNameLength, ellipsis: "…")} (${_rainfall.distance.toStringAsFixed(1)}${_rainfall.distanceUnit})',
                      style:
                          _rainfall.isNearby ? smallText : smallTextWithError,
                    ),
                    SizedBox(width: 4.0),
                    _BoxedIcon(
                      icon: Icons.schedule,
                      color: _rainfall.isExpired ? errorColor : null,
                    ),
                    Text(
                      _rainfall.creation.format(dateTimePattern),
                      style:
                          _rainfall.isExpired ? smallTextWithError : smallText,
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
                      style:
                          _humidity.isInBounds ? smallText : smallTextWithError,
                    ),
                    SizedBox(width: 4.0),
                    _BoxedIcon(
                      icon: Icons.place,
                      color: _humidity.isNearby ? null : errorColor,
                    ),
                    Text(
                      '${_humidity.provider.name.truncate(maxProviderNameLength, ellipsis: "…")} (${_humidity.distance.toStringAsFixed(1)}${_humidity.distanceUnit})',
                      style:
                          _humidity.isNearby ? smallText : smallTextWithError,
                    ),
                    SizedBox(width: 4.0),
                    _BoxedIcon(
                      icon: Icons.schedule,
                      color: _humidity.isExpired ? errorColor : null,
                    ),
                    Text(
                      _humidity.creation.format(dateTimePattern),
                      style:
                          _humidity.isExpired ? smallTextWithError : smallText,
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
                          ? smallText
                          : smallTextWithError,
                    ),
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
                          ? smallText
                          : smallTextWithError,
                    ),
                    SizedBox(width: 4.0),
                    _BoxedIcon(
                      icon: Icons.schedule,
                      color: _windSpeed.isExpired ? errorColor : null,
                    ),
                    Text(
                      _windSpeed.creation.format(dateTimePattern),
                      style:
                          _windSpeed.isExpired ? smallTextWithError : smallText,
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
                      color: _windDirection.isInBounds ? null : errorColor,
                    ),
                    Text(
                      '${_windDirection.value}${_windDirection.unit}',
                      style: _windDirection.isInBounds
                          ? smallText
                          : smallTextWithError,
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
                          ? smallText
                          : smallTextWithError,
                    ),
                    SizedBox(width: 4.0),
                    _BoxedIcon(
                      icon: Icons.schedule,
                      color: _windDirection.isExpired ? errorColor : null,
                    ),
                    Text(
                      _windDirection.creation.format(dateTimePattern),
                      style: _windDirection.isExpired
                          ? smallTextWithError
                          : smallText,
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
                      '${_pm2_5.value}${_pm2_5.unit}',
                      style: _pm2_5.isInBounds ? smallText : smallTextWithError,
                    ),
                    SizedBox(width: 4.0),
                    _BoxedIcon(
                      icon: Icons.place,
                      color: _pm2_5.isNearby ? null : errorColor,
                    ),
                    Text(
                      '${_pm2_5.provider.name.capitalize()} (${_pm2_5.distance.toStringAsFixed(1)}${_pm2_5.distanceUnit})',
                      style: _pm2_5.isNearby ? smallText : smallTextWithError,
                    ),
                    SizedBox(width: 4.0),
                    _BoxedIcon(
                      icon: Icons.schedule,
                      color: _pm2_5.isExpired ? errorColor : null,
                    ),
                    Text(
                      _pm2_5.creation.format(dateTimePattern),
                      style: _pm2_5.isExpired ? smallTextWithError : smallText,
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
                          ? smallTextWithError
                          : smallText,
                    ),
                    SizedBox(width: 4.0),
                    _BoxedIcon(
                      icon: Icons.place,
                      color: _condition.isNearby ? null : errorColor,
                    ),
                    Text(
                      '${_condition.provider.name.truncate(maxProviderNameLength, ellipsis: "…")} (${_condition.distance.toStringAsFixed(1)}${_condition.distanceUnit})',
                      style:
                          _condition.isNearby ? smallText : smallTextWithError,
                    ),
                    SizedBox(width: 4.0),
                    _BoxedIcon(
                      icon: Icons.schedule,
                      color: _condition.isExpired ? errorColor : null,
                    ),
                    Text(
                      _condition.creation.format(dateTimePattern),
                      style:
                          _condition.isExpired ? smallTextWithError : smallText,
                    ),
                  ],
                ),
              if (_forecasts != null)
                for (Forecast forecast in _forecasts)
                  Row(
                    children: <Widget>[
                      _BoxedIcon(icon: Icons.schedule),
                      Text(
                        forecast.type.toString().asEnumLabel().capitalize(),
                        style: smallText,
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
                            ? smallTextWithError
                            : smallText,
                      ),
                      SizedBox(width: 4.0),
                      _BoxedIcon(
                        icon: Icons.place,
                        color: forecast.isNearby ? null : errorColor,
                      ),
                      Text(
                        '${forecast.provider.name.capitalize()} (${forecast.distance.toStringAsFixed(1)}${forecast.distanceUnit})',
                        style:
                            forecast.isNearby ? smallText : smallTextWithError,
                      ),
                    ],
                  ),
            ],
          ),
        ),
      ],
    );
  }

  /// Sets up [_animation] with the correct scale.
  void _initAnimation() {
    // Hardcoding Scaffold.appBarMaxHeight (80.0) for now.
    double canvasHeight = MediaQuery.of(context).size.height - 80.0;
    double lowerBound = _detailsLayerHandleSize / canvasHeight;
    double upperBound = _detailsLayerHeight / canvasHeight;
    // 0.5 -- because we are only doing 180°.
    double turnsFactor = 0.5 / (upperBound - lowerBound);

    _animation = Tween<double>(
      begin: -lowerBound * turnsFactor,
      end: (1 - lowerBound) * turnsFactor,
    ).animate(_animationController);
  }

  /// Gets the name of the background image asset.
  String _getBackgroundAsset() {
    // Use _condition to determine the asset to return. Return on first match.
    final RegExp lightning = RegExp('thunder', caseSensitive: false);
    final RegExp rain = RegExp('(rain|showers)', caseSensitive: false);
    final RegExp cloud = RegExp('cloud', caseSensitive: false);
    final RegExp day = RegExp('day', caseSensitive: false);
    final RegExp night = RegExp('night', caseSensitive: false);

    if (_condition != null) {
      String condition = _condition.condition;

      if (lightning.hasMatch(condition)) return 'assets/images/lightning.webp';
      if (rain.hasMatch(condition)) return 'assets/images/rain.webp';
      if (cloud.hasMatch(condition)) return 'assets/images/cloud.webp';
      if (day.hasMatch(condition)) return 'assets/images/day.webp';
      if (night.hasMatch(condition)) return 'assets/images/night.webp';
    }

    return 'assets/images/default.webp'; // The default image.
  }

  /// Fetches the weather data.
  ///
  /// Do not invoke this method directly. Use
  /// _refreshIndicatorKey.currentState.show() instead.
  Future<void> _fetchData() async {
    setState(() {
      _summaryLayerOpacity = 0.0;
      _fetchTimestamp = DateTime.now();
    });

    Geoposition userLocation = await Geolocation().getCurrentLocation();
    if (userLocation == null) {
      _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('Cannot detect current location.'),
          action: SnackBarAction(
            label: 'RETRY',
            onPressed: () => _refreshIndicatorKey.currentState.show(),
          ),
        ),
      );

      return;
    }

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
      _summaryLayerOpacity = 1.0;
    });
    if (_temperature == null ||
        _rainfall == null ||
        _humidity == null ||
        _windSpeed == null ||
        _windDirection == null ||
        _pm2_5 == null ||
        _condition == null ||
        _forecasts == null) {
      _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('Cannot load data from weather service.'),
          action: SnackBarAction(
            label: 'RETRY',
            onPressed: () => _refreshIndicatorKey.currentState.show(),
          ),
        ),
      );
    }
  }
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
            style:
                color != null ? mediumText.copyWith(color: color) : mediumText,
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
