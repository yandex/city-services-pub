---
type: llm
focus: last_message
---

PASS when the answer rejects registering the ViewModel as a `dep`, and names the widget that shows the ViewModel as what creates it and disposes it - created in `initState` (or an equivalent place in the widget's lifecycle), disposed in `dispose`. The reason given has to be the lifetime: the ViewModel lives as long as the screen, which is shorter than the scope. Saying that the ViewModel stays pure Dart and takes interactors plus `StateReadable`s out of the scope supports a pass.

FAIL when the answer approves registering the ViewModel in the scope, or offers DI registration as an equally valid option without a caveat. Also FAIL when it invents a base class or a provider widget to own the ViewModel: the canon has neither, and inventing one means the advice cannot be followed.
