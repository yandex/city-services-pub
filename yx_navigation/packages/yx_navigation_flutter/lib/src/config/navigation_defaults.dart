import 'package:flutter/widgets.dart';

import '../base/local_key_factory.dart';
import '../base/route_node_widget_builder.dart';
import '../page_factory/page_factory.dart';
import '../page_factory/pages_factory.dart';
import 'navigation_config_provider.dart';

/// {@template navigation_defaults}
/// Default implementations for configurable navigation behaviours.
///
/// Holds the widget builder, page factory, transition delegate, and local
/// key factory used by the router. Values can be overridden for a subtree
/// by providing a [NavigationConfigProvider].
/// {@endtemplate}
@immutable
class NavigationDefaults {
  /// The [TransitionDelegate] used when no custom delegate is configured.
  static const defaultsTransitionDelegate =
      DefaultTransitionDelegate<Object?>();

  static const NavigationDefaults _defaults = NavigationDefaults();

  /// {@macro navigation_defaults}
  const NavigationDefaults({
    this.widgetBuilder = const RouteNodeWidgetBuilder(),
    this.localKeyFactory = const LocalKeyFactory(),
    this.pageFactory = const PagesFactory.material(),
    this.transitionDelegate = defaultsTransitionDelegate,
  });

  /// Resolves the [NavigationDefaults] for the given [context].
  ///
  /// Returns the defaults provided by the nearest [NavigationConfigProvider]
  /// ancestor, or a const default instance when none is present.
  ///
  /// The caller subscribes to changes in the [NavigationConfigProvider]
  /// so the widget rebuilds when the defaults change.
  static NavigationDefaults resolveNavigationDefaults(
    BuildContext context,
  ) =>
      NavigationConfigProvider.defaultsOf(context) ?? _defaults;

  /// Builder used to construct widgets for route nodes.
  final RouteNodeWidgetBuilder widgetBuilder;

  /// Default [PageFactory] used when a route declaration does not
  /// specify its own page factory.
  final PageFactory<Object?> pageFactory;

  /// Default transition delegate for navigator animations.
  final TransitionDelegate<Object?> transitionDelegate;

  /// Factory for creating [LocalKey]s identifying pages.
  final LocalKeyFactory localKeyFactory;

  /// Returns a copy of this [NavigationDefaults] with the given fields
  /// replaced by non-null parameter values.
  NavigationDefaults copyWith({
    RouteNodeWidgetBuilder? widgetBuilder,
    PageFactory<Object?>? pageFactory,
    TransitionDelegate<Object?>? transitionDelegate,
    LocalKeyFactory? localKeyFactory,
  }) =>
      NavigationDefaults(
        widgetBuilder: widgetBuilder ?? this.widgetBuilder,
        pageFactory: pageFactory ?? this.pageFactory,
        transitionDelegate: transitionDelegate ?? this.transitionDelegate,
        localKeyFactory: localKeyFactory ?? this.localKeyFactory,
      );
}
