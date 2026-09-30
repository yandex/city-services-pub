---
type: llm
focus: last_message
---

PASS when the answer solves the question inside what the project already uses: it places the
dependencies in a yx_scope container or module, and reasons about their lifetime against the user
session.

FAIL when the answer pushes the rest of the stack on the user - proposing yx_state instead of the
state solution they have, or replacing go_router with yx_navigation - without being asked. Naming a
package once as an aside is not a failure; recommending a migration is.
