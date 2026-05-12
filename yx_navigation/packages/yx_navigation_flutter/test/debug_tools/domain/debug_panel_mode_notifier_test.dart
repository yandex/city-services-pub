import 'package:flutter_test/flutter_test.dart';
import 'package:yx_navigation_flutter/src/debug_tools/domain/debug_panel_mode_notifier.dart';

import '../../helpers/fallbacks.dart';

void main() {
  setUpAll(registerFallbacks);

  group('DebugPanelModeNotifier', () {
    test('setEnableDebugPanel updates value and notifies listeners', () {
      // arrange
      final actualNotifier = DebugPanelModeNotifier(enableDebugPanel: false);
      addTearDown(actualNotifier.dispose);
      var notifyCount = 0;
      actualNotifier
        ..addListener(() => notifyCount++)
        // act
        ..setEnableDebugPanel(true);

      // assert
      expect(actualNotifier.enableDebugPanel, isTrue);
      expect(notifyCount, equals(1));
    });
  });
}
