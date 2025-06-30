import 'package:flutter/widgets.dart';

typedef ScopeWidgetBuilder<T> = Widget Function(BuildContext context, T? scope);

typedef NonNullableScopeWidgetBuilder<T> = Widget Function(
  BuildContext context,
  T scope,
);
