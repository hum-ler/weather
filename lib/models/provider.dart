import 'package:flutter/foundation.dart';

import 'geoposition.dart';

/// A provider of a reading or forecast.
@immutable
class Provider {
  /// The ID of this provider.
  final String id;

  /// The name of this provider.
  final String name;

  /// The type of this provider.
  final ProviderType type;

  /// The location of this provider.
  final Geoposition location;

  /// The effective range for this provider type.
  double get effectiveRange => _effectiveRange[type];

  /// Creates a new provider.
  const Provider({
    @required this.id,
    @required this.name,
    @required this.type,
    @required this.location,
  })  : assert(id != null),
        assert(name != null),
        assert(type != null),
        assert(location != null);

  /// Creates a new meteorological observing station.
  const Provider.station({
    @required String id,
    @required String name,
    @required Geoposition location,
  }) : this(
          id: id,
          name: name,
          type: ProviderType.station,
          location: location,
        );

  /// Creates a new provider that spans an area.
  const Provider.area({
    @required String id,
    @required String name,
    @required Geoposition location,
  }) : this(
          id: id,
          name: name,
          type: ProviderType.area,
          location: location,
        );

  /// Creates a new provider that spans a region.
  const Provider.region({
    @required String id,
    @required String name,
    @required Geoposition location,
  }) : this (
      id: id,
      name: name,
      type: ProviderType.region,
      location: location,
    );

  /// The effective range for each [ProviderType].
  static const Map<ProviderType, double> _effectiveRange = {
    ProviderType.station: 10.0,
    ProviderType.area: 10.0,
    ProviderType.region: 20.0,
  };
}

/// The types of provider.
enum ProviderType {
  station,
  area,
  region,
}

/// The set of reference region providers.
///
/// Mainly used by the 24-hour forecast, which has region names but no
/// associated coordinates.
class Providers {
  /// The reference central region.
  static const Provider central = Provider.region(
    id: 'central',
    name: 'central',
    location: const Geoposition(
      latitude: 1.360195,
      longitude: 103.815675,
    ),
  );

  /// The reference north region.
  static const Provider north = Provider.region(
    id: 'north',
    name: 'north',
    location: const Geoposition(
      latitude: 1.439147,
      longitude: 103.815675,
    ),
  );

  /// The reference east region.
  static const Provider east = Provider.region(
    id: 'east',
    name: 'east',
    location: const Geoposition(
      latitude: 1.360195,
      longitude: 103.992073,
    ),
  );

  /// The reference south region.
  static const Provider south = Provider.region(
    id: 'south',
    name: 'south',
    location: const Geoposition(
      latitude: 1.290981,
      longitude: 103.815675,
    ),
  );

  /// The reference west region.
  static const Provider west = Provider.region(
    id: 'west',
    name: 'west',
    location: const Geoposition(
      latitude: 1.360195,
      longitude: 103.669195,
    ),
  );
}
