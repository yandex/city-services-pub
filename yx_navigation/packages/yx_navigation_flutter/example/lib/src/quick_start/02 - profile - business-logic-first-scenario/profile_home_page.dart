import 'package:flutter/material.dart';
import 'package:yx_navigation_flutter/yx_navigation_flutter.dart';

/// {@template profile_home_page}
/// Driver-profile home page. Uses an outlet to host a nested navigator.
/// {@endtemplate}
class ProfileHomePage extends StatefulWidget {
  const ProfileHomePage({
    required this.title,
    this.outlet,
    super.key,
  });

  final String title;

  final Widget? outlet;

  @override
  State<ProfileHomePage> createState() => _ProfileHomePageState();
}

class _ProfileHomePageState extends State<ProfileHomePage> {
  @override
  Widget build(BuildContext context) {
    // Grab the navigator to drive page transitions.
    final routeNavigator = YxNavigation.navigatorOf(context);
    final canPop = routeNavigator.canPop();

    final parentRouteNavigator = YxNavigation.parentNavigatorOf(context);
    final canPopByParent = parentRouteNavigator.canPop();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: false,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        leadingWidth: 100,
        leading: SizedBox(
          height: 30,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              IconButton(
                tooltip: 'Back on the current navigator',
                iconSize: 22,
                icon: canPop
                    ? const Icon(Icons.arrow_back)
                    : const Icon(Icons.close),
                onPressed: canPop ? routeNavigator.pop : null,
              ),
              if (!canPop)
                IconButton(
                  tooltip: 'Back on the parent navigator',
                  iconSize: 22,
                  icon: canPopByParent
                      ? const Icon(Icons.arrow_back)
                      : const Icon(Icons.close),
                  onPressed: canPopByParent ? parentRouteNavigator.pop : null,
                ),
            ],
          ),
        ),
      ),
      body: widget.outlet,
    );
  }
}
