import 'package:PiliPlus/prism/localizations.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Prism delegate supports Chinese and English with a safe fallback', () async {
    const delegate = PiliPrismLocalizationsDelegate();
    expect(delegate.isSupported(const Locale('zh', 'CN')), true);
    expect(delegate.isSupported(const Locale('fr', 'FR')), true);
    final zh = await delegate.load(const Locale('zh', 'CN'));
    final en = await delegate.load(const Locale('en', 'US'));
    final fallback = await delegate.load(const Locale('fr', 'FR'));
    expect(zh.back, '返回');
    expect(zh.search, '搜索');
    expect(zh.clearSearch, '清空搜索');
    expect(zh.hidePassword, '隐藏密码');
    expect(en.back, 'Back');
    expect(en.search, 'Search');
    expect(en.noSearchResults, 'No search results');
    expect(fallback.back, 'Back');
    expect(fallback.submit, 'Submit');
    expect(delegate.shouldReload(const PiliPrismLocalizationsDelegate()), false);
  });
}
