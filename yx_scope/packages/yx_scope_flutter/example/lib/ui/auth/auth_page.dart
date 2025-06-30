import 'package:flutter/material.dart';
import 'package:yx_scope_flutter/yx_scope_flutter.dart';

import '../../di/app/app_scope.dart';
import '../../domain/auth/models/account_params.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('login')),
        body: ScopeBuilder<AppScopeContainer>.withPlaceholder(
          builder: (context, appScope) {
            final authManager = appScope.authManagerDep.get;

            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Login'),
                  TextButton(
                    onPressed: () =>
                        authManager.login(AccountParams('login', 'pass')),
                    child: const Text('login'),
                  ),
                  TextButton(
                    onPressed: () => authManager.startRegister(),
                    child: const Text('start register'),
                  ),
                ],
              ),
            );
          },
        ),
      );
}
