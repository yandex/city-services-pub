import 'package:meta/meta.dart';

import '../../base/route_node.dart';

/// {@template mutation}
/// Describes a single transition of the navigation tree.
///
/// A [Mutation] captures both the [originalState] (before the change) and
/// the [targetState] (after the change). It is emitted to observers for
/// logging and debugging, and does not itself perform the transition.
/// {@endtemplate}
@immutable
class Mutation {
  /// The state before the mutation.
  final RouteNode originalState;

  /// The state after the mutation.
  final RouteNode targetState;

  /// {@macro mutation}
  const Mutation({required this.originalState, required this.targetState});

  @override
  int get hashCode => originalState.hashCode ^ targetState.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Mutation &&
          runtimeType == other.runtimeType &&
          originalState == other.originalState &&
          targetState == other.targetState;

  @override
  String toString() =>
      'Mutation { currentState: $originalState, nextState: $targetState }';
}
