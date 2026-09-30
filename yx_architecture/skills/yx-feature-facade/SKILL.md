---
name: yx-feature-facade
description: Design or audit an embeddable feature module - the InputDeps, OutputDeps and WidgetFactory contracts, the internal scope, and the wiring into the host.
argument-hint: "[path to the feature package; empty means design a new one]"
allowed-tools: Read, Glob, Grep, Skill
user-invocable: true
disable-model-invocation: true
---

# Feature facade: design or audit

Target: `$ARGUMENTS` (when empty, design a new facade instead of auditing one).

Read `../yx-architecture/references/procedures/feature_facade.md` and follow it. That file is the
whole procedure: both modes, the contracts to produce, the nine-item checklist and the output
format. The same procedure answers a plain "design a feature module for me" - this command only
pins the target.
