import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:yx_navigation/yx_navigation.dart';
import 'package:yx_navigation_flutter/src/base/builder/route_builder.dart';

import '../../base/builder/route_indexed_stack_builder.dart';
import '../../base/builder/route_outlet_builder.dart';
import '../../base/builder/route_widget_builder.dart';
import '../../base/declaration/route_builder_declaration.dart';
import '../../base/declaration/route_indexed_stack_declaration.dart';
import '../../base/declaration/route_schema_declaration.dart';
import '../../base/route_declaration_resolver.dart';
import '../utils/theme.dart';

class StateTreeView extends StatelessWidget {
  const StateTreeView({
    required this.stateManager,
    required this.routeDeclarationResolver,
    super.key,
  });

  final RouteNodeStateManager stateManager;
  final RouteDeclarationResolver? routeDeclarationResolver;

  @override
  Widget build(BuildContext context) => StreamBuilder(
        stream: stateManager.stream,
        initialData: stateManager.state,
        builder: (context, state) => StateTreeLayout(
          node: state.requireData,
          routeDeclarationResolver: routeDeclarationResolver,
        ),
      );
}

class StateTreeLayout extends StatefulWidget {
  final RouteNode node;
  final RouteDeclarationResolver? routeDeclarationResolver;

  const StateTreeLayout({
    required this.node,
    this.routeDeclarationResolver,
    super.key,
  });

  @override
  State<StateTreeLayout> createState() => _StateTreeLayoutState();
}

class _StateTreeLayoutState extends State<StateTreeLayout> {
  bool _showingMetadata = false;
  bool _expandedByDefault = true;

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Theme(
                data: _buildListTheme(Theme.of(context)),
                child: _NodeTile(
                  key: ValueKey(
                    Object.hash(widget.node.route.id, _expandedByDefault),
                  ),
                  node: widget.node,
                  declarationIconResolver: _getIconFromNode,
                  isLast: true,
                  showingMetadata: _showingMetadata,
                  expandedByDefault: _expandedByDefault,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton.icon(
                  onPressed: () => setState(
                    () => _showingMetadata = !_showingMetadata,
                  ),
                  icon: Icon(
                    _showingMetadata
                        ? Icons.text_decrease_rounded
                        : Icons.text_increase_rounded,
                  ),
                  label: const Text('Toggle metadata'),
                ),
                const SizedBox(height: 4),
                ElevatedButton.icon(
                  onPressed: () => setState(
                    () => _expandedByDefault = !_expandedByDefault,
                  ),
                  icon: Icon(
                    _expandedByDefault
                        ? Icons.expand_rounded
                        : Icons.arrow_circle_down_rounded,
                  ),
                  label: Text(
                    _expandedByDefault
                        ? 'Expanded by default'
                        : 'Collapsed by default',
                  ),
                ),
              ],
            ),
          ),
        ],
      );

  ThemeData _buildListTheme(ThemeData data) => data.copyWith(
        listTileTheme: data.listTileTheme.copyWith(
          shape: const Border(),
        ),
        expansionTileTheme: data.expansionTileTheme.copyWith(
          shape: const Border(),
        ),
      );

  /// Someday we added meta information and make this method more complex.
  IconData? _getIconFromNode(RouteNode node) {
    final value = widget.routeDeclarationResolver?.resolve(node);
    if (value == null) {
      return null;
    }

    if (value case final RouteBuilderDeclaration declaration) {
      final builder = declaration.routeBuilder;
      return switch (builder) {
        RouteOutletBuilder() => Icons.window,
        RouteWidgetBuilder() => Icons.photo,
        RouteIndexedStackBuilder() => Icons.format_list_numbered_rounded,
        RouteBuilder() => Icons.question_mark_rounded,
      };
    }

    if (value case final RouteSchemaDeclaration declaration) {
      final builder = declaration.routeBuilder;
      return switch (builder) {
        RouteOutletBuilder() => Icons.window,
        RouteWidgetBuilder() => Icons.photo,
        RouteIndexedStackBuilder() => Icons.format_list_numbered_rounded,
        RouteBuilder() => Icons.question_mark_rounded,
      };
    }

    if (value case final RouteIndexedStackDeclaration _) {
      return Icons.onetwothree;
    }

    return null;
  }
}

class _NodeTile extends StatelessWidget {
  final RouteNode node;
  final int depth;
  final bool isLast;
  final bool showingMetadata;
  final bool expandedByDefault;
  final IconData? Function(RouteNode) declarationIconResolver;

  const _NodeTile({
    required this.node,
    required this.showingMetadata,
    required this.expandedByDefault,
    required this.declarationIconResolver,
    this.depth = 0,
    this.isLast = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final activeNode = isLast && !node.hasChildren;
    final declarationIcon = declarationIconResolver(node);

    final title = Text.rich(
      TextSpan(
        children: [
          TextSpan(text: node.route.id),
          if (declarationIcon != null)
            WidgetSpan(
              child: Padding(
                padding: const EdgeInsetsDirectional.only(start: 4),
                child: Icon(
                  declarationIcon,
                  size: 16,
                  color: Theme.of(context).colorScheme.tertiary,
                ),
              ),
              baseline: TextBaseline.ideographic,
              alignment: PlaceholderAlignment.baseline,
            ),
        ],
      ),
      style: DebugToolsThemeUtils.monospaceTextStyle.copyWith(
        color:
            activeNode ? Theme.of(context).colorScheme.onInverseSurface : null,
      ),
    );
    final shouldShowSubtitle =
        showingMetadata && (node.hasArguments || node.hasExtra);
    final subtitle = shouldShowSubtitle
        ? Text(
            [
              node.arguments,
              node.extra,
            ].whereNot((e) => e.isEmpty).map((e) => e.toString()).join('\n'),
            style: DebugToolsThemeUtils.monospaceTextStyle,
          )
        : null;
    final padding = EdgeInsetsDirectional.only(
      start: depth * 20 + 8,
      end: 8,
    );
    final color = DebugToolsThemeUtils
        .stateTreeColors[depth % DebugToolsThemeUtils.stateTreeColors.length];

    if (node.hasChildren) {
      return ExpansionTile(
        title: title,
        subtitle: subtitle,
        tilePadding: padding,
        dense: true,
        initiallyExpanded: expandedByDefault,
        collapsedBackgroundColor: color,
        backgroundColor: color,
        children: node.children
            .mapIndexed(
              (index, child) => _NodeTile(
                node: child,
                declarationIconResolver: declarationIconResolver,
                expandedByDefault: expandedByDefault,
                depth: depth + 1,
                isLast: isLast && identical(node.children.last, child),
                showingMetadata: showingMetadata,
              ),
            )
            .toList(),
      );
    } else {
      return ColoredBox(
        color:
            activeNode ? Theme.of(context).colorScheme.inverseSurface : color,
        child: ListTile(
          key: ObjectKey(
            Object.hash(node.route.id, showingMetadata),
          ),
          title: title,
          subtitle: subtitle,
          contentPadding: padding,
          dense: true,
        ),
      );
    }
  }
}
