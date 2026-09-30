# Evals

Behaviour tests for the four skills of this stack: the `yx-architecture` canon with its three
commands, and the three skills that ship inside the packages.

## How to run

```
python3 evals/run.py
python3 evals/run.py --case scope-vs-module --runs 1 --ablation none
python3 evals/run.py --threshold 0.8 -j 4
```

**Always through `run.py`, not `claude plugin eval` directly.** The runner loads exactly one plugin
into the sandbox, and a plugin may only reference files inside its own directory, while the package
skills live in the packages. The script assembles a throwaway bundle - this plugin plus
`yx-scope-fundamentals`, `yx-state-fundamentals` and `yx-navigation-fundamentals` - and runs the
cases against it, so every case is judged with the same set of skills a real project has. Results
land in `evals/results/`, which is ignored by git.

Running `claude plugin eval .` by hand loads the canon alone; the cases that expect a package skill
fail, and that failure says nothing about the skills.

## What is here

| Case | Skill under test | Checks |
|---|---|---|
| `scope-vs-module` | yx-scope-fundamentals | a `ScopeModule` is chosen over a separate scope when the lifetime matches the parent |
| `scope-only-app` | yx-scope-fundamentals | a project on yx_scope and go_router is answered within the stack it already uses, without being pushed towards the rest |
| `emit-outside-handle` | yx-state-fundamentals | an `emit` escaping its handler through a timer callback is diagnosed correctly |
| `navigate-without-context` | yx-navigation-fundamentals | navigation from an interactor happens without a `BuildContext`, and is not awaited |
| `state-manager-cross-talk` | yx-architecture | coordination between two state managers is routed through an Interactor |
| `view-model-not-in-di` | yx-architecture | a ViewModel is kept out of DI, created and disposed by its widget |
| `feature-facade-review` | yx-architecture | leaks past `OutputDeps` are caught |
| `negative-generic-di` | none may fire | get_it versus provider is not a question for this stack |
| `negative-generic-routing` | none may fire | navigating from a bloc on go_router is close to the trigger boundary and must stay outside it |
| `negative-generic-state-management` | none may fire | a plain Flutter state management question |
| `negative-plain-dart` | none may fire | a plain Dart language question |
| `negative-bloc-concurrency` | none may fire | `handle`, `emit` and the four strategy names are shared with `bloc_concurrency`, so they are a trigger only next to yx_state |
| `cmd-new-feature` | the command | produces the decision record, the tree, the signatures and the route, and stops before implementation |
| `cmd-review` | the command | finds at least three of four planted violations, reports them as a table, and loads the package catalogs it needs instead of inventing them |
| `cmd-feature-facade` | the command | audits a package against the nine-item checklist, failures first, with a verdict |

## How to read the results

**Look at the delta, not at the score.** Every case runs twice, with the skills and without them. A
case that scores high with a delta near zero is testing what the model already knows.

The negative cases work the other way around: there the delta should be near zero and both arms
should pass. They exist to catch a description that has grown too broad.

**Suggested threshold: `--threshold 0.8`.** The `llm` graders are noisy, and a threshold of 1.0
makes normal variance fail the run.

## Which skill fired

Cases that test triggering carry a `loads-the-right-skill` grader: it reads the trace and checks
**which** skill was loaded, not merely that one was. The `cmd-*` cases and `scope-only-app` judge
the answer instead - there the question is what the command produced, not which skill it reached
for. With four skills installed at once that is the
interesting question: a DI question has to reach `yx-scope-fundamentals`, not the canon, and the
canon has to stay out of questions that belong to a single package.

The negative cases use `tool_used: Skill` with `arm: both` and `min: 0`, `max: 0` instead - there
the point is that nothing fires at all.

## Pitfalls

- `runs` defaults to 3 deliberately: a single run of the same case can vary between 0.0 and 1.0.
- `max_turns` has to leave room to load a skill, read a reference and only then answer. Three turns
  is not enough; the skill cases use ten, the command cases 20 to 30, because a command loads a
  package skill on top of its own references.
- A grader criterion describes who does what, not which words appear. Requiring a specific phrasing
  fails correct answers; so does forbidding a name that a correct answer may mention while
  explaining another layer.
- Each run starts in an empty working directory, so any code to review is inlined into the prompt.
- The default judge model misreads long table answers. On the `cmd-*` cases either pass
  `--judge-model sonnet`, or keep the criteria short and countable - `cmd-review` asks the judge to
  count how many of four planted violations were reported, nothing more.
- **`cmd-new-feature` is the noisiest case in the suite.** Its answer runs to eight thousand
  characters, and repeated runs of the same unchanged command have scored between 0.56 and 0.89
  with a strong judge. Read its delta, not its score: the delta has stayed between +0.50 and +0.75
  across every run. Splitting a criterion into smaller countable ones helps; chasing the last tenth
  of the score does not.

## When a skill changes

Any edit to a `SKILL.md` - especially to `description`, which is what drives triggering - should be
measured before and after. Triggering is now a choice between four skills, so a description that
grows too broad does not only fire when it should not, it also shadows the skill that should have
answered.
