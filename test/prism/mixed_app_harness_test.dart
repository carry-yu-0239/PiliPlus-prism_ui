import 'dart:io';

import 'package:PiliPlus/prism/bridge.dart';
import 'package:PiliPlus/prism/localizations.dart';
import 'package:PiliPlus/utils/storage.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart' as gx;
import 'package:hive_ce/hive.dart';
import 'package:material_ui/material_ui.dart' as m;
import 'package:prism_ui/prism_ui.dart' as prism;

/// Exercises the production GetMaterialApp -> PiliPrismBridge -> Navigator
/// composition. This is intentionally not an upstream PrismApp test.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory temporaryStorage;

  setUpAll(() async {
    temporaryStorage = await Directory.systemTemp.createTemp('prism-mixed-');
    Hive.init(temporaryStorage.path);
    GStorage.setting = await Hive.openBox('setting');
    GStorage.video = await Hive.openBox('video');
    GStorage.localCache = await Hive.openBox('localCache');
  });

  tearDownAll(() async {
    await Hive.close();
    if (temporaryStorage.existsSync()) {
      temporaryStorage.deleteSync(recursive: true);
    }
  });

  Widget mixedApp(Widget body) => gx.GetMaterialApp(
    theme: m.ThemeData.light(),
    locale: const Locale('zh', 'CN'),
    localizationsDelegates: [
      ...m.GlobalMaterialLocalizations.delegates,
      const PiliPrismLocalizationsDelegate(),
    ],
    home: m.Scaffold(body: Center(child: body)),
    builder: (context, child) => PiliPrismBridge(
      child: child ?? const SizedBox.shrink(),
    ),
  );

  final localDark = prism.ThemeData(
    colorScheme: const prism.ColorScheme.dark(),
  );

  testWidgets('Alert uses caller theme across GetX Navigator and returns result',
      (tester) async {
    String? result;
    Brightness? observedBrightness;
    await tester.pumpWidget(mixedApp(
      prism.Theme(
        data: localDark,
        child: Builder(builder: (context) => m.TextButton(
          onPressed: () async {
            result = await prism.showFloatingDialog<String>(
              context: context,
              child: Builder(builder: (alertContext) {
                observedBrightness = prism.Theme.of(alertContext).brightness;
                return m.TextButton(
                  onPressed: () => Navigator.of(alertContext).pop('accepted'),
                  child: const Text('Accept alert'),
                );
              }),
            );
          },
          child: const Text('Open alert'),
        )),
      ),
    ));

    await tester.tap(find.text('Open alert'));
    await tester.pumpAndSettle();
    expect(find.text('Accept alert'), findsOneWidget);
    expect(observedBrightness, Brightness.dark);

    await tester.tap(find.text('Accept alert'));
    await tester.pumpAndSettle();
    expect(result, 'accepted');
    expect(find.text('Accept alert'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Popup keeps local theme and can be dismissed on GetX Navigator',
      (tester) async {
    late prism.PopupOpen open;
    Brightness? observedBrightness;
    await tester.pumpWidget(mixedApp(
      prism.Theme(
        data: localDark,
        child: prism.PopupAnchor(
          targetBuilder: (callback) {
            open = callback;
            return const SizedBox(width: 48, height: 48, child: Text('Anchor'));
          },
          popupBuilder: (popupContext) {
            observedBrightness = prism.Theme.of(popupContext).brightness;
            return const SizedBox(width: 120, height: 90, child: Text('Popup content'));
          },
        ),
      ),
    ));

    open();
    await tester.pumpAndSettle();
    expect(find.text('Popup content'), findsOneWidget);
    expect(observedBrightness, Brightness.dark);
    gx.Get.back();
    await tester.pumpAndSettle();
    expect(find.text('Popup content'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('SnapSheet uses source theme and returns typed Navigator result',
      (tester) async {
    String? result;
    Brightness? observedBrightness;
    await tester.pumpWidget(mixedApp(
      prism.Theme(
        data: localDark,
        child: Builder(builder: (context) => m.TextButton(
          onPressed: () async {
            result = await prism.showSheet<String>(
              context: context,
              builder: (sheetContext) {
                observedBrightness = prism.Theme.of(sheetContext).brightness;
                return m.TextButton(
                  onPressed: () => Navigator.of(sheetContext).pop('sheet-value'),
                  child: const Text('Close sheet'),
                );
              },
            );
          },
          child: const Text('Open sheet'),
        )),
      ),
    ));

    await tester.tap(find.text('Open sheet'));
    await tester.pumpAndSettle();
    expect(find.text('Close sheet'), findsOneWidget);
    expect(observedBrightness, Brightness.dark);
    await tester.tap(find.text('Close sheet'));
    await tester.pumpAndSettle();
    expect(result, 'sheet-value');
    expect(tester.takeException(), isNull);
  });
}
