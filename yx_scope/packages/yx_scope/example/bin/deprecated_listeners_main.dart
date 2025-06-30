import 'app_listener.dart';

/// This file will be deleted in the next major version
/// when Listeners will be completely removed
void main() async {
  final appScopeHolderWithListener = AppScopeHolderWithListener();

  await appScopeHolderWithListener.create();

  print(appScopeHolderWithListener.scope?.routerDelegateDep.get);

  await appScopeHolderWithListener.drop();

  print(appScopeHolderWithListener.scope?.routerDelegateDep.get);
}
