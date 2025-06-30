import '../../data/map/map.dart';

abstract class MapInitializer {
  Future<void> createMap(MapController mapController);

  Future<void> dropMap();
}
