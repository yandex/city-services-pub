## Introduction

### Dependency Management Challenges

In any non-trivial application, organizing interactions between classes of different layers and functions is a primary challenge. There are several standard approaches to solving this problem:

**Singleton** — The simplest method, but with critical flaws:
- Impossible to manage resources (disposal).
- No control over scope/visibility.
- Implicit connections between components.
- Non-deterministic behavior effectively detectable only at runtime.

**ServiceLocator** — A more flexible approach with partial control:
- Allows resource management via Factories and containers.
- However, it retains issues with scope visibility and implicit dependencies.
- Any component can access any other component through the global locator.

**Dependency Injection (DI)** — Receiving dependencies via the constructor:
- Full resource control by the container.
- Unambiguous dependency graph known at compile time.
- Consumers are unaware of *how* dependencies are provided.

### What is yx_scope?

**yx_scope** is a compile-safe DI framework for Dart featuring advanced scope management capabilities.

**Core Principles:**
- **Compile-safety** — If the code compiles, the connections are valid.
- **Transparency** — No "magic"; behavior is fully deterministic and predictable.
- **Simplicity** — In basic scenarios, it is almost identical to other DI solutions.
- **Scalability** — Easy to create, link, and modify scopes.
- **Flutter-friendly** — Pure Dart, but with convenient integration for UI.

**Key Characteristics:**
- Pure Dart (no dependency on the UI framework).
- True DI approach (neither static access nor ServiceLocator).
- **No code generation.**
- Non-reactive dependency tree (stable graph).
- Declarative dependency definition.
- Support for asynchronous dependencies.
- Compile-safe access to dependencies.
- Nested scopes of any depth.

### The Concept of Scopes

A **Scope** is a group of dependencies bounded by a specific lifecycle. Unlike simple technical lifecycles (singleton, factory), scopes operate on **semantic lifecycles**:

- **Technical Lifecycle:** App lifetime, function execution time.
- **Semantic Lifecycle:** An authorized user session, an active workout, an open document.
- **UI Lifecycle:** Visible screen, active component.

**Key Principle of yx_scope:** Scopes should reflect **business processes, not UI elements**. This allows you to design dependency relationships in terms of domain logic, making the architecture resilient to changes in the presentation layer.

### Terminology

- **Container** — A group of combined dependencies.
- **Dependency (Dep)** — An entity within a container that provides access to a class instance.
- **Scope** — A lifecycle within which only one instance of a container exists.
- **Scope Holder** — An entity managing the container's state (creation/deletion).
- **Super-dependency** — A dependency that the current one depends on.
- **Sub-dependency** — A dependency that depends on the current one.
- **Initialization** — The process of creating and preparing dependencies for use.
- **Dispose** — The process of correctly releasing dependency resources.

### The yx_scope Ecosystem

The ecosystem consists of three packages:

