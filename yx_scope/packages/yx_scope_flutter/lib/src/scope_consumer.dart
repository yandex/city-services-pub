import 'package:flutter/widgets.dart';
import 'package:yx_scope/yx_scope.dart' hide ScopeListener;

import '../yx_scope_flutter.dart';
import 'scope_widget_listener.dart';

/// [ScopeConsumer] exposes a [builder] and [listener] in order react to new
/// scope.
/// [ScopeConsumer] is analogous to a nested [ScopeListener]
/// and [ScopeBuilder] but reduces the amount of boilerplate needed.
/// [ScopeConsumer] should only be used when it is necessary to both rebuild UI
/// and execute other reactions to scope changes in the [holder].
///
/// If the [holder] parameter is omitted, [ScopeConsumer] will automatically
/// perform a lookup using `ScopeProvider` and the current `BuildContext`.
///
/// ```dart
/// ScopeConsumer<SomeScopeContainer>(
///   listener: (context, scope) {
///     // do stuff here based on the scope
///   },
///   builder: (context, scope) {
///     // return widget here based on the scope
///   }
/// )
/// ```
///
/// Only specify the [holder] if you wish to provide a [holder] that is otherwise
/// not accessible via [ScopeProvider] and the current [BuildContext].
///
/// ```dart
/// ScopeConsumer<SomeScopeContainer>(
///   holder: holder,
///   listener: (context, scope) {
///     // do stuff here based on the scope
///   },
///   builder: (context, scope) {
///     // return widget here based on the scope
///   }
/// )
/// ```
class ScopeConsumer<T> extends StatefulWidget {
  final ScopeWidgetBuilder<T> builder;
  final ScopeWidgetListener<T> listener;
  final ScopeStateHolder<T?>? holder;

  const ScopeConsumer({
    required this.builder,
    required this.listener,
    this.holder,
    super.key,
  });

  /// This is a factory that provides a non-null scope
  /// in the builder and uses a [placeholder] if the scope is null.
  factory ScopeConsumer.withPlaceholder({
    required NonNullableScopeWidgetBuilder<T> builder,
    required ScopeWidgetListener<T> listener,
    required Widget placeholder,
    ScopeStateHolder<T?>? holder,
  }) =>
      ScopeConsumer(
        builder: (context, scope) {
          if (scope == null) {
            return placeholder;
          }
          return builder(context, scope);
        },
        listener: listener,
        holder: holder,
      );

  @override
  State<ScopeConsumer<T>> createState() => _ScopeConsumerState<T>();
}

class _ScopeConsumerState<T> extends State<ScopeConsumer<T>> {
  late ScopeStateHolder<T?> _holder;

  @override
  void initState() {
    super.initState();
    _holder = widget.holder ??
        ScopeProvider.scopeHolderOf(
          context,
          listen: false,
        );
  }

  @override
  void didUpdateWidget(covariant ScopeConsumer<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldHolder =
        oldWidget.holder ?? ScopeProvider.scopeHolderOf(context, listen: false);
    final currentHolder = widget.holder ?? oldHolder;
    if (oldHolder != currentHolder) {
      _holder = currentHolder;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final holder = widget.holder ?? ScopeProvider.scopeHolderOf(context);
    if (holder != _holder) {
      _holder = holder;
    }
  }

  @override
  Widget build(BuildContext context) => ScopeListener(
        holder: _holder,
        listener: widget.listener,
        child: ScopeBuilder(
          holder: _holder,
          builder: widget.builder,
        ),
      );
}
