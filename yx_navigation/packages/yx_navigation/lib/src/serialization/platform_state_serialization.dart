import 'package:meta/meta.dart';

import '../base/route_node.dart';
import 'serializers/squid_fragment_based_serializer.dart';
import 'serializers/squid_path_based_serializer.dart';
import 'serializers/uri_fragment_based_serializer.dart';
import 'serializers/uri_path_based_serializer.dart';

/// {@template uri_strategy}
/// Strategy for placing serialized navigation state in URL.
///
/// Values select path-based vs fragment-based encoding for serializers such as
/// [UriStringStateSerialization] and [PrettyUriStateSerialization].
/// {@endtemplate}
enum UriStrategy {
  /// Use the path part of URL (without #).
  ///
  /// Example: `/root/.dashboard`
  ///
  /// This is useful for scenarios where third parties ignore the hash (#)
  /// in redirect URLs, such as OAuth callbacks or Telegram login redirects.
  path,

  /// Use the fragment part of URL (after #).
  ///
  /// Example: `#/root/.dashboard`
  fragment,
}

/// {@template platform_state_serialization}
/// A way to transform platform route state (URL from browser, deeplink, etc)
/// into a [RouteNode] and back.
///
/// This mirrors the role of Flutter's `RouteInformationParser` and
/// `RouteInformationProvider` from `package:flutter/widgets.dart`, but stays
/// framework-agnostic so it can be used in tests and non-Flutter contexts.
/// {@endtemplate}
abstract interface class PlatformStateSerialization {
  /// Converts the given [RouteNode] into a [Uri].
  Uri convert(RouteNode node);

  /// Parses the given [Uri] into a [RouteNode].
  ///
  /// Can throw an [Exception] if the [Uri] is invalid.
  RouteNode parse(Uri data);
}

/// {@template uri_string_state_serialization}
/// Converts the given [RouteNode] into a [Uri] string and back.
///
/// Example string is as follows
/// #('cnQ':('aWQ':'YVtde30iYg'),'YXJncw':('a2V5W117fSI':'dmFsdWVbXXt9Ig'))
///
/// This complex format allows to pack a lot of data into short string
/// while preserving some level of readability.
/// For example, you could count the number of nodes in the string,
/// or you find nodes with same ID.
///
/// For more info on the format, see [UriFragmentBasedSerializer].
///
/// Parameters:
/// - [strategy] - determines whether to use fragment (#) or path for
///   serialization. Defaults to [UriStrategy.fragment].
/// - [mergeQueryParams] - if true, query parameters from the URL will be
///   merged into the arguments of the deepest child node during parsing.
///   This is useful for OAuth callbacks where third parties add their own
///   query parameters. Defaults to false.
/// {@endtemplate}
@immutable
class UriStringStateSerialization implements PlatformStateSerialization {
  /// Creates a new [UriStringStateSerialization].
  ///
  /// {@macro uri_string_state_serialization}
  const UriStringStateSerialization({
    this.strategy = UriStrategy.fragment,
    this.mergeQueryParams = false,
  });

  /// Strategy for placing serialized state in URL.
  final UriStrategy strategy;

  /// Whether to merge URL query parameters into deepest child node arguments.
  final bool mergeQueryParams;

  @override
  Uri convert(RouteNode node) {
    switch (strategy) {
      case UriStrategy.fragment:
        return UriFragmentBasedSerializer.toUri(node);
      case UriStrategy.path:
        return UriPathBasedSerializer.toUri(node);
    }
  }

  @override
  RouteNode parse(Uri data) {
    final RouteNode node;
    switch (strategy) {
      case UriStrategy.fragment:
        node = UriFragmentBasedSerializer.fromUri(data);
      case UriStrategy.path:
        node = UriPathBasedSerializer.fromUri(data);
    }

    if (mergeQueryParams && data.queryParameters.isNotEmpty) {
      return _mergeQueryParamsIntoDeepestChild(node, data.queryParameters);
    }

    return node;
  }
}

/// {@template pretty_uri_state_serialization}
/// Converts the given [RouteNode] into a [Uri] string and back.
///
/// Example string is as follows
/// #/home$?user=watermelon%3Dgood/.level1-1$?arg1=value1&arg2=value2/..level2/...leve3-1/....leve4-1/....leve4-2/...leve3-2/....leve4-1/....leve4-2/.....level5/.level1-1
///
/// This simpler and verbose format is easier to read and write by hand.
/// The main advantage is that it's easy to understand tree structure.
///
/// For the given example string it is as follows:
/// home {user: 'watermelon=good'}
/// - level1-1 {arg1: 'value1', arg2: 'value2'}
///   - level2
///     - leve3-1
///       - leve4-1
///       - leve4-2
///     - leve3-2
///       - leve4-1
///       - leve4-2
///         - level5
/// - level1-1
///
/// For more info on the format, see [SquidFragmentBasedSerializer].
///
/// Parameters:
/// - [strategy] - determines whether to use fragment (#) or path for
///   serialization. Defaults to [UriStrategy.fragment].
/// - [mergeQueryParams] - if true, query parameters from the URL will be
///   merged into the arguments of the deepest child node during parsing.
///   This is useful for OAuth callbacks where third parties add their own
///   query parameters. Defaults to false.
/// {@endtemplate}
@immutable
class PrettyUriStateSerialization implements PlatformStateSerialization {
  /// Creates a new [PrettyUriStateSerialization].
  ///
  /// {@macro pretty_uri_state_serialization}
  const PrettyUriStateSerialization({
    this.strategy = UriStrategy.fragment,
    this.mergeQueryParams = false,
  });

  /// Strategy for placing serialized state in URL.
  final UriStrategy strategy;

  /// Whether to merge URL query parameters into deepest child node arguments.
  final bool mergeQueryParams;

  @override
  Uri convert(RouteNode node) {
    switch (strategy) {
      case UriStrategy.fragment:
        return SquidFragmentBasedSerializer.toUri(node);
      case UriStrategy.path:
        return SquidPathBasedSerializer.toUri(node);
    }
  }

  @override
  RouteNode parse(Uri data) {
    final RouteNode node;
    switch (strategy) {
      case UriStrategy.fragment:
        node = SquidFragmentBasedSerializer.fromUri(data);
      case UriStrategy.path:
        node = SquidPathBasedSerializer.fromUri(data);
    }

    if (mergeQueryParams && data.queryParameters.isNotEmpty) {
      return _mergeQueryParamsIntoDeepestChild(node, data.queryParameters);
    }

    return node;
  }
}

/// Merges query parameters into the deepest child node's arguments.
///
/// Traverses the tree to find the deepest child (last child at each level)
/// and merges the query parameters into its arguments.
RouteNode _mergeQueryParamsIntoDeepestChild(
  RouteNode node,
  Map<String, String> queryParams,
) {
  if (node.children.isEmpty) {
    // This is the deepest node, merge query params
    final mergedArguments = {...node.arguments, ...queryParams};
    return RouteNode.fromRoute(
      route: node.route,
      arguments: mergedArguments,
      extra: node.extra,
    );
  }

  // Recursively process children, merging into the last child
  final children = node.children.toList();
  final lastIndex = children.length - 1;
  children[lastIndex] = _mergeQueryParamsIntoDeepestChild(
    children[lastIndex],
    queryParams,
  );

  return RouteNode.fromRoute(
    route: node.route,
    arguments: node.arguments,
    extra: node.extra,
    children: children,
  );
}
