import 'package:yx_navigation_flutter/yx_navigation_flutter.dart';

import 'custom_implementations.dart';

/// Demo modes for overriding navigation configuration.
enum DemoMode {
  /// Standard configuration (same as the host).
  standard('Standard configuration', 'Material pages, default animations'),

  /// Cupertino pages instead of Material.
  cupertino('Cupertino pages', 'iOS-style pages instead of Material'),

  /// Disable route transitions.
  noAnimations('No animations', 'Instant transitions, no animation'),

  /// Custom NotFound / Empty widgets.
  customWidgets(
    'Custom widgets',
    'Overridden NotFound and Empty pages',
  ),

  /// Custom fade animations via PageFactory.
  fadeAnimations(
    'Fade animations (PageFactory)',
    'Smooth fade transitions via custom pages',
  ),

  /// Custom fade animations via TransitionDelegate.
  fadeTransitions(
    'Fade animations (TransitionDelegate)',
    'Smooth fade transitions via a transition delegate',
  );

  const DemoMode(this.title, this.description);

  final String title;
  final String description;
}

/// Configuration factory for each demo mode.
class DemoConfigurations {
  /// Returns the NavigationDefaults for the given mode.
  static NavigationDefaults getConfiguration(DemoMode mode) {
    switch (mode) {
      case DemoMode.standard:
        return const NavigationDefaults();

      case DemoMode.cupertino:
        return const NavigationDefaults(
          pageFactory: PagesFactory.cupertino(
            fullscreenDialog: true,
          ),
        );

      case DemoMode.noAnimations:
        return const NavigationDefaults(
          transitionDelegate: NoAnimationTransitionDelegate(),
        );

      case DemoMode.customWidgets:
        return const NavigationDefaults(
          widgetBuilder: CustomRouteNodeWidgetBuilder(),
        );

      case DemoMode.fadeAnimations:
        return const NavigationDefaults(
          pageFactory: FadePageFactory(),
        );

      case DemoMode.fadeTransitions:
        return const NavigationDefaults(
          transitionDelegate: FadeTransitionDelegate(),
          pageFactory: FadePageFactory(),
        );
    }
  }

  /// Returns a description of the changes the given mode applies.
  static String getChangesDescription(DemoMode mode) {
    switch (mode) {
      case DemoMode.standard:
        return 'Uses the default navigation configuration:\n'
            '- Material pages\n'
            '- Standard transition animations\n'
            '- Default NotFound / Empty widgets';

      case DemoMode.cupertino:
        return 'Overrides:\n'
            '- defaultPageFactory: PagesFactory.cupertino()\n'
            '- iOS-style pages with matching animations\n'
            '- Everything else is default';

      case DemoMode.noAnimations:
        return 'Overrides:\n'
            '- transitionDelegate: NoAnimationTransitionDelegate()\n'
            '- Instant transitions with no animation\n'
            '- Everything else is default';

      case DemoMode.customWidgets:
        return 'Overrides:\n'
            '- widgetBuilder: CustomRouteNodeWidgetBuilder()\n'
            '- Custom NotFound and Empty pages\n'
            '- Everything else is default';

      case DemoMode.fadeAnimations:
        return 'Overrides:\n'
            '- defaultPageFactory: FadePageFactory()\n'
            '- Smooth fade transitions through custom pages\n'
            '- Animation is built into PageRouteBuilder';

      case DemoMode.fadeTransitions:
        return 'Overrides:\n'
            '- transitionDelegate: FadeTransitionDelegate()\n'
            '- defaultPageFactory: FadeTransitionPageFactory()\n'
            '- Fade transitions via custom delegate + pages (500ms)';
    }
  }
}
