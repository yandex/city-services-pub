---
type: tool_used
tool: Skill
arm: both
min: 0
max: 0
---

None of the four skills may be triggered here. The prompt is loaded with the exact words that used to
be unconditional triggers in the `yx-state-fundamentals` description - `handle`, `emit`, and all four
strategy names - but the package under discussion is BLoC, and `sequential`, `restartable`,
`droppable`, `concurrent` are also the vocabulary of `package:bloc_concurrency`. Those words are a
trigger only together with yx_state or code that imports it.

`arm: both` is required here: without it the grader is treated as a with-plugin indicator and is
excluded from the score, which is the opposite of what a negative case needs.
