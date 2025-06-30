import '../../data/map/map.dart';

import '../../data/orders/models/incoming_order_data.dart';
import '../map_navigation/map_navigation_manager.dart';

class MapManager {
  final MapController _mapController;
  final MapNavigationHolder _mapNavigationHolder;

  const MapManager(
    this._mapController,
    this._mapNavigationHolder,
  );

  List<MapItem> get selectedItems => _mapController.items.values
      .where((item) => item.selected)
      .toList(growable: false);

  void focus(int position) {
    _mapController.focus(position);
  }

  void selectMapItem(int position, {required bool selected}) {
    _mapController.selectPosition(position, selected: selected);
  }

  void clear() {
    _mapController.clear();
  }

  void startNavigation() {
    assert(
      selectedItems.length > 1,
      'Incorrect number of selected items for map navigation',
    );
    _mapNavigationHolder.startNavigation(
      MapNavigationParams(
        fromAddress:
            Address(name: 'Street', position: selectedItems[0].position),
        toAddress: Address(
            name: 'Street',
            position: selectedItems[selectedItems.length - 1].position),
      ),
    );
  }
}
