import 'package:test/test.dart';
// internal type, not exported
import 'package:yx_navigation/src/guard/guard_context.dart';

import '../helpers/fallbacks.dart';

void main() {
  setUpAll(registerFallbacks);

  group('GuardContext', () {
    test('operator []= stores and operator [] retrieves the same value', () {
      final actualContext = GuardContextImpl()..['k'] = 'v';
      expect(actualContext['k'], equals('v'));
    });

    test('addAll merges map entries and overrides duplicate keys', () {
      final actualContext = GuardContextImpl()
        ..['a'] = 1
        ..addAll(<String, Object>{'a': 99, 'b': 2});
      expect(actualContext['a'], equals(99));
      expect(actualContext['b'], equals(2));
    });
  });
}
