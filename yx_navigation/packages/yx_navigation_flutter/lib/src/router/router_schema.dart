import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';
import 'package:yx_navigation/yx_navigation.dart';

import '../base/declaration/route_declaration.dart';
import '../base/route_declaration_resolver.dart';
import '../base/route_node_builder.dart';
import '../config/navigation_debug_configuration.dart';
import '../config/navigator_configuration.dart';
import '../config/router_configuration.dart';
import '../config/state_manager_configuration.dart';
import '../debug_tools/domain/debug_observer_readable.dart';
import 'yx_route_information_parser.dart';
import 'yx_route_information_provider.dart';
import 'yx_router_config.dart';
import 'yx_router_delegate.dart';

/// {@template router_schema}
/// Describes the routing schema of a feature or an entire application.
///
/// A schema collects [RouteDeclaration]s, schema-level guards, deeplink
/// handlers, and the builder used to compose the initial [RouteNode] tree.
/// Call [build] to obtain a [YxRouterConfig] that can be passed to
/// `MaterialApp.router` or `WidgetsApp.router`.
///
/// Schemas compose: a [RouteSchemaDeclaration] embeds a nested schema as
/// an isolated subtree, allowing features to be developed as reusable
/// modules.
/// {@endtemplate}
abstract class RouterSchema {
  /// Nested child declarations.
  @internal
  abstract final Iterable<RouteDeclaration> declarations;

  /// Guards that run for the schema.
  @internal
  Iterable<RouteNodeGuard> get guards => const [];

  /// Deeplink handlers for the schema.
  @experimental
  @internal
  Iterable<DeeplinkHandler> get deeplinkHandlers => const [];

  /// Strategy for iterating through deeplink handlers.
  @experimental
  @internal
  DeeplinkHandlerStrategy get deeplinkStrategy =>
      const DeeplinkHandlerStrategy.fifo();

  /// Builds the initial [RouteNode] for the schema.
  @internal
  RouteNode initialNodeBuilder(MutableRouteNode node);

  /// Builds a [YxRouterConfig] from this schema.
  ///
  /// Each configuration parameter is optional and falls back to the default
  /// implementation when omitted. The returned config owns the created
  /// [YxRouterDelegate] and must be disposed by the owning [State].
  @nonVirtual
  YxRouterConfig build({
    StateManagerConfiguration? stateManagerConfiguration,
    NavigationDebugConfiguration? debugConfiguration,
    NavigatorConfiguration? navigatorConfiguration,
    RouterConfiguration? routerConfiguration,
    RouteNodeBuilder? nodeBuilder,
    RouteDeclarationResolver? declarationResolver,
  }) {
    const defaultRootRoute = YxRoute(id: 'root');

    assert(
      nodeBuilder == null || declarationResolver == null,
      'Node Builder uses Declaration Resolver. '
      'It\'s why they can\'t be not null both.',
    );

    DebugObserverReadableImpl? debugObserver;
    assert(() {
      debugObserver = DebugObserverReadableImpl();
      return true;
    }(), '');

    final schemaStateManager = stateManagerConfiguration?.stateManager ??
        RouteNodeStateManager(
          routeNode: initialNodeBuilder(defaultRootRoute.toMutableNode()),
          observer: stateManagerConfiguration?.stateManagerObserver ??
              StateManagerDiffObserver(
                sourceObserver: debugObserver,
                routeObservers: _flattenDeclarations(declarations: declarations)
                    .map((declaration) => declaration.observer)
                    .nonNulls
                    .toList(),
              ),
          routeNodeGuard: GuardConfiguration(
            guards: buildGuards(),
            observer: stateManagerConfiguration?.guardObserver ?? debugObserver,
          ),
        );

    // Router configuration
    final informationParser = routerConfiguration?.informationParser;
    final informationProvider = routerConfiguration?.informationProvider;
    final serialization = routerConfiguration?.serialization ??
        const PrettyUriStateSerialization();
    final backButtonDispatcher = routerConfiguration?.backButtonDispatcher;

    final composedHandler = buildSubtreeDeeplinkHandler();

    final routeInformationParser = informationParser ??
        YxRouteInformationParser(
          stateManager: schemaStateManager,
          serialization: serialization,
          fallbackBuilder: const RouteInformationParserFallbackBuilderImpl(),
          deeplinkHandler: composedHandler,
          deeplinkHandlerObserver:
              routerConfiguration?.deeplinkObserver ?? debugObserver,
        );
    final routeInformationProvider = informationProvider ??
        YxRouteInformationProvider(
          serialization: serialization,
        );

    // Route declaration resolver & node builder
    final routeDeclarationResolver = declarationResolver ??
        RouteDeclarationResolver(
          declarations: declarations,
        );
    final routeNodeBuilder = nodeBuilder ??
        BaseRouteNodeBuilder(
          routeDeclarationResolver: routeDeclarationResolver,
        );

    // Navigator configuration
    final navigatorKey = navigatorConfiguration?.navigatorKey;
    final navigatorObservers =
        navigatorConfiguration?.navigatorObservers ?? const [];
    final navigatorBuilder = navigatorConfiguration?.navigatorBuilder;
    final transitionDelegate = navigatorConfiguration?.transitionDelegate;

    // Router delegate
    final routerDelegate = YxRouterDelegate(
      stateManager: schemaStateManager,
      debugPanelModeNotifier: debugConfiguration?.debugPanelModeNotifier,
      defaultDisplayType: debugConfiguration?.defaultDisplayType,
      observerReadable: debugConfiguration?.observerReadable ?? debugObserver,
      builder: navigatorBuilder,
      observers: navigatorObservers.toList(),
      transitionDelegate: transitionDelegate,
      navigatorKey: navigatorKey,
      routeNodeBuilder: routeNodeBuilder,
      routeDeclarationResolver: routeDeclarationResolver,
    );

    return YxRouterConfig(
      routerDelegate: routerDelegate,
      routeInformationParser: routeInformationParser,
      routeInformationProvider: routeInformationProvider,
      backButtonDispatcher: backButtonDispatcher ?? RootBackButtonDispatcher(),
    );
  }

