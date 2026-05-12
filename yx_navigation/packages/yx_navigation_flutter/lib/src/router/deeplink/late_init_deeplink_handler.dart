import 'package:meta/meta.dart';
import 'package:yx_navigation/yx_navigation.dart';

/// {@template late_init_deeplink_handler}
/// Interface for dynamic registration of deeplink handlers.
/// {@endtemplate}
@experimental
abstract interface class LateInitDeeplinkHandler implements DeeplinkHandler {
  /// Attaches a handler with a unique name.
  ///
  /// Throws [StateError] if a handler with this name is already attached.
  void attach(String name, DeeplinkHandler handler);

  /// Detaches a previously attached handler.
  ///
  /// Throws [StateError] if no handler with this name was attached.
  void detach(String name);
}

/// {@template late_init_deeplink_handler_impl}
/// Implementation of [LateInitDeeplinkHandler] with caching support.
///
/// This handler combines base handlers (added via [add]) with dynamically
/// attached handlers (via [attach]/[detach]). The [handlers] getter returns
/// a cached iterable that is invalidated when handlers are attached or detached.
///
/// Handlers are iterated according to the specified [strategy].
/// {@endtemplate}
@experimental
class LateInitDeeplinkHandlerImpl extends CompositeDeeplinkHandler
    implements LateInitDeeplinkHandler {
  final Map<String, DeeplinkHandler> _namedHandlers = {};
  Iterable<DeeplinkHandler>? _cachedHandlers;

  /// {@macro late_init_deeplink_handler_impl}
  ///
  /// [strategy] - The strategy for iterating through handlers.
  /// [handlers] - Initial iterable of base handlers.
  LateInitDeeplinkHandlerImpl({
    super.strategy,
    Iterable<DeeplinkHandler> handlers = const [],
  }) {
    for (final handler in handlers) {
      add(handler);
    }
  }

  @override
  Iterable<DeeplinkHandler> get handlers {
    final cached = _cachedHandlers;
    if (cached != null) {
      return cached;
    }

    return _cachedHandlers = List.unmodifiable([
      ...super.handlers,
      ..._namedHandlers.values,
    ]);
  }

  @override
  void attach(String name, DeeplinkHandler handler) {
    if (_namedHandlers.containsKey(name)) {
      throw StateError('Handler "$name" is already attached');
    }
    _namedHandlers[name] = handler;
    _cachedHandlers = null;
  }

  @override
  void detach(String name) {
    if (!_namedHandlers.containsKey(name)) {
      throw StateError('Handler "$name" was not attached');
    }
    _namedHandlers.remove(name);
    _cachedHandlers = null;
  }
}
