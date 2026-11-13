import 'package:PiliPlus/models/common/nav_bar_config.dart';
import 'package:PiliPlus/prism/preferences.dart';
import 'package:PiliPlus/prism/root_tab_host.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('lazy stable slots do not instantiate intermediate tabs',
      (tester) async {
    final built = <NavigationBarType, int>{};
    Widget host(int current) => Directionality(
      textDirection: TextDirection.ltr,
      child: PrismRootTabHost(
        destinations: NavigationBarType.values,
        selectedIndex: current,
        transition: PrismRootTransition.none,
        reduceMotion: false,
        vertical: false,
        pageBuilder: (identity) {
          built[identity] = (built[identity] ?? 0) + 1;
          return Center(child: Text(identity.label));
        },
      ),
    );
    await tester.pumpWidget(host(0));
    expect(built.keys, {NavigationBarType.home});
    await tester.pumpWidget(host(2));
    expect(built.keys, {NavigationBarType.home, NavigationBarType.mine});
    await tester.pumpWidget(host(0));
    expect(built[NavigationBarType.home], 1);
    expect(built[NavigationBarType.mine], 1);
  });

  testWidgets('rapid fade transitions retain previously built pages',
      (tester) async {
    final built = <NavigationBarType, int>{};
    Widget host(int current) => Directionality(
      textDirection: TextDirection.ltr,
      child: PrismRootTabHost(
        destinations: NavigationBarType.values,
        selectedIndex: current,
        transition: PrismRootTransition.fade,
        reduceMotion: false,
        vertical: false,
        pageBuilder: (identity) {
          built[identity] = (built[identity] ?? 0) + 1;
          return Text(identity.label);
        },
      ),
    );
    await tester.pumpWidget(host(0));
    await tester.pumpWidget(host(2));
    await tester.pump(const Duration(milliseconds: 60));
    await tester.pumpWidget(host(1));
    await tester.pumpAndSettle();
    expect(built.values.every((x) => x == 1), true);
    expect(built.length, 3);
  });
}
