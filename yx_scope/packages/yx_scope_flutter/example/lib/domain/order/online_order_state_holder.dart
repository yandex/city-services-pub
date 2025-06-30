abstract class OnlineOrderStateHolder {
  bool get isOnline;
  Stream<bool> get isOnlineStream;
  Future<void> toggle();
}
