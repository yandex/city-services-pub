import 'package:meta/meta.dart';

import '../base/route_node.dart';

/// {@template deeplink_handler_result}
/// Result of processing a deeplink.
/// {@endtemplate}
@experimental
sealed class DeeplinkHandlerResult {
  /// {@macro deeplink_handler_result}
  const DeeplinkHandlerResult();

  /// Deeplink handled, navigation required.
  ///
  /// Use this when the deeplink corresponds to a specific screen or navigation state.
  /// The package will apply the provided [node] as the new navigation stack.
  const factory DeeplinkHandlerResult.navigate(RouteNode node) =
      DeeplinkHandlerNavigateResult;

  /// Deeplink handled, no navigation required (logic executed).
  ///
  /// Use this when the deeplink triggers a side effect (e.g., saving a token,
  /// toggling a feature, sending analytics) but the user should remain
  /// on the current screen.
  ///
  /// The package will ignore the deeplink URI and return the **current** state.
  /// The platform's URL (address bar) will be restored to match the current screen,
  /// effectively "swallowing" the deeplink.
  const factory DeeplinkHandlerResult.handled() = DeeplinkHandlerHandledResult;
}

/// {@template deeplink_handler_navigate_result}
/// Result indicating that navigation is required.
/// {@endtemplate}
final class DeeplinkHandlerNavigateResult extends DeeplinkHandlerResult {
  /// The node to navigate to.
  final RouteNode node;

  /// {@macro deeplink_handler_navigate_result}
  const DeeplinkHandlerNavigateResult(this.node);
}

/// {@template deeplink_handler_handled_result}
/// Result indicating that the deeplink was handled without navigation.
/// {@endtemplate}
final class DeeplinkHandlerHandledResult extends DeeplinkHandlerResult {
  /// {@macro deeplink_handler_handled_result}
  const DeeplinkHandlerHandledResult();
}
