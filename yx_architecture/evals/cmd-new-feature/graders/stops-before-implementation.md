---
type: llm
focus: last_message
---

PASS when the public methods of the planned classes are only declared - a name, parameters and a
return type - and the answer says it stops before writing them.

FAIL when a method of the state manager, the view model or the api is written out with a body.

Dependency registration (`dep(...)`, `rawAsyncDep(...)`, `initializeQueue`) is wiring, not an
implementation of those methods: it does not fail the case. Neither does a route declaration.
