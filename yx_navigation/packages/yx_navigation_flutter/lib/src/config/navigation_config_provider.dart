import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

import '../widgets/navigator_overrides.dart';
import 'navigation_defaults.dart';

/// {@template navigation_config_provider}
/// Inherited widget that exposes navigation configuration to its descendants.
///
/// Provides the current [NavigatorOverrides] and [NavigationDefaults] to
/// every widget below it in the tree. Consumers read these values via
/// [NavigationConfigProvider.defaultsOf] or by depending on specific
/// aspects through [InheritedModel].
/// {@endtemplate}
@immutable
class NavigationConfigProvider
    extends InheritedModel<NavigationConfigUpdateAspect> {
  /// Overrides applied to navigator operations.
  final NavigatorOverrides navigatorOverrides;

  /// Default navigation behaviours and implementations.
  final NavigationDefaults defaults;

  /// Creates a [NavigationConfigProvider].
  ///
  /// {@macro navigation_config_provider}
  const NavigationConfigProvider({
    required super.child,
    this.navigatorOverrides = const NavigatorOverrides.defaults(),
    this.defaults = const NavigationDefaults(),
    super.key,
  });

  @override
  bool updateShouldNotify(NavigationConfigProvider oldWidget) => false;

  @override
  bool updateShouldNotifyDependent(
    covariant NavigationConfigProvider oldWidget,
    Set<NavigationConfigUpdateAspect> dependencies,
  ) {
    for (final dependency in dependencies) {
      switch (dependency) {
        case NavigationConfigUpdateAspect.navigatorOverrides:
          final currentValue = navigatorOverrides;
          final oldCurrentValue = oldWidget.navigatorOverrides;
          if (currentValue != oldCurrentValue) {
            return true;
          }
        case NavigationConfigUpdateAspect.defaults:
          final currentValue = defaults;
          final oldCurrentValue = oldWidget.defaults;
          if (currentValue != oldCurrentValue) {
            return true;
          }
      }
    }

    return false;
  }

  /// Returns the [NavigatorOverrides] for the given [context], if any.
  @internal
  static NavigatorOverrides? navigatorOverridesOf(
    BuildContext context, {
    bool listen = true,
  }) =>
      _maybeOf(
        context,
        listen: listen,
        aspect: NavigationConfigUpdateAspect.navigatorOverrides,
      )?.navigatorOverrides;

  /// Returns the [NavigationDefaults] for the given [context], if any.
  ///
  /// Pass `listen: false` to read without registering a dependency.
  static NavigationDefaults? defaultsOf(
    BuildContext context, {
    bool listen = true,
  }) =>
      _maybeOf(
        context,
        listen: listen,
        aspect: NavigationConfigUpdateAspect.defaults,
      )?.defaults;

  /// Returns the nearest [NavigationConfigProvider] ancestor, or `null`
  /// if no such ancestor exists.
  static NavigationConfigProvider? maybeOf(
    BuildContext context, {
    bool listen = false,
  }) =>
      _maybeOf(
        context,
        listen: listen,
        aspect: NavigationConfigUpdateAspect.defaults,
      );

  /// Returns the nearest [NavigationConfigProvider] ancestor.
  ///
  /// Throws an [ArgumentError] if no [NavigationConfigProvider] is found
  /// in the ancestor widget tree.
  static NavigationConfigProvider of(
    BuildContext context, {
    required NavigationConfigUpdateAspect aspect,
    bool listen = true,
  }) {
    final result = _maybeOf(
      context,
      listen: listen,
      aspect: aspect,
    );
    return ArgumentError.checkNotNull(result, 'NavigationConfigProvider');
  }

  /// Returns the [NavigationConfigProvider] associated with the current [BuildContext],
  /// or `null` if there is no [NavigationConfigProvider] widget in the tree.
  static NavigationConfigProvider? _maybeOf(
    BuildContext context, {
    required NavigationConfigUpdateAspect aspect,
    bool listen = true,
  }) {
    if (listen) {
      return InheritedModel.inheritFrom<NavigationConfigProvider>(
        context,
        aspect: aspect,
      );
    }

    return context.getInheritedWidgetOfExactType<NavigationConfigProvider>();
  }
}

enum NavigationConfigUpdateAspect { navigatorOverrides, defaults }
