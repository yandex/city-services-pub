import 'dart:math';

class IncomingOrder {
  static final _random = Random();

  final DateTime createdTime;
  final String uid;
  final Address fromAddress;
  final Address toAddress;

  IncomingOrder({
    required this.fromAddress,
    required this.toAddress,
  })  : createdTime = DateTime.now(),
        uid = _random.nextInt(100000).toString();
}

class Address {
  final String name;
  final int position;

  const Address({
    required this.name,
    required this.position,
  });
}
