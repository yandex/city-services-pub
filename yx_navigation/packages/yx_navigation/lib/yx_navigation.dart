/// Core building blocks for declarative navigation: immutable route trees,
/// state management, guards, observers, and URI serialization.
///
/// Flutter widgets and route declarations live in the companion package
/// `yx_navigation_flutter`.
library yx_navigation;

export 'src/base/active_route_controller.dart';
export 'src/base/comparators/route_node_comparator.dart';
export 'src/base/equality/route_node_equality.dart';
export 'src/base/route.dart';
export 'src/base/route_navigator.dart' hide BaseRouteNavigator;
export 'src/base/route_node.dart' hide BaseRouteNode, ImmutableRouteNode;
export 'src/base/route_node_resolver.dart';
export 'src/base/route_observer/route_node_diff_result.dart';
export 'src/base/route_observer/route_observer.dart';
export 'src/base/route_observer/state_manager_diff_observer.dart';
export 'src/deeplink/composite_deeplink_handler.dart';
export 'src/deeplink/deeplink_handler.dart';
export 'src/deeplink/deeplink_handler_result.dart';
export 'src/deeplink/deeplink_handler_strategy.dart';
export 'src/extensions/route_node_extensions.dart';
export 'src/guard/default/initialize_schema_node_guard.dart';
export 'src/guard/default/navigate_to_indexed_stack_node_guard.dart';
export 'src/guard/default/redirect_route_node_guard.dart';
export 'src/guard/default/strict_hierarchy_guard.dart';
export 'src/guard/guard_configuration.dart';
export 'src/guard/guard_context.dart' hide GuardContextImpl;
export 'src/guard/guard_observer.dart';
export 'src/guard/guard_result.dart';
export 'src/guard/guard_sync.dart';
export 'src/guard/route_node_guard.dart';
export 'src/late_initialization/late_init_guard_configuration.dart';
export 'src/serialization/platform_state_serialization.dart';
export 'src/serialization/serializers/squid_fragment_based_serializer.dart';
export 'src/serialization/serializers/squid_path_based_serializer.dart';
export 'src/state/base/base_state_manager.dart';
export 'src/state/base/mutation.dart';
export 'src/state/base/route_node_readable.dart';
export 'src/state/base/state_manager_observer.dart';
export 'src/state/state_manager.dart';
