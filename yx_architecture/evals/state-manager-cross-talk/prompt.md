---
schema_version: "1.1"
name: state-manager-cross-talk
description: Coordination between two state managers goes through an Interactor, never by injecting one into the other.
tags: [yx_state, architecture]
runs: 3
max_turns: 10
timeout_seconds: 300
allowed_tools: [Read, Glob, Grep, Skill]
---

In my app, once an order is accepted, OrderStateManager needs to tell AccountStateManager to mark the account as busy. What is the right way to connect these two? Should I just pass AccountStateManager into the OrderStateManager constructor?
