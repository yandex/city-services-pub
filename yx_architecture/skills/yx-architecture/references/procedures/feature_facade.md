# Procedure: design or audit a feature facade

Follow this when the user asks about an embeddable feature module - its `InputDeps`, `OutputDeps`
and `WidgetFactory` contracts, its internal scope, or its wiring into a host - whether they said it
in prose or ran `/yx-architecture:yx-feature-facade`.

**Do not report on which skills are installed when they all are.** Mention a missing companion skill
only where its absence changes the answer, and keep it to one line.

Read `../feature_facade/overview.md` in full - this procedure is built on it.

Two topics live in the package skills rather than here. When the scope interfaces need work, load
the `yx-scope-fundamentals` skill and read its `references/advanced.md`; if that skill is not
installed, say so and suggest `fvm dart run skills@ get --agent <agent>`. When the feature has
navigation of its own, load the `yx-navigation-fundamentals` skill and read its
`references/isolation.md`; if that skill is not installed, say so and suggest `fvm dart run skills@
get --agent <agent>`.

## Mode A: no path, or a package with no `XxxFeature` yet - design it

Work through the contract table and the seven-step checklist from the reference.

1. Ask what the feature needs from the host and what it exposes. Without those two answers the
   contracts cannot be designed - do not guess them.
2. Produce `XxxInputDeps`, `XxxOutputDeps`, `XxxWidgetFactory` and any narrow interactor interfaces,
   as Dart signatures.
3. Produce the internal DI: `XxxScope`, `XxxScopeContainer`, `XxxScopeHolder`. The scope interface
   holds only internal deps.
4. Produce `XxxFeature implements XxxOutputDeps`.
5. Show the host-side wiring: the `rawAsyncDep` entry, the `initializeQueue` entry, and where
   `widgetFactory` is called from the `RouterSchema`.

Skip `XxxOutputDeps` entirely when the feature exposes nothing - do not invent an empty interface.

## Mode B: an existing package - audit it

Go through the review and migration checklist from the reference, all nine items, and report each
one as passed or failed with the evidence.

Pay particular attention to the three that are violated most often:

- something is exposed outside of `XxxOutputDeps` - a public getter, an `as` cast, or `XxxFeature`
  implementing `XxxWidgetFactory` directly;
- the `XxxScope` interface carries `widgetFactory` or another outward-facing contract;
- `pubspec.yaml` depends on another `*_feature` package.

## Output

Mode A: the contracts as Dart code, then the host wiring, then the checklist with every item already
satisfied by construction.

Mode B: a checklist where each of the nine items is marked passed or failed, failures first, each
with `file:line` and the fix. Then a short verdict: is this a valid facade, or does it need
restructuring.

## Example output (mode B)

| # | Check | Result | Evidence and fix |
|---|---|---|---|
| 2 | Exposes only through `XxxOutputDeps` | failed | `search_feature.dart:12` - `SearchFeature implements SearchWidgetFactory` directly. Implement `SearchOutputDeps` and expose `widgetFactory` through a getter |
| 3 | `XxxScope` holds internal deps only | failed | `search_scope.dart:5` - `widgetFactory` is declared in the scope interface. Move it to `SearchOutputDeps` |
| 1 | One `XxxFeature` with `init()` and `dispose()` | passed | `search_feature.dart:8` |
| 4 | `widgetFactory` is a `late final` field | passed | `search_feature.dart:20` |
| ... | remaining items in the same form | ... | ... |

Verdict: not a valid facade yet. Two contracts leak past `OutputDeps`; both fixes are local to the
two lines above, no restructuring of the scope is needed.

Failures come first so the reader sees the work before the confirmation. In mode A the same table
appears at the end with every row passed, because the contracts were built from the checklist.
