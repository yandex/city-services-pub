import 'account_holder.dart';
import 'models/account.dart';
import 'register_state_holder.dart';

class RegisterManager {
  final AccountHolder _accountHolder;
  final RegisterHolder _registerStateHolder;

  RegisterManager(this._accountHolder, this._registerStateHolder);

  Future<void> createAccount() async {
    await _accountHolder.setAccount(Account('321', 'New Bob'));
    await _registerStateHolder.stopRegister();
  }
}
