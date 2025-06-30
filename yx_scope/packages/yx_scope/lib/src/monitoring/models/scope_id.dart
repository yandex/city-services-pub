/// A ready-only unique identifier of a [ScopeContainer].
/// An instance of ScopeId is always the same for
/// the same [ScopeContainer] instance.
class ScopeId {
  final Type type;
  final int scopeHashCode;
  final String? name;

  const ScopeId(this.type, this.scopeHashCode, this.name);

  @override
  String toString() =>
      '${name ?? type}${name != null ? '[$type]' : ''}[$scopeHashCode]';
}
