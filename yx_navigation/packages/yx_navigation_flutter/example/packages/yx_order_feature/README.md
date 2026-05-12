# yx_order_feature

Example feature module used by the yx_navigation example app. Shows how to
ship a self-contained feature with its own navigation schema.

## Features

- `OrdersFeatureRouterSchema` - the navigation schema exposed by the feature
- `OrderRoutes` - the routes the feature owns

## Usage

Mount the schema into a host application via
`RouteDeclaration.scheme`:

```dart
RouteDeclaration.scheme(
  route: hostRoute,
  schema: OrdersFeatureRouterSchema(),
)
```
