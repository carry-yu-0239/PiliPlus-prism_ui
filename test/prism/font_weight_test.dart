import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prism_ui/prism_ui.dart' as prism;

void main() {
  testWidgets('null override preserves original Prism typography hierarchy', (tester) async {
    late FontWeight ordinary;
    late FontWeight emphasized;
    await tester.pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: prism.Theme(
        data: prism.ThemeData(),
        child: Builder(builder: (context) {
          ordinary = prism.AppTextStyle.body.of(context).fontWeight!;
          emphasized = prism.AppTextStyle.body.of(context, emphasized: true).fontWeight!;
          return const SizedBox.shrink();
        }),
      ),
    ));
    expect(ordinary, FontWeight.w400);
    expect(emphasized, FontWeight.w600);
  });

  testWidgets('explicit weight overrides header, body and custom glyph text absolutely', (tester) async {
    late List<FontWeight?> weights;
    await tester.pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: prism.Theme(
        data: prism.ThemeData(fontWeightOverride: FontWeight.w800),
        child: Builder(builder: (context) {
          weights = [
            prism.AppTextStyle.headline.of(context).fontWeight,
            prism.AppTextStyle.headline.of(context, emphasized: true).fontWeight,
            prism.AppTextStyle.custom(context, size: 11, leading: 14).fontWeight,
          ];
          return const SizedBox.shrink();
        }),
      ),
    ));
    expect(weights, everyElement(FontWeight.w800));
  });
}
