import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:yx_navigation/yx_navigation.dart';

import '../base/route_declaration_resolver.dart';
import 'debug_panel_display_type.dart';
import 'domain/debug_observer_readable.dart';
import 'utils/theme.dart';
import 'view/debug_view.dart';
import 'view/draggable_overlay_widget.dart';

class DebugPanelPageWrapper extends StatefulWidget {
  const DebugPanelPageWrapper({
    required this.child,
    required this.stateManager,
    required this.routeDeclarationResolver,
    this.defaultDisplayType,
    this.observerReadable,
    this.isVisible = false,
    super.key,
  });

  final RouteNodeStateManager stateManager;

  final DebugPanelDisplayType? defaultDisplayType;

  final RouteDeclarationResolver? routeDeclarationResolver;

  final DebugObserverReadable? observerReadable;

  final Widget child;

  final bool isVisible;

  @override
  State<DebugPanelPageWrapper> createState() => _DebugPanelPageWrapperState();
}

class _DebugPanelPageWrapperState extends State<DebugPanelPageWrapper> {
  /// If `true` both sidebar and [DebugView] are visible
  bool _debugViewVisible = false;

  int _selectedDebugViewIndex = 0;

  late DebugPanelDisplayType _debugPanelDisplayType =
      widget.defaultDisplayType ?? DebugPanelDisplayType.fullscreen;

  void _toggleVisibility() => setState(
        () => _debugViewVisible = !_debugViewVisible,
      );

  @override
  void initState() {
    super.initState();
    _debugViewVisible = widget.isVisible;
  }

