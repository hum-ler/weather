import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart';
import 'package:kiwi/kiwi.dart';

import '../../services/geolocation.dart';
import '../../services/weather.dart';

part 'injector.g.dart';

abstract class Injector {
  @Register.factory(Client)
  @Register.singleton(Geolocation)
  @Register.factory(Geolocator)
  @Register.singleton(Weather)
  void configure();
}

Injector getInjector() => _$Injector();
