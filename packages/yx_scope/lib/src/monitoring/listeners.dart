part of 'observers.dart';

@Deprecated('Use ScopeObserver instead')
abstract class ScopeListener implements ScopeObserver {}

@Deprecated('Use DepObserver instead')
abstract class DepListener implements DepObserver {}

@Deprecated('Use AsyncDepObserver instead')
abstract class AsyncDepListener extends DepListener
    implements AsyncDepObserver {}