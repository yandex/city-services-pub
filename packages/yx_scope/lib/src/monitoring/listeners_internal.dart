part of '../base_scope_container.dart';

@Deprecated('Use ScopeObserverInternal instead')
class ScopeListenerInternal extends ScopeObserverInternal {
  ScopeListenerInternal(super.observers);
}

@Deprecated('Use DepObserverInternal instead')
class DepListenerInternal extends DepObserverInternal {
  DepListenerInternal(super.scope);
}

@Deprecated('Use AsyncDepObserverInternal instead')
class AsyncDepListenerInternal extends DepObserverInternal
    implements DepListenerInternal {
  AsyncDepListenerInternal(super.scope);
}
