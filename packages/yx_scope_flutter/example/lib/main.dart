import 'package:flutter/material.dart';
import 'package:yx_scope/yx_scope.dart' hide ScopeObserver;
import 'package:yx_scope_flutter/yx_scope_flutter.dart';

import 'di/app/app_scope.dart';
import 'utils/logger.dart';

Future<void> main() async {
  ScopeObservatory.logger = const Logger();
  runApp(const App());
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  final _appScopeHolder = AppScopeHolder();

  @override
  void initState() {
    super.initState();
    _appScopeHolder.create();
  }

  @override
  void dispose() {
    _appScopeHolder.drop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScopeProvider(
      holder: _appScopeHolder,
      child: ScopeBuilder<AppScopeContainer>.withPlaceholder(
        builder: (context, appScope) {
          return MaterialApp.router(
            title: 'YxScopedFlutter Demo',
            theme: ThemeData(
              primarySwatch: Colors.blue,
            ),
            routerDelegate: appScope.routerDelegateDep.get,
          );
        },

        // Shows this widget while [appScopeHolder] is loading
        placeholder: const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
