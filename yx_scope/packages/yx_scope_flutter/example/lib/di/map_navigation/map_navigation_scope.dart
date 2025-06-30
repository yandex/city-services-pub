import 'package:yx_scope/yx_scope.dart';

import '../../domain/map/map_manager.dart';
import '../../domain/map_navigation/map_navigation_manager.dart';
import '../utils/listeners.dart';

abstract class MapNavigationScope {
  MapNavigationManager get mapNavigationManager;
}

abstract class MapNavigationParent implements Scope {
  MapManager get mapManager;

  void onNavigationStop();
}

class MapNavigationScopeContainer
    extends ChildDataScopeContainer<MapNavigationParent, MapNavigationParams>
    implements MapNavigationScope {
  MapNavigationScopeContainer({required super.parent, required super.data});

  @override
  List<Set<AsyncDep>> get initializeQueue => [
        {_mapNavigationManagerDep}
      ];

  late final _mapNavigationManagerDep = rawAsyncDep<MapNavigationManager>(
    () => MapNavigationManager(
      data,
      parent.mapManager,
      parent.onNavigationStop,
    ),
    init: (dep) async => dep.prepare(),
    dispose: (dep) async {},
  );

  @override
  MapNavigationManager get mapNavigationManager => _mapNavigationManagerDep.get;
}

class MapNavigationScopeHolder extends BaseChildDataScopeHolder<
    MapNavigationScope,
    MapNavigationScopeContainer,
    MapNavigationParent,
    MapNavigationParams> implements MapNavigationHolder {
  MapNavigationScopeHolder(super.parent)
      : super(
          scopeObservers: [diObserver],
          depObservers: [diObserver],
          asyncDepObservers: [diObserver],
        );

  @override
  MapNavigationScopeContainer createContainer(
    MapNavigationParent parent,
    MapNavigationParams data,
  ) =>
      MapNavigationScopeContainer(parent: parent, data: data);

  @override
  Future<void> startNavigation(MapNavigationParams navigationParams) =>
      create(navigationParams);

  @override
  Future<void> stopNavigation() => drop();
}
