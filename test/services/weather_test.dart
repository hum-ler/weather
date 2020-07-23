import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:kiwi/kiwi.dart';
import 'package:mockito/mockito.dart';

import 'package:weather/models/condition.dart';
import 'package:weather/models/forecast.dart';
import 'package:weather/models/provider.dart';
import 'package:weather/models/reading.dart';
import 'package:weather/services/weather.dart';

class MockClient extends Mock implements Client {}

void main() {
  test('.getNearest...(): before calling .fetchReadings() => null', () async {
    Weather weather = Weather();
    expect(weather.getNearest24HourForecast(), isNull);
    expect(weather.getNearest2HourForecast(), isNull);
    expect(weather.getNearestCondition(), isNull);
    expect(weather.getNearestHumidityReading(), isNull);
    expect(weather.getNearestPM2_5Reading(), isNull);
    expect(weather.getNearestRainfallReading(), isNull);
    expect(weather.getNearestTemperatureReading(), isNull);
    expect(weather.getNearestWindDirectionReading(), isNull);
    expect(weather.getNearestWindSpeedReading(), isNull);
  });

  test('.getNearest...(): null result => null', () async {
    Client client = MockClient();
    when(client.get(any, headers: anyNamed('headers')))
        .thenAnswer((_) async => null);
    KiwiContainer()
      ..clear()
      ..registerInstance<Client>(client);

    Weather weather = Weather();
    await weather.fetchReadings(userLocation: Providers.central.location);
    expect(weather.getNearest24HourForecast(), isNull);
    expect(weather.getNearest2HourForecast(), isNull);
    expect(weather.getNearestCondition(), isNull);
    expect(weather.getNearestHumidityReading(), isNull);
    expect(weather.getNearestPM2_5Reading(), isNull);
    expect(weather.getNearestRainfallReading(), isNull);
    expect(weather.getNearestTemperatureReading(), isNull);
    expect(weather.getNearestWindDirectionReading(), isNull);
    expect(weather.getNearestWindSpeedReading(), isNull);
  });

  /// Check against a common problem at Data.gov.sg.
  test('.getNearest24HourForecast(): empty result => null', () async {
    Client client = MockClient();
    when(client.get(any, headers: anyNamed('headers')))
        .thenAnswer((_) async => Response('''
{
  "items": [
    {}
  ],
  "api_info": {
    "status": "healthy"
  }
}
''', 200));
    KiwiContainer()
      ..clear()
      ..registerInstance<Client>(client);

    Weather weather = Weather();
    await weather.fetchReadings(userLocation: Providers.central.location);
    expect(weather.getNearest24HourForecast(), isNull);
  });

  /// Check against a common problem at Data.gov.sg.
  test('.getNearest2HourForecast(): empty result => null', () async {
    Client client = MockClient();
    when(client.get(any, headers: anyNamed('headers')))
        .thenAnswer((_) async => Response('''
{
  "items": [
    {}
  ],
  "area_metadata": [],
  "api_info": {
    "status": "healthy"
  }
}
''', 200));
    KiwiContainer()
      ..clear()
      ..registerInstance<Client>(client);

    Weather weather = Weather();
    await weather.fetchReadings(userLocation: Providers.central.location);
    expect(weather.getNearest2HourForecast(), isNull);
    expect(weather.getNearestCondition(), isNull);
  });

  /// Check against a common problem at Data.gov.sg.
  test('.getNearest...Reading(): empty result => null', () async {
    Client client = MockClient();
    when(client.get(any, headers: anyNamed('headers')))
        .thenAnswer((_) async => Response('''
{
  "metadata": {},
  "items": [
    {}
  ],
  "api_info": {
    "status": "healthy"
  }
}
''', 200));
    KiwiContainer()
      ..clear()
      ..registerInstance<Client>(client);

    Weather weather = Weather();
    await weather.fetchReadings(userLocation: Providers.central.location);
    expect(weather.getNearestHumidityReading(), isNull);
    expect(weather.getNearestRainfallReading(), isNull);
    expect(weather.getNearestTemperatureReading(), isNull);
    expect(weather.getNearestWindDirectionReading(), isNull);
    expect(weather.getNearestWindSpeedReading(), isNull);
  });

  /// Check against a common problem at Data.gov.sg.
  test('.getNearestPM2_5Reading(): empty result => null', () async {
    Client client = MockClient();
    when(client.get(any, headers: anyNamed('headers')))
        .thenAnswer((_) async => Response('''
{
  "region_metadata": [],
  "items": [
    {}
  ],
  "api_info": {
    "status": "healthy"
  }
}
''', 200));
    KiwiContainer()
      ..clear()
      ..registerInstance<Client>(client);

    Weather weather = Weather();
    await weather.fetchReadings(userLocation: Providers.central.location);
    expect(weather.getNearestPM2_5Reading(), isNull);
  });

  test('.getNearest24HourForecast()', () async {
    Client client = MockClient();
    when(client.get(any, headers: anyNamed('headers')))
        .thenAnswer((_) async => null);
    when(client.get(argThat(contains('24-hour')), headers: anyNamed('headers')))
        .thenAnswer((_) async => Response('''
{
  "items": [
    {
      "update_timestamp": "2020-06-23T11:51:18+08:00",
      "timestamp": "2020-06-23T11:36:00+08:00",
      "valid_period": {
        "start": "2020-06-23T12:00:00+08:00",
        "end": "2020-06-24T12:00:00+08:00"
      },
      "general": {
        "forecast": "Moderate Rain",
        "relative_humidity": {
          "low": 70,
          "high": 100
        },
        "temperature": {
          "low": 25,
          "high": 29
        },
        "wind": {
          "speed": {
            "low": 15,
            "high": 25
          },
          "direction": "SW"
        }
      },
      "periods": [
        {
          "time": {
            "start": "2020-06-23T12:00:00+08:00",
            "end": "2020-06-23T18:00:00+08:00"
          },
          "regions": {
            "west": "Moderate Rain",
            "east": "Light Rain",
            "central": "Moderate Rain",
            "south": "Moderate Rain",
            "north": "Light Rain"
          }
        },
        {
          "time": {
            "start": "2020-06-23T18:00:00+08:00",
            "end": "2020-06-24T06:00:00+08:00"
          },
          "regions": {
            "west": "Cloudy",
            "east": "Cloudy",
            "central": "Cloudy",
            "south": "Cloudy",
            "north": "Cloudy"
          }
        },
        {
          "time": {
            "start": "2020-06-24T06:00:00+08:00",
            "end": "2020-06-24T12:00:00+08:00"
          },
          "regions": {
            "west": "Partly Cloudy (Day)",
            "east": "Partly Cloudy (Day)",
            "central": "Partly Cloudy (Day)",
            "south": "Partly Cloudy (Day)",
            "north": "Partly Cloudy (Day)"
          }
        }
      ]
    }
  ],
  "api_info": {
    "status": "healthy"
  }
}
''', 200));
    logInvocations([client as Mock]);
    KiwiContainer()
      ..clear()
      ..registerInstance<Client>(client);

    Weather weather = Weather();
    await weather.fetchReadings(userLocation: Providers.central.location);
    List<Forecast> forecasts = weather.getNearest24HourForecast();
    expect(
      forecasts,
      allOf([
        isNotNull,
        isNotEmpty,
      ]),
    );
    expect(forecasts.length, equals(3));
    expect(forecasts[0].type, equals(ForecastType.afternoon));
    expect(forecasts[1].type, equals(ForecastType.night));
    expect(forecasts[2].type, equals(ForecastType.morning));
    expect(forecasts[0].condition, equals('Moderate Rain'));
  });

  test('.getNearest2HourForecast()', () async {
    Client client = MockClient();
    when(client.get(any, headers: anyNamed('headers')))
        .thenAnswer((_) async => null);
    when(client.get(argThat(contains('2-hour')), headers: anyNamed('headers')))
        .thenAnswer((_) async => Response('''
{
  "area_metadata": [
    {
      "name": "Ang Mo Kio",
      "label_location": {
        "latitude": 1.375,
        "longitude": 103.839
      }
    }
  ],
  "items": [
    {
      "update_timestamp": "2020-07-24T01:38:52+08:00",
      "timestamp": "2020-07-24T01:30:00+08:00",
      "valid_period": {
        "start": "2020-07-24T01:30:00+08:00",
        "end": "2020-07-24T03:30:00+08:00"
      },
      "forecasts": [
        {
          "area": "Ang Mo Kio",
          "forecast": "Partly Cloudy (Night)"
        }
      ]
    }
  ],
  "api_info": {
    "status": "healthy"
  }
}
''', 200));
    KiwiContainer()
      ..clear()
      ..registerInstance<Client>(client);

    Weather weather = Weather();
    await weather.fetchReadings(userLocation: Providers.central.location);
    Forecast forecast = weather.getNearest2HourForecast();
    expect(forecast, isNotNull);
    expect(forecast.condition, equals('Partly Cloudy (Night)'));

    Condition condition = weather.getNearestCondition();
    expect(condition, isNotNull);
    expect(condition.condition, equals('Partly Cloudy (Night)'));
  });

  test('.getNearest...Reading()', () async {
    Client client = MockClient();
    when(client.get(any, headers: anyNamed('headers')))
        .thenAnswer((_) async => null);
    when(
      client.get(
        argThat(matches('(temperature|rain|humidity|wind)')),
        headers: anyNamed('headers'),
      ),
    ).thenAnswer((_) async => Response('''
{
  "metadata": {
    "stations": [
      {
        "id": "S109",
        "device_id": "S109",
        "name": "Ang Mo Kio Avenue 5",
        "location": {
          "latitude": 1.3764,
          "longitude": 103.8492
        }
      }
    ],
    "reading_type": "DBT 1M F",
    "reading_unit": "deg C"
  },
  "items": [
    {
      "timestamp": "2020-06-20T15:55:00+08:00",
      "readings": [
        {
          "station_id": "S109",
          "value": 27.2
        }
      ]
    }
  ],
  "api_info": {
    "status": "healthy"
  }
}
''', 200));
    KiwiContainer()
      ..clear()
      ..registerInstance<Client>(client);

    Weather weather = Weather();
    await weather.fetchReadings(userLocation: Providers.central.location);

    Reading reading = weather.getNearestHumidityReading();
    expect(reading, isNotNull);
    expect(reading.value, moreOrLessEquals(27.2));

    reading = weather.getNearestRainfallReading();
    expect(reading, isNotNull);
    expect(reading.value, moreOrLessEquals(27.2));

    reading = weather.getNearestTemperatureReading();
    expect(reading, isNotNull);
    expect(reading.value, moreOrLessEquals(27.2));

    reading = weather.getNearestWindDirectionReading();
    expect(reading, isNotNull);
    expect(reading.value, moreOrLessEquals(27.2));

    // Wind speed needs to be converted to m/s.
    // According to Google, 27.2knots = 13.99289m/s.
    reading = weather.getNearestWindSpeedReading();
    expect(reading, isNotNull);
    expect(reading.value, moreOrLessEquals(13.99289, epsilon: 0.001));
  });

  test('.getNearestPM2_5Reading()', () async {
    Client client = MockClient();
    when(client.get(any, headers: anyNamed('headers')))
        .thenAnswer((_) async => null);
    when(client.get(argThat(contains('pm25')), headers: anyNamed('headers')))
        .thenAnswer((_) async => Response('''
{
  "region_metadata": [
    {
      "name": "west",
      "label_location": {
        "latitude": 1.35735,
        "longitude": 103.7
      }
    },
    {
      "name": "east",
      "label_location": {
        "latitude": 1.35735,
        "longitude": 103.94
      }
    },
    {
      "name": "central",
      "label_location": {
        "latitude": 1.35735,
        "longitude": 103.82
      }
    },
    {
      "name": "south",
      "label_location": {
        "latitude": 1.29587,
        "longitude": 103.82
      }
    },
    {
      "name": "north",
      "label_location": {
        "latitude": 1.41803,
        "longitude": 103.82
      }
    }
  ],
  "items": [
    {
      "timestamp": "2020-06-20T16:00:00+08:00",
      "update_timestamp": "2020-06-20T16:08:52+08:00",
      "readings": {
        "pm25_one_hourly": {
          "west": 6,
          "east": 9,
          "central": 8,
          "south": 17,
          "north": 11
        }
      }
    }
  ],
  "api_info": {
    "status": "healthy"
  }
}
''', 200));
    KiwiContainer()
      ..clear()
      ..registerInstance<Client>(client);

    Weather weather = Weather();
    await weather.fetchReadings(userLocation: Providers.central.location);
    Reading reading = weather.getNearestPM2_5Reading();
    expect(reading, isNotNull);
    expect(reading.value, equals(8));
  });
}
