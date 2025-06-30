### avoid_call_dep_method_inside_functions

Do not invoke the `dep` and `asyncDep` methods from within functions. Only assign them
to `late final` fields.

### avoid_direct_scope_child

If a `Dep` within a `ScopeContainer` is responsible for a child scope, it should be a holder (a
subclass of `CoreScopeHolder`), not a `ScopeContainer`.

### consider_module_suffix

Do not use the `Dep` suffix for `ScopeModule` fields. Use the `Module` suffix: `entityNameModule`.

### avoid_sync_init_dispose

Entities that require initialization are often initialized asynchronously. Similarly, disposal often
requires asynchronous execution (e.g., `subscription.cancel()`). Using synchronous `init`/`dispose`
methods can lead to asynchronous functions being called without `await`, potentially causing
non-deterministic initialization or disposal order. To avoid this, even synchronous initialization
should be handled in asynchronous `init`/`dispose` methods.

### avoid_passing_deps_in_constructor

Do not pass `Dep` into the constructor of other entities. `Dep` should only be used within
a `ScopeContainer`.

### order_initialize_queue_first

Declare `initializeQueue` as the first member in `ScopeContainer`. This helps to quickly identify
asynchronous dependencies and their execution order.

### wrong_scope_container_fields_order

Declare fields within a `ScopeContainer` in the following order (if applicable):

1. `initializeQueue` getter (if necessary)
2. All `ScopeHolder` fields for child scopes
3. All `ScopeModule` fields for the current scope
4. All `Dep` fields

The order of private/public fields is not regulated.

### avoid_cache_dep_outscope

Do not assign `Dep` to fields or global variables outside the scope.

### avoid_scope_without_holder

Do not instantiate a scope manually outside of a `ScopeHolder`.

### avoid_creating_child_holder_outside_parent_scope

Do not instantiate a child scope outside the parent scope.

### create_container_always_protected

The `createContainer` method should always be `protected`, even in subclasses. This ensures that no
one calls `createContainer` directly, but instead uses the `create` method.

### container_or_dep_in_module_constructor

When instantiating a `ScopeModule`, only pass a `ScopeContainer` or a `Dep` to its constructor, not
instances of classes. Otherwise, there is a risk of breaking the scope's lifecycle. For example,
passing `ScopeModule(someDep.get)` would cause `someDep` to be instantiated immediately upon module
creation, rather than lazily when the dependency is first accessed.

### avoid_child_scope_in_initialize_queue

A child scope should not be an `asyncDep` inside a parent scope. If this happens, it means the child
and parent scopes have the same lifecycle. In this case, the child scope is likely unnecessary. It
is just a subset of the parent scope’s dependencies. Use `ScopeModule` to separate these
dependencies logically. They will still belong to the same scope and share its lifecycle.

### avoid_conditions_in_initialize_queue

All asynchronous dependencies in a scope must be initialized. This ensures that accessing any
dependency always works predictably. If a dependency is declared, it must be ready to use. Any
conditions for initialization should be placed inside the init method.