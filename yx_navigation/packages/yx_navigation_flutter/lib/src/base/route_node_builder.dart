import 'package:flutter/widgets.dart';
import 'package:yx_navigation/yx_navigation.dart';

import '../compatibility/route_node_compatibility_extension.dart';
import '../config/navigation_defaults.dart';
import 'declaration/route_declaration.dart';
import 'local_key_factory.dart';
import 'route_declaration_resolver.dart';
import 'route_node_widget_builder.dart';

/// A pair of [Page] and the [RouteNode] it was built from.
@immutable
class RoutePageEntry {
  /// The page produced for [routeNode].
  final Page<Object?> page;

  /// The route node that backs [page].
  final RouteNode routeNode;

  /// Creates a [RoutePageEntry].
  const RoutePageEntry({
    required this.page,
    required this.routeNode,
  });
}

/// {@template route_node_builder}
/// Builds the pages and widgets presented for a tree of [RouteNode]s.
///
/// Implementations translate each route node into a [Page] or a [Widget]
/// based on the matching [RouteDeclaration]. The default implementation is
/// [BaseRouteNodeBuilder].
/// {@endtemplate}
abstract interface class RouteNodeBuilder {
  /// Builds the list of pages that correspond to [routeNodes].
  ///
  /// The returned iterable is consumed by a [Navigator] to render the stack.
  Iterable<RoutePageEntry> buildPages(
    BuildContext context,
    Iterable<RouteNode> routeNodes,
  );

  /// Builds the widget that represents [routeNode] on its own.
  Widget buildWidget(
    BuildContext context,
    RouteNode routeNode,
  );

  /// Builds the widget displayed when [routeNode] has no children.
  Widget emptyWidgetBuilder(
    BuildContext context,
    RouteNode routeNode,
  );
}

/// Default [RouteNodeBuilder] implementation.
///
/// Resolves each [RouteNode] to a [RouteDeclaration] via a
/// [RouteDeclarationResolver] and renders it through the configured
/// [RouteNodeWidgetBuilder] and [LocalKeyFactory]. When a dependency is not
/// supplied, the corresponding default from the surrounding
/// `NavigationDefaults` is used.
@immutable
class BaseRouteNodeBuilder implements RouteNodeBuilder {
  final LocalKeyFactory? _localKeyFactory;
  final RouteNodeWidgetBuilder? _widgetRouteNodeBuilder;
  final RouteDeclarationResolver _routeDeclarationResolver;

  const BaseRouteNodeBuilder({
    required RouteDeclarationResolver routeDeclarationResolver,
    RouteNodeWidgetBuilder? widgetRouteNodeBuilder,
    LocalKeyFactory? localKeyFactory,
  })  : _localKeyFactory = localKeyFactory,
        _routeDeclarationResolver = routeDeclarationResolver,
        _widgetRouteNodeBuilder = widgetRouteNodeBuilder;

  @override
  Iterable<RoutePageEntry> buildPages(
    BuildContext context,
    Iterable<RouteNode> routeNodes,
  ) sync* {
    final widgetBuilder = _resolveWidgetBuilder(context);
    final localKeyFactory = _resolveLocalKeyFactory(context);

    for (final routeNode in routeNodes) {
      final key = localKeyFactory.createKey(routeNode);
      final isPageLess = !routeNode.isPageBased;
      final wrappedPage = routeNode.pageFactory;
      if (isPageLess && wrappedPage != null) {
        yield RoutePageEntry(page: wrappedPage, routeNode: routeNode);
        continue;
      }

      final declaration = _routeDeclarationResolver.resolve(routeNode);
      if (declaration != null) {
        yield RoutePageEntry(
          page: _buildDeclarationBasedPage(
            context: context,
            declaration: declaration,
            routeNode: routeNode,
            key: key,
            widgetBuilder: widgetBuilder,
          ),
          routeNode: routeNode,
        );
      } else {
        yield RoutePageEntry(
          page: _buildNotFoundPage(context, key, routeNode, widgetBuilder),
          routeNode: routeNode,
        );
      }
    }
  }

  @override
  Widget buildWidget(BuildContext context, RouteNode routeNode) {
    final widgetBuilder = _resolveWidgetBuilder(context);
    final declaration = _routeDeclarationResolver.resolve(routeNode);
    if (declaration != null) {
      return widgetBuilder.toWidget(
        context,
        routeNode,
        declaration,
      );
    }
    return widgetBuilder.toNotFoundWidget(context, routeNode);
  }

  @override
  Widget emptyWidgetBuilder(
    BuildContext context,
    RouteNode routeNode,
  ) {
    final widgetBuilder = _resolveWidgetBuilder(context);
    return widgetBuilder.toEmptyWidget(context, routeNode);
  }

  Page<Object?> _buildDeclarationBasedPage({
    required RouteDeclaration declaration,
    required BuildContext context,
    required RouteNode routeNode,
    required LocalKey key,
    required RouteNodeWidgetBuilder widgetBuilder,
  }) {
    final routeBuilder = declaration.routeBuilder;
    final pageFactory = routeBuilder.pageFactory ??
        NavigationDefaults.resolveNavigationDefaults(context).pageFactory;

    final child = widgetBuilder.toWidget(
      context,
      routeNode,
      declaration,
    );
    return pageFactory(context, routeNode, key, child);
  }

  Page<Object?> _buildNotFoundPage(
    BuildContext context,
    LocalKey key,
    RouteNode routeNode,
    RouteNodeWidgetBuilder widgetBuilder,
  ) {
    final navigationDefaults =
        NavigationDefaults.resolveNavigationDefaults(context);
    return navigationDefaults.pageFactory(
      context,
      routeNode,
      key,
      widgetBuilder.toNotFoundWidget(context, routeNode),
    );
  }

  /// Resolves the local key factory for the given context.
  ///
  /// If the local key factory is not provided, the default local key factory
  /// is returned.
  ///
  /// @return The resolved local key factory.
  LocalKeyFactory _resolveLocalKeyFactory(BuildContext context) {
    final LocalKeyFactory localKeyFactory;

    final current = _localKeyFactory;
    if (current == null) {
      final navigationDefaults =
          NavigationDefaults.resolveNavigationDefaults(context);
      localKeyFactory = navigationDefaults.localKeyFactory;
    } else {
      localKeyFactory = current;
    }
    return localKeyFactory;
  }

  /// Resolves the widget builder for the given context.
  ///
  /// If the widget builder is not provided, the default widget builder
  /// is returned.
  ///
  /// @return The resolved widget builder.
  RouteNodeWidgetBuilder _resolveWidgetBuilder(BuildContext context) {
    final RouteNodeWidgetBuilder widgetBuilder;

    final current = _widgetRouteNodeBuilder;
    if (current == null) {
      final navigationDefaults =
          NavigationDefaults.resolveNavigationDefaults(context);
      widgetBuilder = navigationDefaults.widgetBuilder;
    } else {
      widgetBuilder = current;
    }
    return widgetBuilder;
  }
}
