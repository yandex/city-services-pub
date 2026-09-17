# 1.1.0

- Added a debug assert for imperative `push`, `pushReplacement` and
  `pushAndRemoveUntil` issued while a route tree mutation has not reached
  `Navigator.pages` yet. Without `NavigatorCompatibilityOverrides` such a route
  stays pageless, and Flutter drops it together with the outgoing page -
  previously this happened with no diagnostics at all.
- Documented the boundary in `docs/compatibility_architecture.md`: why a
  pageless route is removed with the page it is tied to, that this is Flutter
  SDK behaviour rather than a yx_navigation defect, and what to do instead.

# 1.0.0

- Initial version.
