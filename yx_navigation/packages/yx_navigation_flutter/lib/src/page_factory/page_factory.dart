import 'package:flutter/material.dart';
import 'package:yx_navigation/yx_navigation.dart';

/// {@template page_factory}
/// Builds a [Page] for a given [RouteNode].
///
/// A [PageFactory] is responsible for translating a [RouteNode] and its
/// rendered [child] widget into a Navigator 2.0 [Page]. The returned page is
/// then supplied to the [Navigator] by the router.
///
/// Use one of the factories exposed by [PagesFactory] for the common cases
/// (Material, Cupertino, dialog, bottom sheet, etc.), or implement this
/// interface directly for fully custom behaviour.
/// {@endtemplate}
abstract interface class PageFactory<T> {
  /// Produces a [Page] for [routeNode] rendered as [child].
  ///
  /// [key] is the [LocalKey] that uniquely identifies the resulting page
  /// within the current navigator stack.
  Page<T> call(
    BuildContext context,
    RouteNode routeNode,
    LocalKey key,
    Widget child,
  );
}
