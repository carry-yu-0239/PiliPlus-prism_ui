import 'package:PiliPlus/models/common/dynamic/dynamic_badge_mode.dart';
import 'package:PiliPlus/models/common/nav_bar_config.dart';
import 'package:PiliPlus/pages/main/controller.dart';
import 'package:PiliPlus/utils/feed_back.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:material_ui/material_ui.dart' as m;
import 'package:prism_ui/prism_ui.dart' as prism;

/// The same configured identities and existing MainController selection logic.
/// Glyphs use Prism's native 24dp path primitives, not Material Icon widgets.
class PiliNavigationDock extends StatelessWidget {
  const PiliNavigationDock({
    super.key,
    required this.controller,
  });

  final MainController controller;

  static const _homeGlyph = prism.Glyph([
    prism.GlyphPolyline([
      prism.GlyphVertex(3, 10),
      prism.GlyphVertex(12, 3),
      prism.GlyphVertex(21, 10),
    ], role: prism.GlyphRole.line),
    prism.GlyphPolyline([
      prism.GlyphVertex(5.5, 10),
      prism.GlyphVertex(5.5, 21),
      prism.GlyphVertex(18.5, 21),
      prism.GlyphVertex(18.5, 10),
    ], role: prism.GlyphRole.line),
    prism.GlyphPolyline([
      prism.GlyphVertex(10, 21),
      prism.GlyphVertex(10, 14),
      prism.GlyphVertex(14, 14),
      prism.GlyphVertex(14, 21),
    ], role: prism.GlyphRole.detail),
  ]);

  static const _dynamicGlyph = prism.Glyph([
    prism.GlyphCircle(12, 12, 7, role: prism.GlyphRole.line),
    prism.GlyphPolyline([
      prism.GlyphVertex(8, 13),
      prism.GlyphVertex(11, 9),
      prism.GlyphVertex(13, 14),
      prism.GlyphVertex(16, 10),
    ], role: prism.GlyphRole.line),
    prism.GlyphCircle(18, 5.5, 1.8, solid: true),
  ]);

  static const _mineGlyph = prism.Glyph([
    prism.GlyphCircle(12, 8, 4, role: prism.GlyphRole.line),
    prism.GlyphPath(
      'M 4 21 C 4 16 7.2 14.1 12 14.1 C 16.8 14.1 20 16 20 21',
      role: prism.GlyphRole.line,
    ),
  ]);

  static const homeGlyph = _homeGlyph;
  static const dynamicGlyph = _dynamicGlyph;
  static const mineGlyph = _mineGlyph;

  static prism.Glyph glyphOf(NavigationBarType type) => switch (type) {
    NavigationBarType.home => _homeGlyph,
    NavigationBarType.dynamics => _dynamicGlyph,
    NavigationBarType.mine => _mineGlyph,
  };

  @override
  Widget build(BuildContext context) => Obx(() {
    final selected = controller.selectedIndex.value;
    final count = controller.dynCount.value;
    final showUnread =
        controller.dynamicBadgeMode != DynamicBadgeMode.hidden && count > 0;
    final destinations = [
      for (final nav in controller.navigationBars)
        prism.NavigationDockDestination(
          label: nav.label,
          glyph: glyphOf(nav),
          badge: nav == NavigationBarType.dynamics && showUnread
              ? m.Badge(
                  label: controller.dynamicBadgeMode == DynamicBadgeMode.number
                      ? m.Text(count.toString())
                      : null,
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                )
              : null,
          semanticLabel: nav == NavigationBarType.dynamics && showUnread
              ? '${nav.label}，${count}条未读动态'
              : nav.label,
        ),
    ];
    return prism.NavigationDock(
      destinations: destinations,
      selectedIndex: selected,
      // MainController owns tap, refresh, throttle and page selection semantics.
      onSelected: (index) => controller.setIndex(index, haptic: false),
      onReselected: (index) => controller.setIndex(index, haptic: false),
      onActivationFeedback: feedBack,
    );
  });
}
