enum TabbarPageType {
  map,
  orders,
  account;
}

class AppState {
  final bool hasAccount;
  final bool isOpenRegister;
  final TabbarPageType tabbarPage;

  const AppState._(
    this.hasAccount,
    this.isOpenRegister,
    this.tabbarPage,
  );

  const AppState.init()
      : hasAccount = false,
        isOpenRegister = false,
        tabbarPage = TabbarPageType.orders;

  AppState copyWith({
    bool? hasAccount,
    bool? isOpenRegister,
    TabbarPageType? tabbarPage,
  }) =>
      AppState._(
        hasAccount ?? this.hasAccount,
        isOpenRegister ?? this.isOpenRegister,
        tabbarPage ?? this.tabbarPage,
      );
}
