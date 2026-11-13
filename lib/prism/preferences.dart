import 'package:PiliPlus/models/common/enum_with_label.dart';
import 'package:PiliPlus/utils/storage.dart';
import 'package:PiliPlus/utils/storage_key.dart';

enum PrismGlassMode with EnumWithLabel {
  off, standard, ultra;

  @override
  String get label => switch (this) {
    off => '关闭',
    standard => 'Standard',
    ultra => 'Ultra',
  };
}

enum PrismMotionMode with EnumWithLabel {
  system, reduced;

  @override
  String get label => switch (this) {
    system => '跟随系统',
    reduced => '减弱动效',
  };
}

enum PrismRootTransition with EnumWithLabel {
  inherit, none, fade, slide;

  @override
  String get label => switch (this) {
    inherit => '沿用原设置',
    none => '无过渡',
    fade => '淡入淡出',
    slide => '滑动',
  };
}

/// Parses persistent values without relying on Enum.index or assuming types.
abstract final class PrismPreferenceCodec {
  static T enumValue<T extends Enum>(
    Object? raw,
    List<T> values,
    T fallback,
  ) {
    if (raw is! String) return fallback;
    for (final value in values) {
      if (value.name == raw) return value;
    }
    return fallback;
  }

  static bool enabled(Object? raw) => raw is bool ? raw : false;

  static PrismGlassMode glass(Object? raw) =>
      enumValue(raw, PrismGlassMode.values, PrismGlassMode.off);

  static PrismMotionMode motion(Object? raw) =>
      enumValue(raw, PrismMotionMode.values, PrismMotionMode.system);

  static PrismRootTransition transition(Object? raw) =>
      enumValue(raw, PrismRootTransition.values, PrismRootTransition.inherit);
}

/// Startup-applied root decisions remain stable through GStorage imports.
/// Glass and reduced motion are separate live preferences.
abstract final class PrismPreferences {
  static bool _isEnabled = false;
  static PrismRootTransition _rootTransition = PrismRootTransition.inherit;

  static void captureAtStartup() {
    _isEnabled = PrismPreferenceCodec.enabled(
      GStorage.setting.get(SettingBoxKey.prismUiEnabled),
    );
    _rootTransition = PrismPreferenceCodec.transition(
      GStorage.setting.get(SettingBoxKey.prismRootTransition),
    );
  }

  static bool get isEnabled => _isEnabled;
  static PrismRootTransition get rootTransition => _rootTransition;

  static PrismGlassMode get glassMode => PrismPreferenceCodec.glass(
    GStorage.setting.get(SettingBoxKey.prismGlassMode),
  );

  static PrismMotionMode get motionMode => PrismPreferenceCodec.motion(
    GStorage.setting.get(SettingBoxKey.prismMotionMode),
  );
}
