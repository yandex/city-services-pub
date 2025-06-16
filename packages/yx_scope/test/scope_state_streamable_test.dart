import 'package:test/test.dart';
import 'package:yx_scope/src/base_scope_container.dart';
import 'package:yx_scope/yx_scope.dart';

import 'utils/test_logger.dart';

void main() {
  setUp(() {
    ScopeObservatory.logger = const TestLogger();
  });

  group('stream of scope', () {
    test('stream for scope happy path', () async {
      final holder = _TestScopeHolder();

      int counter = 0;
      holder.stream.listen((scope) {
        if (counter % 2 == 0) {
          expect(scope, isNotNull);
        } else {
          expect(scope, isNull);
        }
      });

      await holder.create();
      counter++;
      await holder.drop();
      counter++;
      await holder.create();
      counter++;
      await holder.drop();
      counter++;
    });

    test('after pausing stream of scope it emits buffered events', () async {
      final holder = _TestScopeHolder();

      int counter = 0;
      final subscription = holder.stream.listen((scope) {
        if (counter % 2 == 0) {
          expect(scope, isNotNull);
        } else {
          expect(scope, isNull);
        }
        counter++;
      });

      await holder.create();
      await holder.drop();

      subscription.pause();

      await holder.create();
      await holder.drop();
      await holder.create();

      subscription.resume();

      await holder.drop();
      await holder.create();
      await holder.drop();

      expect(counter, 7);
    });

    test('reusing the same instance of stream cause an exception', () async {
      final holder = _TestScopeHolder();
      final stream = holder.stream;

      stream.listen((_) {});
      try {
        stream.listen((_) {});
        fail('Must throw an exception');
      } on StateError catch (e) {
        expect(e.message, 'Stream has already been listened to.');
      }
    });

    test('two different get calls return different streams', () async {
      final holder = _TestScopeHolder();
      final stream1 = holder.stream;
      final stream2 = holder.stream;
      expect(stream1, isNot(stream2));
    });

    test('ask for a stream creates new listener and cancelling removes it',
        () async {
      final holder = _TestScopeHolder();
      final testHolder = TestableScopeStateHolder(holder);
      final stream1 = holder.stream;
      expect(testHolder.listeners.isEmpty, isTrue);
      final sub1 = stream1.listen((_) {});
      expect(testHolder.listeners.length, 1);
      final stream2 = holder.stream;
      expect(testHolder.listeners.length, 1);
      final sub2 = stream2.listen((_) {});
      expect(testHolder.listeners.length, 2);
      await sub1.cancel();
      expect(testHolder.listeners.length, 1);
      await sub2.cancel();
      expect(testHolder.listeners.isEmpty, isTrue);
    });
  });

  group('stream of state', () {
    test('stream for scope happy path', () async {
      final holder = _TestScopeHolder();

      int counter = 0;
      holder.stateStream.listen((state) {
        switch (counter % 4) {
          case 0:
            expect(state, isA<ScopeStateInitializing<_TestScopeContainer>>());
            break;
          case 1:
            expect(state, isA<ScopeStateAvailable<_TestScopeContainer>>());
            expect((state as ScopeStateAvailable).scope,
                isA<_TestScopeContainer>());
            break;
          case 2:
            expect(state, isA<ScopeStateDisposing<_TestScopeContainer>>());
            break;
          case 3:
            expect(state, isA<ScopeStateNone<_TestScopeContainer>>());
            break;
          default:
        }
        counter++;
      });

      await holder.create();
      await holder.drop();
      await holder.create();
      await holder.drop();
      await holder.create();
      await holder.drop();
    });

    test('after pausing stream of scope it emits buffered events', () async {
      final holder = _TestScopeHolder();

      int counter = 0;
      final subscription = holder.stateStream.listen((state) {
        print(counter);
        print(state);
        switch (counter % 4) {
          case 0:
            expect(state, isA<ScopeStateInitializing<_TestScopeContainer>>());
            break;
          case 1:
            expect(state, isA<ScopeStateAvailable<_TestScopeContainer>>());
            expect((state as ScopeStateAvailable).scope,
                isA<_TestScopeContainer>());
            break;
          case 2:
            expect(state, isA<ScopeStateDisposing<_TestScopeContainer>>());
            break;
          case 3:
            expect(state, isA<ScopeStateNone<_TestScopeContainer>>());
            break;
          default:
        }
        counter++;
      });

      await holder.create();
      await holder.drop();

      subscription.pause();

      await holder.create();
      await holder.drop();
      await holder.create();

      subscription.resume();

      await holder.drop();
      await holder.create();
      await holder.drop();

      expect(counter, 8);
    });

    test('reusing the same instance of stream cause an exception', () async {
      final holder = _TestScopeHolder();
      final stream = holder.stateStream;

      stream.listen((_) {});
      try {
        stream.listen((_) {});
        fail('Must throw an exception');
      } on StateError catch (e) {
        expect(e.message, 'Stream has already been listened to.');
      }
    });

    test('two different get calls return different streams', () async {
      final holder = _TestScopeHolder();
      final stream1 = holder.stateStream;
      final stream2 = holder.stateStream;
      expect(stream1, isNot(stream2));
    });

    test('ask for a stream creates new listener and cancelling removes it',
        () async {
      final holder = _TestScopeHolder();
      final testHolder = TestableScopeStateHolder(holder);
      final stream1 = holder.stateStream;
      expect(testHolder.listeners.isEmpty, isTrue);
      final sub1 = stream1.listen((_) {});
      expect(testHolder.listeners.length, 1);
      final stream2 = holder.stateStream;
      expect(testHolder.listeners.length, 1);
      final sub2 = stream2.listen((_) {});
      expect(testHolder.listeners.length, 2);
      await sub1.cancel();
      expect(testHolder.listeners.length, 1);
      await sub2.cancel();
      expect(testHolder.listeners.isEmpty, isTrue);
    });
  });
}

class _TestScopeContainer extends ScopeContainer {}

class _TestScopeHolder extends ScopeHolder<_TestScopeContainer> {
  @override
  _TestScopeContainer createContainer() => _TestScopeContainer();
}
