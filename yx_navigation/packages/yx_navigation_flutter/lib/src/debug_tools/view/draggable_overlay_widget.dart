import 'package:flutter/physics.dart';
import 'package:flutter/widgets.dart';

class DraggableOverlayWidget extends StatefulWidget {
  final Widget child;
  final Offset initialOffset;
  final Size overlaySize;
  final bool isVisible;

  const DraggableOverlayWidget({
    required this.child,
    required this.initialOffset,
    required this.overlaySize,
    this.isVisible = true,
    super.key,
  });

  @override
  State<DraggableOverlayWidget> createState() => _DraggableOverlayWidgetState();
}

class _DraggableOverlayWidgetState extends State<DraggableOverlayWidget>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  static const _spring = SpringDescription(
    mass: 30,
    stiffness: 80,
    damping: 1,
  );

  AnimationController? _controller;
  Animation<Offset> _animation = const AlwaysStoppedAnimation(Offset.zero);
  Offset _currentOffset = Offset.zero;

  /// True once the first frame with a valid (non-zero) screen size has been
  /// processed. On Android, [MediaQuery.size] can be zero during cold start,
  /// so we defer positioning until we have real dimensions.
  bool _hasPositioned = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final controller = AnimationController(vsync: this)
      ..addListener(() => setState(() => _currentOffset = _animation.value));
    _controller = controller;
    _animation = controller.drive(Tween());
    _currentOffset = widget.initialOffset;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    final size = MediaQuery.of(context).size;
    final hasValidSize = size.width > 0 && size.height > 0;
    if (!hasValidSize) {
      return;
    }
    // Re-snap after the frame so MediaQuery reflects the new screen dimensions.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _stick(
        velocity: const Velocity(pixelsPerSecond: Offset.zero),
        from: _currentOffset,
        viewPadding: MediaQuery.of(context).viewPadding,
        size: MediaQuery.of(context).size,
      );
    });
  }

  void _stick({
    required Velocity velocity,
    required Offset from,
    required EdgeInsets viewPadding,
    required Size size,
  }) {
    final controller = _controller;
    final hasValidSize = size.width > 0 && size.height > 0;
    if (controller == null || !hasValidSize) {
      return;
    }

    final topMin = viewPadding.top;
    final bottomMax =
        size.height - widget.overlaySize.height - viewPadding.bottom;
    final snapToRight = from.dx > size.width / 2 - widget.overlaySize.width / 2;
    final endDx = snapToRight
        ? (size.width - widget.overlaySize.width).clamp(0.0, double.infinity)
        : 0.0;
    final endDy = from.dy.clamp(topMin, bottomMax);

    _animation = controller.drive(
      Tween<Offset>(
        begin: from,
        end: Offset(endDx, endDy),
      ),
    );

    final unitsPerSecond = Offset(
      velocity.pixelsPerSecond.dx / size.width,
      velocity.pixelsPerSecond.dy / size.height,
    );
    final simulation =
        SpringSimulation(_spring, 0, 1, -unitsPerSecond.distance);

    controller.animateWith(simulation);
  }

  /// Calculates and applies the initial overlay position once the screen has
  /// valid (non-zero) dimensions. Called from [build] on the first frame where
  /// [MediaQuery.size] is usable.
  void _initPositionIfNeeded(Size size) {
    final controller = _controller;
    final hasValidSize = size.width > 0 && size.height > 0;
    if (_hasPositioned || !hasValidSize || controller == null) {
      return;
    }
    _hasPositioned = true;

    // Snap to the right edge of the screen.
    final correctLeft = size.width - widget.overlaySize.width;
    // Place the overlay at 3/8 of the screen height, shifted down by its own
    // height so it doesn't overlap the status-bar area.
    final correctTop = size.height / 8 * 3 + widget.overlaySize.height;

    _currentOffset = Offset(correctLeft, correctTop);
    _animation = controller.drive(
      Tween<Offset>(begin: _currentOffset, end: _currentOffset),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    _initPositionIfNeeded(size);

    return Positioned(
      left: _currentOffset.dx,
      top: _currentOffset.dy,
      child: Draggable(
        maxSimultaneousDrags: 1,
        feedback: widget.child,
        childWhenDragging: const SizedBox.shrink(),
        onDragStarted: () {
          final controller = _controller;
          if (controller != null && controller.isAnimating) {
            controller
              ..stop()
              ..reset();
          }
        },
        onDraggableCanceled: (velocity, offset) => _stick(
          velocity: velocity,
          from: offset,
          viewPadding: MediaQuery.of(context).viewPadding,
          size: MediaQuery.of(context).size,
        ),
        child: Visibility.maintain(
          visible: widget.isVisible,
          child: widget.child,
        ),
      ),
    );
  }
}
