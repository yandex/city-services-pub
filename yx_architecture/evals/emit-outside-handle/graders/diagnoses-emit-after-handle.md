---
type: llm
focus: last_message
---

PASS when the answer identifies the real cause: the `Timer.periodic` callback runs **after** `handle` has already finished, so `emit` is called outside its handler - which asserts in debug and is silently ignored in production.

The answer should also indicate the correct fix: the periodic work belongs in its own `handle` call per tick (or the subscription is stored and each tick calls a method that opens a new `handle`), and the timer must be cancelled in `close()`.

FAIL when the answer attributes the problem to something else - `copyWith`, immutability, a missing `await`, the polling interval - or when it only says "this is wrong" without naming the handle boundary.
