---
type: llm
focus: trace
---

The planted violations span three catalogs: the layer rule lives in the `yx-architecture` skill, the
handle and emit rule in `yx-state-fundamentals`, the DI rules in `yx-scope-fundamentals`.

PASS when the trace shows the command reaching the package catalogs at all - a `Skill` call naming
one of the fundamentals skills, or a `Read` of a file under one of their `references/` directories.
Either route is fine; what matters is that the catalog was opened.

FAIL when neither happens while findings about DI or about handle and emit are still reported: that
means the command recited catalog entries from memory.

Judge only what the trace shows, not the findings themselves.
