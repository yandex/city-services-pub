import 'package:flutter/material.dart';
import 'package:yx_scope_flutter/yx_scope_flutter.dart';

import '../../di/app/app_scope.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  @override
  Widget build(BuildContext context) =>
      ScopeBuilder<AppScopeContainer>.withPlaceholder(
        builder: (context, appScope) => Scaffold(
          appBar: AppBar(
            title: const Text('Register'),
            leading: IconButton(
              onPressed: () {
                appScope.authManagerDep.get.stopRegister();
              },
              icon: const Icon(Icons.arrow_back),
            ),
          ),
          body: ScopeBuilder.withPlaceholder(
            holder: appScope.registerScopeHolderDep.get,
            builder: (context, registerScope) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Register New Bob'),
                  TextButton(
                    onPressed: () {
                      registerScope.registerManagerDep.get.createAccount();
                    },
                    child: const Text('Create'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}
