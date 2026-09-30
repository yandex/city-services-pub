---
schema_version: "1.1"
name: cmd-new-feature
description: The new-feature command produces a decision record, a folder tree, class signatures and the route, and stops before implementation.
tags: [command, new-feature]
runs: 3
max_turns: 20
timeout_seconds: 400
allowed_tools: [Read, Glob, Grep, Skill]
---

/yx-architecture:yx-new-feature order_history "shows the list of completed orders"
