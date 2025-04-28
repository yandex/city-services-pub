import 'dart:async';
import 'dart:collection';

import 'package:meta/meta.dart';

import 'core/async_lifecycle.dart';
import 'core/scope_exception.dart';
import 'core/scope_state.dart';
import 'monitoring/observers.dart';
import 'monitoring/models/dep_id.dart';
import 'monitoring/models/scope_id.dart';
import 'monitoring/models/value_meta.dart';
import 'monitoring/raw_observers.dart';
import 'monitoring/scope_observatory_internal.dart';
import 'scope_container.dart';
import 'scope_state_streamable.dart';

part 'core/scope_state_holder.dart';

part 'core_scope_holder.dart';

part 'dep.dart';

part 'monitoring/listeners_internal.dart';

part 'monitoring/observers_internal.dart';

part 'monitoring/models/scope_meta.dart';

part 'scope_holder.dart';

part 'scope_module.dart';

part 'test_utils/scope_container_test_utils.dart';

part 'test_utils/scope_state_test_utils.dart';

typedef _AsyncVoidCallback = Future<void> Function();

typedef _AsyncVoidCallbackRemove = void Function();

typedef AsyncDepCallback<Value> = Future<void> Function(Value dep);

/// {@template base_scope_container}
/// A container and a description of a scope.
///
/// A [BaseScopeContainer] is responsible for managing the lifecycle
/// of its associated dependencies.
///
/// It provides a convenient way to group
/// related dependencies together and initialize them at the same time.
///
/// To create a [ScopeContainer]:
/// 1. Declare a subclass
/// 2. Declare dependencies: late final yourEntityDep = [dep] (or [asyncDep])
/// 3. Override [initializeQueue] getter to specify which dependencies
/// should be initialized when the [ScopeContainer] is initialized.
///
/// An example:
///
/// class SomeScopeContainer extends ScopeContainer {
///   late final appManagerDep = dep(() => AppManager());
///
///   late final reporterDep = dep(() => Reporter());
///
///   late final navigationDep = dep(() => Navigation());
/// }
/// {@endtemplate}
abstract class BaseScopeContainer extends Scope {
  final _container = <Dep>[];

  final String? _name;
  late final ScopeId _id;

  late final DepObserverInternal _depObserver;
  late final AsyncDepObserverInternal _asyncDepObserver;

  BaseScopeContainer({String? name})
      : _name = name,
        super._() {
    _id = ScopeId(runtimeType, hashCode, _name);
    _depObserver = DepObserverInternal(this);
    _asyncDepObserver = AsyncDepObserverInternal(this);
  }

  /// A queue of the initialization for [AsyncDep].
  /// The order of the execution is the following:
  /// [Dep]s inside each Set are executed in parallel in random order —
  /// if dependencies do not depend from each other then place them in Set.
  /// Sets are executed in the order of the List — from 0 to the next and so on.
  /// If some dependencies must be executed in specific order, consider placing
  /// them in separate Sets and order relatively.
  @protected
  List<Set<AsyncDep>> get initializeQueue => [];

  /// The only correct way to declare a [Dep] inside [BaseScopeContainer].
  /// Returns a factory for your [Value].
  ///
  /// Here is an example:
  /// ```
  /// late final someManagerDep = dep(() => SomeManager());
  /// ```
  /// [Dep] must be a late final field inside [BaseScopeContainer]. No methods!
  /// Add suffix 'Dep' to the name of your dependency — it explicitly says in the code
  /// that you are working with [Dep] and not the entity (ex. SomeManager) itself.
  ///
  /// If your entity depends on the other entity, use this approach:
  /// ```
  /// late final dependentManagerDep = dep(() => DependentManager(someManagerDep.get));
  /// ```
  /// In this example DependentManager depends on SomeManager. So we access
  /// SomeManager via Dep<SomeManager> and pass an actual instance
  /// of the SomeManager inside DependentManager.
  ///
  /// [name] parameter can be ignored unless you want to see distinguish
  /// dependencies with the same [Type] in the same or in different scopes.
  @nonVirtual
  @protected
  Dep<Value> dep<Value>(
    DepBuilder<Value> builder, {
    String? name,
  }) =>
      Dep._(this, builder, name: name, observer: _depObserver);

  /// Exactly the same as [BaseScopeContainer.dep] but you only allowed
  /// to declare [AsyncLifecycle] dependencies using this method.
  ///
  /// [name] parameter can be ignored unless you want to see distinguish
  /// dependencies with the same [Type] in the same or in different scopes.
  @nonVirtual
  @protected
  AsyncDep<Value> asyncDep<Value extends AsyncLifecycle>(
    DepBuilder<Value> builder, {
    String? name,
  }) =>
      rawAsyncDep(
        builder,
        init: (value) => value.init(),
        dispose: (value) => value.dispose(),
        name: name,
      );

