part of '../base_scope_container.dart';

typedef StateListener<S> = void Function(S? scope);

typedef ScopeStateListener<S> = void Function(ScopeState<S> state);

typedef RemoveStateListener = void Function();

class ScopeStateHolder<Scope> {
  final _listeners = LinkedList<Entry<Scope>>();
  ScopeState<Scope> _state;

  bool _debugCanAddListeners = true;

  ScopeStateHolder(this._state);

  Scope? get scope {
    final state = this.state;
    if (state is ScopeStateAvailable<Scope>) {
      return state.scope;
    }
    return null;
  }

  ScopeState<Scope> get state => _state;

  void _updateState(ScopeState<Scope> state) {
    _state = state;

    final errors = <Object>[];
    final stackTraces = <StackTrace>[];

    final listeners = [..._listeners];
    for (final listener in listeners) {
      try {
        listener.listener(state);
      } on Object catch (e, s) {
        errors.add(e);
        stackTraces.add(s);
      }
    }

    if (errors.isNotEmpty) {
      throw NotifyListenerError._(errors, stackTraces);
    }
  }

  /// Subscribes to the state.
  ///
  /// The [listener] callback will be called immediately on addition and
  /// synchronously whenever [state] changes.
  ///
  /// Note: This method only calls the callback when the state is [ScopeStateAvailable]
  /// (passing the scope object) or when the scope is [ScopeStateNone] (passing null).
  /// It doesn't trigger for [ScopeStateInitializing] or [ScopeStateDisposing] states.
  ///
  /// Set [emitImmediately] to true if you want to an immediate execution
  /// of the [listener] with the current state.
  ///
  /// To remove this [listener], call the function returned by [listen].
  ///
  /// Listeners cannot add other listeners.
  /// Adding and removing listeners has a constant time-complexity.
  RemoveStateListener listen(
    StateListener<Scope> listener, {
    bool emitImmediately = false,
  }) =>
      _listen(
        (state) {
          if (state is ScopeStateAvailable<Scope>) {
            listener(state.scope);
          } else if (state is ScopeStateNone) {
            listener(null);
          }
        },
        emitImmediately: emitImmediately,
      );

  /// Subscribes to the state.
  ///
  /// The [listener] callback will be called immediately on addition and
  /// synchronously whenever [state] changes.
  ///
  /// Note: This method emits on every [ScopeState] change.
  ///
  /// Set [emitImmediately] to true if you want to an immediate execution
  /// of the [listener] with the current state.
  ///
  /// To remove this [listener], call the function returned by [listen].
  ///
  /// Listeners cannot add other listeners.
  /// Adding and removing listeners has a constant time-complexity.
  RemoveStateListener listenState(
    ScopeStateListener<Scope> listener, {
    bool emitImmediately = false,
  }) =>
      _listen(
        (state) => listener(state),
        emitImmediately: emitImmediately,
      );

  RemoveStateListener _listen(
    void Function(ScopeState<Scope> state) listener, {
    bool emitImmediately = false,
  }) {
    assert(() {
      if (!_debugCanAddListeners) {
        throw ConcurrentModificationError();
      }
      return true;
    }(), '');
    final listenerEntry = Entry<Scope>(listener);
    if (emitImmediately) {
      assert(_debugSetCanAddListeners(false), '');
      try {
        // Intentionally unsafe call of the listener before adding to the [_listeners]
        // so that if there is an exception — we throw it back to consumer
        // with an original stacktrace without adding to the [_listeners].
        listener(state);
      } on Object catch (_) {
        rethrow;
      } finally {
        assert(_debugSetCanAddListeners(true), '');
      }
    }
    _listeners.add(listenerEntry);

    return () {
      if (listenerEntry.list != null) {
        listenerEntry.unlink();
      }
    };
  }

  bool _debugSetCanAddListeners(bool value) {
    assert(() {
      _debugCanAddListeners = value;
      return true;
    }(), '');
    return true;
  }
}

@visibleForTesting
class Entry<T> extends LinkedListEntry<Entry<T>> {
  Entry(this.listener);

  final ScopeStateListener<T> listener;
}

/// An error thrown when tried to update the state of a [ScopeStateHolder],
/// but some of the listeners threw an exception.
class NotifyListenerError extends Error {
  NotifyListenerError._(
    this.errors,
    this.stackTraces,
  ) : assert(
          errors.length == stackTraces.length,
          'errors and stackTraces must match',
        );

  final List<Object> errors;
  final List<StackTrace?> stackTraces;

  @override
  String toString() {
    final buffer = StringBuffer();

    for (var i = 0; i < errors.length; i++) {
      final error = errors[i];
      final stackTrace = stackTraces[i];

      buffer
        ..writeln(error)
        ..writeln(stackTrace);
    }

    return 'Some of listeners threw exception when updating the state. '
        'The exceptions thrown are:\n$buffer';
  }
}
