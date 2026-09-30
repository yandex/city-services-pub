# Data and Domain: boundaries and mapping

Three levels of coupling between Data and Domain, the state mapping rules, and the StateProvider. **The default is Medium.**

## Boundaries: Easy / Medium / Hard

### Medium - the default

- DTOs are in `data/api` (or in `shared` if they are reused).
- Domain has its own models (`Entity`, `Aggregate`).
- The DTO-to-domain mapping is a pure function inside the repository.

```dart
// data/repository/order_repository.dart
class OrderRepository {
  Future<Order> getOrder() async {
    final dto = await _orderApi.fetch();
    return _mapDtoToDomain(dto); // a pure function
  }
}
// domain works with the domain model Order
class OrderStateManager extends StateManager<Order?> { /* ... */ }
```

### Easy - only under severe time pressure

- DTOs are in shared and Domain uses them directly, with no models of its own.
- For a prototype, an MVP, an experiment. **Not** for long-lived features whose contract evolves.

```dart
// shared/dto/order_dto.dart -> domain uses it directly
class OrderStateManager extends StateManager<OrderDto?> { /* ... */ }
```

### Hard - the canonical option, for long-lived features

- Domain declares an abstract repository interface, the implementation is in Data.
- Domain does not depend on Data. The implementation is injected through DI.

```dart
// domain/repository/order_repository.dart - the interface only
abstract interface class OrderRepository {
  Future<Order> getOrder();
}
// data/repository/order_repository_impl.dart
class OrderRepositoryImpl implements OrderRepository { /* ... */ }
```

Use it for large features, multi-team development, and an evolving contract.

## State mapping

Turn business state into a `ViewObject` with **a pure function inside the ViewModel**, not with a getter on the StateManager.

```dart
// WRONG - mapping through a getter on the StateManager
class OrderStateManager extends StateManager<Order?> {
  String get statusLabel => state?.status == OrderStatus.delivering ? 'On the way' : '...';
}

// RIGHT - a pure function inside the ViewModel
class OrderViewModel implements StateReadable<OrderViewObject> {
  String _mapStatusToLabel(OrderStatus s) => switch (s) {
    OrderStatus.delivering => 'On the way',
    // ...
  };
}
```

Always do the mapping. The only exception is a BFF that already returns the UI format AND a feature that does not evolve. "It is a simple feature" or "there is only one developer" are not reasons: features grow and developers leave.

## StateProvider in domain

Formally "Domain holds only state managers and interactors", and the StateProvider is the exception. Use it when presentation needs an aggregated view without subscribing to several sources separately.

```dart
class OrderSummaryProvider implements StateReadable<OrderSummary> {
  OrderSummaryProvider(this._order, this._account, this._balance);

  final OrderStateReadable _order;
  final AccountStateReadable _account;
  final BalanceStateReadable _balance;

  @override
  OrderSummary get state => OrderSummary(
    orderId: _order.state.id,
    accountName: _account.state.name,
    fee: _balance.state.lastFee,
  );

  @override
  Stream<OrderSummary> get stream => /* combine the streams */;
}
```

A StateProvider only **reads** other state managers. It mutates nothing.
