---
type: llm
focus: last_message
---

PASS when the answer recommends a `ScopeModule` instead of a separate scope, and explains the criterion: a separate scope is justified only when the group of dependencies has start and end conditions of its own, and here the lifetime matches the parent.

FAIL when the answer recommends creating a separate `ScopeContainer` with its own `ScopeHolder`, or when it stays neutral and never names `ScopeModule`.

Do not require any particular code layout - the decision and the reason behind it are what matter.
