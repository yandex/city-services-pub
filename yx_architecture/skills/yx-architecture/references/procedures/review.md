# Procedure: review code against the canon

Follow this when the user asks for a review of Dart/Flutter code written on the yx stack, whether
they said it in prose or ran `/yx-architecture:yx-review`.

**Do not report on which skills are installed when they all are.** Mention a missing companion skill
only where its absence changes the answer, and keep it to one line.

## Reading budget

The `yx-architecture` skill sets a budget of two reference files per answer. **A review deliberately
exceeds it.** The antipattern catalogs are spread over five files in four different skills, and
reading only two of them means silently skipping most of the checks. Read every catalog that applies
to the target.

## What to read

Always:

- `../architecture/recipes.md` - the antipattern catalog (12 entries) and the note on accessing a
  StateManager directly.

Then, depending on what the target actually contains. Three of the catalogs live in the skills that
ship with the packages themselves; load such a skill through the Skill tool before using its
catalog:

| The target has | Also read |
|---|---|
| `ScopeContainer`, `ScopeHolder`, `dep(`, `asyncDep(` | the `yx-scope-fundamentals` skill, `references/flutter_recipes.md` (10 antipatterns, the linter section) |
| `StateManager`, `handle(`, `emit(` | the `yx-state-fundamentals` skill, `references/flutter_recipes.md` (10 antipatterns) |
| `RouteNode`, `RouterSchema`, `RouteDeclaration`, `push(`, `pop(` | the `yx-navigation-fundamentals` skill, `references/recipes.md` (9 antipatterns) |
| a class implementing `StateReadable` in `presentation/`, a view object, a ViewModel | `../view_model/recipes.md` (12 antipatterns) |
| a path that looks like `*_feature` | `../feature_facade/overview.md` (the review and migration checklist) |

**When a package skill is not installed**, its catalog is unavailable - do not guess its contents
from memory. Review what you can, and name the missing catalog in the Checked line of the output
together with the command that installs it: `fvm dart run skills@ get --agent <agent>`.

## How to review

1. Determine the layer of every file from its path and its imports: `data/`, `domain/`,
   `presentation/`, `di/`, `shared/`.
2. Check the dependency flow first - it is the simplest and most valuable check. Presentation must
   not import Data. Domain and ViewModel must not import Flutter.
3. Go through the applicable catalogs entry by entry. Do not invent rules that are not in the
   references.
4. For every finding, quote the exact line and name the catalog entry it violates.

## Output

A table sorted by severity, highest first:

| File:line | Catalog and number | What is wrong | How to fix |
|---|---|---|---|

Severity order: a broken dependency flow, then a correctness bug (an `emit` outside `handle`, a
missing `close()`, an `asyncDep` missing from `initializeQueue`), then a structural violation, then
style.

If nothing is found, state it explicitly and list which catalogs you checked - a silent pass is
indistinguishable from a review that never ran.

## Example output

| File:line | Catalog and number | What is wrong | How to fix |
|---|---|---|---|
| `lib/domain/polling_state_manager.dart:14` | yx_state #1 | `emit` is called from a `Timer.periodic` callback, after `handle` has finished | make every tick its own `handle` call and cancel the timer in `close()` |
| `lib/presentation/order_view_model.dart:3` | architecture #5 | `import 'package:flutter/material.dart'` in a ViewModel | move the widget code to the screen, keep the ViewModel pure Dart |
| `lib/di/app_scope_container.dart:27` | yx_scope #7 | `_cacheDep` is an `asyncDep` but is missing from `initializeQueue` | add it to the set after `_databaseDep` |

Checked: architecture, yx_scope, yx_state, view model. Not applicable: yx_navigation (no routes in
the target), feature facade (not a feature package). Not available: none.

When a catalog could not be read, that last line carries it instead, for example: Not available:
yx_state (the `yx-state-fundamentals` skill is not installed; `fvm dart run skills@ get --agent
<agent>` adds it).

Every row quotes a real line, names one catalog entry, and gives a fix the reader can apply without
opening the reference.
