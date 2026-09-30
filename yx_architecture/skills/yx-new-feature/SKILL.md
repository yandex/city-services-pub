---
name: yx-new-feature
description: Plan a new feature in the yx_architecture canon - pick the Data-Domain boundary, decide between a scope, a ScopeModule or neither, define the single business state, and lay out the five layers and the route.
argument-hint: "[feature-name] [one-line description of what it does]"
allowed-tools: Read, Glob, Grep, Skill
user-invocable: true
disable-model-invocation: true
---

# Plan a new feature

Feature name: `$0` (snake_case). What it does: `$ARGUMENTS`.

Read `../yx-architecture/references/procedures/new_feature.md` and follow it. That file is the whole
procedure: the pre-flight checklist, the single business state, the layer layout and the exact shape
of the output. The same procedure answers a plain "how do I lay out this feature" - this command
only pins the name and the description.

If either the name or the description is missing, ask for it before planning.
