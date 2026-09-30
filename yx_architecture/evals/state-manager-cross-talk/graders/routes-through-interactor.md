---
type: llm
focus: last_message
---

PASS when the answer rejects injecting one state manager into another, and routes the coordination through an Interactor - second-order business logic that owns both state managers and changes them together.

FAIL when the answer accepts passing `AccountStateManager` into the `OrderStateManager` constructor, or suggests a stream subscription between the two managers, or proposes a shared singleton.

The mention of `StateManager does not depend on StateManager` as an explicit rule is a strong indicator of a pass, but a correct answer that routes through an Interactor without quoting the rule also passes.
