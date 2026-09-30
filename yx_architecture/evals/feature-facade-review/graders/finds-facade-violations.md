---
type: llm
focus: last_message
---

The snippet breaks three rules at once. PASS when the review finds at least two of them:

1. `SearchFeature implements SearchWidgetFactory` directly - it must implement `SearchOutputDeps` and expose the factory through a `widgetFactory` getter.
2. The public `scopeHolder` getter exposes the internals - everything outward-facing goes through `SearchOutputDeps` only.
3. The `SearchScope` interface carries `widgetFactory` - the scope interface holds internal deps only.

FAIL when the review finds at most one of them, or spends the answer on unrelated style points without mentioning the leaks.
