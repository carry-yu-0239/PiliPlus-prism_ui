import 'package:PiliPlus/models/common/nav_bar_config.dart';
import 'package:PiliPlus/prism/preferences.dart';
import 'package:flutter/widgets.dart';
import 'package:prism_ui/prism_ui.dart' as prism;

/// Lazy, identity-stable root pages. Selection belongs exclusively to MainController.
///
/// An interrupted transition starts from its *current visual values* rather
/// than replaying its old start/end. No screenshot or intermediate tabs.
class PrismRootTabHost extends StatefulWidget {
  const PrismRootTabHost({
    super.key,
    required this.destinations,
    required this.selectedIndex,
    required this.transition,
    required this.reduceMotion,
    required this.vertical,
    this.pageBuilder,
  });

  final List<NavigationBarType> destinations;
  final int selectedIndex;
  final PrismRootTransition transition;
  final bool reduceMotion;
  final bool vertical;
  final Widget Function(NavigationBarType identity)? pageBuilder;

  @override
  State<PrismRootTabHost> createState() => _PrismRootTabHostState();
}

enum _TabEffect { none, fade, slide }

class _PrismRootTabHostState extends State<PrismRootTabHost>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final _pages = <NavigationBarType, Widget>{};
  final _startOpacity = <NavigationBarType, double>{};
  final _endOpacity = <NavigationBarType, double>{};
  final _startOffset = <NavigationBarType, double>{};
  final _endOffset = <NavigationBarType, double>{};
  NavigationBarType? _selected;
  int _generation = 0;

  NavigationBarType? _identityOf(PrismRootTabHost widget) {
    if (widget.destinations.isEmpty) return null;
    final index = widget.selectedIndex;
    return widget.destinations[
      index >= 0 && index < widget.destinations.length ? index : 0
    ];
  }

  _TabEffect get _effect {
    if (widget.reduceMotion) return _TabEffect.none;
    return switch (widget.transition) {
      PrismRootTransition.inherit =>
        _TabEffect.none, // resolved in MainApp against Pref.mainTabBarView
      PrismRootTransition.none => _TabEffect.none,
      PrismRootTransition.fade => _TabEffect.fade,
      PrismRootTransition.slide => _TabEffect.slide,
    };
  }

  Duration get _duration => switch (_effect) {
    _TabEffect.none => Duration.zero,
    _TabEffect.fade => const Duration(milliseconds: 220),
    _TabEffect.slide => const Duration(milliseconds: 300),
  };

  double get _progress {
    final t = _controller.value;
    return switch (_effect) {
      _TabEffect.none => 1.0,
      _TabEffect.fade => Curves.easeInOut.transform(t),
      _TabEffect.slide => Curves.easeOut.transform(t),
    };
  }

  void _visit(NavigationBarType? identity) {
    if (identity == null) return;
    _pages.putIfAbsent(
      identity,
      () => widget.pageBuilder?.call(identity) ?? identity.page,
    );
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      value: 1,
      duration: Duration.zero,
    );
    _selected = _identityOf(widget);
    _visit(_selected);
    if (_selected case final initial?) {
      _startOpacity[initial] = 1;
      _endOpacity[initial] = 1;
      _startOffset[initial] = 0;
      _endOffset[initial] = 0;
    }
  }

  double _at(Map<NavigationBarType, double> from,
      Map<NavigationBarType, double> to, NavigationBarType identity) {
    final start = from[identity] ?? 0;
    final end = to[identity] ?? start;
    return start + (end - start) * _progress;
  }

  int _orderOf(NavigationBarType identity) =>
      widget.destinations.indexOf(identity);

  void _settleImmediately() {
    _controller
      ..stop()
      ..value = 1;
    if (_selected == null) {
      for (final identity in _pages.keys) {
        _startOpacity[identity] = 0;
        _endOpacity[identity] = 0;
      }
      return;
    }
    for (final identity in _pages.keys) {
      final selected = identity == _selected;
      _startOpacity[identity] = selected ? 1 : 0;
      _endOpacity[identity] = selected ? 1 : 0;
      final direction = _orderOf(identity) < _orderOf(_selected!)
          ? -1.0
          : 1.0;
      _startOffset[identity] = selected ? 0 : direction;
      _endOffset[identity] = selected ? 0 : direction;
    }
  }

  void _select(NavigationBarType? next) {
    if (next == _selected) return;
    final old = _selected;
    final currentOpacity = {
      for (final identity in _pages.keys)
        identity: _at(_startOpacity, _endOpacity, identity),
    };
    final currentOffset = {
      for (final identity in _pages.keys)
        identity: _at(_startOffset, _endOffset, identity),
    };
    ++_generation;
    _selected = next;
    _visit(next);
    if (next == null || _effect == _TabEffect.none) {
      _settleImmediately();
      return;
    }
    final forward = old == null ||
        _orderOf(next) >= _orderOf(old);
    for (final identity in _pages.keys) {
      final isTarget = identity == next;
      _startOpacity[identity] = currentOpacity[identity] ?? 0;
      _endOpacity[identity] = isTarget ? 1 : 0;
      _startOffset[identity] = currentOffset[identity] ??
          (isTarget ? (forward ? 1 : -1) : 0);
      _endOffset[identity] = isTarget
          ? 0
          : (_orderOf(identity) < _orderOf(next) ? -1 : 1);
    }
    _controller
      ..duration = _duration
      ..forward(from: 0);
  }

  @override
  void didUpdateWidget(PrismRootTabHost oldWidget) {
    super.didUpdateWidget(oldWidget);
    final next = _identityOf(widget);
    if (next != _selected) {
      _select(next);
    } else if (widget.reduceMotion != oldWidget.reduceMotion ||
        widget.transition != oldWidget.transition ||
        widget.vertical != oldWidget.vertical ||
        widget.destinations.length != oldWidget.destinations.length) {
      _settleImmediately();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_selected == null) return const SizedBox.shrink();
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) => Stack(
        fit: StackFit.expand,
        clipBehavior: Clip.hardEdge,
        children: [
          for (final identity in _pages.keys)
            Positioned.fill(
              child: _renderPage(identity),
            ),
        ],
      ),
    );
  }

  Widget _renderPage(NavigationBarType identity) {
    final selected = identity == _selected;
    Widget page = KeyedSubtree(
      key: ValueKey(identity),
      child: _pages[identity]!,
    );
    page = TickerMode(
      enabled: selected,
      child: ExcludeFocus(
        excluding: !selected,
        child: ExcludeSemantics(
          excluding: !selected,
          child: IgnorePointer(ignoring: !selected, child: page),
        ),
      ),
    );
    switch (_effect) {
      case _TabEffect.none:
        page = Offstage(offstage: !selected, child: page);
      case _TabEffect.fade:
        page = prism.LiquidGlassFade(
          opacity: AlwaysStoppedAnimation(
            _at(_startOpacity, _endOpacity, identity),
          ),
          child: page,
        );
      case _TabEffect.slide:
        final delta = _at(_startOffset, _endOffset, identity);
        page = FractionalTranslation(
          translation: widget.vertical ? Offset(0, delta) : Offset(delta, 0),
          child: page,
        );
    }
    return page;
  }
}
