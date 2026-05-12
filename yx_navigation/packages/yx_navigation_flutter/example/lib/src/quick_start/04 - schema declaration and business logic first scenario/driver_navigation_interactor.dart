import 'package:yx_navigation/yx_navigation.dart';

import 'driver_routes.dart';

/// Navigation interactor for the driver application.
///
/// Demonstrates a combined approach:
/// - Business Logic First - the root RouteNodeStateManager is built in the DI container
/// - Schema Declaration - the profile is mounted as a nested schema
/// - Profile Feature Isolation - the profile is driven in isolation via arguments
///
/// Responsibilities:
/// - Navigation methods for DriverApp sections
/// - Demo business-logic methods
/// - Coordination between the host app and nested features
class DriverNavigationInteractor {
  final RouteNodeStateManager _stateManager;

  /// Root state-manager handle for the UI layer.
  RouteNodeStateManager get stateManager => _stateManager;

  /// Navigator for top-level DriverApp navigation.
  RouteNavigator get navigator => _stateManager;

  /// Creates DriverNavigationInteractor with its dependencies injected.
  ///
  /// Unlike scenario 02 where the interactor built its own dependencies,
  /// here every dependency comes from [DriverAppDependencies] through the
  /// constructor.
  /// The profile feature is fully isolated and driven through route arguments.
  const DriverNavigationInteractor({
    required RouteNodeStateManager stateManager,
  }) : _stateManager = stateManager;

  // ============================================================================
  // Navigation methods for DriverApp sections.
  // ============================================================================

  /// Open the sign-in page.
  void openLogin() => navigator.push(DriverRoutes.login);

  /// Open the driver home screen.
  void openHome() => navigator.push(DriverRoutes.home);

  /// Open the orders page.
  void openOrders() => navigator.push(DriverRoutes.orders);

  /// Open the messages page.
  void openMessages() => navigator.push(DriverRoutes.messages);

  /// Open the driver profile (nested schema).
  /// Navigation inside the profile is driven by the feature's initialNodeBuilder.
  void openProfile({String? initialPage}) {
    navigator.push(
      DriverRoutes.profile,
      arguments: {
        'initialPage': initialPage ?? 'home',
      },
    );
  }

  /// Open the profile with the driver-details page on top.
  void openProfileWithDriverDetails() {
    openProfile(initialPage: 'driverProfile');
  }

  /// Open the profile with the settings page on top.
  void openProfileWithSettings() {
    openProfile(initialPage: 'settings');
  }

  /// Return to the previous screen.
  void goBack() => navigator.maybePop();

  /// Can we go back?
  bool canPop() => navigator.canPop();

  /// Sign out (return to the login screen).
  void logout() => navigator.popAll();

  /// Return to the root screen (login).
  void popAll() => navigator.popAll();

  // ============================================================================
  // Demo business-logic methods.
  // ============================================================================

  /// Demo: complete sign-in flow.
  void performLoginFlow() async {
    print('Performing login flow...');
    await Future.delayed(const Duration(seconds: 1));

    // Navigate to the home screen once "signed in".
    openHome();
    print('Login flow completed, navigated to Home.');
  }

  /// Demo: sign in and jump into the main flow.
  void performLogin() async {
    // Navigate to the home screen once "signed in".
    openHome();

    // Optionally show notifications right away.
    await Future.delayed(const Duration(milliseconds: 300));
    openMessages();
  }

  /// Demo: open the profile with several different initial states.
  void demonstrateProfileNavigation() async {
    print('Demonstrating profile navigation with different initial states...');

    // Start with the profile home.
    openProfile();
    await Future.delayed(const Duration(seconds: 1));

    // Go back, then reopen it at the settings page.
    goBack();
    await Future.delayed(const Duration(milliseconds: 500));
    openProfileWithSettings();
    await Future.delayed(const Duration(seconds: 1));

    // And finally at the driver profile.
    goBack();
    await Future.delayed(const Duration(milliseconds: 500));
    openProfileWithDriverDetails();

    print('Profile navigation demonstration completed.');
  }
}
