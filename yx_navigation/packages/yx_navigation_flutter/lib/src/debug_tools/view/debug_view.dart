import 'package:flutter/material.dart';
import 'package:yx_navigation/yx_navigation.dart';

import '../../base/route_declaration_resolver.dart';
import '../domain/debug_observer_readable.dart';
import 'history_view.dart';
import 'serialization_view.dart';
import 'state_tree_view.dart';

class DebugView extends StatelessWidget {
  const DebugView({
    required this.stateManager,
    required this.routeDeclarationResolver,
    required this.selectedIndex,
    this.observerReadable,
    super.key,
  });

  final RouteNodeStateManager stateManager;
  final RouteDeclarationResolver? routeDeclarationResolver;
  final DebugObserverReadable? observerReadable;
  final int selectedIndex;

  @override
  Widget build(BuildContext context) => IndexedStack(
        index: selectedIndex,
        children: <Widget>[
          StateTreeView(
            stateManager: stateManager,
            routeDeclarationResolver: routeDeclarationResolver,
          ),
          SerializationView(
            stateManager: stateManager,
          ),
          HistoryView(
            observerReadable: observerReadable,
          ),
        ],
      );
}
