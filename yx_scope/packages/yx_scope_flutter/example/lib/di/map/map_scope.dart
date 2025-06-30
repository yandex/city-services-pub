import 'package:yx_scope/yx_scope.dart';

import '../../data/map/map.dart';
import '../../domain/map/map_factory.dart';
import '../../domain/map/map_manager.dart';
import '../../domain/map_navigation/map_navigation_manager.dart';
import '../map_navigation/map_navigation_scope.dart';
import '../utils/listeners.dart';

abstract class MapScope implements Scope {
  MapNavigationScopeHolder get mapNavigationScopeHolder;

  MapController get controller;

  MapManager get mapManager;

  MapNavigationHolder get mapNavigationHolder;
}

class MapScopeContainer extends DataScopeContainer<MapController>
    implements MapScope, MapNavigationParent {
  MapScopeContainer({required super.data});

  late final _mapNavigationScopeHolderDep =
      dep(() => MapNavigationScopeHolder(this));

  late final _mapManagerDep =
      dep(() => MapManager(data, _mapNavigationScopeHolderDep.get));

  @override
  MapNavigationScopeHolder get mapNavigationScopeHolder =>
      _mapNavigationScopeHolderDep.get;

  @override
  MapManager get mapManager => _mapManagerDep.get;

  @override
  MapController get controller => data;

  @override
  MapNavigationHolder get mapNavigationHolder =>
      _mapNavigationScopeHolderDep.get;

  @override
  void onNavigationStop() => _mapNavigationScopeHolderDep.get.drop();
}

class MapScopeHolder
    extends BaseDataScopeHolder<MapScope, MapScopeContainer, MapController>
    implements MapInitializer {
  MapScopeHolder()
      : super(
          scopeObservers: [diObserver],
          depObservers: [diObserver],
          asyncDepObservers: [diObserver],
        );

  @override
  MapScopeContainer createContainer(MapController data) =>
      MapScopeContainer(data: data);

  @override
  Future<void> createMap(MapController mapController) => create(mapController);

  @override
  Future<void> dropMap() => drop();
}
