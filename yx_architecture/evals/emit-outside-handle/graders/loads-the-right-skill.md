---
type: llm
focus: trace
---

PASS when the agent loads the `yx-state-fundamentals` skill before answering - look for a `Skill` tool call naming
it in the trace.

FAIL when no skill is loaded at all, or when a different skill of this stack is loaded instead:
the handle and emit lifetime rule belongs to the state package, so picking another one means a description is drawing the wrong questions.

Judge only which skill was loaded, not the quality of the answer; another grader covers that.