  @override
  Widget build(BuildContext context) => Overlay(
        initialEntries: [
          OverlayEntry(
            builder: (context) => LayoutBuilder(
              builder: (context, constraints) {
                final biggest = constraints.biggest;
                final width = min<double>(320, biggest.width * 0.5);

                final rail = _Rail(
                  selectedIndex: _selectedDebugViewIndex,
                  onDestinationSelected: (value) => setState(
                    () => _selectedDebugViewIndex = value,
                  ),
                  onHide: () => _toggleVisibility(),
                  displayType: _debugPanelDisplayType,
                  onDisplayTypeTap: () =>
                      _DebugPanelTypeMenu.showDisplayTypeOverlay(
                    context,
                    state: _debugPanelDisplayType,
                    availableSize: biggest,
                    onSelected: (type) => setState(
                      () => _debugPanelDisplayType = type,
                    ),
                  ),
                );

                final debugView = DebugView(
                  stateManager: widget.stateManager,
                  routeDeclarationResolver: widget.routeDeclarationResolver,
                  observerReadable: widget.observerReadable,
                  selectedIndex: _selectedDebugViewIndex,
                );

                final sidebar = _Wrappers(
                  child: _DebugRowLayout(
                    rail: rail,
                    body: debugView,
                    reverseOrder: {
                      DebugPanelDisplayType.overlayTrailing,
                      DebugPanelDisplayType.splitTrailing
                    }.contains(_debugPanelDisplayType),
                  ),
                );

                return Stack(
                  children: [
                    if (_debugViewVisible)
                      ...switch (_debugPanelDisplayType) {
                        DebugPanelDisplayType.overlayLeading => [
                            widget.child,
                            Align(
                              alignment: AlignmentDirectional.centerStart,
                              child: SizedBox(
                                width: width,
                                child: sidebar,
                              ),
                            ),
                          ],
                        DebugPanelDisplayType.overlayTrailing => [
                            widget.child,
                            Align(
                              alignment: AlignmentDirectional.centerEnd,
                              child: SizedBox(
                                width: width,
                                child: sidebar,
                              ),
                            ),
                          ],
                        DebugPanelDisplayType.splitLeading => [
                            Row(
                              children: [
                                SizedBox(
                                  width: width,
                                  child: sidebar,
                                ),
                                Expanded(
                                  child: widget.child,
                                ),
                              ],
                            ),
                          ],
                        DebugPanelDisplayType.splitTrailing => [
                            Row(
                              children: [
                                Expanded(
                                  child: widget.child,
                                ),
                                SizedBox(
                                  width: width,
                                  child: sidebar,
                                ),
                              ],
                            ),
                          ],
                        DebugPanelDisplayType.fullscreen => [
                            widget.child,
                            sidebar,
                          ],
                        DebugPanelDisplayType.splitTop => [
                            Row(
                              children: [
                                _Wrappers(child: rail),
                                Expanded(
                                  child: Column(
                                    children: [
                                      Flexible(
                                        child: _Wrappers(child: debugView),
                                      ),
                                      Flexible(
                                        child: widget.child,
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            )
                          ],
                        DebugPanelDisplayType.splitBottom => [
                            Row(
                              children: [
                                _Wrappers(child: rail),
                                Expanded(
                                  child: Column(
                                    children: [
                                      Flexible(
                                        child: widget.child,
                                      ),
                                      Flexible(
                                        child: _Wrappers(child: debugView),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            )
                          ],
                      }
                    else
                      widget.child,
                    DraggableOverlayWidget(
                      initialOffset: _makeInitialOffset(
                        biggest,
                        _EyeButton.size,
                      ),
                      overlaySize: _EyeButton.size,
                      isVisible: !_debugViewVisible,
                      child: _EyeButton(
                        onTap: () => _toggleVisibility(),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      );

  Offset _makeInitialOffset(Size availableSize, Size overlaySize) {
    final top = availableSize.height / 8 * 3 + overlaySize.height;
    final left = availableSize.width - overlaySize.width;
    return Offset(left, top);
  }
}

class _Wrappers extends StatelessWidget {
  final Widget child;

  const _Wrappers({
    required this.child,
  });

  @override
  Widget build(BuildContext context) => Theme(
        data: ThemeData.from(
          colorScheme: ColorScheme.fromSeed(
            seedColor: DebugToolsThemeUtils.primaryColor,
            brightness: Brightness.dark,
          ),
        ),
        child: Material(
          child: DefaultSelectionStyle(
            child: ScaffoldMessenger(
              child: HeroControllerScope.none(
                child: Navigator(
                  pages: <Page<void>>[
                    MaterialPage<void>(
                      child: child,
                    ),
                  ],
                  onDidRemovePage: (page) {},
                ),
              ),
            ),
          ),
        ),
      );
}

class _DebugRowLayout extends StatelessWidget {
  final Widget rail;
  final Widget body;
  final bool reverseOrder;

  const _DebugRowLayout({
    required this.rail,
    required this.body,
    required this.reverseOrder,
  });

  @override
  Widget build(BuildContext context) {
    var children = [rail, Expanded(child: body)];
    if (reverseOrder) {
      children = children.reversed.toList();
    }
    return Scaffold(
      body: SafeArea(
        child: Row(
          children: children,
        ),
      ),
    );
  }
}

class _EyeButton extends StatelessWidget {
  final VoidCallback onTap;

  const _EyeButton({
    required this.onTap,
  });

  static const double _iconSize = 24;
  static const double _padding = 8;
  static Size size = const Size.square(_iconSize + _padding * 2);

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(_padding),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.grey.shade200,
        ),
        child: GestureDetector(
          onTap: onTap,
          child: const Icon(
            Icons.route,
            size: _iconSize,
            color: Colors.black87,
          ),
        ),
      );
}

class _Rail extends StatelessWidget {
  final int selectedIndex;
  final ValueSetter<int> onDestinationSelected;
  final VoidCallback onHide;
  final DebugPanelDisplayType displayType;
  final VoidCallback onDisplayTypeTap;

  const _Rail({
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.onHide,
    required this.displayType,
    required this.onDisplayTypeTap,
  });

  static double iconSize = 20;

  @override
  Widget build(BuildContext context) => LimitedBox(
        maxWidth: 36,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.navigation),
              iconSize: iconSize,
              isSelected: selectedIndex == 0,
              onPressed: () => onDestinationSelected(0),
            ),
            IconButton(
              icon: const Icon(Icons.copy),
              iconSize: iconSize,
              isSelected: selectedIndex == 1,
              onPressed: () => onDestinationSelected(1),
            ),
            IconButton(
              icon: const Icon(Icons.history),
              iconSize: iconSize,
              isSelected: selectedIndex == 2,
              onPressed: () => onDestinationSelected(2),
            ),
            const Divider(
              indent: 4,
              endIndent: 4,
              height: 32,
            ),
            IconButton(
              icon: const Icon(
                Icons.visibility_off,
              ),
              iconSize: iconSize,
              onPressed: onHide,
            ),
            IconButton(
              icon: _DebugPanelTypeMenu.mapStateToWidget(displayType),
              iconSize: iconSize,
              onPressed: onDisplayTypeTap,
            ),
            const Spacer(),
          ],
        ),
      );
}

abstract class _DebugPanelTypeMenu {
  static Widget mapStateToWidget(DebugPanelDisplayType state) => RotatedBox(
        quarterTurns: switch (state) {
          DebugPanelDisplayType.splitTop => 1,
          DebugPanelDisplayType.splitBottom => 3,
          _ => 0,
        },
        child: Icon(
          switch (state) {
            DebugPanelDisplayType.fullscreen => CupertinoIcons.square,
            DebugPanelDisplayType.overlayLeading => CupertinoIcons.sidebar_left,
            DebugPanelDisplayType.overlayTrailing =>
              CupertinoIcons.sidebar_right,
            DebugPanelDisplayType.splitLeading =>
              CupertinoIcons.square_righthalf_fill,
            DebugPanelDisplayType.splitTrailing =>
              CupertinoIcons.square_lefthalf_fill,
            DebugPanelDisplayType.splitTop =>
              CupertinoIcons.square_righthalf_fill,
            DebugPanelDisplayType.splitBottom =>
              CupertinoIcons.square_righthalf_fill,
          },
        ),
      );

  static void showDisplayTypeOverlay(
    BuildContext context, {
    required DebugPanelDisplayType state,
    required ValueSetter<DebugPanelDisplayType> onSelected,
    required Size availableSize,
  }) {
    OverlayEntry? entry;

    entry = OverlayEntry(
      builder: (context) => SafeArea(
        child: Stack(
          children: [
            Align(
              child: Card(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: DebugPanelDisplayType.values
                      .map(
                        (e) => ListTile(
                          onTap: () {
                            entry?.remove();
                            entry?.dispose();
                            onSelected(e);
                          },
                          leading: mapStateToWidget(e),
                          trailing: state == e ? const Icon(Icons.check) : null,
                          title: Text(e.description),
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    Overlay.of(context).insert(entry);
  }
}
