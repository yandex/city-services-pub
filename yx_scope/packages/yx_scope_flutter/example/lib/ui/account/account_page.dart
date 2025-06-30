import 'package:flutter/material.dart';
import 'package:yx_scope_flutter/yx_scope_flutter.dart';

import '../../di/account/account_scope.dart';
import '../../di/app/app_scope.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  @override
  Widget build(BuildContext context) =>
      ScopeBuilder<AppScopeContainer>.withPlaceholder(
        builder: (context, appScope) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ScopeBuilder<AccountScope>(
                  builder: (context, scope) {
                    return Text('account: ${scope?.account.name}');
                  },
                ),
                TextButton(
                  onPressed: () {
                    appScope.authManagerDep.get.logout();
                  },
                  child: const Text('logout'),
                ),
                TextButton(
                  onPressed: () {
                    appScope.authManagerDep.get.startRegister();
                  },
                  child: const Text('start register'),
                ),
              ],
            ),
          );
        },
      );
}
