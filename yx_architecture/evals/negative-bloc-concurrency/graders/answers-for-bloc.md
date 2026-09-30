---
type: llm
focus: last_message
arm: both
---

PASS when the answer stays in BLoC terms and names `restartable` from `package:bloc_concurrency` as
the transformer that cancels the running handler, passed through `EventTransformer` in the `on<Event>`
registration.

FAIL when the answer explains the four strategies as yx_state features, recommends `StateManager` or
`handle((emit) async {...})`, or suggests switching to the yx_* stack. The user has BLoC and asked
which of four names they already saw is the right one.

Naming `switchMap` or `restartable` without the package is not a failure by itself - the question is
whether the answer stays inside BLoC.
