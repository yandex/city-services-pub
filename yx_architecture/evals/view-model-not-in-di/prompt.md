---
schema_version: "1.1"
name: view-model-not-in-di
description: A ViewModel is never registered in DI - the widget that shows it creates it and disposes it.
tags: [view_model, di]
runs: 3
max_turns: 10
timeout_seconds: 300
allowed_tools: [Read, Glob, Grep, Skill]
---

Where should my ViewModel be created? I was going to register it as a dep in the ScopeContainer right next to the StateManager, so the widget can get it from the scope. Is that the right approach?
