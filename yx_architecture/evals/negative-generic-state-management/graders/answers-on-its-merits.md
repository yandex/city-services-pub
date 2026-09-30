---
type: llm
focus: last_message
arm: both
---

PASS when the answer compares the libraries the user actually asked about and does not recommend yx_state, yx_scope or yx_navigation.

FAIL when the answer directs the user towards the yx_* stack, or answers in terms of `StateManager`, `handle`/`emit`, `ScopeContainer` - none of which the user has.

Mentioning that other options exist is fine; recommending an unavailable in-house stack as the answer is not.
