import 'package:flutter/widgets.dart';

class Provider<T> extends InheritedWidget {
  final T data;
  const Provider({
    required super.child,
    required this.data,
    super.key,
  });

  static T of<T>(BuildContext context, {bool listen = true}) {
    final provider = listen
        ? context.dependOnInheritedWidgetOfExactType<Provider<T>>()
        : (context
            .getElementForInheritedWidgetOfExactType<Provider<T>>()
            ?.widget as Provider<T>?);

    if (provider == null) {
      throw NotFoundProviderException();
    } else {
      return provider.data;
    }
  }

  @override
  bool updateShouldNotify(Provider<T> oldWidget) => oldWidget.data != data;
}

class NotFoundProviderException implements Exception {}
