import 'package:PiliPlus/prism/preferences.dart';
import 'package:prism_ui/prism_ui.dart' as prism;

enum PrismGlassBlockReason {
  uiDisabled, userOff, rendererUnsupported, shaderNotReady, shaderFailed,
  unsafeSurface, unsafeTransition, appNotVisible, inaccessibleContrast,
}

class ResolvedGlassPolicy {
  const ResolvedGlassPolicy({
    required this.requested,
    required this.enabled,
    required this.quality,
    required this.reasons,
  });

  final PrismGlassMode requested;
  final bool enabled;
  final prism.LiquidGlassQuality quality;
  final Set<PrismGlassBlockReason> reasons;
}

/// Deterministic effective policy. Temporary fallback never persists Off.
abstract final class PrismGlassPolicy {
  static ResolvedGlassPolicy resolve({
    required bool uiEnabled,
    required PrismGlassMode requested,
    required bool rendererSupported,
    required prism.LiquidGlassShaderLoadState shaderState,
    required bool unsafeSurface,
    required bool unsafeTransition,
    required bool appVisible,
    required bool highContrast,
  }) {
    final reasons = <PrismGlassBlockReason>{};
    if (!uiEnabled) reasons.add(PrismGlassBlockReason.uiDisabled);
    if (requested == PrismGlassMode.off) {
      reasons.add(PrismGlassBlockReason.userOff);
    }
    if (!rendererSupported) {
      reasons.add(PrismGlassBlockReason.rendererUnsupported);
    } else if (shaderState == prism.LiquidGlassShaderLoadState.failed) {
      reasons.add(PrismGlassBlockReason.shaderFailed);
    } else if (shaderState != prism.LiquidGlassShaderLoadState.ready) {
      reasons.add(PrismGlassBlockReason.shaderNotReady);
    }
    if (unsafeSurface) reasons.add(PrismGlassBlockReason.unsafeSurface);
    if (unsafeTransition) reasons.add(PrismGlassBlockReason.unsafeTransition);
    if (!appVisible) reasons.add(PrismGlassBlockReason.appNotVisible);
    if (highContrast) reasons.add(PrismGlassBlockReason.inaccessibleContrast);
    return ResolvedGlassPolicy(
      requested: requested,
      enabled: reasons.isEmpty,
      quality: requested == PrismGlassMode.ultra
          ? prism.LiquidGlassQuality.ultra
          : prism.LiquidGlassQuality.standard,
      reasons: Set.unmodifiable(reasons),
    );
  }
}
