# yx_navigation: serialization and deep links

The contract:

```dart
abstract interface class PlatformStateSerialization {
  Uri convert(RouteNode node);
  RouteNode parse(Uri data);
}
```

Two formats are included in the package:

- **`PrettyUriStateSerialization`** (the default) - readable: `#/home$?tab=orders/.documents$?folder=work`. The path segments mirror the hierarchy (`/` means a child, and `.`, `..`, `...` set the nesting level).
- **`UriStringStateSerialization`** - a compact base64 form for long paths. It suits OAuth redirects and third-party query parameters. Both serializers take `mergeQueryParams` (off by default) and a `strategy` that puts the state in the path or in the fragment.

```dart
config = schema.build(
  routerConfiguration: RouterConfiguration(
    serialization: const PrettyUriStateSerialization(),
  ),
);
```

For a custom format, implement `PlatformStateSerialization`.

**Pageless routes** (Navigator 1.0 through the compatibility layer) cannot be addressed by a deep link and are invisible to declarative guards.
