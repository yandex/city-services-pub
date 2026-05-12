import 'package:meta/meta.dart';

import 'deeplink_handler.dart';

/// {@template deeplink_handler_strategy}
/// Strategy for iterating through multiple deeplink handlers.
///
/// Determines the order in which handlers are called when processing a deeplink.
/// Iteration stops at the first handler that returns a non-null result.
///
/// Two built-in strategies are provided:
/// - [DeeplinkHandlerStrategy.fifo] — handlers are called in registration order.
/// - [DeeplinkHandlerStrategy.lifo] — handlers are called in reverse order.
///
/// To implement a custom strategy, extend this class and override [apply]:
/// ```dart
/// class MyCustomStrategy extends DeeplinkHandlerStrategy {
///   const MyCustomStrategy();
///
///   @override
///   Iterable<DeeplinkHandler> apply(Iterable<DeeplinkHandler> handlers) {
///     // Return handlers in the desired order.
///     return handlers.where((h) => h is MyPriorityHandler).followedBy(
///       handlers.where((h) => h is! MyPriorityHandler),
///     );
///   }
/// }
/// ```
/// {@endtemplate}
@experimental
abstract class DeeplinkHandlerStrategy {
  const DeeplinkHandlerStrategy();

  /// FIFO (First In, First Out): first registered handler is called first.
  const factory DeeplinkHandlerStrategy.fifo() = FifoDeeplinkHandlerStrategy;

  /// LIFO (Last In, First Out): last registered handler is called first.
  const factory DeeplinkHandlerStrategy.lifo() = LifoDeeplinkHandlerStrategy;

  /// Returns [handlers] in the order this strategy defines.
  ///
  /// Called by [CompositeDeeplinkHandler] to determine the iteration order
  /// before processing a deeplink. The first handler in the returned iterable
  /// that returns a non-null result wins.
  Iterable<DeeplinkHandler> apply(Iterable<DeeplinkHandler> handlers);
}

/// {@template fifo_deeplink_handler_strategy}
/// FIFO strategy: handlers are called in registration order.
/// {@endtemplate}
final class FifoDeeplinkHandlerStrategy extends DeeplinkHandlerStrategy {
  /// {@macro fifo_deeplink_handler_strategy}
  const FifoDeeplinkHandlerStrategy();

  @override
  Iterable<DeeplinkHandler> apply(Iterable<DeeplinkHandler> handlers) =>
      handlers;
}

/// {@template lifo_deeplink_handler_strategy}
/// LIFO strategy: handlers are called in reverse registration order.
/// {@endtemplate}
final class LifoDeeplinkHandlerStrategy extends DeeplinkHandlerStrategy {
  /// {@macro lifo_deeplink_handler_strategy}
  const LifoDeeplinkHandlerStrategy();

  @override
  Iterable<DeeplinkHandler> apply(Iterable<DeeplinkHandler> handlers) =>
      handlers.toList().reversed;
}
