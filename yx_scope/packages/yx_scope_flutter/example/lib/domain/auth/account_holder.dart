import 'models/account.dart';

abstract class AccountHolder {
  Account? get account;

  Stream<Account?> get accountStream;

  Future<void> setAccount(Account account);

  Future<void> dropAccount();
}
