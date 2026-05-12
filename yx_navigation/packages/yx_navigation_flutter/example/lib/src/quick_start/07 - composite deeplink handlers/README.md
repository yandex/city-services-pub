# Composite Deeplink Handlers Demo

This example demonstrates the new deeplink handling features:

## Features Demonstrated

### 1. Multiple Handlers (CompositeDeeplinkHandler)

- Combine multiple deeplink handlers into one
- Each handler processes its own set of deeplinks
- Initialize handlers via constructor: `CompositeDeeplinkHandler(handlers: [...])`

### 2. Handler Strategies (FIFO vs LIFO)

- **FIFO (First In, First Out)**: First registered handler is called first
- **LIFO (Last In, First Out)**: Last registered handler is called first

### 3. Competing Handlers Demo

This example includes two handlers that process the same `/order/*` path:

- `OrderV1DeeplinkHandler` (V1) — navigates to blue-themed order page
- `OrderV2DeeplinkHandler` (V2) — navigates to green-themed order page

When you send `/order/123`:

- **FIFO strategy**: V1 handler wins → blue OrderDetailsPage
- **LIFO strategy**: V2 handler wins → green OrderDetailsV2Page

To switch strategy, change **`kUseLifoStrategy`** (root `/order/*` handlers) or
**`kUseLifoProfileStrategy`** (nested `/profile/settings` handlers) in
`main.dart`, then restart the app.

### 4. Dynamic Registration (LateInitDeeplinkHandler)

- Attach/detach handlers at runtime
- Useful for modular applications where features register their own handlers

### 5. Schema-level Deeplink Handler

- Define deeplink handler directly in RouterSchema
- Handlers can be inherited by RouteSchemaDeclaration

## Available Deeplinks

### Analytics Handler (registered first)

- `/track?event=<name>` — Track an analytics event (handled, no navigation)

### Order Handler V1 (registered second)

- `/order/<id>` — Navigate to order details (blue page, FIFO wins)
- `/orders` — Navigate to orders list

### Order Handler V2 (registered third)

- `/order/<id>` — Navigate to order details V2 (green page, LIFO wins)

### Dynamic Feature Handler (attached at runtime)

- `/promo?code=<code>` — Show promo code notification

## Testing

1. Run the app with `kUseLifoStrategy = false` (default)
2. Observe the strategy indicator at the top (shows FIFO)
3. Click `/order/123` button — blue OrderDetailsPage appears
4. Stop the app, change `kUseLifoStrategy = true` in `main.dart`
5. Run again and click `/order/123` — green OrderDetailsV2Page appears
6. Use "Attach/Detach Promo Handler" to test dynamic registration
7. Try `/promo?code=SAVE20` with promo handler attached
