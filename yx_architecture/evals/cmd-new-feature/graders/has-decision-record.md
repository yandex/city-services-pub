---
type: regex
target: last_message
pattern: "state:\\s*\\w+State\\s*\\{"
---

The decision record ends with a `state:` line that names the business state type and lists its fields, for example `state: OrderHistoryState { orders: List<Order>, ... }`. Without it the command did not run its first step.
