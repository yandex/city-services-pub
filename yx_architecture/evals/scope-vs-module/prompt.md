---
schema_version: "1.1"
name: scope-vs-module
description: The canon answer is ScopeModule when the lifetime matches the parent, not a separate scope.
tags: [yx_scope, trigger]
runs: 3
max_turns: 10
timeout_seconds: 300
allowed_tools: [Read, Glob, Grep, Skill]
---

I have an app built on yx_scope. I want to add a separate ScopeContainer for the settings screen dependencies. They live exactly as long as AppScope does - the settings are read at startup and stay until the app is terminated. How should I set this up?
