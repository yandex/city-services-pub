import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:yx_navigation/yx_navigation.dart';

import 'page_factory.dart';

part 'page_factory_modal_bottom_sheet_route.dart';
part 'pages_factory_cupertino_page_route.dart';
part 'pages_factory_material_page_route.dart';
part 'pages_factory_modal_route_proxy.dart';
part 'pages_factory_dialog_route.dart';
part 'pages_factory_cupertino_dialog_route.dart';
part 'pages_factory_cupertino_modal_popup_route.dart';
part 'pages_factory_raw_dialog_route.dart';

/// Signature for the [PagesFactory.custom] builder.
typedef CustomBuilder<T> = Page<T> Function(
  BuildContext context,
  RouteNode routeNode,
  LocalKey key,
  Widget child,
);

/// {@template pages_factory}
/// Sealed set of built-in [PageFactory] implementations.
///
/// Use one of the named constructors to build the kind of [Page] you need:
///
/// * [PagesFactory.material] / [PagesFactory.cupertino] for standard
///   full-screen routes.
/// * [PagesFactory.modalBottomSheet] for Material modal bottom sheets.
/// * [PagesFactory.dialog], [PagesFactory.cupertinoDialog],
///   [PagesFactory.cupertinoModalPopup], [PagesFactory.rawDialog] for
///   modal dialogs and popups.
/// * [PagesFactory.modalRouteProxy] to adapt an existing [ModalRoute]
///   into a [Page].
/// * [PagesFactory.custom] for fully custom page construction via a
///   [CustomBuilder].
/// {@endtemplate}
@immutable
sealed class PagesFactory<T> implements PageFactory<T> {
  const PagesFactory._();

  /// Produces a [MaterialPage]-backed [Page].
  const factory PagesFactory.material({
    bool maintainState,
    bool fullscreenDialog,
    bool allowSnapshotting,
    Completer<T?>? routeCompleter,
    String? restorationId,
    bool canPop,
    PopInvokedWithResultCallback<T>? onPopInvoked,
  }) = MaterialPageFactory<T>;

  /// Produces a [CupertinoPage]-backed [Page].
  const factory PagesFactory.cupertino({
    String? title,
    bool maintainState,
    bool fullscreenDialog,
    bool allowSnapshotting,
    Completer<T?>? routeCompleter,
    String? restorationId,
    bool canPop,
    PopInvokedWithResultCallback<T>? onPopInvoked,
  }) = CupertinoPageFactory<T>;

  /// Produces a [Page] built by a caller-supplied [CustomBuilder].
  const factory PagesFactory.custom({
    required CustomBuilder<T> builder,
  }) = CustomPageFactory<T>;

  /// Wraps an existing [ModalRoute] so it can participate in Navigator 2.0.
  const factory PagesFactory.modalRouteProxy({
    required Route<T> route,
    Completer<T?>? routeCompleter,
    Object? arguments,
    String? name,
  }) = ModalRouteProxyPageFactory<T>;

  /// Produces a [Page] backed by a [ModalBottomSheetRoute].
  const factory PagesFactory.modalBottomSheet({
    required bool isScrollControlled,
    Completer<T?>? routeCompleter,
    CapturedThemes? capturedThemes,
    double scrollControlDisabledMaxHeightRatio,
    Color? backgroundColor,
    double? elevation,
    ShapeBorder? shape,
    Clip? clipBehavior,
    BoxConstraints? constraints,
    Color? modalBarrierColor,
    bool isDismissible,
    bool enableDrag,
    bool? showDragHandle,
    AnimationController? transitionAnimationController,
    Offset? anchorPoint,
    bool useSafeArea,
    String? barrierOnTapHint,
    String? barrierLabel,
    String? restorationId,
    bool canPop,
    PopInvokedWithResultCallback<T>? onPopInvoked,
  }) = ModalBottomSheetPageFactory<T>;

  /// Produces a [Page] backed by a Material [DialogRoute].
  const factory PagesFactory.dialog({
    required Route<T> route,
    required bool barrierDismissible,
    required bool useSafeArea,
    Completer<T?>? routeCompleter,
    Color? barrierColor,
    String? barrierLabel,
    Offset? anchorPoint,
  }) = DialogRoutePageFactory<T>;

  /// Produces a [Page] backed by a [CupertinoDialogRoute].
  const factory PagesFactory.cupertinoDialog({
    required Route<T> route,
    required bool barrierDismissible,
    Completer<T?>? routeCompleter,
    Color? barrierColor,
    String? barrierLabel,
    Offset? anchorPoint,
  }) = CupertinoDialogRoutePageFactory<T>;

  /// Produces a [Page] backed by a [CupertinoModalPopupRoute].
  const factory PagesFactory.cupertinoModalPopup({
    required Route<T> route,
    required bool barrierDismissible,
    required bool semanticsDismissible,
    Completer<T?>? routeCompleter,
    Color? barrierColor,
    String? barrierLabel,
    Offset? anchorPoint,
  }) = CupertinoModalPopupRoutePageFactory<T>;

  /// Produces a [Page] backed by a [RawDialogRoute].
  const factory PagesFactory.rawDialog({
    required Route<T> route,
    required bool barrierDismissible,
    required Duration transitionDuration,
    required Duration reverseTransitionDuration,
    Completer<T?>? routeCompleter,
    Color? barrierColor,
    String? barrierLabel,
    Offset? anchorPoint,
  }) = RawDialogRoutePageFactory<T>;
}

/// [PageFactory] that builds pages via a caller-supplied [CustomBuilder].
///
/// Use this when none of the built-in factories exposed by [PagesFactory]
/// fit: the [builder] is invoked for every route and returns the [Page] that
/// should represent it.
@immutable
class CustomPageFactory<T> extends PagesFactory<T> {
  /// Builder invoked to construct the [Page].
  final CustomBuilder<T> builder;

  /// Creates a [CustomPageFactory] that delegates to [builder].
  const CustomPageFactory({
    required this.builder,
  }) : super._();

  @override
  Page<T> call(
    BuildContext context,
    RouteNode routeNode,
    LocalKey key,
    Widget child,
  ) =>
      builder(context, routeNode, key, child);
}
