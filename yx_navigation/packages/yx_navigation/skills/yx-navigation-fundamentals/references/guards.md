# yx_navigation: guards

A guard is the **access policy** for navigation - what is allowed. Orchestrating actions and navigating is the job of an Interactor, not of a guard ("log the user in and then go there" is business logic and does not belong in a guard).

**Keep guards light.** They run on **every** navigation mutation, that is on every `push`, `pop` and the others. No heavy work inside: no network calls, no expensive computation, no traversal of large structures. A guard has to answer "allow, redirect, or cancel" quickly, from state that is already available. Anything heavy goes into an Interactor before the navigation happens.

```dart
abstract interface class RouteNodeGuard {
  GuardResult call(RouteNode origin, RouteNode target, GuardContext context);
}
```

`GuardResult`:
- `.next()` - allow, the next guard runs.
- `.redirect(target: newTarget)` - replace the target; the checks **restart** with the new target.
- `.cancel()` - cancel the mutation, the remaining guards do not run.

Declare guards in `RouteDeclaration.guards` or in `RouterSchema.guards`. They run in list order. Mutate the target through `target.toMutable()` (`findByRoute`, `setChildren`, `add`, `addAll`, `insert`, `removeWhere`, `removeUntil`, `setArguments`).

**An important detail:** a guard declared on one declaration applies to the whole mutation pipeline, not only to its own route. That is why an `AuthGuard` needs to be declared once, at the `RouterSchema` level.

## Recipe: AuthGuard

```dart
class AuthGuard implements RouteNodeGuard {
  const AuthGuard(this._authService);
  final AuthService _authService;

  @override
  GuardResult call(RouteNode origin, RouteNode target, GuardContext context) {
    if (target.findByRoute(AppRoutes.login) != null) return const GuardResult.next();
    if (!_authService.isAuthorized()) {
      return GuardResult.redirect(target: AppRoutes.login.toNode());
    }
    return const GuardResult.next();
  }
}

class AppNavigationSchema extends RouterSchema {
  AppNavigationSchema(this._authService);

  final AuthService _authService;

  @override
  RouteNode initialNodeBuilder(MutableRouteNode node) =>
      node..setChildren([AppRoutes.main.toNode()]);

  @override
  Iterable<RouteNodeGuard> get guards => [AuthGuard(_authService)];

  @override
  late final Iterable<RouteDeclaration> declarations = [/* ... */];
}
```
