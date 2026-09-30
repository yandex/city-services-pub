---
schema_version: "1.1"
name: cmd-review
description: The review command finds the violations in a small package and reports them as a table with the catalog entry and a fix.
tags: [command, review]
runs: 3
max_turns: 30
timeout_seconds: 500
allowed_tools: [Read, Glob, Grep, Skill]
---

/yx-architecture:yx-review the three files below

```dart
// lib/domain/polling_state_manager.dart
import 'dart:async';
import 'package:yx_state/yx_state.dart';

class PollingStateManager extends StateManager<PollingState> {
  PollingStateManager(super.state);

  Future<void> startPolling() => handle((emit) async {
    emit(state.copyWith(isPolling: true));
    Timer.periodic(const Duration(seconds: 5), (_) {
      emit(state.copyWith(tick: state.tick + 1));
    });
  });
}

// lib/presentation/polling_view_model.dart
import 'package:flutter/material.dart';
import 'package:yx_state/yx_state.dart';

class PollingViewModel implements StateReadable<PollingViewObject> {
  PollingViewModel(this._polling);
  final StateReadable<PollingState> _polling;

  @override
  PollingViewObject get state => PollingViewObject(
    label: Text('${_polling.state.tick}'),
  );

  @override
  Stream<PollingViewObject> get stream => _polling.stream.map((_) => state);
}

// lib/di/app_scope_container.dart
class AppScopeContainer extends ScopeContainer implements AppScope {
  late final _databaseDep = asyncDep(() => Database());
  late final _cacheDep = asyncDep(() => Cache(_databaseDep.get));
  late final _pollingDep = dep(() => PollingStateManager(const PollingState()));

  @override
  List<Set<AsyncDep>> get initializeQueue => [{_databaseDep}];
}
```
