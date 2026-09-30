---
schema_version: "1.1"
name: negative-plain-dart
description: A plain Dart language question is outside the scope of the skill and must not trigger it.
tags: [negative, trigger]
runs: 3
max_turns: 10
timeout_seconds: 300
allowed_tools: [Read, Glob, Grep, Skill]
---

Explain the difference between Stream and Future in Dart, and when to use each one.
