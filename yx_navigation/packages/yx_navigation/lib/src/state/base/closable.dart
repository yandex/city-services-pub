import 'package:meta/meta.dart';

/// An object that must be closed when no longer in use.
@internal
abstract interface class Closable {
  /// Whether the object is closed.
  ///
  /// An object is considered closed once [close] is called.
  bool get isClosed;

  /// Closes the current instance.
  /// The returned future completes when the instance has been closed.
  Future<void> close();
}
