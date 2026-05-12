import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:yx_navigation/yx_navigation.dart';

import '../../router/deeplink/deeplink_handler_observer.dart';
import 'log_types.dart';

/// {@template debug_observer_readable}
/// Read-only view over the logs captured by the navigation debug observer.
///
/// Implementations expose the most recent state-manager, guard, and deeplink
/// events so the debug panel can render them. [DebugObserverReadable]
/// itself is a [Listenable] and notifies listeners whenever new entries
/// are recorded.
/// {@endtemplate}
abstract class DebugObserverReadable implements Listenable {
  /// Recent [StateManagerLog] entries, oldest first.
  Iterable<StateManagerLog> get stateManagerLogs;

  /// Recent [GuardLog] entries, oldest first.
  Iterable<GuardLog> get guardLogs;

  /// Recent [DeeplinkLog] entries, oldest first.
  Iterable<DeeplinkLog> get deeplinkLogs;
}

/// {@template debug_observer_readable_impl}
/// Default [DebugObserverReadable] that also implements observer interfaces
/// and buffers the latest navigation, guard, and deeplink log lines.
/// {@endtemplate}
class DebugObserverReadableImpl
    with ChangeNotifier
    implements
        DebugObserverReadable,
        StateManagerObserver,
        GuardObserver,
        DeeplinkHandlerObserver {
  /// {@macro debug_observer_readable_impl}
  DebugObserverReadableImpl();

  static const _capacity = 1000;

  final _stateManagerLogsBuffer = _CircularBuffer<StateManagerLog>(
    _capacity,
  );

  final _guardLogsBuffer = _CircularBuffer<GuardLog>(
    _capacity,
  );

  final _deeplinkLogsBuffer = _CircularBuffer<DeeplinkLog>(
    _capacity,
  );

  @override
  Iterable<StateManagerLog> get stateManagerLogs =>
      _stateManagerLogsBuffer.elements;

  DateTime get _now => DateTime.now();

  @override
  Iterable<GuardLog> get guardLogs => _guardLogsBuffer.elements;

  @override
  Iterable<DeeplinkLog> get deeplinkLogs => _deeplinkLogsBuffer.elements;

  @override
  void onCancel(RouteNode origin, RouteNode target, RouteNodeGuard guard) {
    _guardLogsBuffer.add(
      OnCancelLog(
        origin: origin,
        target: target,
        guard: guard,
        timestamp: _now,
      ),
    );
    notifyListeners();
  }

  @override
  void onClose(BaseStateManager stateManager) {
    _stateManagerLogsBuffer.add(OnCloseLog(timestamp: _now));
    notifyListeners();
  }

  @override
  void onCreate(BaseStateManager stateManager) {
    _stateManagerLogsBuffer.add(OnCreatedLog(timestamp: _now));
  }

  @override
  void onError(
    BaseStateManager stateManager,
    Object error,
    StackTrace stackTrace,
  ) {
    _stateManagerLogsBuffer.add(
      ErrorLog(
        error: error,
        stackTrace: stackTrace,
        timestamp: _now,
      ),
    );
    notifyListeners();
  }

  @override
  void onGuard(RouteNode origin, RouteNode target, RouteNodeGuard guard) {
    _guardLogsBuffer.add(
      OnGuardLog(
        origin: origin,
        target: target,
        guard: guard,
        timestamp: _now,
      ),
    );
    notifyListeners();
  }

  @override
  void onGuardError(
    RouteNode origin,
    RouteNode target,
    Object error,
    StackTrace stackTrace,
    RouteNodeGuard guard,
  ) {
    _guardLogsBuffer.add(
      OnGuardErrorLog(
        origin: origin,
        target: target,
        error: error,
        stackTrace: stackTrace,
        guard: guard,
        timestamp: _now,
      ),
    );
    notifyListeners();
  }

  @override
  void onGuardSync(GuardSyncReason reason) {
    _guardLogsBuffer.add(
      OnGuardSyncLog(reason: reason, timestamp: _now),
    );
    notifyListeners();
  }

  @override
  void onMutation(BaseStateManager stateManager, Mutation mutation) {
    _stateManagerLogsBuffer.add(
      MutationLog(mutation: mutation, timestamp: _now),
    );
    notifyListeners();
  }

  @override
  void onNext(RouteNode origin, RouteNode target, RouteNodeGuard? guard) {
    _guardLogsBuffer.add(
      OnNextLog(
        origin: origin,
        target: target,
        guard: guard,
        timestamp: _now,
      ),
    );
    notifyListeners();
  }

  @override
  void onRedirect(
    RouteNode origin,
    RouteNode target,
    RouteNode redirect,
    RouteNodeGuard? guard,
  ) {
    _guardLogsBuffer.add(
      OnRedirectLog(
        origin: origin,
        target: target,
        redirect: redirect,
        guard: guard,
        timestamp: _now,
      ),
    );
    notifyListeners();
  }

  @override
  void onStart(RouteNode origin, RouteNode target) {
    _guardLogsBuffer.add(
      OnStartLog(
        origin: origin,
        target: target,
        timestamp: _now,
      ),
    );
  }

  @override
  void onDeeplinkReceived({
    required Uri uri,
    required RouteNode currentState,
  }) {
    _deeplinkLogsBuffer.add(
      DeeplinkReceivedLog(
        uri: uri,
        currentState: currentState,
        timestamp: _now,
      ),
    );
    notifyListeners();
  }

  @override
  void onDeeplinkNavigate({
    required Uri uri,
    required RouteNode currentState,
    required RouteNode targetState,
  }) {
    _deeplinkLogsBuffer.add(
      DeeplinkNavigateLog(
        uri: uri,
        currentState: currentState,
        targetState: targetState,
        timestamp: _now,
      ),
    );
    notifyListeners();
  }

  @override
  void onDeeplinkHandled({
    required Uri uri,
    required RouteNode currentState,
  }) {
    _deeplinkLogsBuffer.add(
      DeeplinkHandledLog(
        uri: uri,
        currentState: currentState,
        timestamp: _now,
      ),
    );
    notifyListeners();
  }

  @override
  void onDeeplinkSkipped({
    required Uri uri,
    required RouteNode currentState,
  }) {
    _deeplinkLogsBuffer.add(
      DeeplinkSkippedLog(
        uri: uri,
        currentState: currentState,
        timestamp: _now,
      ),
    );
    notifyListeners();
  }

  @override
  void onDeeplinkError({
    required Uri uri,
    required RouteNode currentState,
    required Object error,
    required StackTrace stackTrace,
  }) {
    _deeplinkLogsBuffer.add(
      DeeplinkErrorLog(
        uri: uri,
        currentState: currentState,
        error: error,
        stackTrace: stackTrace,
        timestamp: _now,
      ),
    );
    notifyListeners();
  }
}

class _CircularBuffer<T> {
  final int capacity;
  final Queue<T> _buffer = Queue();

  _CircularBuffer(this.capacity)
      : assert(
          capacity > 0,
          'capacity must be greater than 0',
        );

  void add(T element) {
    _buffer.add(element);
    if (_buffer.length > capacity) {
      _buffer.removeFirst();
    }
  }

  Iterable<T> get elements => _buffer;
}
