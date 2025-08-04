import 'package:mocktail/mocktail.dart';
import 'package:yx_state/src/function_stream_handler/handle_task_emitter.dart';
import 'package:yx_state/yx_state.dart';

class MockEmitter<State extends Object?> extends Mock
    implements Emitter<State> {}

class MockHandleTaskEmitter<State extends Object?> extends Mock
    implements HandleTaskEmitter<State> {}

class MockStateManagerObserver extends Mock implements StateManagerObserver {}

class MockFunctionHandler<State extends Object?> extends Mock
    implements FunctionHandler<State> {}
