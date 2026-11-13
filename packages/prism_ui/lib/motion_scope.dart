import 'package:flutter/widgets.dart';

/// Only the policy values the upstream animations need to observe.
/// Standard physics remain wholly owned by each Prism component.
class PrismMotionScope extends InheritedWidget {
  const PrismMotionScope({
    super.key,
    required this.reduceMotion,
    required this.hapticsEnabled,
    required super.child,
  });

  final bool reduceMotion;
  final bool hapticsEnabled;

  static PrismMotionScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<PrismMotionScope>();

  static bool reduceMotionOf(BuildContext context) =>
      maybeOf(context)?.reduceMotion ?? false;

  static bool hapticsEnabledOf(BuildContext context) =>
      maybeOf(context)?.hapticsEnabled ?? true;

  @override
  bool updateShouldNotify(PrismMotionScope previous) =>
      reduceMotion != previous.reduceMotion ||
      hapticsEnabled != previous.hapticsEnabled;
}
