# Intellij IDEA / Android Studio

1. Go to IntelliJ IDEA > Settings (or IntelliJ IDEA > Preferences on macOS) to open the Settings.
2. In the Settings window, navigate to Editor > Live Templates.
3. Click Add (plus button), select Template Group and give it a name "yx_scope".
4. Select created group and click Add button one more time — select Live Template.
5. For each template below repeat the following steps
6. Add an Abbreviation (the title of the snippet below) and copy the snippet to the Template Text.
7. There is a text "No applicable contexts" — click "Define" and select Dart.

Now you can type abbreviations in any file of your project and apply the snippet by clicking Enter.

## scope

```dart
import 'package:meta/meta.dart';
import 'package:yx_scope/yx_scope.dart';

class $NAME$ScopeContainer extends ScopeContainer {
  // TODO deps
}

class $NAME$ScopeHolder extends ScopeHolder<$NAME$ScopeContainer> {
  @protected
  @override
  $NAME$ScopeContainer createContainer() => $NAME$ScopeContainer();
}
```

## scope_child

```dart
import 'package:meta/meta.dart';
import 'package:yx_scope/yx_scope.dart';

class $NAME$ScopeContainer extends ChildScopeContainer<$PARENTNAME$> {
  $NAME$ScopeContainer({required $PARENTNAME$ parent}) : super(parent: parent);

// TODO deps
}

class $NAME$ScopeHolder extends ChildScopeHolder<$NAME$ScopeContainer, $PARENTNAME$> {
  $NAME$ScopeHolder($PARENTNAME$ parent) : super(parent);

  @protected
  @override
  $NAME$ScopeContainer createContainer($PARENTNAME$ parent) =>
      $NAME$ScopeContainer(parent: parent);
}
```

## scope_data

```dart
import 'package:meta/meta.dart';
import 'package:yx_scope/yx_scope.dart';

class $NAME$ScopeContainer extends DataScopeContainer<$DATA$> {
  $NAME$ScopeContainer({required $DATA$ data}) : super(data: data);

// TODO deps
}

class $NAME$ScopeHolder extends DataScopeHolder<$NAME$ScopeContainer, $DATA$> {
  @protected
  @override
  $NAME$ScopeContainer createContainer($DATA$ data) => $NAME$ScopeContainer(data: data);
}
```

## scope_child_data

```dart
import 'package:meta/meta.dart';
import 'package:yx_scope/yx_scope.dart';

class $NAME$ScopeContainer extends ChildDataScopeContainer<$PARENTNAME$, $DATA$> {
  $NAME$ScopeContainer({
    required $PARENTNAME$ parent,
    required $DATA$ data,
  }) : super(parent: parent, data: data);

// TODO deps
}

class $NAME$ScopeHolder extends ChildDataScopeHolder<$NAME$ScopeContainer,
    $PARENTNAME$,
    $DATA$> {
  $NAME$ScopeHolder($PARENTNAME$ parent) : super(parent);

  @protected
  @override
  $NAME$ScopeContainer createContainer($PARENTNAME$ parent,
      $DATA$ data,) =>
      $NAME$ScopeContainer(parent: parent, data: data);
}
```

## dep

```dart

late final $NAME$Dep = dep(() => $INSTANCE$);
```

## dep_async

```dart

late final $NAME$Dep = asyncDep(() => $INSTANCE$);
```

## dep_raw_async

```dart

late final $NAME$Dep = rawAsyncDep(
      () => $INSTANCE$,
  init: (value) async {
    // init
  },
  dispose: (value) async {
    // dispose
  },
);
```

# VSCode

1. Go to File > Preferences > Configure Snippets.
2. Select "New global snippets file" or "New snippets file for [your project]"
3. Enter the name of the file
4. Copy and paste the entire code below
5. Save file

Now you can type keys from that json in any file of your project and apply the snippet by clicking
Enter.

