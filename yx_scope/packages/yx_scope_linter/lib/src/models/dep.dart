import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:yx_scope_linter/src/types.dart';

class DepDeclaration {
  final FieldDeclaration field;
  final Token nameToken;
  final DartType type;
  final Set<String> dependencies;

  const DepDeclaration({
    required this.field,
    required this.nameToken,
    required this.type,
    required this.dependencies,
  });

  String get name => nameToken.lexeme;

  bool get isSync => depValueType.isExactlyType(type);

  bool get isAsync => asyncDepValueType.isExactlyType(type);
}
