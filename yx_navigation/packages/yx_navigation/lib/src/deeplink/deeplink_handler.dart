import 'package:meta/meta.dart';

import '../base/route_node.dart';

import 'deeplink_handler_result.dart';

/// {@template deeplink_handler}
/// Interface for deeplink handling.
/// {@endtemplate}
@experimental
abstract interface class DeeplinkHandler {
  /// {@template deeplink_handler_handle}
  /// Handles the [uri].
  ///
  /// Returns [DeeplinkHandlerResult] if the handler can handle the URI,
  /// otherwise returns `null`.
  /// {@endtemplate}
  DeeplinkHandlerResult? handle(
    Uri uri,
    RouteNode currentState,
  );
}
