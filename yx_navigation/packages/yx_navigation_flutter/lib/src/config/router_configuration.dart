import 'package:flutter/widgets.dart';
import 'package:yx_navigation/yx_navigation.dart';

import '../router/deeplink/deeplink_handler_observer.dart';
import '../router/yx_route_information_parser.dart';
import '../router/yx_route_information_provider.dart';

/// {@template router_configuration}
/// Groups [Router]-related parameters for `RouterSchema.build`.
///
/// Holds the information parser and provider used to parse incoming route
/// information, the [PlatformStateSerialization] used to encode the current
/// state back to the platform, the [BackButtonDispatcher] for system back
/// button handling, and the optional [DeeplinkHandlerObserver].
/// {@endtemplate}
@immutable
class RouterConfiguration {
  /// Parser that converts route information into the navigation state.
  final YxRouteInformationParser? informationParser;

  /// Provider that delivers platform route information to the router.
  final YxRouteInformationProvider? informationProvider;

  /// Serialization strategy used to encode the navigation state back to
  /// the platform.
  final PlatformStateSerialization serialization;

  /// Dispatcher used to handle the system back button.
  final BackButtonDispatcher? backButtonDispatcher;

  /// Observer notified about deeplink handling events.
  final DeeplinkHandlerObserver? deeplinkObserver;

  /// {@macro router_configuration}
  const RouterConfiguration({
    this.informationParser,
    this.informationProvider,
    this.serialization = const PrettyUriStateSerialization(),
    this.backButtonDispatcher,
    this.deeplinkObserver,
  });
}
