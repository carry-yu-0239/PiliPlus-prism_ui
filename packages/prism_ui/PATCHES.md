# Local Prism patch ledger

Frozen upstream: `5d8ed7ab674ed2011adf94a7e41aff6d705e9cb6`.

| Patch | Files | Purpose | Test / removal criterion |
| --- | --- | --- | --- |
| VP-01 (partial) | `lib/navigation_dock.dart` | `onReselected`, activation feedback, one foreground badge and merged semantics; drag returning to current identity is not a reselect | Run touch/keyboard/semantics/drag cancellation tests and verify no duplicate feedback before G1/G3. |
| VP-02 (partial) | `lib/motion_scope.dart`, `lib/context.dart`, `lib/prism_ui.dart` | Inherited reduce-motion and haptics policy, connected to contextual motion duration | Test runtime scope update and port remaining internal tickers/feedback. Remove if upstream provides equivalent scope. |
| VP-04 (partial) | `lib/liquid_glass.dart` | Idempotent non-blocking `ensureLoaded`, read-only renderer flag and loading/ready/failed state, reuses upstream loader | Test first-pane-free load, Off during load, terminal failure; profile counters not yet implemented. |
| VP-05 (partial) | `lib/theme_data.dart`, `lib/typography.dart` | Nullable absolute font weight overrides, existing Prism tiers untouched when null | Test body/header/custom and audit explicit component overrides. |
| VP-03 | `lib/measure.dart` | Support TextScaler and inherited text direction without breaking legacy constructor | Compare RTL/explicit direction and non-linear TextScaler in package tests; remove when upstream exposes equivalent. |

VP-07 has **not** yet been implemented. VP-01/02/04/05 are partial and may not satisfy G1. Keep all original spring descriptions and shaders unchanged; update this ledger when each patch gains automated and device evidence.