  Iterable<RouteNodeGuard> buildGuards() => [
        ...guards,
        ..._buildGuards(
          declarations: declarations,
        ),
      ];

  Iterable<RouteNodeGuard> _buildGuards({
    required Iterable<RouteDeclaration> declarations,
  }) sync* {
    for (final declaration in declarations) {
      yield* declaration.guards;
      yield* _buildGuards(declarations: declaration.declarations);
    }
  }

  /// Builds the fully composed deeplink handler for this schema's subtree.
  ///
  /// Combines [deeplinkHandlers] from this schema with handlers collected
  /// from nested [RouteSchemaDeclaration]s. The [deeplinkStrategy] controls
  /// the composition order.
  @experimental
  DeeplinkHandler? buildSubtreeDeeplinkHandler() {
    return _buildDeeplinkHandler(
      deeplinkHandlers: deeplinkHandlers,
      deeplinkStrategy: deeplinkStrategy,
      declarations: declarations,
    );
  }

  DeeplinkHandler? _buildDeeplinkHandler({
    required Iterable<DeeplinkHandler> deeplinkHandlers,
    required DeeplinkHandlerStrategy deeplinkStrategy,
    required Iterable<RouteDeclaration> declarations,
  }) {
    final nestedHandlers = declarations
        .map(
          (declaration) => _buildDeeplinkHandler(
            deeplinkHandlers: declaration.deeplinkHandlers,
            deeplinkStrategy: declaration.deeplinkStrategy,
            declarations: declaration.declarations,
          ),
        )
        .nonNulls;

    final allHandlers = [...deeplinkHandlers, ...nestedHandlers];

    if (allHandlers.isEmpty) return null;
    if (allHandlers.length == 1) return allHandlers.first;

    return CompositeDeeplinkHandler(
      strategy: deeplinkStrategy,
      handlers: allHandlers,
    );
  }

  Iterable<RouteDeclaration> _flattenDeclarations({
    required Iterable<RouteDeclaration> declarations,
  }) sync* {
    for (final declaration in declarations) {
      yield declaration;
      yield* _flattenDeclarations(declarations: declaration.declarations);
    }
  }
}