  /// Exactly the same as [BaseScopeContainer.asyncDep] but you must
  /// declare init and dispose functions.
  ///
  /// It is useful if you don't want to implement [AsyncLifecycle] interface,
  /// but you still have async init/dispose process in your entity.
  ///
  /// [name] parameter can be ignored unless you want to see distinguish
  /// dependencies with the same [Type] in the same or in different scopes.
  @nonVirtual
  @protected
  AsyncDep<Value> rawAsyncDep<Value>(
    DepBuilder<Value> builder, {
    required AsyncDepCallback<Value> init,
    required AsyncDepCallback<Value> dispose,
    String? name,
  }) =>
      AsyncDep._(
        this,
        builder,
        init: init,
        dispose: dispose,
        name: name,
        observer: _asyncDepObserver,
      );

  void _registerDep(Dep dep) => _container.add(dep);

  void _unregister() {
    for (final dep in _container.reversed) {
      dep._unregister();
    }
    _container.clear();
  }
}

/// Mixin for [BaseScopeContainer].
///
/// {@template child_scope_container}
/// Helps to have a parent in a scope.
/// If the scope has a parent you can access
/// parent dependencies within a current scope.
/// {@endtemplate}
mixin ChildScopeContainerMixin<Parent extends Scope> on BaseScopeContainer {
  Parent? _parent;

  /// Must not be used anyone except for the child with this mixin.
  /// Should only be used inside constructor, see [ChildScopeContainer].
  @protected
  set parent(Parent parent) => _parent = parent;

  /// Access parent of the current [BaseScopeContainer].
  Parent get parent {
    final p = _parent;
    if (p == null) {
      throw ScopeException(
        '$runtimeType: You must set parent in your Scope constructor',
      );
    }
    return p;
  }
}

/// Mixin for [BaseScopeContainer].
/// {@template data_scope_container}
/// Helps to have a initial data in a scope.
/// If the scope has data, you can access
/// it as a non-nullable value within current scope.
/// {@endtemplate}
mixin DataScopeContainerMixin<Data> on BaseScopeContainer {
  Data? _data;

  /// Must not be used anyone except for the child with this mixin.
  /// Should only be used inside constructor, see [DataScopeContainer].
  @protected
  set data(Data data) => _data = data;

  /// Access data of the current [BaseScopeContainer].
  Data get data {
    final data = _data;
    if (data == null) {
      throw ScopeException(
        '$runtimeType: You must set data in your Scope constructor',
      );
    }
    return data;
  }
}

/// This is an abstract interface for a custom developer interface
/// that is considered to be implemented by their [BaseScopeContainer].
///
/// For example, you have a [ScopeContainer]:
///
/// class SomeScopeContainer extends ScopeContainer {
///   late final appManagerDep = dep(() => AppManager());
///
///   late final navigationDep = dep(() => Navigation());
///
///   late final reporterDep = dep(() => Reporter());
/// }
///
/// But you don't want to share actual deps with your consumers or
/// you don't want them to know anything about your SomeScopeContainer implementation.
///
/// Then you create an interface:
///
/// abstract class SomeScope implements BaseScope {
///   AppManager get appManager;
///
///   NavigationManager get navigationManager;
/// }
///
/// and implement it by your SomeScopeContainer:
///
/// class SomeScopeContainer extends ScopeContainer implements SomeScope {
///   @override
///   AppManager get appManager => appManagerDep.get;
///
///   @override
///   NavigationManager get navigationManager => navigationDep.get;
///
///   late final appManagerDep = dep(() => AppManager());
///
///   late final navigationDep = dep(() => Navigation());
///
///   late final reporterDep = dep(() => Reporter());
/// }
///
/// It helps you in two ways:
/// 1. You can now use [BaseScopeHolder] (or Child/Data/ChildData-ScopeHolder)
/// and pass your interface as a first generic parameter for your ScopeHolder.
/// It narrows access to your deps giving only the contract that is declared by the interface.
/// 2. You can pass you interface as a [parent] to your [ChildScopeHolder] instead of
/// actual [BaseScopeContainer] implementation. It also narrows access to deps from the parent.
abstract class Scope {
  final _disposeListeners = <_AsyncVoidCallback>{};

  _AsyncVoidCallbackRemove _listenDispose(_AsyncVoidCallback listener) {
    _disposeListeners.add(listener);
    return () {
      _disposeListeners.remove(listener);
    };
  }

  Scope._();
}
