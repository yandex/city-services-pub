/// A state management library for [Dart](https://dart.dev)/[Flutter](https://flutter.dev) applications.
library yx_state;

export 'src/base/interface.dart'
    hide StateManagerHandler, StateManagerListener, Closable;
export 'src/base/state_manager_base.dart';
export 'src/function_stream_handler/handle_task.dart';
export 'src/function_stream_handler/stream_function_handler.dart';
export 'src/state_manager.dart';
export 'src/state_manager_observer.dart';
export 'src/state_manager_overrides.dart';
