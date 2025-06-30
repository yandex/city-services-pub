import 'package:yx_scope/yx_scope.dart';

import '../../domain/auth/register_manager.dart';
import '../../domain/auth/register_state_holder.dart';
import '../app/app_scope.dart';
import '../utils/listeners.dart';

class RegisterScopeContainer extends ChildScopeContainer<AppScopeContainer> {
  RegisterScopeContainer({required super.parent});

  late final registerManagerDep = dep(
    () => RegisterManager(
      parent.accountScopeHolderDep.get,
      parent.registerScopeHolderDep.get,
    ),
  );
}

class RegisterScopeHolder
    extends ChildScopeHolder<RegisterScopeContainer, AppScopeContainer>
    implements RegisterHolder {
  RegisterScopeHolder(super.parent)
      : super(
          scopeObservers: [diObserver],
          depObservers: [diObserver],
          asyncDepObservers: [diObserver],
        );

  @override
  RegisterScopeContainer createContainer(parent) =>
      RegisterScopeContainer(parent: parent);

  @override
  bool get inProgress => scope != null;

  @override
  Stream<bool> get inProgressStream => stream.map((scope) => scope != null);

  @override
  Future<void> startRegister() async => await create();

  @override
  Future<void> stopRegister() async => await drop();
}
