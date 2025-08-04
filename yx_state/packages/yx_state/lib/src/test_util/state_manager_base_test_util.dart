part of '../base/state_manager_base.dart';

/// {@template state_manager_base_test_util}
/// A utility class for testing [StateManagerBase] instances.
///
/// This class provides a method to set the state of the state manager without
/// going through the normal handler flow.
///
/// {@tool snippet}
/// ```dart
/// import 'package:test/test.dart';
/// import 'package:yx_state/yx_state.dart';
///
/// class TestStateManager extends StateManager<int> {
///   TestStateManager() : super(0);
/// }
///
/// void main() {
///   late TestStateManager stateManager;
///   late StateManagerBaseTestUtil<int> testUtil;
///
///   setUp(() {
///     stateManager = TestStateManager();
///     testUtil = StateManagerBaseTestUtil<int>(stateManager);
///   });
///
///   tearDown(() => stateManager.close());
///
///   test('util usage example', () {
///     // arrange
///     const expectedState = 1;
///
///     // act
///     testUtil.emit(expectedState);
///
///     // assert
///     expect(stateManager.state, expectedState);
///   });
/// }
/// ```
/// {@end-tool}
/// {@endtemplate}
@visibleForTesting
class StateManagerBaseTestUtil<State extends Object?> {
  final StateManagerBase<State> _stateManager;

  /// The identifier for the test util.
  String get identifier => _identifier;

  /// {@macro state_manager_base_test_util}
  const StateManagerBaseTestUtil(this._stateManager);

  /// Base constant identifier for the test util.
  static const String _identifier = 'test_util';

  /// Sets the state to the provided value without going through the normal
  /// handler flow.
  ///
  /// This method is primarily intended for testing purposes. It is not
  /// recommended to use this method in production code.
  @visibleForTesting
  void emit(State state) => _stateManager._emit(state, identifier);
}
