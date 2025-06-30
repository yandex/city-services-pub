import 'dart:async';

import 'package:test/test.dart';

Future<void> expectThrown<T extends Object>(
  FutureOr<void> Function() callback,
) async {
  try {
    await callback();
    fail('There must be $T thrown');
    // ignore: avoid_catching_errors
  } on T catch (_) {}
}

Future<void> expectAssertion(
  FutureOr<void> Function() callback,
) async =>
    expectThrown<AssertionError>(callback);
