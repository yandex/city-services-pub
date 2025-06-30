import 'package:flutter/material.dart';
import 'package:yx_scope_flutter/yx_scope_flutter.dart';

import '../../data/map/map.dart';
import '../../data/map/map_widget.dart';
import '../../di/account/account_scope.dart';
import '../../di/map/map_scope.dart';
import '../../di/map_navigation/map_navigation_scope.dart';
import '../../domain/map/map_factory.dart';

const kMainMap = 'main_map_page_key';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late final AccountScope _accountScope;
  late final MapInitializer _mapInitializer;

  void _onMapCreated(MapController map) {
    _mapInitializer.createMap(map);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _accountScope = ScopeProvider.of<AccountScope>(context)!;
    _mapInitializer = _accountScope.mapInitializer;
  }

  @override
  void dispose() {
    super.dispose();
    _mapInitializer.dropMap();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Column(
          children: [
            const Center(
              child: Text('Tap a street to select points for navigation'),
            ),
            Expanded(child: MapWidget(onMapCreated: _onMapCreated)),
          ],
        ),
        floatingActionButton: ScopeBuilder<MapScope>.withPlaceholder(
          holder: _accountScope.mapScopeHolder,
          builder: (context, mapScope) {
            return ListenableBuilder(
                listenable: mapScope.controller,
                builder: (context, value) {
                  if (mapScope.mapManager.selectedItems.length > 1) {
                    return ScopeBuilder<MapNavigationScope>(
                      holder: mapScope.mapNavigationScopeHolder,
                      builder: (context, navigationScope) {
                        if (navigationScope == null) {
                          return FloatingActionButton.extended(
                            onPressed: () {
                              mapScope.mapManager.startNavigation();
                            },
                            label: const Text('Start Navigation'),
                          );
                        } else {
                          return FloatingActionButton.extended(
                            onPressed: () {
                              navigationScope.mapNavigationManager
                                  .navigateToNextPosition();
                            },
                            label: const Text('Proceed to next point'),
                          );
                        }
                      },
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                });
          },
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      );
}
