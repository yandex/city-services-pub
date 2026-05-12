import 'package:flutter/widgets.dart';

import '../widgets/navigator_outlet.dart';
import 'navigation_defaults.dart';

/// {@template navigator_configuration}
/// Groups [Navigator]-related parameters for `RouterSchema.build`.
///
/// Holds the navigator key, observers, an optional wrapping builder, and
/// the [TransitionDelegate] used to animate page changes.
/// {@endtemplate}
@immutable
class NavigatorConfiguration {
  /// The key assigned to the underlying [Navigator].
  final GlobalKey<NavigatorState>? navigatorKey;

  /// Observers attached to the [Navigator].
  final Iterable<NavigatorObserver> navigatorObservers;

  /// Optional builder that wraps the [Navigator] widget in custom content.
  final NavigatorBuilder? navigatorBuilder;

  /// Transition delegate used for navigator animations.
  final TransitionDelegate<Object?> transitionDelegate;

  /// {@macro navigator_configuration}
  const NavigatorConfiguration({
    this.navigatorKey,
    this.transitionDelegate = NavigationDefaults.defaultsTransitionDelegate,
    this.navigatorObservers = const [],
    this.navigatorBuilder,
  });
}
