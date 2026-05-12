import 'package:flutter/widgets.dart';
import 'package:yx_navigation/yx_navigation.dart';

import '../../page_factory/page_factory.dart';

import 'route_widget_builder.dart';
import 'route_outlet_builder.dart';
import 'route_indexed_stack_builder.dart';

/// Signature for a function that builds the widget presented for a route.
///
/// Invoked with the current [BuildContext] and the [RouteNode] that owns
/// the route state.
typedef RouteNodeContentBuilder = Widget Function(
  BuildContext context,
  RouteNode routeNode,
);

/// Route builder that produces the UI for a [RouteDeclaration].
///
/// A route builder is attached to a declaration and supplies the widget
/// shown when the route becomes visible. Implementations decide how the
/// route is wrapped:
/// * [RouteBuilder.widget] — a plain page widget.
/// * [RouteBuilder.outlet] — a nested [Navigator] subtree.
/// * [RouteBuilder.indexed] — an `IndexedStack`-based tab container.
///
/// [T] is the route's "result" type (the type returned by `Navigator.pop`),
/// surfaced through [PageFactory] when present.
abstract interface class RouteBuilder<T> {
  /// Factory used to wrap the built widget into a [Page].
  ///
  /// When `null`, the default page factory resolved from the surrounding
  /// configuration is used.
  abstract final PageFactory<T>? pageFactory;

  /// Builds the widget shown for the route.
  abstract final RouteNodeContentBuilder builder;

  /// Creates a builder that renders a plain widget for the route.
  ///
  /// The [builder] callback is invoked whenever the route is shown.
  const factory RouteBuilder.widget({
    required RouteNodeContentBuilder builder,
    PageFactory<T>? pageFactory,
  }) = RouteWidgetBuilder<T>;

  /// Creates a builder that mounts a nested [Navigator] for the route.
  ///
  /// The nested navigator manages the route's children as a stack. Use
  /// [outletBuilder] to wrap the nested navigator with additional
  /// scaffolding or dependency scopes.
  const factory RouteBuilder.outlet({
    PageFactory<T>? pageFactory,
    RouteNodeOutletBuilder? outletBuilder,
  }) = RouteOutletBuilder<T>;

  /// Creates a builder that renders the route's children in an
  /// `IndexedStack`.
  ///
  /// Typically used to implement bottom navigation bars, tabbed UIs, or
  /// any view where only one child is visible at a time while the others
  /// retain their state.
  static RouteIndexedStackBuilder<T> indexed<T>({
    required RouteNodeIndexedBuilder indexedBuilder,
    PageFactory<T>? pageFactory,
  }) =>
      RouteIndexedStackBuilder<T>(
        indexedBuilder: indexedBuilder,
        pageFactory: pageFactory,
      );
}
