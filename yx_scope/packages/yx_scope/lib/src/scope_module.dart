part of 'base_scope_container.dart';

/// This class helps to decompose [ScopeContainer] into a number of features.
///
/// For example we want to extract all monitoring entities into a separate feature:
///
/// class SomeScopeContainer extends ScopeContainer {
///   // We declare [ScopeModule] inside it's [ScopeContainer]
///   late final monitorScopeModule = MonitorScopeModule(this);
///
///   late final appManagerDep = dep(() => AppManager());
///
///   late final navigationDep = dep(() => Navigation());
/// }
///
/// class MonitorScopeModule extends ScopeModule<SomeScopeModule> {
///   MonitorScopeModule(super.container);
///
///   late final reporterDep = dep(() => Reporter());
///
///   late final loggerDep = dep(() => Logger());
/// }
abstract class ScopeModule<Container extends BaseScopeContainer> {
  final Container container;

  const ScopeModule(this.container);

  @protected
  Dep<Value> dep<Value>(
    DepBuilder<Value> builder, {
    String? name,
  }) =>
      container.dep(builder, name: name);

  @protected
  AsyncDep<Value> asyncDep<Value extends AsyncLifecycle>(
    DepBuilder<Value> builder, {
    String? name,
  }) =>
      container.rawAsyncDep(
        builder,
        init: (value) => value.init(),
        dispose: (value) => value.dispose(),
        name: name,
      );

  @protected
  AsyncDep<Value> rawAsyncDep<Value>(
    DepBuilder<Value> builder, {
    required AsyncDepCallback<Value> init,
    required AsyncDepCallback<Value> dispose,
    String? name,
  }) =>
      container.rawAsyncDep(
        builder,
        init: init,
        dispose: dispose,
        name: name,
      );
}
