import 'package:meta/meta.dart';

import '../base/route_node.dart';

import 'deeplink_handler.dart';
import 'deeplink_handler_result.dart';
import 'deeplink_handler_strategy.dart';

/// {@template composite_deeplink_handler}
/// Composite handler that combines multiple [DeeplinkHandler]s.
///
/// Iterates through handlers according to the specified [strategy].
/// Stops at the first handler that returns a non-null result.
/// {@endtemplate}
@experimental
class CompositeDeeplinkHandler implements DeeplinkHandler {
  /// The strategy for iterating through handlers.
  final DeeplinkHandlerStrategy strategy;

  final List<DeeplinkHandler> _handlers = [];

  /// {@macro composite_deeplink_handler}
  ///
  /// [handlers] - Initial iterable of handlers to add.
  CompositeDeeplinkHandler({
    this.strategy = const DeeplinkHandlerStrategy.fifo(),
    Iterable<DeeplinkHandler> handlers = const [],
  }) {
    _handlers.addAll(handlers);
  }

  /// Returns handlers in their registration order.
  ///
  /// Returns an unmodifiable snapshot of the current list.
  /// Override in subclasses to include additional handlers
  /// (e.g. dynamically attached ones).
  Iterable<DeeplinkHandler> get handlers => List.unmodifiable(_handlers);

  /// Adds a handler to the end of the list.
  void add(DeeplinkHandler handler) => _handlers.add(handler);

  /// Removes a handler from the list.
  ///
  /// Returns `true` if the handler was removed, `false` if it was not found.
  bool remove(DeeplinkHandler handler) => _handlers.remove(handler);

  @override
  DeeplinkHandlerResult? handle(Uri uri, RouteNode currentState) {
    final values = strategy.apply(handlers);
    for (final handler in values) {
      final result = handler.handle(uri, currentState);
      if (result != null) {
        return result;
      }
    }
    return null;
  }
}
