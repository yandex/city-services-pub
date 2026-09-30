---
schema_version: "1.1"
name: negative-bloc-concurrency
description: The words handle, emit and the four strategy names are shared with bloc_concurrency and must not trigger the yx_state skill on their own.
tags: [negative, trigger]
runs: 3
max_turns: 10
timeout_seconds: 300
allowed_tools: [Read, Glob, Grep, Skill]
---

In my BLoC I have a handler that does an `emit` after an await. Right now a second call just queues up
behind the first one. How do I make the new call cancel the one already running instead? I have seen
`sequential`, `restartable`, `droppable` and `concurrent` mentioned somewhere - which one is that?
