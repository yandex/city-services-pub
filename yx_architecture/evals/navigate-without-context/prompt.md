---
schema_version: "1.1"
name: navigate-without-context
description: Navigation from business logic goes through a NavigationController, with no BuildContext involved.
tags: [yx_navigation, blf]
runs: 3
max_turns: 10
timeout_seconds: 300
allowed_tools: [Read, Glob, Grep, Skill]
---

I need to open the documents screen from an interactor right after a payment succeeds. There is no BuildContext available there. How do I do this?
