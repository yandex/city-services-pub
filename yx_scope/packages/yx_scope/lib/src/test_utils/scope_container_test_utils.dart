part of '../base_scope_container.dart';

class ScopeContainerTestUtils {
  /// Count of mounted providers. After dispose provider will be unmount.
  @visibleForTesting
  static int getDepCount(BaseScopeContainer container) =>
      container._container.length;
}
