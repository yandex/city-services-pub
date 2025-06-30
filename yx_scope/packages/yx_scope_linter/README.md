# yx_scope_linter

## Table of contents

- [Installing yx\_scoped\_linter](#installing-yx_scope_linter)
- [Enabling/disabling lints](#enablingdisabling-lints)
    - [Disable one specific rule](#disable-one-specific-rule)
    - [Disable all lints by default](#disable-all-lints-by-default)
- [All the lints](#all-the-lints)
    - [consider_dep_suffix](#consider_dep_suffix)
    - [dep_cycle](#dep_cycle)
    - [final_dep](#final_dep)
    - [pass_async_lifecycle_in_initialize_queue](#pass_async_lifecycle_in_initialize_queue)
    - [use_async_dep_for_async_lifecycle](#use_async_dep_for_async_lifecycle)

## Installing yx_scope_linter

yx_scope_linter is implemented using [custom_lint]. As such, it uses custom_lint's installation
logic.
Long story short:

- Add both yx_scope_linter and custom_lint to your `pubspec.yaml`:
  ```yaml
  dev_dependencies:
    custom_lint:
    yx_scope_linter:
  ```
- Enable `custom_lint`'s plugin in your `analysis_options.yaml`:

  ```yaml
  analyzer:
    plugins:
      - custom_lint
  ```

## Enabling/disabling lints.

By default when installing yx_scope_linter, most of the lints will be enabled.
To change this, you have a few options.

### Disable one specific rule

You may dislike one of the various lint rules offered by yx_scope_linter.
In that event, you can explicitly disable this lint rule for your project
by modifying the `analysis_options.yaml`

```yaml
analyzer:
    plugins:
        - custom_lint

custom_lint:
    rules:
        # Explicitly disable one lint rule
        -   consider_dep_suffix: false
```

### Disable all lints by default

Instead of having all lints on by default and manually disabling lints of your choice,
you can switch to the opposite logic:
Have lints off by default, and manually enable lints.

This can be done in your `analysis_options.yaml` with the following:

```yaml
analyzer:
    plugins:
        - custom_lint

custom_lint:
    # Forcibly disable lint rules by default
    enable_all_lint_rules: false
    rules:
        # You can now enable one specific rule in the "rules" list
        - consider_dep_suffix
```

## All the lints

### consider_dep_suffix

For dependencies in the Scope Container, use a name with the suffix "Dep".

<span style="color:green">**Good**</span>.

```dart

late final myDep = dep(() => MyDep());
```

<span style="color:red">**Bad**</span>.

```dart

late final justMyString = dep(() => SomeDep());
```

### dep_cycle

A cyclical dependency has been identified. It is necessary to eliminate it.

<span style="color:red">**Bad**</span>.

```dart
// The cycle is detected: my1Dep <- my3Dep <- my2Dep <- my1Dep (dep_cycle)
late final Dep<MyDep1> my1Dep = dep(() => MyDep1(my3Dep));
late final Dep<MyDep2> my2Dep = dep(() => MyDep2(my1Dep));
late final Dep<MyDep3> my3Dep = dep(() => MyDep3(my2Dep));
```

### final_dep

A dep field must be `late final`

<span style="color:green">**Good**</span>.

```dart

late final myDep = dep(() => MyDep());
```

<span style="color:red">**Bad**</span>.

```dart

final myDep = dep(() => SomeDep());

var myDep = dep(() => SomeDep());

late var myDep = dep(() => SomeDep());
```

### pass_async_lifecycle_in_initialize_queue

A dependencies that is asyncDep or rawAsyncDep must be passed to initializeQueue. Otherwise
init/dispose methods will not be called.

### use_async_dep_for_async_lifecycle

Dependency implements AsyncLifecycle interface, must be use asyncDep or rawAsyncDep. Otherwise
init/dispose methods will not be called.

## Manual lints

Not all of the lint rules are implemented so far. So there are all not implemented
ones: [manual linter](doc/manual_linter.md).
