import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';

import 'types.dart';

/// Utility class for working with class declarations and elements
class ClassUtils {
  /// Checks if a class implements the specified interface by name
  static bool implementsInterface(ClassElement element, String ancestorName) =>
      element.interfaces
          .map((e) => e.getDisplayString())
          .contains(ancestorName);

  /// Determines if a class declaration is a scope container
  static bool isScopeContainer(ClassDeclaration node) {
    final element = node.declaredElement;
    return element != null
        ? baseScopeContainerType.isAssignableFrom(element)
        : false;
  }

  /// Gets all non-static field declarations from a class
  static Iterable<FieldDeclaration> getInstanceFields(ClassDeclaration node) {
    return node.members
        .whereType<FieldDeclaration>()
        .where((element) => !element.isStatic);
  }

  /// Gets all non-static method declarations from a class
  static Iterable<MethodDeclaration> getInstanceMethods(ClassDeclaration node) {
    return node.members
        .whereType<MethodDeclaration>()
        .where((element) => !element.isStatic);
  }

  const ClassUtils._();
}
