import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';
import 'package:yx_navigation/yx_navigation.dart';

import '../../page_factory/page_factory.dart';
import '../../router/router_schema.dart';
import '../back_button_handler.dart';
import '../builder/route_builder.dart';
import '../builder/route_outlet_builder.dart';
import '../builder/route_indexed_stack_builder.dart';
import 'route_builder_declaration.dart';
import 'route_schema_declaration.dart';
import 'route_indexed_stack_declaration.dart';
import 'route_strict_declaration.dart';

/// Public interface for route declarations.
///
/// A declaration binds a [YxRoute] to a [RouteBuilder] that produces
/// the UI for the route. Use one of the named factory constructors to pick
/// the flavour that matches your use case:
///
/// * [RouteDeclaration.routeBuilder] — flexible declaration with optional,
///   non-enforced child routes.
/// * [RouteDeclaration.scheme] — embeds a nested [RouterSchema] as an
///   isolated subtree with its own Navigator.
/// * [RouteDeclaration.indexedStack] — tab-style navigation backed by an
///   `IndexedStack`.
/// * [RouteDeclaration.strict] — declaration with enforced child hierarchy
///   validation.
///
/// Custom declarations should extend [BaseRouteDeclaration] rather than
/// implementing this interface directly, so they inherit the standard
/// [buildDeclarations] / [buildGuards] traversal.
abstract interface class RouteDeclaration {
  /// The Flutter-agnostic route identity for this declaration.
  abstract final YxRoute route;

  /// Nested child declarations.
  abstract final Iterable<RouteDeclaration> declarations;

  /// Guards that run for the route this declaration owns.
  abstract final Iterable<RouteNodeGuard> guards;

  /// The Flutter-specific builder that produces the route's widget.
  abstract final RouteBuilder routeBuilder;

  /// Observer notified about mutations that affect this route.
  @experimental
  abstract final YxRouteObserver? observer;

  /// Deeplink handlers provided by this declaration.
  @experimental
  abstract final Iterable<DeeplinkHandler> deeplinkHandlers;

  /// Strategy for iterating through deeplink handlers.
  @experimental
  abstract final DeeplinkHandlerStrategy deeplinkStrategy;

  /// Returns this declaration and every nested declaration in pre-order.
  ///
  /// Used by the framework to flatten the declaration tree when building
  /// resolvers and observer lists.
  Iterable<RouteDeclaration> buildDeclarations();

  /// Returns the guards owned by this declaration and every nested declaration.
  Iterable<RouteNodeGuard> buildGuards();

  /// {@macro route_builder_declaration}
  ///
  /// Additional notes:
  /// * The [declarations] parameter documents expected child routes but does not
  ///   enforce them - any route can be pushed as a child at runtime.
  /// * For production-ready features where you want to ensure all navigation paths
  ///   are explicitly validated, use [RouteDeclaration.strict] instead.
  factory RouteDeclaration.routeBuilder({
    required YxRoute route,
    required RouteBuilder routeBuilder,
    Iterable<RouteDeclaration> declarations,
    Iterable<RouteNodeGuard> guards,
    Iterable<DeeplinkHandler> deeplinkHandlers,
    DeeplinkHandlerStrategy deeplinkStrategy,
    YxRouteObserver? observer,
  }) = RouteBuilderDeclaration;

  /// {@macro route_schema_declaration}
  ///
  /// Parameters:
  /// * [outletBuilder] - allows wrapping the Navigator with InheritedWidgets
  ///   for dependency injection while maintaining isolation
  /// * [navigationController] - optional custom controller for Business Logic First approach
  factory RouteDeclaration.scheme({
    required YxRoute route,
    required RouterSchema schema,
    PageFactory? pageFactory,
    RouteNodeOutletBuilder? outletBuilder,
    GlobalKey<NavigatorState>? navigatorKey,
    TransitionDelegate<Object?>? transitionDelegate,
    Iterable<NavigatorObserver>? navigatorObservers,
    BackButtonHandler? backButtonHandler,
    String? restorationScopeId,
    NavigationController? navigationController,
    YxRouteObserver? observer,
    Iterable<RouteNodeGuard> guards,
  }) = RouteSchemaDeclaration;

  /// {@macro route_indexed_declaration}
  ///
  /// Additional notes:
  /// * Children are automatically synchronized with [declarations] by guards
  /// * No need for manual initialNodeBuilder configuration for tabs
  /// * Use [RouteBuilderDeclaration] + indexed for dynamic tab scenarios
  factory RouteDeclaration.indexedStack({
    required YxRoute route,
    required RouteIndexedStackBuilder routeBuilder,
    required Iterable<RouteDeclaration> declarations,
    Iterable<RouteNodeGuard> guards,
    Iterable<DeeplinkHandler> deeplinkHandlers,
    DeeplinkHandlerStrategy deeplinkStrategy,
    YxRouteObserver? observer,
  }) = RouteIndexedStackDeclaration;

  /// Creates a route declaration with strict hierarchy validation.
  ///
  /// When using this declaration type, all child routes must be explicitly
  /// declared in the [declarations] list. In debug mode, attempting to navigate
  /// to an undeclared child route will trigger an assertion error.
  ///
  /// This is useful for production-ready features where you want to ensure
  /// all navigation paths are explicitly defined and validated.
  factory RouteDeclaration.strict({
    required YxRoute route,
    required RouteBuilder routeBuilder,
    required Iterable<RouteDeclaration> declarations,
    Iterable<RouteNodeGuard> guards,
    Iterable<DeeplinkHandler> deeplinkHandlers,
    DeeplinkHandlerStrategy deeplinkStrategy,
    YxRouteObserver? observer,
  }) = RouteStrictDeclaration;
}

/// Base class shared by all built-in [RouteDeclaration] flavours.
///
/// Holds the common fields (route, declarations, guards, deeplink config,
/// observer) and provides a default pre-order traversal in
/// [buildDeclarations] / [buildGuards]. Subclass it when adding a new
/// declaration type so the framework can walk its tree uniformly.
///
/// The [routeBuilder] field is marked `@internal` — it is part of the
/// renderer contract between a declaration and the framework, not a public
/// API for consumers.
abstract class BaseRouteDeclaration implements RouteDeclaration {
  @override
  final YxRoute route;

  @override
  final Iterable<RouteDeclaration> declarations;

  @override
  final Iterable<RouteNodeGuard> guards;

  @override
  @internal
  final RouteBuilder routeBuilder;

  @override
  final YxRouteObserver? observer;

  @override
  final Iterable<DeeplinkHandler> deeplinkHandlers;

  @override
  final DeeplinkHandlerStrategy deeplinkStrategy;

  BaseRouteDeclaration({
    required this.route,
    required this.routeBuilder,
    this.declarations = const [],
    this.guards = const [],
    @experimental this.deeplinkHandlers = const [],
    @experimental this.deeplinkStrategy = const DeeplinkHandlerStrategy.fifo(),
    @experimental YxRouteObserver? observer,
  }) : observer =
            observer != null ? RouteObserverAdapter(route, observer) : null;

  @override
  Iterable<RouteDeclaration> buildDeclarations() sync* {
    yield this;
    for (final declaration in declarations) {
      yield* declaration.buildDeclarations();
    }
  }

  @override
  Iterable<RouteNodeGuard> buildGuards() sync* {
    yield* guards;
    for (final declaration in declarations) {
      yield* declaration.buildGuards();
    }
  }
}
