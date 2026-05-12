import 'package:meta/meta.dart';

import '../../state/base/mutation.dart';
import '../route.dart';
import '../route_node.dart';
import '../route_node_util.dart';

/// {@template route_node_diff_result}
/// Describes the difference between two [RouteNode] trees.
///
/// The diff contains three buckets keyed by [YxRoute]:
/// - [added] nodes present only in the target tree.
/// - [removed] nodes present only in the original tree.
/// - [updates] for routes that exist in both trees but whose payload changed.
/// {@endtemplate}
@immutable
final class RouteNodeDiffResult {
  /// Nodes introduced by the mutation.
  final Map<YxRoute, RouteNode> added;

  /// Nodes that disappeared as a result of the mutation.
  final Map<YxRoute, RouteNode> removed;

  /// Routes that changed payload between the original and target trees.
  final Map<YxRoute, Mutation> updates;

  /// {@macro route_node_diff_result}
  const RouteNodeDiffResult(this.added, this.removed, this.updates);

  /// Computes the diff between [originalNode] and [targetNode].
  factory RouteNodeDiffResult.difference(
    RouteNode originalNode,
    RouteNode targetNode,
  ) =>
      RouteNodeUtil.compareNodes(originalNode, targetNode);

  /// Whether the diff contains no additions, removals or updates.
  bool get isEmpty => added.isEmpty && removed.isEmpty && updates.isEmpty;

  /// Whether the diff contains any additions, removals or updates.
  bool get isNotEmpty => !isEmpty;
}
