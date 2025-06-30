part of 'raw_observers.dart';

@Deprecated('Use RawScopeObserver instead')
abstract class RawScopeListener extends RawScopeObserver {
  static set override(RawScopeObserver? override) =>
      RawScopeObserver.override = override;

  static RawScopeObserver? get override => RawScopeObserver.override;

  RawScopeListener._() : super._();
}

@Deprecated('Use RawDepObserver instead')
abstract class RawDepListener extends RawDepObserver {
  static set override(RawDepObserver? override) =>
      RawDepObserver.override = override;

  static RawDepObserver? get override => RawDepObserver.override;
}

@Deprecated('Use RawAsyncDepObserver instead')
abstract class RawAsyncDepListener extends RawAsyncDepObserver
    implements RawDepListener {
  static set override(RawAsyncDepObserver? override) =>
      RawAsyncDepObserver.override = override;

  static RawAsyncDepObserver? get override => RawAsyncDepObserver.override;
}