1. [**yx_scope**](https://github.com/yandex/yx_scope/tree/main/packages/yx_scope) — The core framework and DI logic.
2. [**yx_scope_flutter**](https://github.com/yandex/yx_scope/tree/main/packages/yx_scope_flutter) — Adapter for integration into the Flutter widget tree.
3. [**yx_scope_linter**](https://github.com/yandex/yx_scope/tree/main/packages/yx_scope_linter) — A set of lint rules to prevent common mistakes.

---

## Getting Started

### Installation

Add dependencies to your `pubspec.yaml`:

```yaml
dependencies:
  yx_scope: ^1.0.0
  yx_scope_flutter: ^1.0.0  # If using Flutter

dev_dependencies:
  yx_scope_linter: ^1.0.0
  custom_lint: ^0.5.3
```

To enable the linter, add the following to `analysis_options.yaml`:

```yaml
analyzer:
  plugins:
    - custom_lint
```

### Minimal Example

Create a container with dependencies:

```dart
import 'package:yx_scope/yx_scope.dart';

class AppScopeContainer extends ScopeContainer {
  late final routerDep = dep(() => AppRouter());
  late final apiClientDep = dep(() => ApiClient());
  late final userManagerDep = dep(() => UserManager(apiClientDep.get));
}
```

Create a holder to manage the lifecycle:

```dart
class AppScopeHolder extends ScopeHolder<AppScopeContainer> {
  @override
  AppScopeContainer createContainer() => AppScopeContainer();
}
```

Use it in your application:

```dart
Future<void> main() async {
  final appScopeHolder = AppScopeHolder();
  await appScopeHolder.create();

  final appScope = appScopeHolder.scope;
  if (appScope != null) {
    final userManager = appScope.userManagerDep.get;
    // Work with dependencies
  }
  
  await appScopeHolder.drop(); // Release resources
}
```

### Integration with Flutter

```dart
class App extends StatefulWidget {
  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {

  // Variable to store scope state
  final _appScopeHolder = AppScopeHolder();

  @override
  void initState() {
    super.initState();
    // Create scope
    _appScopeHolder.create();
  }

  @override
  void dispose() {
    // Drop scope
    _appScopeHolder.drop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Provide scope to the widget subtree
    return ScopeProvider(
      holder: _appScopeHolder,
      child: ScopeBuilder<AppScopeContainer>.withPlaceholder(
        // Extract scope within the subtree
        builder: (context, appScope) {
          return MaterialApp(
            // Use scope dependencies
            home: HomePage(appScope.config),
          );
        },
        placeholder: const CircularProgressIndicator(),
      ),
    );
  }
}
```

This minimal example demonstrates the core concepts: the **Container** describes dependencies, the **Holder** manages the lifecycle, and Flutter widgets access the scope via a **Provider** and **Builder**.

---

## Basics

### ScopeContainer and Dep

#### Implementing the Container

`ScopeContainer` is a semantic group of dependencies. In the simplest case, this includes all application dependencies:

```dart
class AppScopeContainer extends ScopeContainer {
  late final apiClientDep = dep(() => ApiClient());
  late final userRepositoryDep = dep(() => UserRepository(apiClientDep.get));
  late final authManagerDep = dep(() => AuthManager(userRepositoryDep.get));
}
```

**Key Rules:**

1.  **Must use `late final`** — Dependencies are initialized lazily upon first access and remain immutable.
2.  **Privacy via Underscore** — Hide dependencies that should not be exposed externally:
    ```dart
    late final _internalServiceDep = dep(() => InternalService());
    late final publicServiceDep = dep(() => PublicService(_internalServiceDep.get));
    ```
3.  **Explicit Declaration** — All super-dependencies must be visible inside the container.
4.  **Principle:** The container and dependency links must be described explicitly. This concentrates the dependency tree in one place and makes all connections visible at edit-time.

#### Using `Dep`

`Dep` is a wrapper around a concrete dependency that allows the container to manage instantiation:

```dart
class UserManager {
  final ApiClient _apiClient;
  UserManager(this._apiClient);
}

class AppScopeContainer extends ScopeContainer {
  late final apiClientDep = dep(() => ApiClient());
  
  // Access dependency via .get
  late final userManagerDep = dep(() => UserManager(apiClientDep.get));
}
```

**Important Characteristics:**
- **Single Instance** — Within one container, each dependency is created only once upon first access.
- **Lazy Initialization** — The dependency is created only when it is accessed for the first time.
- **Container Isolation** — Different containers hold completely independent instances.
- **Principle:** `Dep` should only be passed inside via constructor inside other Dep instances. This isolates the DI mechanism from business logic.

### ScopeHolder

#### Implementing ScopeHolder

`ScopeHolder` is the storage that holds the current state of the container for a scope:

```dart
class AppScopeHolder extends ScopeHolder<AppScopeContainer> {
  @override
  AppScopeContainer createContainer() => AppScopeContainer();
}
```

Using `ScopeHolder` is mandatory for accessing the container. It provides two key benefits:
1.  **Compile-time null-safety** — Enforces checking if the scope exists.
2.  **Reactivity** — Ability to subscribe to scope state changes.

#### Using ScopeHolder

```dart
final appScopeHolder = AppScopeHolder();

// Scope creation (always async)
await appScopeHolder.create();

// Synchronous access to container (can be null)
final appScope = appScopeHolder.scope;
if (appScope != null) {
  final userManager = appScope.userManagerDep.get;
}

// Reactive subscription
appScopeHolder.stream.listen((scope) {
  if (scope != null) {
    // Scope exists
  } else {
    // Scope is closed
  }
});

// Closing the scope
await appScopeHolder.drop();
```

### Safe Scope Usage

All access to the scope falls into three categories:

#### Safe Access

Working with the container inside the scope usage tree, where access is guaranteed:

```dart
class UserScopeContainer extends ScopeContainer {
  late final userManagerDep = dep(() => UserManager());

  late final userServiceDep = dep(() => UserService(userManagerDep.get));
}

class UserService {
  final UserManager _userManager;

  UserService(this._userManager);
  
  void doWork() {
    // Safe — we are inside the scope, 
    // so userManager definitely exists
    final userManager = _userManager;
  }
}
```

#### Unsafe Access

Accessing the holder without guarantees that the scope exists:

```dart
void someFunction(AppScopeHolder holder) {
  final scope = holder.scope; // Can be null!
  if (scope != null) {
    final userManager = scope.userManagerDep.get;
    // Use userManager
  } else {
    // Handle scope absence
  }
}
```

#### Quasi-safe Access

After a null check, but before an async gap:

```dart
void handleUser(AppScopeHolder holder) {
  final scope = holder.scope;
  if (scope != null) {
    // Quasi-safe until the first await
    final userManager = scope.userManagerDep.get;
    
    // DO NOT DO THIS — after the async gap, the scope might be closed
    await someAsyncOperation();
    final otherService = scope.otherServiceDep.get; // Dangerous!
  }
}
```

**Rule:** Do not store the container instance in a class field or a local variable accessed across an async gap. This may lead to accessing a closed scope/disposed resources.

### Asynchronous Dependencies

#### The Problem with Constructor Initialization

Many services require asynchronous initialization. Performing this in the constructor creates problems:
- Non-deterministic initialization timing.
- Asymmetry in resource allocation/release.
- Inability to `await` the completion of initialization.

```dart
// BAD
class DatabaseService {
  DatabaseService() {
    _init(); // When will this finish?
  }
  
  Future<void> _init() async { /* ... */ }
}
```

#### Explicit Lifecycle Methods

It is recommended to use explicit `init`/`dispose` async methods:

```dart
class DatabaseService implements AsyncLifecycle {
  Database? _db;
  
  @override
  Future<void> init() async {
    _db = await openDatabase('app.db');
  }
  
  @override
  Future<void> dispose() async {
    await _db?.close();
  }
  
  void query() {
    if (_db == null) throw StateError('Not initialized');
    // Use _db
  }
}
```

#### rawAsyncDep

For dependencies with custom lifecycle logic:

```dart
class AppScopeContainer extends ScopeContainer {
  late final databaseServiceDep = rawAsyncDep<DatabaseService>(
    () => DatabaseService(),
    init: (service) async => service.initilize(),
    dispose: (service) async => service.close(),
  );
}
```

#### asyncDep

For dependencies implementing `AsyncLifecycle`:

```dart
class DatabaseService implements AsyncLifecycle {
  // ...
}

class AppScopeContainer extends ScopeContainer {
  late final databaseServiceDep = asyncDep(() => DatabaseService());
}
```

#### initializeQueue

To control the initialization order of dependencies:

```dart
class AppScopeContainer extends ScopeContainer {
  @override
  List<Set<AsyncDep>> get initializeQueue => [
    // Stage 1 — Parallel initialization
    {configServiceDep, loggerServiceDep},
    // Stage 2 — Depends on Stage 1
    {databaseServiceDep},
    // Stage 3 — Depends on Stage 2
    {userRepositoryDep, authServiceDep},
  ];

  late final configServiceDep = asyncDep(() => ConfigService());
  late final loggerServiceDep = asyncDep(() => LoggerService());
  late final databaseServiceDep = asyncDep(() => DatabaseService(loggerServiceDep.get, configServiceDep.get));
  late final userRepositoryDep = asyncDep(() => UserRepository(databaseServiceDep.get));
  late final authServiceDep = asyncDep(() => AuthService(loggerServiceDep.get));
}
```

**Guarantee:** yx_scope ensures not only the availability of instances but also their full readiness. If access to the container is obtained, all async dependencies typically required at startup are initialized.

### ScopeModule

For grouping related dependencies without creating a separate managed scope:

```dart
class AppScopeContainer extends ScopeContainer {
  late final userScopeHolderDep = dep(() => UserScopeHolder(this));
  
  // Grouping related dependencies
  late final networkModule = NetworkAppScopeModule(this);
  late final storageModule = StorageAppScopeModule(this);
}

class NetworkAppScopeModule extends ScopeModule<AppScopeContainer> {
  NetworkAppScopeModule(super.container);

  late final httpClientDep = dep(() => HttpClient());
  late final apiClientDep = dep(() => ApiClient(httpClientDep.get));
  
  late final authenticatedApiDep = dep(() => AuthenticatedApi(
    apiClientDep.get,
    // Accessing container dependencies
    container.userScopeHolderDep.get,
  ));
}
```

**Principle:** Do not create a Scope if the lifecycle of the entities is the same! Use `ScopeModule` for logical grouping instead.

---

## Interfaces and Architecture

### Container implements Scope

#### The Problem with Direct Container Access

Using the container directly causes architectural issues:

```dart
// Problematic
void someFunction(AppScopeHolder holder) {
  final scope = holder.scope;
  if (scope != null) {
    // 1. Dependency on yx_scope (Dep<T>)
    final userManager = scope.userManagerDep.get;
    
    // 2. Access to all container methods (dep, asyncDep, etc.)
    // 3. Access to all dependencies
  }
}
```

#### Solution via Interface

Create an interface describing only the necessary public dependencies:

```dart
abstract class AppScope implements Scope {
  UserManager get userManager;
  AuthManager get authManager;
  // Only public contract
}

class AppScopeContainer extends ScopeContainer implements AppScope {
  late final _internalServiceDep = dep(() => InternalService());
  late final userManagerDep = dep(() => UserManager(_internalServiceDep.get));
  late final authManagerDep = dep(() => AuthManager(userManagerDep.get));

  // Interface implementation
  @override
  UserManager get userManager => userManagerDep.get;

  @override  
  AuthManager get authManager => authManagerDep.get;
}
```

#### Using the Interface

```dart
void businessLogic(AppScope appScope) {
  // Work only with domain entities
  final userManager = appScope.userManager;
  final authManager = appScope.authManager;
  
  // No access to dep, asyncDep methods
  // No knowledge of yx_scope specifics
}
```

### BaseScopeHolder vs ScopeHolder

#### When to use `BaseScopeHolder`

`BaseScopeHolder` is required when working with interfaces:

```dart
// Standard Holder — works with concrete Container
class SimpleAppScopeHolder extends ScopeHolder<AppScopeContainer> {
  @override
  AppScopeContainer createContainer() => AppScopeContainer();
}

// BaseScopeHolder — allows using an Interface
class AppScopeHolder extends BaseScopeHolder<AppScope, AppScopeContainer> {
  @override
  AppScopeContainer createContainer() => AppScopeContainer();
}
```

**Access Comparison:**

```dart
final simpleAppScopeHolder = SimpleAppScopeHolder();
final appScopeHolder = AppScopeHolder();

// ScopeHolder<AppScopeContainer>
AppScopeContainer? simpleAppScope = simpleAppScopeHolder.scope; // Exposes entire container

// BaseScopeHolder<AppScope, AppScopeContainer>  
AppScope? appScope = appScopeHolder.scope; // Exposes only the interface
```

#### Practical Benefits

```dart
// Accept the Interface, not the implementation
class UserWidget extends StatelessWidget {
  final AppScope appScope;
  
  const UserWidget({required this.appScope, super.key});

  @override
  Widget build(BuildContext context) {
    // Work with domain methods
    return Text(appScope.userManager.currentUser.name);
  }
}

// Use in widget tree
ScopeBuilder<AppScope>.withPlaceholder(
  builder: (context, appScope) => UserWidget(appScope: appScope),
  placeholder: const CircularProgressIndicator(),
)
```

### Holder implements Logic

#### Hiding DI Logic Behind Domain Interfaces

Holders can also be integrated into the domain layer via interfaces:

```dart
// Domain Interface
abstract class UserSessionManager {
  bool get isActive;
  Stream<bool> get isActiveStream;
  Future<void> startSession(User user);
  Future<void> endSession();
}

// Using interface for Holder
class UserScopeHolder extends BaseDataScopeHolder<UserScope, UserScopeContainer, User>
    implements UserSessionManager {
    
  UserScopeHolder();

  @override
  UserScopeContainer createContainer(User data) => UserScopeContainer(user: data);

  // Domain methods
  @override
  bool get isActive => scope != null;

  @override
  Stream<bool> get isActiveStream => stream.map((scope) => scope != null);

  @override
  Future<void> startSession(User user) => create(user);

  @override
  Future<void> endSession() => drop();
}
```

#### Usage in Business Logic

```dart
class AuthManager {
  final UserSessionManager _userSessionManager;
  
  AuthManager(this._userSessionManager);

  Future<void> login(String email, String password) async {
    final user = await _authenticate(email, password);
    
    // Domain logic independent of Scopes
    await _userSessionManager.startSession(user);
  }

  Future<void> logout() async {
    await _userSessionManager.endSession();
  }
}
```

#### Integration in Container

```dart
class AppScopeContainer extends ScopeContainer implements AppScope {
  late final userSessionManagerDep = dep(() => UserScopeHolder());
  late final authManagerDep = dep(() => AuthManager(userSessionManagerDep.get));

  @override
  UserSessionManager get userSessionManager => userSessionManagerDep.get;

  @override
  AuthManager get authManager => authManagerDep.get;
}
```

### Architectural Principles

#### 1. Interfaces in Every Layer

```dart
// DI Layer
abstract class AppScope implements Scope { /* public dependencies */ }
class AppScopeContainer implements AppScope { /* implementation */ }

// Domain Layer
abstract class UserSessionManager { /* business operations */ }
class UserScopeHolder implements UserSessionManager { /* scope logic */ }

// UI Layer
abstract class NavigationDelegate { /* nav operations */ }
class FlutterNavigationDelegate implements NavigationDelegate { /* Flutter specifics */ }
```

#### 2. Depend Only on Interfaces

```dart
class OrderManager {
  final UserSessionManager _userSession;     // Not UserScopeHolder
  final PaymentService _paymentService;      // Not PaymentScopeContainer
  final NavigationDelegate _navigation;      // Not FlutterNavigationDelegate
  
  OrderManager(this._userSession, this._paymentService, this._navigation);
}
```

#### 3. Hide DI Implementation

```dart
// BAD — Leaking DI abstractions
class BadUserWidget extends StatelessWidget {
  final ScopeStateHolder<UserScope?> userScopeHolder;
  
  const BadUserWidget({required this.userScopeHolder, super.key});
}

// GOOD — Only domain interfaces
class GoodUserWidget extends StatelessWidget {
  final UserScope userScope;
  
  const GoodUserWidget({required this.userScope, super.key});
}
```

### Practical Recommendations

#### 1. Always create interfaces for public containers

```dart
// Create a Scope interface for every ScopeContainer
abstract class FeatureScope implements Scope { /* ... */ }
class FeatureScopeContainer extends ScopeContainer implements FeatureScope { /* ... */ }
```

#### 2. Use `BaseScopeHolder` for interfaces

```dart
// Use BaseScopeHolder<Interface, Container> instead of ScopeHolder<Container>
class FeatureScopeHolder extends BaseScopeHolder<FeatureScope, FeatureScopeContainer> {
  @override
  FeatureScopeContainer createContainer() => FeatureScopeContainer();
}
```

#### 3. Integrate Holders into the domain layer

```dart
// Holders should implement domain interfaces
abstract class FeatureManager { /* domain operations */ }
class FeatureScopeHolder extends BaseScopeHolder<FeatureScope, FeatureScopeContainer>
    implements FeatureManager { /* ... */ }
```

---

## Integration with Flutter

### ScopeProvider

#### Injecting the scope into the widget tree

`ScopeProvider` is an `InheritedWidget` that makes the scope available for any part of the subtree:

```dart
class App extends StatefulWidget {
  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  final _appScopeHolder = AppScopeHolder();

  @override
  void initState() {
    super.initState();
    _appScopeHolder.create();
  }

  @override
  void dispose() {
    _appScopeHolder.drop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScopeProvider<AppScope>(
      holder: _appScopeHolder,
      child: MaterialApp(
        home: HomePage(),
      ),
    );
  }
}
```

#### Retrieving Scope via context

```dart
class SomeWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Direct scope retrieval
    final appScope = ScopeProvider.of<AppScope>(context);
    
    // Check scope availability
    if (appScope != null) {
      return Text('User: ${appScope.userManager.currentUser.name}');
    } else {
      return const CircularProgressIndicator();
    }
  }
}
```

#### Retrieving ScopeHolder via context

```dart
class SomeWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Direct holder retrieval
    final appScopeHolder = ScopeProvider.scopeHolderOf<AppScope>(context);
    
    // Check scope availability
    final appScope = appScopeHolder.scope;
    if (appScope != null) {
      return Text('User: ${appScope.userManager.currentUser.name}');
    } else {
      return const CircularProgressIndicator();
    }
  }
}
```

### ScopeBuilder

#### Reactive UI Building

`ScopeBuilder` automatically rebuilds the widget when the scope state changes:

```dart
class UserProfileWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScopeBuilder<AppScope>(
      builder: (context, appScope) {
        if (appScope == null) {
          return const CircularProgressIndicator();
        }
        
        return Column(
          children: [
            Text('Welcome ${appScope.userManager.currentUser.name}'),
            ElevatedButton(
              onPressed: () => appScope.authManager.logout(),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }
}
```

#### Using `withPlaceholder`

For simplification and code readability, use `withPlaceholder`:

```dart
ScopeBuilder<AppScope>.withPlaceholder(
  builder: (context, appScope) {
    // appScope is guaranteed non-null here
    return UserDashboard(
      userManager: appScope.userManager,
      orderManager: appScope.orderManager,
    );
  },
  placeholder: CircularProgressIndicator(),
)
```

#### Passing a specific holder

If you need to use a holder not available via `ScopeProvider`:

```dart
class FeatureWidget extends StatelessWidget {
  final FeatureScopeHolder featureScopeHolder;
  
  const FeatureWidget({required this.featureScopeHolder, super.key});

  @override
  Widget build(BuildContext context) {
    return ScopeBuilder<FeatureScope>(
      holder: featureScopeHolder,
      builder: (context, featureScope) {
        if (featureScope == null) {
          return const Text('Feature not available');
        }
        
        return FeatureContent(scope: featureScope);
      },
    );
  }
}
```

### ScopeListener

#### Handling Side Effects

`ScopeListener` allows reacting to scope changes without rebuilding the UI:

```dart
class NavigationHandler extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScopeListener<UserScope>(
      listener: (context, userScope) {
        if (userScope == null) {
          // User logged out — go to login screen
          Navigator.of(context).pushReplacementNamed('/login');
        } else {
          // User logged in — go to dashboard
          Navigator.of(context).pushReplacementNamed('/dashboard');
        }
      },
      child: const SizedBox.shrink(), // Invisible widget
    );
  }
}
```

#### Showing Notifications

```dart
ScopeListener<OrderScope>(
  listener: (context, orderScope) {
    if (orderScope != null && orderScope.orderManager.isCompleted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order completed!')),
      );
    }
  },
  child: OrderTrackingWidget(),
)
```

#### Combining with other widgets

```dart
class OrderPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ScopeListener<OrderScope>(
        listener: (context, orderScope) {
          // Side effects
          if (orderScope?.orderManager.hasError == true) {
            _showErrorDialog(context);
          }
        },
        child: ScopeBuilder<OrderScope>.withPlaceholder(
          builder: (context, orderScope) {
            // Main UI
            return OrderContent(orderManager: orderScope.orderManager);
          },
          placeholder: const OrderLoadingWidget(),
        ),
      ),
    );
  }
}
```

---

## Advanced Scopes

### Child Scopes

#### ChildScopeContainer and ChildScopeHolder

Child scopes depend on a parent scope and are strictly tied to it. They automatically close if the parent closes.

```dart
// Parent Scope
abstract class AppScope implements Scope {
  NotificationService get notificationService;
}

class AppScopeContainer extends ScopeContainer implements AppScope {

  late final _userScopeHolder = dep(() => UserScopeHolder(this));

  late final notificationServiceDep = dep(() => NotificationService());
  
  @override
  NotificationService get notificationService => notificationServiceDep.get;
}

// Child Scope
abstract class UserScope implements Scope {
  UserManager get userManager;
  UserRepository get userRepository;
}

class UserScopeContainer extends ChildScopeContainer<AppScope> implements UserScope {
  UserScopeContainer({required super.parent});

  late final userManagerDep = dep(() => UserManager(
    parent.notificationService,
  ));
  
  late final _userPreferencesDep = dep(() => UserPreferences());

  late final userRepositoryDep = dep(() => UserRepository());

  @override
  UserManager get userManager => userManagerDep.get;

  @override
  UserRepository get userRepository => userRepositoryDep.get;
}
```

#### Holder for Child Scope

```dart
class UserScopeHolder extends BaseChildScopeHolder<UserScope, UserScopeContainer, AppScope> {
  UserScopeHolder(AppScope parent) : super(parent);

  @override
  UserScopeContainer createContainer(AppScope parent) => UserScopeContainer(parent: parent);
}
```

#### Integration into Parent Container

```dart
class AppScopeContainer extends ScopeContainer implements AppScope {
  // Child scope declared as a dependency
  late final userScopeHolderDep = dep(() => UserScopeHolder(this));

  late final userRepositoryDep = dep(() => UserRepository());

  late final notificationServiceDep = dep(() => NotificationService());

  @override
  UserRepository get userRepository => userRepositoryDep.get;
  
  @override
  NotificationService get notificationService => notificationServiceDep.get;
}
```

#### Using Child Scope

```dart
class UserManager {
  final AppScopeHolder _appScopeHolder;
  
  UserManager(this._appScopeHolder);

  Future<void> loginUser(User user) async {
    final appScope = _appScopeHolder.scope;
    if (appScope != null) {
      // Create child scope for user
      await appScope.userScopeHolder.create();
      
      // Scope will automatically close if appScope closes
    }
  }

  Future<void> logoutUser() async {
    final appScope = _appScopeHolder.scope;
    if (appScope != null) {
      // Implicitly drop child scope
      await appScope.userScopeHolder.drop();
    }
  }
}
```

### Data Scopes

#### DataScopeContainer and DataScopeHolder

Data scopes accept initial data (payload) upon creation:

```dart
class Order {
  final String id;
  final List<OrderItem> items;
  
  Order({required this.id, required this.items});
}

abstract class OrderScope implements Scope {
  Order get order;
  OrderManager get orderManager;
  PaymentProcessor get paymentProcessor;
}

class OrderScopeContainer extends DataScopeContainer<Order> implements OrderScope {
  OrderScopeContainer({required super.data});

  late final orderManagerDep = dep(() => OrderManager(data));
  late final paymentProcessorDep = dep(() => PaymentProcessor(data));

  @override
  Order get order => data;

  @override
  OrderManager get orderManager => orderManagerDep.get;

  @override
  PaymentProcessor get paymentProcessor => paymentProcessorDep.get;
}
```

#### Holder for Data Scope

```dart
class OrderScopeHolder extends BaseDataScopeHolder<OrderScope, OrderScopeContainer, Order> {
  @override
  OrderScopeContainer createContainer(Order data) => OrderScopeContainer(data: data);
}
```

#### Using Data Scope

```dart
class OrderService {
  final OrderScopeHolder _orderScopeHolder;
  
  OrderService(this._orderScopeHolder);

  Future<void> processOrder(Order order) async {
    // Create scope with specific order data
    await _orderScopeHolder.create(order);
    
    final orderScope = _orderScopeHolder.scope;
    if (orderScope != null) {
      await orderScope.orderManager.process();
      await orderScope.paymentProcessor.charge();
    }
    
    // Close scope after processing
    await _orderScopeHolder.drop();
  }
}
```

### ChildData Scopes

#### Combining Parent + Data

Scopes that depend both on a parent regarding dependencies and accept data upon creation:

```dart
abstract class OrderScope implements Scope {
  Order get order;
  OrderManager get orderManager;
  OrderTracker get orderTracker;
}

class OrderScopeContainer extends ChildDataScopeContainer<AppScope, Order> implements OrderScope {
  OrderScopeContainer({
    required super.parent,
    required super.data,
  });

  @override
  List<Set<AsyncDep>> get initializeQueue => [
    {orderTrackerDep}
  ];

  late final orderManagerDep = dep(() => OrderManager(
    data, // Order data
    parent.userRepository, // From parent scope
    parent.notificationService, // From parent scope
  ));

  late final orderTrackerDep = asyncDep(() => OrderTracker(
    data,
    parent.trackingService,
  ));

  @override
  Order get order => data;

  @override
  OrderManager get orderManager => orderManagerDep.get;

  @override
  OrderTracker get orderTracker => orderTrackerDep.get;
}
```

#### Holder for ChildData Scope

```dart
class OrderScopeHolder extends BaseChildDataScopeHolder<
  OrderScope, // Container Interface
  OrderScopeContainer, // Container Implementation
  AppScope, // Parent Interface
  Order // Data Model
> {
  OrderScopeHolder(AppScope parent) : super(parent);

  @override
  OrderScopeContainer createContainer(AppScope parent, Order data) {
    return OrderScopeContainer(parent: parent, data: data);
  }
}
```

#### Integration and Usage

```dart
class AppScopeContainer extends ScopeContainer implements AppScope {
  late final userRepositoryDep = dep(() => UserRepository());
  late final notificationServiceDep = dep(() => NotificationService());
  late final trackingServiceDep = dep(() => TrackingService());
  
  // Child scope holder
  late final orderScopeHolder = dep(() => OrderScopeHolder(this));

  @override
  UserRepository get userRepository => userRepositoryDep.get;
  
  @override
  NotificationService get notificationService => notificationServiceDep.get;
  
  @override
  TrackingService get trackingService => trackingServiceDep.get;
  
  @override
  OrderScopeHolder get orderScopeHolder => orderScopeHolder.get;
}

// Usage
class OrderService {
  final AppScope _appScope;
  
  OrderService(this._appScope);

  Future<void> processOrder(Order order) async {
    // Create child scope with order data
    await _appScope.orderScopeHolder.create(order);
    
    final orderScope = _appScope.orderScopeHolder.scope;
    if (orderScope != null) {
      await orderScope.orderManager.process();
      await orderScope.orderTracker.track();
    }
    
    // Close scope after processing
    await _appScope.orderScopeHolder.drop();
  }
}
```

### Automatic Lifecycle Management

#### Parent scopes automatically close children

```dart
class LifecycleExample {
  final AppScopeHolder _appScopeHolder;
  
  LifecycleExample(this._appScopeHolder);

  Future<void> demonstrateLifecycle() async {
    // Create parent scope
    await _appScopeHolder.create();
    
    final appScope = _appScopeHolder.scope!;
    
    // Create child scope
    await appScope.orderScopeHolder.create(Order(id: '1', items: []));
    
    print('Order active: ${appScope.orderScopeHolder.scope != null}');
    // Output: Order active: true
    
    // Close parent scope
    await _appScopeHolder.drop();
    
    // Child scope is automatically closed
    print('Order active: ${appScope.orderScopeHolder.scope != null}');
    // Output: Order active: false
  }
}
```

#### Reactive State Tracking

```dart
class OrderStatusWidget extends StatelessWidget {
  final OrderScopeHolder orderScopeHolder;
  
  const OrderStatusWidget({required this.orderScopeHolder, super.key});

  @override
  Widget build(BuildContext context) {
    return ScopeBuilder<OrderScope>(
      holder: orderScopeHolder,
      builder: (context, orderScope) {
        if (orderScope == null) {
          return const Text('Order completed or cancelled');
        }
        
        return Column(
          children: [
            Text('Order: ${orderScope.order.id}'),
            Text('Status: ${orderScope.orderManager.status}'),
            StreamBuilder<TrackingInfo>(
              stream: orderScope.orderTracker.trackingStream,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Text('Location: ${snapshot.data!.location}');
                }
                return const Text('Tracking unavailable');
              },
            ),
          ],
        );
      },
    );
  }
}
```

---

## Linking Scopes

### Parent Interfaces

#### The Problem of Tight Coupling

Without interfaces, scopes create tight coupling to concrete implementations:

```dart
// BAD — Tight coupling to concrete implementation
class OnlineScopeContainer extends ChildScopeContainer<AccountScopeContainer> {
  OnlineScopeContainer({required super.parent});

  late final acceptOrderManagerDep = dep(() => AcceptOrderManager(
    parent.orderRepositoryDep.get,  // Direct dependency on Dep
    parent.notificationServiceDep.get,
    parent.userManagerDep.get,
  ));
}
```

Problems with this approach:
- Knowledge of the internal structure of the parent container.
- Impossible to reuse with other parent scopes.
- Difficult to test.

#### Solution via Parent Interfaces

Define an interface describing the expectations the child scope has of its parent:

```dart
// Interface for the child scope
abstract class OnlineScope implements Scope {
  AcceptOrderManager get acceptOrderManager;
}

// Interface describing requirements regarding the parent
abstract class OnlineScopeParent implements Scope {
  OrderRepository get orderRepository;
  NotificationService get notificationService;
  UserManager get userManager;
}

// Child scope depends on interface, not implementation
class OnlineScopeContainer extends ChildScopeContainer<OnlineScopeParent> 
    implements OnlineScope {
  OnlineScopeContainer({required super.parent});

  late final acceptOrderManagerDep = dep(() => AcceptOrderManager(
    parent.orderRepository,     // Use interface getters
    parent.notificationService,
    parent.userManager,
  ));

  @override
  AcceptOrderManager get acceptOrderManager => acceptOrderManagerDep.get;
}

class OnlineScopeHolder extends BaseChildScopeHolder<OnlineScope, 
    OnlineScopeContainer, OnlineScopeParent> {
  OnlineScopeHolder(OnlineScopeParent parent) : super(parent);

  @override
  OnlineScopeContainer createContainer(OnlineScopeParent parent) =>
      OnlineScopeContainer(parent: parent);
}
```

#### Implementing the Parent Interface

The parent scope implements the required interface:

```dart
class AccountScopeContainer extends ChildDataScopeContainer<AppScope, User>
    implements AccountScope, OnlineScopeParent {  // Implements parent interface
  AccountScopeContainer({
    required super.parent,
    required super.data,
  });

  late final _orderRepositoryDep = dep(() => OrderRepository(data));
  late final _notificationServiceDep = dep(() => NotificationService());
  late final _userManagerDep = dep(() => UserManager(data));
  
  // Child scope is created using the interface
  late final _onlineScopeHolderDep = dep(() => OnlineScopeHolder(this));

  // Implementing AccountScope
  @override
  User get user => data;

  // Implementing OnlineScopeParent
  @override
  OrderRepository get orderRepository => _orderRepositoryDep.get;

  @override
  NotificationService get notificationService => _notificationServiceDep.get;

  @override
  UserManager get userManager => _userManagerDep.get;

  // Public access to child scope
  OnlineScopeHolder get onlineScopeHolder => _onlineScopeHolderDep.get;
}
```

### Advantages of Parent Interfaces

#### 1. Reusability

The child scope can work with any parent implementing the required interface:

```dart
// Different parent scopes can provide OnlineScope
class AdminScopeContainer extends ScopeContainer 
    implements AdminScope, OnlineScopeParent {
  // Different implementation, same interface
  @override
  OrderRepository get orderRepository => adminOrderRepositoryDep.get;
  // ...
}

class GuestScopeContainer extends ScopeContainer 
    implements GuestScope, OnlineScopeParent {
  // Yet another implementation
  @override
  OrderRepository get orderRepository => guestOrderRepositoryDep.get;
  // ...
}
```

#### 2. Testability

Easy to create mock implementations for testing:

```dart
class MockOnlineScopeParent implements OnlineScopeParent {
  @override
  OrderRepository get orderRepository => MockOrderRepository();

  @override
  NotificationService get notificationService => MockNotificationService();

  @override
  UserManager get userManager => MockUserManager();
}

void testOnlineScope() {
  final mockParent = MockOnlineScopeParent();
  final onlineHolder = OnlineScopeHolder(mockParent);
  // Test in isolation
}
```

#### 3. Minimal Contracts

The interface describes only what the child scope actually needs:

```dart
// OnlineScope needs only these three dependencies
abstract class OnlineScopeParent implements Scope {
  OrderRepository get orderRepository;
  NotificationService get notificationService;
  UserManager get userManager;
  
  // Doesn't need:
  // - DatabaseService
  // - AuthManager  
  // - NavigationService
  // and other dependencies from AccountScope
}
```

#### 4. Multi-parenting

Scope can implement multiple Parent interfaces:

```dart
// Parent interfaces for different child scopes
abstract class OrderParent implements Scope {
  OrderRepository get orderRepository;
}

abstract class PaymentParent implements Scope {
  PaymentGateway get paymentGateway;
}

// One scope implements multiple parent interfaces
class AccountScopeContainer extends ScopeContainer 
    implements AccountScope, OrderParent, PaymentParent {
  
  late final _orderRepositoryDep = dep(() => OrderRepository());
  late final _paymentGatewayDep = dep(() => PaymentGateway());

  // Child scopes use different parent interfaces
  late final _orderScopeHolderDep = dep(() => OrderScopeHolder(this));
  late final _paymentScopeHolderDep = dep(() => PaymentScopeHolder(this));

  @override
  OrderRepository get orderRepository => _orderRepositoryDep.get;

  @override
  PaymentGateway get paymentGateway => _paymentGatewayDep.get;
}
```



### External Dependencies

#### Isolated Module Scenario

When your module is developed separately or must be integrated into various host applications. This is useful when an external isolated module cannot guarantee inheritance from `Scope`.

```dart
// External dependencies provided by the host
abstract class ExternalDependencies {
  HttpClient get httpClient;
  SecureStorage get secureStorage;
  Logger get logger;
}

// Your module scope accepts external dependencies
class FeatureModuleScopeContainer extends ScopeContainer implements FeatureModuleScope {
  final ExternalDependencies _externalDeps;
  
  FeatureModuleScopeContainer(this._externalDeps);

  late final apiClientDep = dep(() => ApiClient(_externalDeps.httpClient));
  late final authServiceDep = dep(() => AuthService(
    apiClientDep.get,
    _externalDeps.secureStorage,
  ));
  late final featureManagerDep = dep(() => FeatureManager(
    authServiceDep.get,
    _externalDeps.logger,
  ));

  @override
  FeatureManager get featureManager => featureManagerDep.get;
}

class FeatureModuleScopeHolder extends ScopeHolder<FeatureModuleScopeContainer> {
  final ExternalDependencies _externalDeps;
  
  FeatureModuleScopeHolder(this._externalDeps);

  @override
  FeatureModuleScopeContainer createContainer() => 
      FeatureModuleScopeContainer(_externalDeps);
}
```

#### Integrating External Dependencies

```dart
// In Host App
class HostExternalDependencies implements ExternalDependencies {
  @override
  HttpClient get httpClient => _httpClient;

  @override
  SecureStorage get secureStorage => _secureStorage;

  @override
  Logger get logger => _logger;

  final HttpClient _httpClient = HttpClient();
  final SecureStorage _secureStorage = FlutterSecureStorage();
  final Logger _logger = ConsoleLogger();
}

// Integration into main scope
class AppScopeContainer extends ScopeContainer implements AppScope {
  late final _externalDepsDep = dep(() => HostExternalDependencies());
  
  // Module scope as a dependency
  late final featureModuleScopeHolderDep = dep(() => 
      FeatureModuleScopeHolder(_externalDepsDep.get));

  @override
  FeatureModuleScopeHolder get featureModuleScopeHolder => 
      featureModuleScopeHolderDep.get;
}
```

#### Conditional Integration

```dart
// Different implementations for different environments
class ProductionExternalDependencies implements ExternalDependencies {
  @override
  HttpClient get httpClient => ProductionHttpClient();
  // ...
}

class DevelopmentExternalDependencies implements ExternalDependencies {
  @override
  HttpClient get httpClient => DevelopmentHttpClient();
  // ...
}

class TestExternalDependencies implements ExternalDependencies {
  @override
  HttpClient get httpClient => MockHttpClient();
  // ...
}

// Dependency Factory
class ExternalDependenciesFactory {
  static ExternalDependencies create() {
    if (kDebugMode) {
      return DevelopmentExternalDependencies();
    } else if (Platform.environment.containsKey('FLUTTER_TEST')) {
      return TestExternalDependencies();
    } else {
      return ProductionExternalDependencies();
    }
  }
}

// Usage in App
class AppScopeContainer extends ScopeContainer {
  late final _externalDepsDep = dep(() => ExternalDependenciesFactory.create());
  
  late final featureModuleScopeHolderDep = dep(() => 
      FeatureModuleScopeHolder(_externalDepsDep.get));
}
```

### Best Practices for Linking Scopes

Example of passing dependencies through the hierarchy:

```dart
class AppScopeContainer extends ScopeContainer implements AppScope, UserScopeParent {
  late final configServiceDep = dep(() => ConfigService());
  late final loggingServiceDep = dep(() => LoggingService());
  late final userRepositoryDep = dep(() => UserRepository());
  late final authServiceDep = dep(() => AuthService());

  // Implements both AppScope and UserScopeParent
  @override
  ConfigService get configService => configServiceDep.get;

  @override
  UserRepository get userRepository => userRepositoryDep.get;
  // ...
}

class UserScopeContainer extends ChildScopeContainer<UserScopeParent> 
    implements UserScope, FeatureScopeParent {
  UserScopeContainer({required super.parent});

  late final featureConfigServiceDep = dep(() => FeatureConfigService(
    parent.userRepository,
    parent.authService,
  ));

  // Implements FeatureScopeParent for child scopes
  @override
  FeatureConfigService get featureConfigService => featureConfigServiceDep.get;
}
```

#### 1. Always use Parent Interfaces

```dart
// BAD
class ChildScopeContainer extends ChildScopeContainer<ConcreteScopeContainer>

// GOOD  
class ChildScopeContainer extends ChildScopeContainer<ParentScopeInterface>
```

#### 2. Minimize Parent Interfaces

```dart
// Include only truly necessary dependencies
abstract class MinimalParent implements Scope {
  ServiceA get serviceA;  // Used
  // ServiceB get serviceB;  // DO NOT include if not used
}
```

#### 3. Group logically related dependencies

```dart
abstract class DatabaseParent implements Scope {
  UserRepository get userRepository;
  OrderRepository get orderRepository;
  ProductRepository get productRepository;
}

abstract class NetworkParent implements Scope {
  ApiClient get apiClient;
  WebSocketClient get webSocketClient;
}
```

#### 4. Use Interface Composition

```dart
abstract class ComplexScopeParent implements DatabaseParent, NetworkParent {
  // Inherits all methods from DatabaseParent and NetworkParent
  ConfigService get configService;  // Additional dependencies
}
```

---

## Best Practices

### Scope Design Principles

#### 1. Scopes reflect Business Processes, not UI

```dart
// BAD — UI coupling
class LoginPageScopeContainer extends ScopeContainer {
  late final loginFormControllerDep = dep(() => LoginFormController());
  late final submitButtonControllerDep = dep(() => SubmitButtonController());
}

// GOOD — Business process
class AuthenticationScopeContainer extends ScopeContainer {
  late final credentialsValidatorDep = dep(() => CredentialsValidator());
  late final authenticationServiceDep = dep(() => AuthenticationService());
  late final sessionManagerDep = dep(() => SessionManager());
}
```

#### 2. Static Dependencies

All scope dependencies must be known at compile time:

```dart
// BAD — Dynamic dependency injection
class BadScopeContainer extends ScopeContainer {
  final Map<String, Dep> _dynamicDeps = {};
  
  void addDependency<T>(String key, T Function() factory) {
    _dynamicDeps[key] = dep(factory);  // DO NOT DO THIS
  }
}

// GOOD — Static declaration
class GoodScopeContainer extends ScopeContainer {
  late final serviceADep = dep(() => ServiceA());
  late final serviceBDep = dep(() => ServiceB());
  late final serviceCDep = dep(() => ServiceC());
}
```

#### 3. Same Lifecycle Rule

Do not create a separate scope if the lifecycle of entities is identical:

```dart
// BAD — Redundant scopes with identical lifecycle
class UserScopeContainer extends ScopeContainer { /* ... */ }
class UserPreferencesScopeContainer extends ScopeContainer { /* ... */ }  // Same lifecycle!

// GOOD — Single scope with module grouping
class UserScopeContainer extends ScopeContainer {
  late final coreModule = UserCoreModule(this);
  late final preferencesModule = UserPreferencesModule(this);
  late final notificationsModule = UserNotificationsModule(this);
}
```

### Code Organization

#### Project Structure with Scopes

```
lib/
├── di/                          # DI Layer
│   ├── app/
│   │   ├── app_scope.dart      # AppScope + AppScopeContainer + AppScopeHolder
│   │   └── app_modules.dart    # App modules
│   ├── user/
│   │   ├── user_scope.dart
│   │   └── user_modules.dart
│   └── feature/
│       ├── feature_scope.dart
│       └── feature_modules.dart
├── domain/                     # Domain Layer
│   ├── auth/
│   ├── user/
│   └── feature/
├── data/                       # Data Layer
└── ui/                         # UI Layer
```

#### Naming Conventions

```dart
// Scope Interfaces
abstract class FeatureScope implements Scope { /* ... */ }

// Scope Containers
class FeatureScopeContainer extends ScopeContainer implements FeatureScope { /* ... */ }

// Scope Holders
class FeatureScopeHolder extends BaseScopeHolder<FeatureScope, FeatureScopeContainer> { /* ... */ }

// Parent Interfaces
abstract class FeatureScopeParent implements Scope { /* ... */ }

// Modules
class FeatureNetworkModule extends ScopeModule<FeatureScopeContainer> { /* ... */ }

// Dependencies
late final featureManagerDep = dep(() => FeatureManager());  // 'Dep' suffix

// ScopeHolder in Container
late final featureScopeHolder = dep(() => FeatureScopeHolder());  // No 'Dep' suffix

// ScopeModule in Container
late final featureNetworkModule = dep(() => FeatureNetworkModule());  // No 'Dep' suffix
```

#### Separation of Concerns

```dart
// DI Layer — Wiring only
abstract class OrderScope implements Scope {
  OrderManager get orderManager;
  PaymentProcessor get paymentProcessor;
}

// Domain Layer — Business Logic
class OrderManager {
  final OrderRepository _orderRepository;
  final NotificationService _notificationService;
  
  OrderManager(this._orderRepository, this._notificationService);
  
  Future<void> processOrder(Order order) async {
    // Business logic without DI knowledge
  }
}

// UI Layer — Presentation
class OrderWidget extends StatelessWidget {
  final OrderScope orderScope;
  
  const OrderWidget({required this.orderScope, super.key});
  
  @override
  Widget build(BuildContext context) {
    // UI logic without DI knowledge
    return StreamBuilder<OrderStatus>(
      stream: orderScope.orderManager.statusStream,
      builder: (context, snapshot) => OrderStatusWidget(snapshot.data),
    );
  }
}
```

### Using the Linter

#### Setup and Configuration

pubspec.yaml:

```yaml
dev_dependencies:
  yx_scope_linter: ^1.0.0
  custom_lint: ^0.5.3
```

analysis_options.yaml:

```yaml
analyzer:
  plugins:
    - custom_lint

custom_lint:
  rules:
    - consider_dep_suffix     # Check for Dep suffix
    - final_dep               # Check for late final on dependencies
    - dep_cycle               # Detect cyclic dependencies
```

## Common Scenarios

### Factory Pattern via Scopes

When you need to create multiple instances with identical logic:

```dart
// Factory for creating Document Scopes
class DocumentScopeFactory {
  final AppScope _appScope;
  
  DocumentScopeFactory(this._appScope);

  DocumentScopeHolder createDocumentScope() {
    return DocumentScopeHolder(_appScope);
  }
}

// Document Manager
class DocumentManager {
  final DocumentScopeFactory _factory;
  final Map<String, DocumentScopeHolder> _openDocuments = {};
  
  DocumentManager(this._factory);

  Future<void> openDocument(String documentId, DocumentData data) async {
    final scopeHolder = _factory.createDocumentScope();
    await scopeHolder.create(data);
    _openDocuments[documentId] = scopeHolder;
  }

  Future<void> closeDocument(String documentId) async {
    final scopeHolder = _openDocuments.remove(documentId);
    await scopeHolder?.drop();
  }

  DocumentScope? getDocumentScope(String documentId) {
    return _openDocuments[documentId]?.scope;
  }
}
```

### Navigation Scopes

This approach is discouraged by default, but in some cases this is necessary.

Scopes tied to navigation and screen lifecycle:

```dart
// Scope for screen with nav state
class ScreenScopeContainer extends DataScopeContainer<ScreenParams> 
    implements ScreenScope {
  ScreenScopeContainer({required super.data});

  late final navigationStateDep = dep(() => NavigationState(data.initialRoute));
  late final screenManagerDep = dep(() => ScreenManager(
    data,
    navigationStateDep.get,
  ));

  @override
  NavigationState get navigationState => navigationStateDep.get;

  @override
  ScreenManager get screenManager => screenManagerDep.get;
}

// Integration with Flutter Router / Page
class ScreenPageWrapper extends StatefulWidget {
  final ScreenParams params;
  
  const ScreenPageWrapper({required this.params, super.key});

  @override
  State<ScreenPageWrapper> createState() => _ScreenPageWrapperState();
}

class _ScreenPageWrapperState extends State<ScreenPageWrapper> {
  late final ScreenScopeHolder _scopeHolder;

  @override
  void initState() {
    super.initState();
    _scopeHolder = ScreenScopeHolder();
    _scopeHolder.create(widget.params);
  }

  @override
  void dispose() {
    _scopeHolder.drop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScopeProvider<ScreenScope>(
      holder: _scopeHolder,
      child: ScopeBuilder<ScreenScope>.withPlaceholder(
        builder: (context, scope) => ScreenContent(scope: scope),
        placeholder: const ScreenLoadingWidget(),
      ),
    );
  }
}
```

### Testing Scopes

#### Unit Testing Containers

```dart
void main() {
  group('UserScopeContainer', () {
    late UserScopeContainer container;
    late MockAppScope mockAppScope;

    setUp(() {
      mockAppScope = MockAppScope();
      container = UserScopeContainer(parent: mockAppScope, data: testUser);
    });

    tearDown(() async {
      await container.dispose();
    });

    test('should provide user manager', () {
      final userManager = container.userManager;
      expect(userManager, isNotNull);
      expect(userManager.user, equals(testUser));
    });

    test('should initialize async dependencies', () async {
      await container.init();
      
      final asyncService = container.asyncService;
      expect(asyncService.isInitialized, isTrue);
    });
  });
}
```

#### Integration Testing with Flutter

```dart
void main() {
  group('UserScope Integration', () {
    testWidgets('should display user info when scope is ready', (tester) async {
      final mockAppScope = MockAppScope();
      final userScopeHolder = UserScopeHolder(mockAppScope);
      
      await userScopeHolder.create(testUser);

      await tester.pumpWidget(
        MaterialApp(
          home: ScopeProvider<UserScope>(
            holder: userScopeHolder,
            child: const UserProfileWidget(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text(testUser.name), findsOneWidget);
      expect(find.text(testUser.email), findsOneWidget);
      
      await userScopeHolder.drop();
    });

    testWidgets('should show placeholder when scope is null', (tester) async {
      final userScopeHolder = UserScopeHolder(MockAppScope());
      // DO NOT create scope

      await tester.pumpWidget(
        MaterialApp(
          home: ScopeProvider<UserScope>(
            holder: userScopeHolder,
            child: ScopeBuilder<UserScope>.withPlaceholder(
              builder: (context, scope) => const UserProfileWidget(),
              placeholder: const Text('Loading...'),
            ),
          ),
        ),
      );

      expect(find.text('Loading...'), findsOneWidget);
    });
  });
}
```

---

## Reference

### API Overview

#### Core Classes

**ScopeContainer**
- `dep<T>(T Function() factory)` — Synchronous dependency.
- `asyncDep<T>(T Function() factory)` — Async dependency with `AsyncLifecycle`.
- `rawAsyncDep<T>(...)` — Async dependency with custom `init`/`dispose`.
- `List<Set<AsyncDep>> get initializeQueue` — Initialization order for async dependencies.

**ScopeHolder/BaseScopeHolder**
- `Future<void> create()` — Create scope.
- `Future<void> drop()` — Close scope.
- `T? get scope` — Synchronous access to scope.
- `Stream<T?> get stream` — Reactively subscribe to changes.

**Specialized Containers**
- `ChildScopeContainer<Parent>` — Child scope.
- `DataScopeContainer<Data>` — Scope with data.
- `ChildDataScopeContainer<Parent, Data>` — Combined scope.

**Specialized Holders**
- `BaseChildScopeHolder<Scope, Container, Parent>`
- `BaseDataScopeHolder<Scope, Container, Data>`
- `BaseChildDataScopeHolder<Scope, Container, Parent, Data>`

#### Flutter Integration

**ScopeProvider**
- `ScopeProvider<T>({required holder, required child})`
- `ScopeProvider.of<T>(context)` — Retrieve scope from context.
- `ScopeProvider.holderOf<T>(context)` — Retrieve holder from context.

**ScopeBuilder**
- `ScopeBuilder<T>({required builder, holder?})`
- `ScopeBuilder<T>.withPlaceholder({required builder, placeholder, holder?})`

**ScopeListener**
- `ScopeListener<T>({required listener, required child, holder?})`

### Common Mistakes and Solutions

#### 1. Accessing a Closed Scope

```dart
// ERROR
void badMethod(ScopeHolder holder) async {
  final scope = holder.scope;
  if (scope != null) {
    await someAsyncOperation();
    scope.service.doWork();  // Scope acts may be closed already!
  }
}

// SOLUTION
void goodMethod(ScopeHolder holder) async {
  await someAsyncOperation();
  final scope = holder.scope;  // Check after async op
  if (scope != null) {
    scope.service.doWork();
  }
}
```

#### 2. Cyclic Dependencies

```dart
// ERROR
late final serviceADep = dep(() => ServiceA(serviceBDep.get));
late final serviceBDep = dep(() => ServiceB(serviceADep.get));

// SOLUTION — Via Interface or Refactoring
late final serviceADep = dep(() => ServiceA());
late final serviceBDep = dep(() => ServiceB(serviceADep.get));
```

#### 3. Improper Async Initialization

```dart
// ERROR — Not listed in initializeQueue
class BadScopeContainer extends ScopeContainer {
  late final asyncServiceDep = asyncDep(() => AsyncService());
  // initializeQueue not overridden — dependency won't initialize!
}

// SOLUTION
class GoodScopeContainer extends ScopeContainer {
  @override
  List<Set<AsyncDep>> get initializeQueue => [
    {asyncServiceDep}
  ];

  late final asyncServiceDep = asyncDep(() => AsyncService());
}
```

### Performance Considerations

#### 1. Lazy Initialization
Dependencies are created only upon first access. This saves resources but can cause delays:

```dart
// If necessary, force initialization
void preloadCriticalServices(AppScope scope) {
  // Access critical services to create them
  final _ = scope.criticalService;
  final _ = scope.anotherCriticalService;
}
```

#### 2. Optimizing `initializeQueue`
Group independent dependencies for parallel initialization:

```dart
@override
List<Set<AsyncDep>> get initializeQueue => [
  // Parallel initialization of independent services
  {configServiceDep, loggerServiceDep, metricsServiceDep},
  // Sequential initialization of dependent services
  {databaseServiceDep},
  {repositoryServiceDep},
];
```

#### 3. Avoiding Excessive Scopes
Do not create a scope for every entity — group by semantic lifecycle:

```dart
// BAD — Too many scopes
class UserScopeContainer extends ScopeContainer { /* ... */ }
class UserPreferencesScopeContainer extends ScopeContainer { /* ... */ }
class UserNotificationsScopeContainer extends ScopeContainer { /* ... */ }

// GOOD — Single scope with modules
class UserScopeContainer extends ScopeContainer {
  late final preferencesModule = UserPreferencesModule(this);
  late final notificationsModule = UserNotificationsModule(this);
}
```

---

## Conclusion

yx_scope provides a powerful and flexible toolkit for dependency management in Dart/Flutter applications. Its key advantages are:

- **Compile-time safety** — Most errors are caught during compilation.
- **Transparency** — Deterministic and predictable behavior.
- **Scalability** — Suitable for everything from simple apps to complex enterprise solutions.
- **Flutter-friendly** — Natural integration with the widget architecture.

**Core Principles for Success:**
1.  **Design scopes around business processes**, not UI.
2.  **Use interfaces** to reduce coupling.
3.  **Follow the same-lifecycle rule** when defining scopes.
4.  **Use the linter** to prevent common mistakes.
5.  **Test scopes** just like regular classes.

yx_scope enables clean, maintainable, and scalable architecture where dependency management becomes a natural part of development rather than an obstacle.

