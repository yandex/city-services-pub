import 'package:yx_state/yx_state.dart';
import 'package:yx_state_transformers/yx_state_transformers.dart';

void main() async {
  /// Create a state manager with a concurrent handler.
  final counter = CounterStateManager(0);

  /// Subscribe to state changes and print each state.
  final subscription = counter.stream.listen(print);

  counter.increment();
  counter.incrementBy(8);
  counter.increment();

  // wait for 3 seconds
  await Future.delayed(const Duration(seconds: 3));

  /// Close the state manager.
  await counter.close();

  /// Unsubscribe from state changes.
  await subscription.cancel();
}

class CounterStateManager extends StateManager<int> {
  CounterStateManager(super.state) : super(handler: concurrent());

  void increment() => handle(
        (emit) async {
          await Future.delayed(const Duration(seconds: 2));
          emit(state + 1);
        },
      );

  void incrementBy(int value) => handle(
        (emit) async {
          await Future.delayed(const Duration(seconds: 1));
          emit(state + value);
        },
      );
}
