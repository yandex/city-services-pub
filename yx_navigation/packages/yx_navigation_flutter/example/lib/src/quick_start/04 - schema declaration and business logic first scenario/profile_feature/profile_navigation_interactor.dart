import 'package:yx_navigation/yx_navigation.dart';

import 'profile_routes.dart';

/// Navigation interactor for the driver-profile feature.
/// Holds navigation business logic with no Flutter dependencies.
///
/// Supports two modes:
/// 1. Standalone - receives a RouteNodeStateManager and acts as the root navigator
/// 2. Embedded - receives a NavigationController.node and operates on a subtree
///
/// Dependency injection keeps it flexible and easy to test.
class ProfileNavigationInteractor {
  final NavigationController _navigationController;

  /// Navigator for business-logic calls inside the profile feature.
  RouteNavigator get navigator => _navigationController;

  /// Accepts a prebuilt NavigationController from the DI container.
  /// This can be either a RouteNodeStateManager (standalone) or a
  /// NavigationController.node (embedded).
  ProfileNavigationInteractor({
    required NavigationController navigationController,
  }) : _navigationController = navigationController;

  // ============================================================================
  // Navigation methods for the profile feature's business logic.
  // ============================================================================

  /// Open the profile home page.
  void openHome() => navigator.push(ProfileRoutes.home);

  /// Open the driver profile page.
  void openDriverProfile() => navigator.push(ProfileRoutes.driverProfile);

  /// Open trips history.
  void openTripsHistory() => navigator.push(ProfileRoutes.tripsHistory);

  /// Open statistics.
  void openStatistics() => navigator.push(ProfileRoutes.statistics);

  /// Open settings.
  void openSettings() => navigator.push(ProfileRoutes.settings);

  /// Open documents.
  void openDocuments() => navigator.push(ProfileRoutes.documents);

  /// Return to the previous screen.
  void goBack() => navigator.maybePop();

  /// Can we go back?
  bool canPop() => navigator.canPop();

  /// Return to the root of the profile feature (profile home in embedded mode).
  void goToProfileHome() => navigator.popAll();
}
