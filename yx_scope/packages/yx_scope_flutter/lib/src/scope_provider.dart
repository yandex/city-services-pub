import 'package:flutter/widgets.dart';
import 'package:yx_scope/yx_scope.dart';

import 'core/provider.dart';
import 'core/scope_error.dart';
import 'scope_builder.dart';

/// [ScopeProvider] is an [InheritedWidget] that passes your scope
/// down to any widget in the subtree.
///
/// If you provide some scope container, you can get a nullable scope or
/// ScopeStateHolder of this scope container.
///
/// ``` dart
/// final SomeScopeContainer? scope = ScopeProvider.of<SomeScopeContainer>(context);
/// final ScopeStateHolder<SomeScopeContainer?> holder = ScopeProvider.scopeHolderOf<SomeScopeContainer>(context);
/// ```
class ScopeProvider<T> extends StatelessWidget {
  final ScopeStateHolder<T?> holder;
  final Widget child;

  const ScopeProvider({
    required this.holder,
    required this.child,
    super.key,
  });

  /// This method provide a nullable cope, if there is a ScopeProvider widget higher up the tree
  ///
  /// If you want to use this method with the flag [listen] = true see more about the method
  /// [BuildContext.dependOnInheritedWidgetOfExactType] to learn when to use this method.
  ///
  /// And if you want to use this method with the flag [listen] = false see more about the method
  /// [BuildContext.getElementForInheritedWidgetOfExactType].
  static T? of<T>(BuildContext context, {bool listen = true}) {
    try {
      return Provider.of<T?>(context, listen: listen);
    } on NotFoundProviderException catch (_) {
      throw FlutterScopeError('''
        ScopeProvider.of() called with a context that does not contain a $T.
        No ancestor could be found starting from the context that was passed to ScopeProvider.of<$T>().

        This can happen if the context you used comes from a widget above the ScopeProvider.

        The context used was: $context
        ''');
    }
  }

  /// This method provide ScopeStateHolder<[T]>, if there is a ScopeProvider widget higher up the tree
  ///
  /// You can get ScopeStateHolder and use methods of it. But if you just want listen a scope, it's better
  /// use [ScopeProvider.of] method with flag [listen]=true.
  ///
  /// If you want to use this method with the flag [listen] = true see more about the method
  /// [BuildContext.dependOnInheritedWidgetOfExactType] to learn when to use this method.
  ///
  /// And if you want to use this method with the flag [listen] = false see more about the method
  /// [BuildContext.getElementForInheritedWidgetOfExactType].
  static ScopeStateHolder<T?> scopeHolderOf<T>(
    BuildContext context, {
    bool listen = true,
  }) {
    try {
      return Provider.of<ScopeStateHolder<T?>>(context, listen: listen);
    } on NotFoundProviderException catch (_) {
      throw FlutterScopeError('''
        ScopeProvider.scopeHolderOf() called with a context that does not contain a $T.
        No ancestor could be found starting from the context that was passed to ScopeProvider.scopeHolderOf<$T>().

        This can happen if the context you used comes from a widget above the ScopeProvider.

        The context used was: $context
        ''');
    }
  }

  @override
  Widget build(BuildContext context) => Provider<ScopeStateHolder<T?>>(
        data: holder,
        child: ScopeBuilder<T>(
          holder: holder,
          builder: (context, scope) => Provider<T?>(
            data: scope,
            child: child,
          ),
        ),
      );
}
