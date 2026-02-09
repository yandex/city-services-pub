import 'base_scope_container.dart';
import 'core/scope_exception.dart';

/// Describes the behavior of the scope holder. Typically, it handles cases
/// considered as exceptions in yx_scope.
///
/// It is not recommended to override it everywhere. It is intended only for
/// edge cases where these exceptions cannot be avoided by proper use of
/// scopes.
abstract class ScopeHolderBehavior<Scope,
    Container extends BaseScopeContainer> {
  void onDepDeclarationContainerMismatch({
    required AsyncDep dep,
    required BaseScopeContainer depContainer,
    required Container holderContainer,
  });
}

class CoreScopeHolderBehavior<Scope, Container extends BaseScopeContainer>
    implements ScopeHolderBehavior<Scope, Container> {
  const CoreScopeHolderBehavior();

  @override
  void onDepDeclarationContainerMismatch({
    required AsyncDep dep,
    required BaseScopeContainer depContainer,
    required Container holderContainer,
  }) {
    throw ScopeException(
      'You are initializing async dep ${dep.runtimeType} '
      'within ${holderContainer.runtimeType}#${holderContainer.hashCode}, '
      'but the dep declared in ${depContainer.runtimeType}#${depContainer.hashCode}',
    );
  }
}
