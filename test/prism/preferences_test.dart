import 'package:PiliPlus/prism/preferences.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Prism setting defaults are safe for missing or corrupt storage', () {
    expect(PrismPreferenceCodec.enabled(null), false);
    expect(PrismPreferenceCodec.enabled('true'), false);
    expect(PrismPreferenceCodec.enabled(true), true);

    for (final value in [null, 1, '', 'ULTRA', 'garbage']) {
      expect(PrismPreferenceCodec.glass(value), PrismGlassMode.off);
      expect(PrismPreferenceCodec.motion(value), PrismMotionMode.system);
      expect(
        PrismPreferenceCodec.transition(value),
        PrismRootTransition.inherit,
      );
    }
  });

  test('Prism modes persist by stable string name, not numeric index', () {
    for (final mode in PrismGlassMode.values) {
      expect(PrismPreferenceCodec.glass(mode.name), mode);
    }
    for (final mode in PrismMotionMode.values) {
      expect(PrismPreferenceCodec.motion(mode.name), mode);
    }
    for (final mode in PrismRootTransition.values) {
      expect(PrismPreferenceCodec.transition(mode.name), mode);
    }
  });
}
