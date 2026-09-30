---
schema_version: "1.1"
name: negative-generic-di
description: A plain dependency injection question about other packages must not trigger any skill of this stack.
tags: [negative, trigger]
runs: 3
max_turns: 10
timeout_seconds: 300
allowed_tools: [Read, Glob, Grep, Skill]
---

In a Flutter app, would you use get_it or provider for dependency injection? What are the
trade-offs between a service locator and passing dependencies down the widget tree?
