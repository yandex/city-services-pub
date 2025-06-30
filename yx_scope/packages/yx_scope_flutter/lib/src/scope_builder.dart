import 'package:flutter/widgets.dart';
import 'package:yx_scope/yx_scope.dart' hide ScopeListener;

import '../yx_scope_flutter.dart';

/// [ScopeBuilder] handles building a widget in response to `scope`.
///
/// If you just want to listen a scope, please refer to [ScopeListener]
///
/// If the [holder] is omited,[ScopeBuilder] will automatically
/// perform a lookup using [ScopeProvider] and the current [BuildContext].
///
/// ```dart
/// ScopeBuilder<SomeScopeContainer>(
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
/// ScopeBuilder<SomeScopeContainer>(
///   holder: holder,
///   builder: (context, scope) {
///     // return widget here based on the scope
///   }
/// )
/// ```
class ScopeBuilder<T> extends StatefulWidget {
  final ScopeStateHolder<T?>? holder;
  final ScopeWidgetBuilder<T> builder;

  const ScopeBuilder({
    required this.builder,
    this.holder,
    super.key,
  });

  /// This is a factory that provides a non-null scope
  /// in the builder and uses a [placeholder] if the scope is null.
  factory ScopeBuilder.withPlaceholder({
    required NonNullableScopeWidgetBuilder<T> builder,
    Widget placeholder = const SizedBox.shrink(),
    ScopeStateHolder<T?>? holder,
  }) =>
      ScopeBuilder<T>(
        holder: holder,
        builder: (context, scope) {
          if (scope == null) {
            return placeholder;
          }
          return builder(context, scope);
        },
      );

  @override
  State<ScopeBuilder> createState() => _ScopeBuilderState<T>();
}

class _ScopeBuilderState<T> extends State<ScopeBuilder<T>> {
  late ScopeStateHolder<T?> _holder;
  T? _scope;

  @override
  void initState() {
    super.initState();
    _holder = widget.holder ??
        ScopeProvider.scopeHolderOf(
          context,
          listen: false,
        );
    _scope = _holder.scope;
  }

  @override
  void didUpdateWidget(covariant ScopeBuilder<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    final contextHolder =
        ScopeProvider.scopeHolderOf<T>(context, listen: false);
    final currentHolder = widget.holder ?? contextHolder;
    if (_holder != currentHolder) {
      _holder = currentHolder;
      _scope = _holder.scope;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final holder = widget.holder ?? ScopeProvider.scopeHolderOf(context);
    if (holder != _holder) {
      _holder = holder;
      _scope = _holder.scope;
    }
  }

  @override
  Widget build(BuildContext context) => ScopeListener<T>(
        holder: _holder,
        listener: (context, scope) => setState(() {
          _scope = scope;
        }),
        child: widget.builder(context, _scope),
      );
}
