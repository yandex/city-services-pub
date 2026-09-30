# yx_navigation: the tree, the entities, the declarations

Navigation is a **`RouteNode` tree**, not a stack. The entry point: the state model, the entities, the kinds of declarations, and the RouteBuilder. Guards are in [guards.md](guards.md). Navigating from business logic is in [blf.md](blf.md). Deep links are in [deeplinks.md](deeplinks.md). Feature isolation and branch mutation are in [isolation.md](isolation.md). Interop with Navigator 1.0 is in [compatibility.md](compatibility.md). Scheme recipes are in [recipes.md](recipes.md).

## A tree instead of a stack

The navigation state is a `RouteNode` tree. A node carries `route` (a `YxRoute`), `arguments` (serializable), `extra` (non-serializable, kept for the migration period), and `children`.

How `children` are interpreted depends on the kind of parent: a stack of screens, sibling stacks, or an `IndexedStack` for tabs.

```
Root
`-- Main (IndexedStack: tabs)
    |-- Messages
    |-- Map (children: [orderCard])
    `-- Profile (the active tab)
```

Every `push` and `pop` is a tree mutation. A screen cannot be opened outside the tree. This is what enables full serialization into a URI, mutation of inactive branches, and reactivity through the `stream` and `state` of `RouteNodeReadable`.

## The main entities

| Entity | Purpose |
|---|---|
| `YxRoute` | identity: `YxRoute(id: 'profile-home')` |
| `RouteNode` / `MutableRouteNode` | a tree node / its mutable copy (`node.toMutable()`) |
| `RouterSchema` | the description of a feature: `declarations` plus `initialNodeBuilder` plus optional `guards` |
| `RouteDeclaration` | the link between a `YxRoute` and the UI |
| `RouteBuilder` | how the UI is built (widget, outlet, indexed) |
| `RouteNodeStateManager` | the root implementation of `NavigationController`, owns the root node |
| `NavigationController` | the contract for reading, mutating, and switching the active branch |
| `NavigationController.node` | a controller scoped to one branch (a `RouteNodeResolver`) |
| `YxRouterConfig` | the Navigator 2.0 components for `MaterialApp.router` |
| `YxNavigation.navigatorOf(context)` | access from the UI |

Two packages, two layers: the core package `yx_navigation` is pure Dart (`RouteNode`, `NavigationController`, `RouteNodeGuard`, `YxRoute`); the Flutter package `yx_navigation_flutter` adds the widget layer (`RouteDeclaration`, `RouteBuilder`, `RouterSchema`, `YxRouterConfig`).

## Kinds of declarations

| Factory | When |
|---|---|
| `RouteDeclaration.routeBuilder` | general-purpose (pages, nested stacks, dynamic tabs) |
| `RouteDeclaration.scheme` | connects a ready `RouterSchema` as an isolated module |
| `RouteDeclaration.indexedStack` | static tabs (`BottomNavigationBar`, `TabBar`); guards are created automatically |
| `RouteDeclaration.strict` | a child can be entered only if it is listed in `declarations` (a rigid topology, rare) |

- `scheme` always creates a nested navigator and isolates the branch.
- `indexedStack` creates guards automatically to keep `children` in sync with `declarations`.
- `routeBuilder` with a `RouteBuilder.indexed` does **not** create guards - declare them explicitly.

## RouteBuilder variants

```dart
// a plain page
RouteBuilder.widget(builder: (context, node) => const ProfilePage())

// a nested stack (children form a stack, a new child goes on top). Use it to wrap in a Scaffold or DI.
RouteBuilder.outlet(outletBuilder: (context, node, outlet) =>
    Scaffold(appBar: AppBar(title: const Text('Home')), body: outlet))

// an IndexedStack for tabs (keeps the state of each tab)
RouteBuilder.indexed(indexedBuilder: (context, node, indexedStack, controller) =>
    Scaffold(
      body: indexedStack,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: tabs.indexOf(controller.activeRoute ?? tabs.first),
        onTap: (i) => controller.setActiveRoute(tabs[i]),
        items: const [/* ... */],
      ),
    ))
```

The `controller` is an `ActiveRouteController`: `activeRoute`, `setActiveRoute(route)`, `isRouteActive(route)`. `RouteBuilder.indexed` creates no guards on its own - for static tabs use `RouteDeclaration.indexedStack` instead.
