import 'dart:async';

import '../../data/orders/models/incoming_order_data.dart';
import '../map/map_manager.dart';

class MapNavigationParams {
  final Address fromAddress;
  final Address toAddress;
  final int? currentPosition;

  MapNavigationParams({
    required this.fromAddress,
    required this.toAddress,
    this.currentPosition,
  });

  MapNavigationParams copyWith({
    int? currentPosition,
  }) {
    return MapNavigationParams(
      fromAddress: fromAddress,
      toAddress: toAddress,
      currentPosition: currentPosition ?? this.currentPosition,
    );
  }
}

typedef OnStopNavigation = void Function();

abstract class MapNavigationHolder {
  Future<void> startNavigation(MapNavigationParams navigationParams);

  Future<void> stopNavigation();
}

class MapNavigationManager {
  final _controller = StreamController<MapNavigationParams>.broadcast();

  Stream<MapNavigationParams> get stream => _controller.stream;

  final MapManager _mapManager;
  final OnStopNavigation _onStopNavigation;
  MapNavigationParams _current;

  MapNavigationManager(
    this._current,
    this._mapManager,
    this._onStopNavigation,
  );

  void prepare() {
    _mapManager.selectMapItem(_current.fromAddress.position, selected: true);
    final currentPosition = _current.currentPosition;
    if (currentPosition != null) {
      final sign = _sign(_current);
      for (var i = _current.fromAddress.position;
          sign > 0 ? i <= currentPosition : i >= currentPosition;
          i += sign) {
        _mapManager.selectMapItem(i, selected: true);
      }
    }
    _mapManager.selectMapItem(_current.toAddress.position, selected: true);
    if (currentPosition != null) {
      _mapManager.focus(currentPosition);
    } else {
      _mapManager.focus(_current.fromAddress.position);
    }
  }

  void navigateToNextPosition() {
    final sign = _sign(_current);
    final currentPosition =
        _current.currentPosition ?? _current.fromAddress.position;

    final nextPosition = currentPosition + sign;
    if (_current.toAddress.position - nextPosition == -sign) {
      // reached the destination
      stopNavigation();
    } else {
      _mapManager.focus(nextPosition);
      _emit(_current.copyWith(currentPosition: nextPosition));
    }
  }

  int _sign(MapNavigationParams params) {
    final direction = params.toAddress.position - params.fromAddress.position;
    return direction ~/ direction.abs();
  }

  Future<void> stopNavigation() async => _onStopNavigation();

  void _emit(MapNavigationParams params) {
    _current = params;
    _controller.add(params);
    final currentPosition = params.currentPosition;
    if (currentPosition != null) {
      _mapManager.selectMapItem(currentPosition, selected: true);
    } else {
      _mapManager.clear();
    }
  }
}
