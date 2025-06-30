/// A ready-only unique identifier of a [Dep].
/// An instance of DepId is always the same for
/// the same Dep instance.
class DepId {
  final Type valueType;
  final int depHashCode;
  final String? name;

  const DepId(this.valueType, this.depHashCode, this.name);

  @override
  String toString() =>
      '${name ?? valueType}${name != null ? '[$valueType]' : ''}[$depHashCode]';
}
