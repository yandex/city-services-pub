import 'package:custom_lint_builder/custom_lint_builder.dart';

extension LintCodeCopyWith on LintCode {
  LintCode copyWith({String? problemMessage, String? correctionMessage}) =>
      LintCode(
        name: name,
        problemMessage: problemMessage ?? this.problemMessage,
        correctionMessage: correctionMessage ?? this.correctionMessage,
        uniqueName: uniqueName,
        url: url,
        errorSeverity: errorSeverity,
      );
}
