---
schema_version: "1.1"
name: scope-only-app
description: A project that uses yx_scope with go_router must not be pushed towards the rest of the stack.
tags: [yx_scope, trigger]
runs: 3
max_turns: 10
timeout_seconds: 300
allowed_tools: [Read, Glob, Grep, Skill]
---

My app uses yx_scope for dependency injection and go_router for navigation, and I am happy with
both. I am adding a "saved searches" feature: a repository, one screen and a couple of things that
have to live as long as the user session. Where do I put those dependencies?
