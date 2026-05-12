/// Flutter integration for YX Navigation: route declarations, widgets,
/// router delegates, and compatibility helpers for Navigator 1.0 APIs.
///
/// Route-tree types and state management live in the core `yx_navigation`
/// package; add `package:yx_navigation/yx_navigation.dart` when you need those
/// symbols explicitly.
library yx_navigation_flutter;

export 'package:yx_navigation/yx_navigation.dart'
    show
        DeeplinkHandler,
        DeeplinkHandlerResult,
        DeeplinkHandlerNavigateResult,
        DeeplinkHandlerHandledResult,
        DeeplinkHandlerStrategy,
        FifoDeeplinkHandlerStrategy,
        LifoDeeplinkHandlerStrategy,
        CompositeDeeplinkHandler;

export 'src/base/back_button_handler.dart';
export 'src/base/builder/route_builder.dart';
export 'src/base/builder/route_indexed_stack_builder.dart';
export 'src/base/builder/route_outlet_builder.dart';
export 'src/base/builder/route_widget_builder.dart';
export 'src/base/declaration/route_declaration.dart';
export 'src/base/declaration/route_indexed_stack_declaration.dart';
export 'src/base/declaration/route_builder_declaration.dart';
export 'src/base/declaration/route_schema_declaration.dart';
export 'src/base/declaration/route_strict_declaration.dart';
export 'src/base/route_declaration_resolver.dart';
export 'src/base/route_node_builder.dart';
export 'src/base/route_node_widget_builder.dart';
export 'src/config/navigation_config_provider.dart';
export 'src/config/navigation_debug_configuration.dart';
export 'src/config/navigation_defaults.dart';
export 'src/config/navigator_configuration.dart';
export 'src/config/router_configuration.dart';
export 'src/config/state_manager_configuration.dart';
export 'src/debug_tools/debug_panel_display_type.dart';
export 'src/debug_tools/domain/debug_observer_readable.dart';
export 'src/debug_tools/domain/debug_panel_mode_notifier.dart';
export 'src/late_initialization/late_init_route_declaration_resolver.dart';
export 'src/page_factory/page_factory.dart';
export 'src/page_factory/pages_factory.dart';
export 'src/router/active_route_controller_provider.dart';
export 'src/router/deeplink/deeplink_handler_observer.dart';
export 'src/router/deeplink/late_init_deeplink_handler.dart';
export 'src/router/route_node_provider.dart';
export 'src/router/yx_navigation.dart';
export 'src/router/yx_route_information_parser.dart';
export 'src/router/yx_route_information_provider.dart';
export 'src/router/yx_router_config.dart';
export 'src/router/yx_router_delegate.dart';
export 'src/router/router_schema.dart';
export 'src/widgets/navigator_outlet.dart' show NavigatorBuilder;
export 'src/widgets/navigator_overrides.dart';
