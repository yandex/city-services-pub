import 'account_holder.dart';
import 'models/account.dart';
import 'models/account_params.dart';
import 'register_state_holder.dart';

class AuthManager {
  final AccountHolder _accountHolder;
  final RegisterHolder registerStateHolder;

  AuthManager(this._accountHolder, this.registerStateHolder);

  Future<void> login(AccountParams loginParams) async {
    await _accountHolder.setAccount(Account('123', 'Bob'));
  }

  Future<void> logout() async {
    await _accountHolder.dropAccount();
  }

  Future<void> startRegister() async {
    await registerStateHolder.startRegister();
  }

  Future<void> stopRegister() async {
    await registerStateHolder.stopRegister();
  }
}
