part of 'base_scope_container.dart';

/// Abstract base class for creating custom dependency types.
///
/// Use this class as a base when you need to create a specialized dependency
/// with custom behavior, validation, or additional functionality beyond what
/// the standard [Dep] class provides.
///
/// Example:
/// ```dart
/// class DatabaseDep extends CustomDep<Database> {
///   DatabaseDep(BaseScopeContainer scope, String connectionString)
///     : super(scope, () => Database.connect(connectionString));
///
///   @override
///   Database get get {
///     final db = super.get;
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
  }) : super._(scope, builder, name: name, observer: observer);
}

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
  }) : super._(scope, builder,
            name: name, observer: observer, init: init, dispose: dispose);
}
