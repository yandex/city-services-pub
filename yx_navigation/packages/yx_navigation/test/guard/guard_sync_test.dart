import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import 'package:yx_navigation/src/guard/guard_sync.dart';

import '../helpers/async.dart';
import '../helpers/fallbacks.dart';
import '../helpers/mocks.dart';

void main() {
  setUpAll(registerFallbacks);

  group('GuardSyncReason', () {
    test('equals another reason with the same message', () {
      // arrange
      const actualFirst = GuardSyncReason(message: 'same');
      const actualSecond = GuardSyncReason(message: 'same');

      // assert
      expect(actualFirst, equals(actualSecond));
      expect(actualFirst.hashCode, equals(actualSecond.hashCode));
    });

    test('differs from a reason with a different message', () {
      // arrange
      const actualFirst = GuardSyncReason(message: 'a');
      const actualSecond = GuardSyncReason(message: 'b');

      // assert
      expect(actualFirst, isNot(equals(actualSecond)));
    });
  });

  group('GuardSync', () {
    testAsync('stream emits every sync reason', (fa) {
      // arrange
      final actualSync = GuardSync();
      const firstReason = GuardSyncReason(message: 'first');
      const secondReason = GuardSyncReason(message: 'second');
      final emitted = <GuardSyncReason>[];
      final sub = actualSync.stream.listen(emitted.add);
      addTearDown(sub.cancel);

      // act
      actualSync
        ..sync(firstReason)
        ..add(secondReason)
        ..close();
      fa.flushMicrotasks();

      // assert
      expect(
        emitted,
        equals(<GuardSyncReason>[firstReason, secondReason]),
      );
    });

    testAsync('observer.onGuardSync is notified for every reason', (fa) {
      // arrange
      final actualObserver = GuardObserverMock();
      final actualSync = GuardSync(observer: actualObserver);
      const actualReason = GuardSyncReason(message: 'sync');

      // act
      actualSync
        ..sync(actualReason)
        ..close();
      fa.flushMicrotasks();

      // assert
      verify(() => actualObserver.onGuardSync(actualReason)).called(1);
    });

    testAsync('close finishes the broadcast stream', (fa) {
      // arrange
      final actualSync = GuardSync();
      var actualDone = false;
      final sub = actualSync.stream.listen(
        null,
        onDone: () => actualDone = true,
      );
      addTearDown(sub.cancel);

      // act
      actualSync.close();
      fa.flushMicrotasks();

      // assert
      expect(actualDone, isTrue);
    });
  });
}
