import 'package:http/http.dart';
import 'package:kiwi/kiwi.dart';

import '../../services/geolocation.dart';
import '../../services/weather.dart';

part 'injector.g.dart';

abstract class Injector {
  @Register.singleton(Geolocation)
  @Register.singleton(Weather)
  @Register.factory(Client)
  void configure();
}

Injector getInjector() => _$Injector();
