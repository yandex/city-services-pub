---
type: llm
focus: last_message
---

Count how many of these three blocks the answer contains, after the decision record:

1. a folder tree for the feature;
2. a file list with class signatures - constructor parameters and public method names;
3. the route id together with the declaration factory to use.

PASS when the count is 3. FAIL otherwise. Report the count.

Ignore everything else: prose, notes about DI, remarks about what was deliberately left out.
