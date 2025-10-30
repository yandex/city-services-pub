part of 'base_scope_container.dart';

/// Warning: Use this class with very caution.
/// It is not recommended to use this class unless you absolutely need to.
/// It is much easier to use the standard [Dep] class and it covers most of the use cases.
///
/// Abstract base class for creating custom dependency types.
///
/// Use this class as a base when you need to create a specialized dependency
/// with custom behavior, validation, or additional functionality beyond what
/// the standard [Dep] class provides.
///
/// Example:
/// ```dart
/// class DatabaseDep extends Dep<Database> {
///   DatabaseDep._(BaseScopeContainer scope, String connectionString)
///     : super._(
///       scope,
///       () => Database.connect(connectionString),
///       DatabaseDepBehavior(),
///     );
/// }
///
/// class DatabaseDepBehavior extends DepBehavior<Database, DatabaseDep> {
///   @override
///   Database getValue(DepAccess<Database, DatabaseDep> access) {
///     final db = super.getValue(access);
///     if (!db.isConnected) {
///       throw StateError('Database connection is not available');
///     }
///     return db;
///   }
/// }
/// ```
abstract class CustomDep<Value> extends Dep<Value> {
  /// Creates a custom dependency.
  ///
  /// [scope] - The scope container that owns this dependency
  /// [builder] - Factory function that creates the dependency value
  /// [name] - Optional name for debugging purposes
  /// [observer] - Optional observer for monitoring dependency lifecycle
  CustomDep(
    BaseScopeContainer scope,
    DepBuilder<Value> builder, {
    String? name,
    DepObserverInternal? observer,
    DepBehavior<Value, Dep<Value>>? behavior,
  }) : super._(
          scope,
          builder,
          behavior ?? CoreDepBehavior<Value, Dep<Value>>(),
          name: name,
          observer: observer,
        );
}

/// Warning: Use this class with very caution.
/// It is not recommended to use this class unless you absolutely need to.
/// It is much easier to use the standard [AsyncDep] class and it covers most of the use cases.
///
/// Abstract base class for creating custom async dependency types.
///
/// Use this class as a base when you need to create a specialized async dependency
/// that requires initialization and disposal with custom behavior or validation.
///
/// Example:
/// ```dart
/// class HttpClientDep extends CustomAsyncDep<HttpClient> {
///   HttpClientDep(BaseScopeContainer scope, {required String baseUrl})
///     : super(
///         scope,
///         () => HttpClient()..baseUrl = baseUrl,
///         init: (client) async {
///           await client.authenticate();
///           print('HTTP client authenticated');
///         },
///         dispose: (client) async {
///           await client.logout();
///           client.close();
///           print('HTTP client disposed');
///         },
///       );
/// }
///
/// You can also pass a custom behavior to the dependency.
///
/// Example:
/// ```dart
/// class HttpClientDepBehavior extends AsyncDepBehavior<HttpClient, HttpClientDep> {
///   @override
///   HttpClient getValue(AsyncDepAccess<HttpClient, HttpClientDep> access) {
///     final client = access.dep.get;
///     if(!client.loggedIn) {
///       throw StateError('Client is not logged in');
///     }
///     return client;
///   }
/// }
/// ```
abstract class CustomAsyncDep<Value> extends AsyncDep<Value> {
  /// Creates a custom async dependency.
  ///
  /// [scope] - The scope container that owns this dependency
  /// [builder] - Factory function that creates the dependency value
  /// [init] - Async callback called during dependency initialization
  /// [dispose] - Async callback called during dependency disposal
  /// [name] - Optional name for debugging purposes
  /// [observer] - Optional observer for monitoring dependency lifecycle
  CustomAsyncDep(
    BaseScopeContainer scope,
    DepBuilder<Value> builder, {
    required AsyncDepCallback<Value> init,
    required AsyncDepCallback<Value> dispose,
    String? name,
    AsyncDepObserverInternal? observer,
    AsyncDepBehavior<Value, AsyncDep<Value>>? behavior,
  }) : super._(
          scope,
          builder,
          behavior ?? CoreAsyncDepBehavior<Value, AsyncDep<Value>>(),
          name: name,
          observer: observer,
          init: init,
          dispose: dispose,
        );
}
