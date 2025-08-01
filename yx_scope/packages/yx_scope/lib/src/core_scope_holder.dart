part of 'base_scope_container.dart';

/// DO NOT USE THIS CLASS MANUALLY!
/// Use [ScopeHolder], [ChildScopeHolder],
/// [DataScopeHolder] or [ChildDataScopeHolder] instead.
///
/// Holder contains the state of a [BaseScopeContainer] — null or the scope itself.
/// This is the core entity that provides access to the [BaseScopeContainer].
abstract class CoreScopeHolder<Scope, Container extends BaseScopeContainer>
    extends ScopeStateHolder<Scope> with ScopeStateStreamable<Scope> {
  final ScopeObserverInternal _scopeObserverInternal;
  final List<DepObserver>? _depObservers;
  final List<AsyncDepObserver>? _asyncDepObservers;

  Completer? _waitLifecycleCompleter;

  CoreScopeHolder({
    List<ScopeObserver>? scopeObservers,
    List<DepObserver>? depObservers,
    List<AsyncDepObserver>? asyncDepObservers,
    // ignore: deprecated_member_use_from_same_package
    @Deprecated('Use scopeObservers instead')
    List<ScopeListener>? scopeListeners,
    // ignore: deprecated_member_use_from_same_package
    @Deprecated('Use depObservers instead') List<DepListener>? depListeners,
    // ignore: deprecated_member_use_from_same_package
    @Deprecated('Use asyncDepObservers instead')
    List<AsyncDepListener>? asyncDepListeners,
  })  : assert(!(scopeListeners != null && scopeObservers != null),
            'Both scopeObservers and scopeListeners passed as arguments to ScopeHolder. Consider using only scopeObservers'),
        assert(!(depListeners != null && depObservers != null),
            'Both depObservers and depListeners passed as arguments to ScopeHolder. Consider using only depObservers'),
        assert(!(asyncDepListeners != null && asyncDepObservers != null),
            'Both asyncDepObservers and asyncDepListeners passed as arguments to ScopeHolder. Consider using only asyncDepObservers'),
        _scopeObserverInternal =
            ScopeObserverInternal(scopeObservers ?? scopeListeners),
        _depObservers = depObservers ?? depListeners,
        _asyncDepObservers = asyncDepObservers ?? asyncDepListeners,
        super(ScopeState.none());

  /// Initialize scope. [Scope] becomes available and everyone can
  /// start working with it via [BaseScopeHolder].
  ///
  /// Throws [ScopeException] in following cases:
  /// 1. [Container] does not implement [Scope]
  /// 2. [init] is called when the previous [init] is still running
  /// 3. [init] is called when [Scope] is already [ScopeState.available]
  /// 4. [init] is called when [dispose] is now running
  /// and there is already another [init] is waiting for [dispose] to complete
  /// 5. [AsyncDep] from another [BaseScopeContainer] initialized in this [BaseScopeContainer.initializeQueue].
  ///
  @protected
  @mustCallSuper
  Future<void> init(Container scope) async {
    if (scope is! Scope) {
      throw ScopeException('You must implement $Scope for your $Container');
    }

    if (state.initializing) {
      throw ScopeException(
        'You are trying to initialize $Container that is initializing right now. '
        'Given instances of the $Container might be different, '
        'so do not call `create` sequentially without `drops`',
      );
    }

    if (state.available) {
      throw ScopeException(
        'You are trying to initialize $Container that has been already initialized'
        'Given instances of the $Container might be different, '
        'so do not call `create` sequentially without `drops`',
      );
    }

    if (state.disposing) {
      Logger.warning(
        '$Container calls init method while disposing. '
        'This is a weird situation and can lead to unexpected behaviour.',
      );
      final currentCompleter = _waitLifecycleCompleter;
      if (currentCompleter != null) {
        throw ScopeException(
          'Scope is already waiting for dispose in order to be recreated again. '
          'Probably you have called `create` method without await a few times in a row.',
        );
      }
      final completer = Completer.sync();
      _waitLifecycleCompleter = completer;
      final removeListener = listenState((state) {
        if (state.none) {
          completer.complete();
        } else {
          completer.completeError(
            ScopeError(
              'Unexpected state ($state) after ${ScopeState.disposing},'
              ' must be ${ScopeState.none}',
            ),
          );
        }
      });
      try {
        await completer.future;
      } on Object catch (e, s) {
        Error.throwWithStackTrace(
          ScopeError(
            '$e\n'
            'Unexpected exception when were waiting for dispose during initialization. '
            'This is definitely an error in the library,'
            ' please contact an owner, if you see this message.',
          ),
          s,
        );
      } finally {
        _waitLifecycleCompleter = null;
        removeListener();
        Logger.debug(
          'Wait for scope dispose has completed, state=$state',
        );
        if (!state.none) {
          throw ScopeError(
            'Scope initialization waited for dispose of the previous scope state, '
            'it\'s expected to be ${ScopeState.none}, '
            'but it appeared to be $state.'
            'This is definitely an error in the library,'
            ' please contact an owner, if you see this message.',
          );
        }
      }
    }

    _prepareObservers(scope);

    _scopeObserverInternal.onScopeStartInitialize(scope);

    _initializing();

    // Cache already initialized dependencies in order to
    // dispose only initialized ones in case of an exception
    final initialized = <Set<AsyncDep>>[];
    final queue = scope.initializeQueue;
    try {
      for (var i = 0; i < queue.length; i++) {
        initialized.add({});
        final depSet = queue[i];
        await Future.wait(
          depSet.map(
            (dep) {
              final scopeType = Container;
              final depType = dep.runtimeType;
              if (dep._scope != scope) {
                throw ScopeException(
                  'You are initializing async dep $depType '
                  'within ${scope.runtimeType}#${scope.hashCode}, '
                  'but the dep declared in ${dep._scope.runtimeType}#${dep._scope.hashCode}',
                );
              }
              Logger.debug('($scopeType) Initializing: $depType');
              return dep._init().then(
                (_) {
                  initialized[i].add(dep);
                  Logger.debug('($scopeType) Initialized: $depType');
                },
              );
            },
          ),
        );
      }
    } on Object catch (e, s) {
      _scopeObserverInternal.onScopeInitializeFailed(scope, e, s);

      await _drop(initializedScope: scope, initializedDeps: initialized);
      rethrow;
    }
    _available(scope as Scope);
    _scopeObserverInternal.onScopeInitialized(scope);
  }

  /// Dispose scope. [Scope] becomes unavailable.
  ///
  /// In debug throws [AssertionError] in following cases:
  /// 1. [init] is called when the previous [dispose] is still running
  /// 2. [init] is called when [Scope] is already [ScopeState.none]
  ///
  /// Throws [ScopeException] in following cases:
  /// 1. [init] is called when [init] is now running
  /// and there is already another [dispose] is waiting for [init] to complete
  ///
  @mustCallSuper
  Future<void> drop() => _drop();

  Future<void> _drop({
    Container? initializedScope,
    List<Set<AsyncDep>>? initializedDeps,
  }) async {
    if (!((initializedScope == null && initializedDeps == null) ||
        (initializedScope != null && initializedDeps != null))) {
      throw const ScopeError(
        '[Internal] _drop method must be called with either '
        'both nullable args (user manual drop) or '
        'both non-nullable args (drop during initialization)',
      );
    }

    if (state.disposing) {
      assert(
        false,
        'You are trying to dispose $Container that is disposing right now',
      );
      return;
    }

    if (state.none) {
      assert(
        false,
        'You are trying to dispose $Container that has been already disposed or never existed',
      );
      return;
    }

    if (state.initializing) {
      // if no initialized dependencies has been passed
      // then this is a normal drop
      if (initializedDeps == null && initializedScope == null) {
        Logger.warning(
          '$Container calls dispose method while initializing. '
          'This is a weird situation and can lead to unexpected behaviour.',
        );

        final currentCompleter = _waitLifecycleCompleter;
        if (currentCompleter != null) {
          throw ScopeException(
            'Scope is already waiting for initialization in order to be disposed again. '
            'Probably you have called `drop` method without await a few times in a row.',
          );
        }
        final completer = Completer.sync();
        _waitLifecycleCompleter = completer;

        final removeListener = listenState((state) {
          if (state.available) {
            completer.complete();
          } else {
            completer.completeError(
              ScopeError(
                'Unexpected state ($state) after ${ScopeState.initializing},'
                ' must be ${ScopeState.available}',
              ),
            );
          }
        });
        try {
          await completer.future;
        } on Object catch (e, s) {
          Error.throwWithStackTrace(
            ScopeError(
              '$e\n'
              'Unexpected exception when were waiting for initialization during dispose. '
              'This is definitely an error in the library,'
              ' please contact an owner, if you see this message.',
            ),
            s,
          );
        } finally {
          _waitLifecycleCompleter = null;
          removeListener();
          Logger.debug(
            'Wait for scope initialization has completed, state=$state',
          );
          if (!state.available) {
            throw ScopeError(
              'Scope dispose waited for initialization of the previous scope state, '
              'it\'s expected to be ${ScopeState.available}, '
              'but it appears to be $state. '
              'This is definitely an error in the library,'
              ' please contact an owner, if you see this message.',
            );
          }
        }
      } else {
        Logger.warning(
          '$Container calls dispose method, because of some exception. '
          'See stacktrace below for more details.',
        );
      }
      // If no initialized dependencies has been passed it means this is an internal drop.
      // It happens only when some Exception appeared during init.
      // In this case we do not wait for availability and do the drop.
    }

    final scope = this.scope as Container? ?? initializedScope;
    if (scope == null) {
      throw ScopeError(
        '$Container must not be null if scope state is $state',
      );
    }

    _scopeObserverInternal.onScopeStartDispose(scope);

    _disposing();

    Logger.debug('Dispose children');
    final listeners = [...scope._disposeListeners];
    await Future.wait<void>(listeners.map((e) => e.call()));

    // If there were already initialized dependencies
    // then we dispose only them and do not bother others
    final queue = (initializedDeps ?? scope.initializeQueue).reversed;
    for (final depSet in queue) {
      await Future.wait(
        depSet.map(
          (dep) {
            final scopeType = Container;
            final depType = dep.runtimeType;
            Logger.debug('($scopeType) Disposing: $depType');
            return dep
                ._dispose()
                .then((_) => Logger.debug('($scopeType) Disposed: $depType'))
                // ignore: avoid_types_on_closure_parameters
                .catchError((Object e, StackTrace s) {
              Logger.error(
                'Exception happened during $depType dispose ($scopeType). '
                'This dependency is skipped and dispose continued.',
                e,
                s,
              );
              _scopeObserverInternal.onScopeDisposeDepFailed(
                scope,
                dep,
                e,
                s,
              );
              // We continue disposing even in case of an exception
              // because we have to complete scope dispose at least for
              // dependencies without exceptions and for the scope itself.
            });
          },
        ),
      );
    }
    scope._unregister();
    _clearObservers(scope);
    await _disposed();
    _scopeObserverInternal.onScopeDisposed(scope);
  }

  // ignore: use_setters_to_change_properties
  void _updateScope(ScopeState<Scope> state) {
    Logger.debug('$Container state: $state');
    _updateState(state);
  }

  void _initializing() => _updateScope(ScopeState.initializing());

  Future<void> _disposed() async {
    try {
      _updateScope(ScopeState.none()); // must be the first call in this method
    } on NotifyListenerError catch (e, s) {
      Logger.error('Some listeners thrown an exception during dispose', e, s);
    }
  }

  void _available(Scope scope) {
    try {
      _updateScope(ScopeState.available(
          scope: scope)); // must be the first call in this method
    } on NotifyListenerError catch (e, s) {
      Logger.error('Some listeners thrown an exception during init', e, s);
    }
  }

  void _disposing() => _updateScope(ScopeState.disposing());

  void _prepareObservers(Container scope) {
    scope._depObserver._observers = _depObservers;
    scope._asyncDepObserver._observers = _asyncDepObservers;
    scope._asyncDepObserver._asyncDepObservers = _asyncDepObservers;
  }

  void _clearObservers(Container scope) {
    scope._depObserver._observers = null;
    scope._asyncDepObserver._observers = null;
    scope._asyncDepObserver._asyncDepObservers = null;
  }
}
