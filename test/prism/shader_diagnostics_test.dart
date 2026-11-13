import 'package:flutter_test/flutter_test.dart';
import 'package:prism_ui/prism_ui.dart' as prism;

void main() {
  test('Shader diagnostics expose read-only state without retaining image data', () {
    final state = prism.LiquidGlassShaders.state.value;
    expect(state, isA<prism.LiquidGlassShaderLoadState>());
    expect(prism.LiquidGlassShaders.captureCount, greaterThanOrEqualTo(0));
    expect(prism.LiquidGlassShaders.heldCaptureCount, greaterThanOrEqualTo(0));
    if (!prism.LiquidGlassShaders.profilingEnabled) {
      expect(prism.LiquidGlassShaders.captureCount, 0);
      expect(prism.LiquidGlassShaders.heldCaptureCount, 0);
    }
  });
}
