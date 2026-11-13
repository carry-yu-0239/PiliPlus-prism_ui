# Local Prism patch ledger

Frozen upstream: `5d8ed7ab674ed2011adf94a7e41aff6d705e9cb6`.

| Patch | Files | Purpose | Test / removal criterion |
| --- | --- | --- | --- |
| VP-02 (partial) | `lib/motion_scope.dart`, `lib/context.dart`, `lib/prism_ui.dart` | Inherited reduce-motion and haptics policy, connected to contextual motion duration | Test runtime scope update and port remaining internal tickers/feedback. Remove if upstream provides equivalent scope. |
| VP-03 | `lib/measure.dart` | Support TextScaler and inherited text direction without breaking legacy constructor | Compare RTL/explicit direction and non-linear TextScaler in package tests; remove when upstream exposes equivalent. |

VP-01, VP-04, VP-05 and VP-07 have **not** yet been implemented. Do not claim P1 gate on this ledger alone. Original spring and shader constants remain unchanged.
