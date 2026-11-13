import 'package:PiliPlus/prism/navigation_adapter.dart';
import 'package:PiliPlus/prism/preferences.dart';
import 'package:PiliPlus/prism/glass_policy.dart';
import 'package:flutter/widgets.dart';
import 'package:material_ui/material_ui.dart' as m;
import 'package:prism_ui/prism_ui.dart' as prism;

/// An intentionally media-free, independently captured shader test surface.
/// Never places video textures or PlatformViews under a glass capture.
class PrismPreviewPage extends StatefulWidget {
  const PrismPreviewPage({super.key});

  @override
  State<PrismPreviewPage> createState() => _PrismPreviewPageState();
}

class _PrismPreviewPageState extends State<PrismPreviewPage> {
  late PrismGlassMode _mode;
  int _selected = 0;

  @override
  void initState() {
    super.initState();
    _mode = PrismPreferences.glassMode;
    prism.LiquidGlassShaders.state.addListener(_statusChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) => _prepareShader());
  }

  void _statusChanged() {
    if (mounted) setState(() {});
  }

  void _prepareShader() {
    if (_mode != PrismGlassMode.off &&
        prism.LiquidGlassShaders.rendererSupported) {
      // Do not block startup or rely on a pane being painted to initiate load.
      prism.LiquidGlassShaders.ensureLoaded();
    }
  }

  @override
  void dispose() {
    prism.LiquidGlassShaders.state.removeListener(_statusChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final available = prism.LiquidGlassShaders.rendererSupported;
    final shaderState = prism.LiquidGlassShaders.state.value;
    final policy = PrismGlassPolicy.resolve(
      uiEnabled: true, // isolated preview is opt-in independently of the root
      requested: _mode,
      rendererSupported: available,
      shaderState: shaderState,
      unsafeSurface: false, // only inert colored widgets are below this Host
      unsafeTransition: false,
      appVisible: WidgetsBinding.instance.lifecycleState !=
          AppLifecycleState.paused,
      highContrast: MediaQuery.highContrastOf(context),
    );
    final enabled = policy.enabled;
    final prismColor = prism.ColorScheme.of(context);
    final materialColor = m.ColorScheme.of(context);
    return m.Scaffold(
      appBar: m.AppBar(title: const m.Text('Prism UI 原生预览')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              spacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                for (final mode in PrismGlassMode.values)
                  m.ChoiceChip(
                    label: m.Text(mode.label),
                    selected: _mode == mode,
                    onSelected: (_) {
                      setState(() => _mode = mode);
                      _prepareShader();
                    },
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: m.Text(
              !available
                  ? '当前渲染器不支持原生 Shader Filter，已采用实体材质。'
                  : _mode == PrismGlassMode.off
                      ? '原生玻璃关闭；可切换 Standard 或 Ultra。'
                      : 'Shader: ${shaderState.name} · ${enabled ? '原生折射已启用' : '实体回退'}',
            ),
          ),
          Expanded(
            child: prism.LiquidGlassScope(
              enabled: enabled,
              quality: policy.quality,
              child: prism.LiquidGlassHost(
                enabled: enabled,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: ListView.builder(
                        itemCount: 24,
                        itemBuilder: (context, index) => m.Container(
                          height: 86,
                          padding: const EdgeInsets.all(18),
                          color: index.isEven
                              ? materialColor.primaryContainer
                              : materialColor.tertiaryContainer,
                          alignment: Alignment.centerLeft,
                          child: m.Text(
                            '可滚动背景 ${index + 1} · Prism capture',
                            style: m.TextStyle(
                              color: index.isEven
                                  ? materialColor.onPrimaryContainer
                                  : materialColor.onTertiaryContainer,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: SizedBox(
                        width: 220,
                        height: 70,
                        child: prism.LiquidGlass(
                          style: prism.LiquidGlassStyle.regular(prismColor),
                          child: const Center(child: m.Text('原生 Liquid Glass')),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: prism.NavigationDock(
                        selectedIndex: _selected,
                        onSelected: (index) => setState(() => _selected = index),
                        onReselected: (index) => setState(() => _selected = index),
                        destinations: const [
                          prism.NavigationDockDestination(
                            glyph: PiliNavigationDock.homeGlyph,
                            label: '首页',
                          ),
                          prism.NavigationDockDestination(
                            glyph: PiliNavigationDock.dynamicGlyph,
                            label: '动态',
                          ),
                          prism.NavigationDockDestination(
                            glyph: PiliNavigationDock.mineGlyph,
                            label: '我的',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
