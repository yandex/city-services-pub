import 'package:meta/meta.dart';

/// {@template yx_route}
/// Stable identity of a route within the navigation tree.
///
/// A [YxRoute] is a lightweight, immutable value used to identify a specific
/// destination. It is the key that ties a tree node back to its declaration
/// and is safe to use as a map key or compare for equality.
/// {@endtemplate}
@immutable
final class YxRoute implements Comparable<YxRoute> {
  /// The unique identifier of this route.
  ///
  /// The value should contain only alphabet characters and dashes so that it
  /// can be safely embedded into a [Uri].
  final String id;

  /// {@macro yx_route}
  const YxRoute({required this.id});

  /// Creates a [YxRoute] from its JSON representation.
  factory YxRoute.fromJson(Map<String, Object?> json) {
    if (json case {'id': final String id}) {
      return YxRoute(id: id);
    }

    throw ArgumentError.value(json['id'], 'id', 'Should be a String');
  }

  /// Converts this [YxRoute] to a JSON map.
  Map<String, Object?> toJson() => <String, Object?>{'id': id};

  @override
  int get hashCode => id.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is YxRoute && id == other.id);

  @override
  String toString() => 'Route{id: $id}';

  @override
  int compareTo(YxRoute other) => id.compareTo(other.id);
}
