/// A ready-only meta info of created value in a [Dep].
class ValueMeta {
  final Type valueType;
  final int valueHashCode;

  const ValueMeta(this.valueType, this.valueHashCode);

  static ValueMeta? build(Object? object) =>
      object == null ? null : ValueMeta(object.runtimeType, object.hashCode);

  @override
  String toString() => '$valueType[$valueHashCode]';
}
