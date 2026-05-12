import 'package:yx_navigation/yx_navigation.dart';

import 'profile_routes.dart';

/// Navigation interactor for the driver-profile section.
/// Holds navigation business logic with no Flutter dependencies.
///
/// RouteNodeStateManager is injected through the constructor, which improves
/// separation of concerns and makes the interactor easy to test.
class ProfileNavigationInteractor {
  final RouteNodeStateManager _stateManager;

  /// State-manager handle for the UI layer.
  RouteNodeStateManager get stateManager => _stateManager;

  /// Navigator exposed for business-logic calls.
  RouteNavigator get navigator => _stateManager;

  /// Accepts a prebuilt RouteNodeStateManager from the DI container.
  const ProfileNavigationInteractor({
    required RouteNodeStateManager stateManager,
  }) : _stateManager = stateManager;

  // ============================================================================
  // Navigation methods available to business logic.
  // ============================================================================

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

  /// Return to the profile home page.
  void goToHome() => navigator.popAll();
}
