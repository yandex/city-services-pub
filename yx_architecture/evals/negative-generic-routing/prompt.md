---
schema_version: "1.1"
name: negative-generic-routing
description: Navigating without a BuildContext on go_router must not trigger the navigation skill of this stack.
tags: [negative, trigger]
runs: 3
max_turns: 10
timeout_seconds: 300
allowed_tools: [Read, Glob, Grep, Skill]
---

My app is on go_router. I need to open the documents screen from a bloc after a payment
succeeds, and there is no BuildContext there. How do I do that?
