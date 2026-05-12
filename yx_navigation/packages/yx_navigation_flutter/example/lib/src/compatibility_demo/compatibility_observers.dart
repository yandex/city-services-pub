import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:yx_navigation/yx_navigation.dart';
import 'package:yx_navigation_flutter/yx_navigation_flutter_compatibility.dart';

/// Example observer for monitoring Navigator 1.0 API usage.
///
/// Logs pageless route creation events to help debug and track
/// migration progress toward declarative navigation.
class DebugCompatibilityObserver extends CompatibilityObserver {
  /// Number of pageless routes that were created.
  int _pagelessRoutesCount = 0;

  /// Number of route creation attempts that failed.
  int _failedRoutesCount = 0;

  /// Count of successfully created pageless routes.
  int get pagelessRoutesCount => _pagelessRoutesCount;

  /// Count of failed attempts.
  int get failedRoutesCount => _failedRoutesCount;

  @override
  bool willPushPagelessRoute({
    required RouteNodeReadable routeNodeReadable,
    required Route<dynamic> route,
    required String routeId,
  }) {
    if (kDebugMode) {
      debugPrint(
        '[Compatibility] Will push pageless route:\n'
        '   Current node: ${routeNodeReadable.state}\n'
        '   Type: ${route.runtimeType}\n'
        '   ID: $routeId\n'
        '   Name: ${route.settings.name ?? "(unnamed)"}',
      );
    }
    return true;
  }

  @override
  void didCreatePagelessRoute({
    required RouteNodeReadable routeNodeReadable,
    required Route<dynamic> route,
    required String routeId,
    required String routeType,
    required RouteNode routeNode,
  }) {
    _pagelessRoutesCount++;

    if (kDebugMode) {
      debugPrint(
        '[Compatibility] Pageless route created:\n'
        '   Current node: ${routeNodeReadable.state}\n'
        '   Type: $routeType\n'
        '   ID: $routeId\n'
        '   Name: ${route.settings.name ?? "(unnamed)"}\n'
        '   Children: ${routeNode.children.length}\n'
        '   Total: $_pagelessRoutesCount',
      );
    }
  }

  @override
  void didFailPagelessRoute({
    required RouteNodeReadable routeNodeReadable,
    required Route<dynamic> route,
    required Object error,
    required RouteNode? routeNode,
  }) {
    _failedRoutesCount++;

    if (kDebugMode) {
      // Infer operation kind from the error message.
      final errorMsg = error.toString();
      final isReplaceOperation = errorMsg.contains('pushReplacement') ||
          errorMsg.contains('pushAndRemoveUntil');

      final operationType = isReplaceOperation ? 'CRITICAL' : 'WARNING';
      final behaviorMsg = isReplaceOperation
          ? 'Exception will be re-thrown (fallback forbidden)'
          : 'Fallback to native Navigator';

      debugPrint(
        '[$operationType] [Compatibility] Failed pageless route:\n'
        '   Current node: ${routeNodeReadable.state}\n'
        '   Type: ${route.runtimeType}\n'
        '   Name: ${route.settings.name ?? "(unnamed)"}\n'
        '   Error: $error\n'
        '   Behavior: $behaviorMsg\n'
        '   Total failed: $_failedRoutesCount',
      );
    }
  }

  /// Resets the counters (useful for tests).
  void reset() {
    _pagelessRoutesCount = 0;
    _failedRoutesCount = 0;
  }
}

/// Example observer that tracks the Navigator 1.0 to 2.0 migration.
///
/// Collects route-type stats so migration progress can be analyzed.
class MigrationTrackingObserver extends CompatibilityObserver {
  /// Stats keyed by route type.
  final Map<String, int> _routeTypeStats = {};

  /// Read-only view of the collected route-type stats.
  Map<String, int> get routeTypeStats => Map.unmodifiable(_routeTypeStats);

  @override
  void didCreatePagelessRoute({
    required RouteNodeReadable routeNodeReadable,
    required Route<dynamic> route,
    required String routeId,
    required String routeType,
    required RouteNode routeNode,
  }) {
    _routeTypeStats[routeType] = (_routeTypeStats[routeType] ?? 0) + 1;

    if (kDebugMode) {
      debugPrint(
        '[Migration Tracking] Route type: $routeType, '
        'Count: ${_routeTypeStats[routeType]}',
      );
    }
  }

  /// Prints the collected stats report.
  void printReport() {
    if (_routeTypeStats.isEmpty) {
      debugPrint('[Migration Report] No pageless routes created');
      return;
    }

    debugPrint('[Migration Report] Pageless route types:');
    final sortedEntries = _routeTypeStats.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    for (final entry in sortedEntries) {
      debugPrint('   ${entry.key}: ${entry.value}');
    }

    final total = _routeTypeStats.values.reduce((a, b) => a + b);
    debugPrint('   Total: $total pageless routes');
  }

  /// Resets the stats (useful for tests).
  void reset() {
    _routeTypeStats.clear();
  }
}

/// Composite observer that fans events out to several observers.
///
/// Useful when more than one observer is needed, since
/// [NavigatorCompatibilityOverrides] accepts only a single observer.
///
/// ## Example:
///
/// ```dart
/// navigatorOverrides: NavigatorCompatibilityOverrides(
///   observer: CompositeCompatibilityObserver([
///     DebugCompatibilityObserver(),
///     MigrationTrackingObserver(),
///     AnalyticsCompatibilityObserver(),
///   ]),
/// )
/// ```
class CompositeCompatibilityObserver extends CompatibilityObserver {
  /// Observers that events are delegated to.
  final List<CompatibilityObserver> observers;

  /// Creates a composite observer from the given list.
  CompositeCompatibilityObserver(this.observers);

  @override
  bool willPushPagelessRoute({
    required RouteNodeReadable routeNodeReadable,
    required Route<dynamic> route,
    required String routeId,
  }) =>
      // Every observer must return true for processing to continue.
      observers.every(
        (o) => o.willPushPagelessRoute(
          routeNodeReadable: routeNodeReadable,
          route: route,
          routeId: routeId,
        ),
      );

  @override
  void didCreatePagelessRoute({
    required RouteNodeReadable routeNodeReadable,
    required Route<dynamic> route,
    required String routeId,
    required String routeType,
    required RouteNode routeNode,
  }) {
    for (final observer in observers) {
      observer.didCreatePagelessRoute(
        routeNodeReadable: routeNodeReadable,
        route: route,
        routeId: routeId,
        routeType: routeType,
        routeNode: routeNode,
      );
    }
  }

  @override
  void didFailPagelessRoute({
    required RouteNodeReadable routeNodeReadable,
    required Route<dynamic> route,
    required Object error,
    required RouteNode? routeNode,
  }) {
    for (final observer in observers) {
      observer.didFailPagelessRoute(
        routeNodeReadable: routeNodeReadable,
        route: route,
        error: error,
        routeNode: routeNode,
      );
    }
  }
}
