# yx_scope packages

yx_scope is a compile-safe DI framework with advanced scoping capabilities.

## Library Components

The library group currently consists of:

- **[yx_scope](packages/yx_scope)**: The core implementation of the framework
- **[yx_scope_flutter](packages/yx_scope_flutter)**: An adapter library that allows embedding
  yx_scope containers into the widget tree
- **[yx_scope_linter](packages/yx_scope_linter)**: A set of custom lint rules that provide
  additional protection against errors when working with yx_scope

## Features

- Pure Dart
- DI-like (not static and not ServiceLocator)
- Compile-safe access to dependencies
- No code generation
- Flutter-friendly container management
- Declarative description of the dependency tree
- Non-reactive dependency tree
- Unambiguous behavior and lifecycle of dependencies in containers
- Ability to create scopes of any nesting level
- Compile-safe check for the existence of active scopes
- Support for asynchronous dependencies and their initialization
- Compile-safe protection against circular dependencies
