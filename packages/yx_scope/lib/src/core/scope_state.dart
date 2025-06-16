abstract class ScopeState<Scope> {
  ScopeState._();

  factory ScopeState.none() = ScopeStateNone;
  factory ScopeState.initializing() = ScopeStateInitializing;
  factory ScopeState.available({required Scope scope}) = ScopeStateAvailable;
  factory ScopeState.disposing() = ScopeStateDisposing;

  bool get none => this is ScopeStateNone;

  bool get initializing => this is ScopeStateInitializing;

  bool get available => this is ScopeStateAvailable;

  bool get disposing => this is ScopeStateDisposing;
}

class ScopeStateNone<Scope> extends ScopeState<Scope> {
  ScopeStateNone() : super._();

  @override
  String toString() => 'ScopeState<$Scope>.none';
}

class ScopeStateInitializing<Scope> extends ScopeState<Scope> {
  ScopeStateInitializing() : super._();

  @override
  String toString() => 'ScopeState<$Scope>.initializing';
}

class ScopeStateAvailable<Scope> extends ScopeState<Scope> {
  final Scope scope;

  ScopeStateAvailable({required this.scope}) : super._();

  @override
  String toString() => 'ScopeState<$Scope>.available';
}

class ScopeStateDisposing<Scope> extends ScopeState<Scope> {
  ScopeStateDisposing() : super._();

  @override
  String toString() => 'ScopeState<$Scope>.disposing';
}
