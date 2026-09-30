---
type: llm
focus: last_message
arm: both
---

PASS when the answer explains `Stream` and `Future` in their own terms - one value versus many, subscription, single-subscription versus broadcast, when each is appropriate.

FAIL when the answer introduces `StateManager`, `handle`, `emit`, `StateReadable` or any other concept from the yx_* stack, which the user never mentioned.
