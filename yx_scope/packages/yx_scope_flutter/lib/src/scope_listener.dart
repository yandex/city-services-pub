import 'package:flutter/widgets.dart';
import 'package:yx_scope/yx_scope.dart';

import 'scope_provider.dart';
import 'scope_widget_listener.dart';

/// Takes a [ScopeListener] and an optional [holder] and invokes
/// the [listener] in response to `scope` changes in the [holder].
/// It should be used for functionality that needs to occur only in response to
/// a `scope` change such as navigation, showing a `SnackBar`, showing
/// a `Dialog`, etc...
///
/// If the [holder] is omited,[ScopeListener] will automatically
/// perform a lookup using [ScopeProvider] and the current [BuildContext].
/// ```dart
/// ScopeListener<SomeScopeContainer>(
///   listener: (context, scope) {
///     // do stuff here based on the scope
///   },
///   cild: Container(),
/// )
/// ```
///
/// Only specify the [holder] if you wish to provide a [holder] that is otherwise
/// not accessible via [ScopeProvider] and the current [BuildContext].
///
/// ```dart
/// ScopeListener<SomeScopeContainer>(
///   holder: holder,
///   listener: (context, scope) {
///     // do stuff here based on the scope
///   },
///   child: Container(),
/// )
/// ```
class ScopeListener<T> extends StatefulWidget {
  final ScopeWidgetListener<T> listener;
  final ScopeStateHolder<T?>? holder;
  final Widget child;

  const ScopeListener({
    required this.listener,
    required this.child,
    this.holder,
    super.key,
  });

  @override
  State<ScopeListener<T>> createState() => ScopeListenerState<T>();
}

class ScopeListenerState<T> extends State<ScopeListener<T>> {
  ScopeStateHolder<T?>? _holder;
  RemoveStateListener? _removeStateListener;

  ScopeStateHolder<T?> get _actualHolder =>
      widget.holder ?? ScopeProvider.scopeHolderOf<T>(context);

  @override
  void dispose() {
    _unsubscribe();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _handleHolderChanged();
  }

  @override
  void didUpdateWidget(covariant ScopeListener<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    _handleHolderChanged();
  }

  void _handleHolderChanged() {
    final previous = _holder;
    final current = _actualHolder;

    if (previous == current) {
      return;
    }

    _holder = current;
    _unsubscribe();
    _subscribe(current);
  }

  void _subscribe(ScopeStateHolder<T?> holder) {
    if (mounted) {
      _removeStateListener = holder.listen((scope) {
        if (mounted) {
          widget.listener(context, scope);
        }
      });
    }
  }

  void _unsubscribe() {
    _removeStateListener?.call();
    _removeStateListener = null;
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
