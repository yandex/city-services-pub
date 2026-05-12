import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:yx_navigation/yx_navigation.dart';

/// {@template yx_route_information_provider}
/// Provides [RouteInformation] to the router by bridging platform intents
/// (initial route, deeplinks) with the navigation tree.
///
/// Forwards new route information reported by the router back to the
/// embedder through `SystemNavigator` so deeplinks are reflected in the
/// browser history on web and in the recent intents on other platforms.
/// {@endtemplate}
class YxRouteInformationProvider extends RouteInformationProvider
    with WidgetsBindingObserver, ChangeNotifier {
  final PlatformStateSerialization _serialization;

  late RouteInformation _value;
  late RouteInformation _valueInEngine;

  @override
  RouteInformation get value => _value;

  /// Creates a [YxRouteInformationProvider].
  ///
  /// {@macro yx_route_information_provider}
  YxRouteInformationProvider({
    required PlatformStateSerialization serialization,
  }) : _serialization = serialization {
    if (kFlutterMemoryAllocationsEnabled) {
      ChangeNotifier.maybeDispatchObjectCreation(this);
    }

    _valueInEngine = initialRouteInformation();
    _value = _valueInEngine;
  }

  /// Reads the initial route reported by the embedder.
  ///
  /// Returns a [RouteInformation] with an empty [Uri] when the platform route
  /// name cannot be parsed.
  static RouteInformation initialRouteInformation() {
    final binding = WidgetsBinding.instance;
    final defaultRouteName = binding.platformDispatcher.defaultRouteName;

    final platformDefault = defaultRouteName.trim();

    try {
      final uri = Uri.parse(platformDefault);

      return RouteInformation(uri: uri);
    } on Object {
      return RouteInformation(uri: Uri());
    }
  }

  @override
  @mustCallSuper
  void addListener(VoidCallback listener) {
    if (!hasListeners) {
      WidgetsBinding.instance.addObserver(this);
    }
    super.addListener(listener);
  }

  @override
  @mustCallSuper
  void removeListener(VoidCallback listener) {
    super.removeListener(listener);
    if (!hasListeners) {
      WidgetsBinding.instance.removeObserver(this);
    }
  }

  @override
  @mustCallSuper
  void dispose() {
    // In practice, this will rarely be called. We assume that the listeners
    // will be added and removed in a coherent fashion such that when the object
    // is no longer being used, there's no listener, and so it will get garbage
    // collected.
    if (hasListeners) {
      WidgetsBinding.instance.removeObserver(this);
    }
    super.dispose();
  }

  bool _sameNodeByUri(Uri a, Uri b) {
    try {
      final nodeA = _serialization.parse(a);
      final nodeB = _serialization.parse(b);

      return nodeA.equalsBy(nodeB);
    } on Object {
      return false;
    }
  }

  @override
  void routerReportsNewRouteInformation(
    RouteInformation routeInformation, {
    RouteInformationReportingType type = RouteInformationReportingType.none,
  }) {
    final routeInformationChanged = !_sameNodeByUri(
      _valueInEngine.uri,
      routeInformation.uri,
    );
    final shouldMakeNewHistoryEntry = switch (type) {
      RouteInformationReportingType.neglect => false,
      RouteInformationReportingType.navigate => routeInformationChanged,
      RouteInformationReportingType.none => routeInformationChanged,
    };

    SystemNavigator.selectMultiEntryHistory();
    SystemNavigator.routeInformationUpdated(
      uri: routeInformation.uri,
      state: routeInformation.state,
      replace: !shouldMakeNewHistoryEntry,
    );
    _value = routeInformation;
    _valueInEngine = routeInformation;
  }

  @override
  Future<bool> didPushRouteInformation(
    RouteInformation routeInformation,
  ) {
    assert(hasListeners, 'hasListeners must be true');
    _platformReportsNewRouteInformation(routeInformation);
    return SynchronousFuture(true);
  }

  void _platformReportsNewRouteInformation(RouteInformation routeInformation) {
    if (_value == routeInformation) {
      return;
    }
    _value = routeInformation;
    _valueInEngine = routeInformation;
    notifyListeners();
  }
}
