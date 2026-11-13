import 'package:flutter/rendering.dart' show SemanticsAction;
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prism_ui/prism_ui.dart';

import '../helpers/test_app.dart';

const _items = [
  NavigationDockDestination(
    glyph: Glyph([GlyphCircle(12, 12, 4)]),
    label: 'First',
  ),
  NavigationDockDestination(
    glyph: Glyph([GlyphCircle(12, 12, 5)]),
    label: 'Second',
    badge: SizedBox(key: Key('unread-badge'), width: 8, height: 8),
    semanticLabel: 'Second unread',
  ),
  NavigationDockDestination(
    glyph: Glyph([GlyphCircle(12, 12, 6)]),
    label: 'Third',
  ),
];

void main() {
  testWidgets('Pointer tap and reselect dispatch exactly once; unread badge is one widget',
      (tester) async {
    final selected = <int>[];
    final reselected = <int>[];
    var activationFeedback = 0;
    var current = 0;
    await tester.pumpWidget(HostApp(
      home: Center(
        child: StatefulBuilder(builder: (context, setState) {
          return NavigationDock(
            destinations: _items,
            selectedIndex: current,
            onSelected: (index) {
              selected.add(index);
              setState(() => current = index);
            },
            onReselected: reselected.add,
            onActivationFeedback: () => activationFeedback++,
          );
        }),
      ),
    ));

    expect(find.byKey(const Key('unread-badge')), findsOneWidget);
    await tester.tap(find.text('Second'));
    await tester.pumpAndSettle();
    expect(selected, [1]);
    expect(reselected, isEmpty);
    expect(activationFeedback, 1);
    await tester.tap(find.text('Second'));
    await tester.pumpAndSettle();
    expect(selected, [1]);
    expect(reselected, [1]);
    expect(activationFeedback, 2);
    expect(find.byKey(const Key('unread-badge')), findsOneWidget);
  });

  testWidgets('Canceled drag does not commit preview or trigger activation feedback',
      (tester) async {
    final selected = <int>[];
    final reselected = <int>[];
    var activationFeedback = 0;
    await tester.pumpWidget(HostApp(
      home: Center(child: NavigationDock(
        destinations: _items,
        selectedIndex: 0,
        onSelected: selected.add,
        onReselected: reselected.add,
        onActivationFeedback: () => activationFeedback++,
      )),
    ));

    final gesture = await tester.startGesture(tester.getCenter(find.text('First')));
    await gesture.moveTo(tester.getCenter(find.text('Third')));
    await tester.pump(const Duration(milliseconds: 50));
    expect(selected, isEmpty, reason: 'Preview must not commit business selection');
    await gesture.cancel();
    await tester.pumpAndSettle();
    expect(selected, isEmpty);
    expect(reselected, isEmpty);
    expect(activationFeedback, 0);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Reduced motion switch settles active native Dock tickers and disposes cleanly',
      (tester) async {
    final reduced = ValueNotifier(false);
    addTearDown(reduced.dispose);
    var current = 0;
    await tester.pumpWidget(HostApp(
      home: Center(
        child: ValueListenableBuilder<bool>(
          valueListenable: reduced,
          builder: (context, isReduced, _) => PrismMotionScope(
            reduceMotion: isReduced,
            hapticsEnabled: false,
            child: StatefulBuilder(builder: (context, setState) {
              return NavigationDock(
                destinations: _items,
                selectedIndex: current,
                onSelected: (index) => setState(() => current = index),
              );
            }),
          ),
        ),
      ),
    ));

    await tester.tap(find.text('Second'));
    await tester.pump(const Duration(milliseconds: 16));
    expect(current, 1);
    reduced.value = true;
    await tester.pump();
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    expect(tester.takeException(), isNull);
  });

  testWidgets('Semantics activation uses one callback and respects haptics scope',
      (tester) async {
    final semantics = tester.ensureSemantics();
    final selected = <int>[];
    var activationFeedback = 0;
    await tester.pumpWidget(HostApp(
      home: Center(
        child: PrismMotionScope(
          reduceMotion: true,
          hapticsEnabled: false,
          child: NavigationDock(
            destinations: _items,
            selectedIndex: 0,
            onSelected: selected.add,
            onActivationFeedback: () => activationFeedback++,
          ),
        ),
      ),
    ));

    final node = tester.getSemantics(find.bySemanticsLabel('Second unread'));
    tester.binding.pipelineOwner.semanticsOwner!
        .performAction(node.id, SemanticsAction.tap);
    await tester.pumpAndSettle();
    expect(selected, [1]);
    expect(activationFeedback, 0);
    expect(tester.takeException(), isNull);
    semantics.dispose();
  });
}
