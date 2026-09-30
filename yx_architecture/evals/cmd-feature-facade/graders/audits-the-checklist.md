---
type: llm
focus: last_message
---

The package breaks three facade rules: `SearchFeature` implements `SearchWidgetFactory` directly instead of `SearchOutputDeps`; the public `scopeHolder` getter exposes the internals; the `SearchScope` interface carries `widgetFactory`.

PASS when the answer is an audit: a checklist where each item is marked passed or failed with the evidence, failures listed before passes, at least two of the three violations found with a fix each, and a closing verdict on whether the facade is valid or needs restructuring.

FAIL when the answer designs a new facade instead of auditing this one, when fewer than two violations are found, or when there is no verdict.
