abstract class RegisterHolder {
  bool get inProgress;

  Stream<bool> get inProgressStream;

  Future<void> startRegister();

  Future<void> stopRegister();
}