```
{
	"scope": {
		"prefix": "scope",
		"body": [
			"import 'package:meta/meta.dart';",
			"import 'package:yx_scope/yx_scope.dart';",
			"",
			"class ${1:Name}ScopeContainer extends ScopeContainer {",
			"  // TODO deps",
			"}",
			"",
			"class ${1:Name}ScopeHolder extends ScopeHolder<${1:Name}ScopeContainer> {",
			"  @protected",
			"  @override",
			"  ${1:Name}ScopeContainer createContainer() => ${1:Name}ScopeContainer();",
			"}"
		],
		"description": "Template for scope"
	},
	"scope_child": {
		"prefix": "scope_child",
		"body": [
			"import 'package:meta/meta.dart';",
			"import 'package:yx_scope/yx_scope.dart';",
			"",
			"class ${1:Name}ScopeContainer extends ChildScopeContainer<${2:ParentName}> {",
			"  ${1:Name}ScopeContainer({required ${2:ParentName} parent}) : super(parent: parent);",
			"",
			"  // TODO deps",
			"}",
			"",
			"class ${1:Name}ScopeHolder",
			"    extends ChildScopeHolder<${1:Name}ScopeContainer, ${2:ParentName}> {",
			"  ${1:Name}ScopeHolder(${2:ParentName} parent) : super(parent);",
			"  @protected",
			"  @override",
			"  ${1:Name}ScopeContainer createContainer(${2:ParentName} parent) =>",
			"      ${1:Name}ScopeContainer(parent: parent);",
			"}"
		],
		"description": "Template for child scope"
	},
	"scope_data": {
		"prefix": "scope_data",
		"body": [
			"import 'package:meta/meta.dart';",
			"import 'package:yx_scope/yx_scope.dart';",
			"",
			"class ${1:Name}ScopeContainer extends DataScopeContainer<${2:Data}> {",
			"  ${1:Name}ScopeContainer({required ${2:Data} data}) : super(data: data);",
			"",
			"  // TODO deps",
			"}",
			"",
			"class ${1:Name}ScopeHolder extends DataScopeHolder<${1:Name}ScopeContainer, ${2:Data}> {",
			"  @protected",
			"  @override",
			"  ${1:Name}ScopeContainer createContainer(${2:Data} data) => ${1:Name}ScopeContainer(data: data);",
			"}"
		],
		"description": "Template for scope data"
	},
	"scope_child_data": {
		"prefix": "scope_child_data",
		"body": [
			"import 'package:meta/meta.dart';",
			"import 'package:yx_scope/yx_scope.dart';",
			"",
			"class ${1:Name}ScopeContainer",
			"    extends ChildDataScopeContainer<${2:ParentName}, ${3:Data}> {",
			"  ${1:Name}ScopeContainer({",
			"    required ${2:ParentName} parent,",
			"    required ${3:Data} data,",
			"  }) : super(parent: parent, data: data);",
			"",
			"  // TODO deps",
			"}",
			"",
			"class ${1:Name}ScopeHolder extends ChildDataScopeHolder<${1:Name}ScopeContainer,",
			"    ${2:ParentName}, ${3:Data}> {",
			"  ${1:Name}ScopeHolder(${2:ParentName} parent) : super(parent);",
			"  @protected",
			"  @override",
			"  ${1:Name}ScopeContainer createContainer(",
			"    ${2:ParentName} parent,",
			"    ${3:Data} data,",
			"  ) =>",
			"      ${1:Name}ScopeContainer(parent: parent, data: data);",
			"}"
		],
		"description": "Template for child data scope"
	},
	"dep": {
		"prefix": "dep",
		"body": [
			"late final ${1:Name}Dep = dep(() => ${2:Instance});"
		],
		"description": "Template for dependency"
	},
	"dep_async": {
		"prefix": "dep_async",
		"body": [
			"late final ${1:Name}Dep = asyncDep(() => ${2:Instance});"
		],
		"description": "Template for async dependency"
	},
	"raw_async_dep": {
		"prefix": "raw_async_dep",
		"body": [
			"late final ${1:Name}Dep = rawAsyncDep(",
			"  () => ${2:Instance},",
			"  init: (value) async {",
			"    // init",
			"    ${3:// Initialization logic here}",
			"  },",
			"  dispose: (value) async {",
			"    // dispose",
			"    ${4:// Disposal logic here}",
			"  },",
			");"
		],
		"description": "Template for raw async dependency with init and dispose"
	}
}
```