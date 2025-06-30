import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class MapController extends ChangeNotifier {
  static const totalPositions = 100;
  static const itemHeight = 56.0;

  final ScrollController _scrollController;

  final Map<int, MapItem> items = Map.fromEntries(
    List.generate(
      100,
      (i) => MapItem(name: 'Street $i', position: i, selected: false),
    ).map(
      (item) => MapEntry(item.position, item),
    ),
  );

  MapController(this._scrollController);

  void selectPosition(int position, {required bool selected}) {
    assert(
      position >= 0 && position < totalPositions,
      'Your position is out of our simulated map',
    );
    items[position] = items[position]!.copyWith(selected: selected);
    notifyListeners();
  }

  void clear() {
    for (final position in items.keys) {
      items[position] = items[position]!.copyWith(selected: false);
    }
    notifyListeners();
  }

  void focus(int position) {
    SchedulerBinding.instance.addPostFrameCallback((_) =>
        _scrollController.animateTo((position - 2) * itemHeight,
            duration: const Duration(milliseconds: 200), curve: Curves.ease));
  }
}

class MapItem {
  final String name;
  final int position;
  final bool selected;

  const MapItem({
    required this.name,
    required this.position,
    required this.selected,
  });

  MapItem copyWith({
    bool? selected,
  }) {
    return MapItem(
      selected: selected ?? this.selected,
      name: name,
      position: position,
    );
  }
}
