import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:yx_scope_linter/src/types.dart';

class DepDeclaration {
  final FieldDeclaration field;
  final Token nameToken;
  final DartType type;
  final BaseScopeDeclaration parent;
  final Map<String, DepDeclaration> deps = {};

  DepDeclaration({
    required this.field,
    required this.nameToken,
    required this.type,
    required this.parent,
  });

  String get name => nameToken.lexeme;

  void addDep(DepDeclaration dep) => deps[dep.name] = dep;

  bool get isSync => depValueType.isExactlyType(type);

  bool get isAsync => asyncDepValueType.isExactlyType(type);

  @override
  String toString() => name;
}

abstract class BaseScopeDeclaration {
  final ClassDeclaration node;

  final Map<String, DepDeclaration> deps = {};
  final Map<String, ModuleDeclaration> modules = {};

  BaseScopeDeclaration({required this.node});

  DartType get type => node.declaredElement!.thisType;

  addDep(DepDeclaration dep) => deps[dep.name] = dep;
  addModule(ModuleDeclaration module) => modules[module.name] = module;

  bool get isRoot => this is ScopeDeclaration;
  bool get isModule => this is ModuleDeclaration;
}

class ScopeDeclaration extends BaseScopeDeclaration {
  ScopeDeclaration({required super.node});
  final List<Set<DepDeclaration>> initializeQueue = [];

  void addScopeQueue() => initializeQueue.add({});
  void addDepToQueue(DepDeclaration dep) => initializeQueue.last.add(dep);

  @override
  String toString() => '';
}

class ModuleDeclaration extends BaseScopeDeclaration {
  final BaseScopeDeclaration parent;
  final Token? nameToken;

  ModuleDeclaration({
    required this.parent,
    required Token this.nameToken,
    required super.node,
  });

  String get name => nameToken?.lexeme ?? '';

  @override
  String toString() => '$parent$name.';
}
