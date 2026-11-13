import 'package:PiliPlus/prism/glass_policy.dart';
import 'package:PiliPlus/prism/preferences.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prism_ui/prism_ui.dart' as prism;

ResolvedGlassPolicy resolve({
  PrismGlassMode mode = PrismGlassMode.standard,
  bool ui = true, bool shader = true, bool surface = false,
  bool transition = false, bool visible = true, bool contrast = false,
  prism.LiquidGlassShaderLoadState state =
      prism.LiquidGlassShaderLoadState.ready,
}) => PrismGlassPolicy.resolve(
  uiEnabled: ui, requested: mode, rendererSupported: shader,
  shaderState: state, unsafeSurface: surface,
  unsafeTransition: transition, appVisible: visible,
  highContrast: contrast,
);

void main() {
  test('Off and absent enabled UI never capture a backdrop', () {
    expect(resolve(mode: PrismGlassMode.off).enabled, false);
    expect(resolve(ui: false).reasons, contains(PrismGlassBlockReason.uiDisabled));
  });
  test('unsupported or unloaded Shader disables native glass', () {
    expect(resolve(shader: false).enabled, false);
    expect(resolve(state: prism.LiquidGlassShaderLoadState.loading).reasons,
        contains(PrismGlassBlockReason.shaderNotReady));
    expect(resolve(state: prism.LiquidGlassShaderLoadState.failed).reasons,
        contains(PrismGlassBlockReason.shaderFailed));
  });
  test('unsafe surfaces and inaccessible states independently block capture', () {
    expect(resolve(surface: true).enabled, false);
    expect(resolve(transition: true).enabled, false);
    expect(resolve(visible: false).enabled, false);
    expect(resolve(contrast: true).enabled, false);
  });
  test('original quality preserved through temporary fallback', () {
    final fallback = resolve(mode: PrismGlassMode.ultra, surface: true);
    expect(fallback.enabled, false);
    expect(fallback.requested, PrismGlassMode.ultra);
    expect(fallback.quality, prism.LiquidGlassQuality.ultra);
    expect(resolve(mode: PrismGlassMode.ultra).enabled, true);
  });
}
