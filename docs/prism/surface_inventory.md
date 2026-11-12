# Prism surface migration inventory (P0-09 / P0-10)

> Stable IDs refer to business entry points. Source paths and callbacks were checked against PiliPlus baseline `cab0114a`. This is the initial **targeted** inventory; repository-wide rg coverage and manual baseline recordings remain open. Never treat an unlisted entry as implicitly migrated.

| ID | Entry / source | Existing trigger, callback and result | State / navigator / scroll owner | Planned ownership |
|---|---|---|---|---|
| NAV-01 | `lib/pages/main/view.dart` bottom floating/Material navigation | `onDestinationSelected: MainController.setIndex`; same-item reselect/double-tap refresh | `MainController.selectedIndex`, `navigationBars`, `PageController` or `TabController`; root pages | P3 Prism Dock adapter; preserve reorder/delete/single-item, badges, haptics and hide |
| NAV-02 | `lib/pages/main/view.dart` Drawer and NavigationRail | `onDestinationSelected: setIndex` | `useSideBar`, current index and configured order; main root | P3 preserve existing side navigation; no forced Dock |
| NAV-03 | `lib/pages/main/controller.dart` `setIndex` | first selection jumps/animates; repeat scrolls top; rapid repeat refreshes | Home/Dynamics controllers, `EasyThrottle`, `Pref.mainTabBarView` | P3/P4 adapt visual motion, keep business events and page identities |
| NAV-04 | `lib/models/common/nav_bar_config.dart` | three enum destinations with Material icons and page widgets | `NavigationBarType` plus stored `navBarSort` | P3 Glyph mapping without changing enum identity |
| BTN-01 | `lib/pages/main/view.dart` search action | `onPressed: Get.toNamed('/search')` | GetX root Navigator | P5 Prism elastic action; preserve named route |
| MENU-01 | `lib/common/widgets/video_popup_menu.dart` | `PopupMenuButton` itemBuilder, actions copy BVID, watch later, AI summary, visit member, dislike | `Accounts`, `Pref.enableAi`, network and `SmartDialog`; menu Navigator and nested dialogs | P5 typed popup adapter; exactly-once network/callback, keep conditional items |
| MENU-02 | `lib/pages/setting/widgets/popup_item.dart` | `onTapUp` → `showMenu<T>`; selected value delivered only when non-null and changed | caller's Navigator, `PopupListTile<T>` local refresh and preference owner | P5 typed popup; preserve `initialValue`, focus=false, cancellation and equality guard |
| DLG-01 | `lib/common/widgets/video_popup_menu.dart` AI summary | after async summary `showDialog` and `AiConclusionPanel` | mounted context and caller Navigator | P6 Alert candidate only after preserving async/mounted behavior |
| DLG-02 | `lib/common/widgets/video_popup_menu.dart` dislike reasons | `showDialog(SimpleDialog)`; reason action `Get.back`, loading, API and optional `onRemove` | nested menu/dialog, `SmartDialog`, network and business state | P6 preserve callback order and dangerous action semantics |
| DLG-03 | `lib/common/widgets/video_popup_menu.dart` dislike undo | FilledButton → async `feedDislikeCancel` → toast → `Get.back` | same dialog Navigator and loading overlay | P6 keep result, failure and dismissal behavior |
| SHEET-01 | `lib/common/widgets/scaffold/bottom_sheet.dart` | custom `BottomSheet_`, drag only within top 45 logical pixels | caller-owned builder/scroll controller, vertical drag recognizer and Navigator | P7 **retain** custom base; only individually approved ordinary sheets migrate |
| MEDIA-01 | `lib/pages/video/` and `media_kit_video` | player transport, gestures, overlays, fullscreen and PiP | player controller/native rendering + nested overlay | P8 preserve native player and suppress glass capture |
| MEDIA-02 | `lib/pages/live_room/` | live playback and overlay | live player controller / media surface | P8 retain, unsafe lease |
| PLATFORM-01 | `flutter_inappwebview` integrations | platform-view interactions and callbacks | owning page's Navigator and platform view | P8 retain; unsafe lease whenever visible |
| TOGGLE-01 | `lib/pages/setting/` settings switches | row/button toggle and persisted preference callbacks (per-callsite audit pending) | GStorage/Pref and settings state | P6 candidate; prevent duplicate toggles |

## Outstanding source audit

Use repository-wide `rg -n 'PopupMenuButton|showMenu<|showDialog|Switch\(|showModalBottomSheet|showBottomSheet|BottomSheet_|InAppWebView|Video\(' lib` in the isolated CI or source checkout. Expand this table to each real entry, including video-side and persistent sheets, their return type, root/nearest Navigator, and scroll controller. **P0-09/P0-10 stay unchecked** until the audit is complete. P0-11–P0-14 also require device evidence.
