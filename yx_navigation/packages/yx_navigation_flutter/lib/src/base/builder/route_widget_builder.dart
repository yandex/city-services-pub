import 'package:meta/meta.dart';

import '../../page_factory/page_factory.dart';
import 'route_builder.dart';

/// {@template route_widget_builder}
/// A [RouteBuilder] that renders a plain widget for a route.
///
/// Attached to a route declaration, it builds the UI shown whenever the
/// associated route becomes visible.
/// {@endtemplate}
@immutable
class RouteWidgetBuilder<T> implements RouteBuilder<T> {
  @override
  final PageFactory<T>? pageFactory;

  @override
  final RouteNodeContentBuilder builder;

  /// {@macro route_widget_builder}
  const RouteWidgetBuilder({required this.builder, this.pageFactory});
}
