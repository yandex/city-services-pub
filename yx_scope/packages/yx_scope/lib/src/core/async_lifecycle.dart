/// An interface for entities that must be initialized and disposed.
/// You can use this interface both for asynchronous and synchronous initialization.
///
/// If your entity implements this interface and it's created in [ScopeContainer],
/// you have to use [AsyncDep] for instance
/// and pass this dep into [ScopeContainer.initializeQueue].
abstract class AsyncLifecycle {
  /// When you use [AsyncLifecycle] in [ScopeContainer],
  /// this method will be called during initialization of this [ScopeContainer].
  Future<void> init();

  /// When you use [AsyncLifecycle] in [ScopeContainer],
  /// this method will be called during dispose of the [ScopeContainer].
  Future<void> dispose();

  /// AsyncLifecycle can be used only as an interface via 'implements'
  const AsyncLifecycle._();
}
