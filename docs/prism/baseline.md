# P0 frozen baseline (R01 / T01)

> Source: `spec.md` §§2, 5, 12 and P0. This is a source inventory, not a successful build report.

| Source | Immutable revision |
|---|---|
| PiliPlus application | `cab0114a21ce7fad5b90b9a4d788d35d313d25f9` |
| Prism UI to vendor | `5d8ed7ab674ed2011adf94a7e41aff6d705e9cb6` |
| FlClash reference | `be84736605527034689c95bf27828ff27d912c5e` |
| FlClash Prism gitlink | `63450c0ac0e8e1b2c0f3ed4ad7926dc94e083185` |
| Flutter SDK | `3.47.9` from `.fvmrc` and `pubspec.yaml` |
| Application version | `2.2.0+1` |

The implementation branch `feat/prism-p0-foundation` begins at the documentation branch `docs/prism-ui-spec-20261111` (commit `0ff65c68814e1f751328d768e889303f051f43a8`); application code is based on `cab0114a`. The specification merge into `main` is tracked in PR #1.

## Lockfile and controlled dependencies

`pubspec.lock` at application baseline is Git blob `4726433677fe1ef9217b3d43a399becc24e26f64`.

| Dependency | Locked version / resolved Git revision |
|---|---|
| `material_ui` | hosted 1.10.0 (patched) |
| `cupertino_ui` | hosted 1.1.6 (patched for iOS) |
| `get` | 4.7.2, `3e65da893d9736135b2631a39e46c8f5388c2536` |
| `flutter_smart_dialog` | 5.3.0, `5a1be84314e8c53efa3b7324cd8dc535fefe931a` |
| `media_kit` | 1.1.11, `73771ec38176be2d984a3049c28177bce23b54a0` |
| `media_kit_video` | 1.2.5, `85f0a69ea66b100882b27a3375c72e5155375343` |

All Git dependencies remain locked by `pubspec.lock`. A later Prism dependency solve must compare the entire lockfile and reject unrelated resolved-ref drift.

## SDK and pub-cache patch chain

`lib/scripts/patch.ps1 android` runs after installing Flutter and before analyze/tests/build. It applies Flutter framework patches (selection, text, scrolling, modal, navigator, layout, sheets, etc.), runs `flutter pub get`, and patches hosted `material_ui` in the pub cache. The Android branch executes `git reset --hard HEAD` **inside the Flutter SDK checkout**. Its package path lookup uses `~/.pub-cache`; the CI explicitly isolates HOME and PUB_CACHE together so the patch does not target a developer cache. No release signing, tags or release publishing are used.

The CI records Flutter/Dart/engine, the SDK Git HEAD, lockfile hash, patch output and modified SDK status. Baseline failures are to be recorded verbatim, not hidden by dependency upgrades.

## Media capture / layer risk (P0-05, P8-01)

| Surface | Known implementation / source | Risk and initial policy |
|---|---|---|
| VOD and video-card player | `lib/pages/video/` and `media_kit_video` locked fork | Texture/native rendering may not be replayable by Prism's `_Replay._walk`; no glass capture until platform layer trace |
| Live playback | `lib/pages/live_room/` | Same unsafe-video lease; verify independently of VOD |
| Picture viewer and Live Photo | image/gallery viewer and `live_photo_maker` | Animated/video-backed layer may be visible outside `/video`; register actual surface, not route name |
| Embedded WebView/captcha/payment | `flutter_inappwebview` and platform-view entry points | PlatformViewLayer not handled by Prism replay; suppress capture during visibility and transitions |
| Player side/persistent sheets | `lib/common/widgets/scaffold/bottom_sheet.dart` and player UI | Preserve local history, gesture arena and scroll ownership; do not wholesale replace with SnapSheet |

These are **source-level risks**, not measured TextureLayer/PlatformViewLayer results. Runtime renderer/layer traces remain P8 work. Windows/Linux currently disable Impeller and are not declared to support full refraction.

## Evidence pending

- P0-02/P0-03/P0-04/P0-06: isolated Actions SDK/patch/analyze/test/build logs.
- P0-05: inspect the locked media renderer at exact SHA, then compare with runtime layer traces.
- P0-11–P0-14: actual screenshots, gestures and Android profile baseline; no device evidence yet.
- G0: **not passed** until the original application builds reproducibly and the surface inventory is complete.
