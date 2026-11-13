import 'package:flutter/foundation.dart' show SynchronousFuture;
import 'package:flutter/widgets.dart';
import 'package:prism_ui/prism_ui.dart' as p;

/// The 20 fields required by the upstream UiLocalizations interface.
class PiliPrismLocalizations extends p.UiLocalizations {
  PiliPrismLocalizations(this.languageCode);

  final String languageCode;
  bool get _zh => languageCode == 'zh';

  @override
  String get back => _zh ? '返回' : 'Back';
  @override
  String get cancel => _zh ? '取消' : 'Cancel';
  @override
  String get clearSearch => _zh ? '清空搜索' : 'Clear search';
  @override
  String get close => _zh ? '关闭' : 'Close';
  @override
  String get copy => _zh ? '复制' : 'Copy';
  @override
  String get cut => _zh ? '剪切' : 'Cut';
  @override
  String get dialog => _zh ? '对话框' : 'Dialog';
  @override
  String get hidePassword => _zh ? '隐藏密码' : 'Hide password';
  @override
  String get more => _zh ? '更多' : 'More';
  @override
  String get noSearchResults => _zh ? '无搜索结果' : 'No search results';
  @override
  String get paste => _zh ? '粘贴' : 'Paste';
  @override
  String get reset => _zh ? '重置' : 'Reset';
  @override
  String get search => _zh ? '搜索' : 'Search';
  @override
  String get select => _zh ? '选择' : 'Select';
  @override
  String get selectAll => _zh ? '全选' : 'Select all';
  @override
  String get showLess => _zh ? '收起' : 'Show less';
  @override
  String get showMore => _zh ? '展开' : 'Show more';
  @override
  String get showPassword => _zh ? '显示密码' : 'Show password';
  @override
  String get sort => _zh ? '排序' : 'Sort';
  @override
  String get submit => _zh ? '提交' : 'Submit';
}

class PiliPrismLocalizationsDelegate
    extends LocalizationsDelegate<p.UiLocalizations> {
  const PiliPrismLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<p.UiLocalizations> load(Locale locale) => SynchronousFuture(
    PiliPrismLocalizations(locale.languageCode == 'zh' ? 'zh' : 'en'),
  );

  @override
  bool shouldReload(PiliPrismLocalizationsDelegate old) => false;
}
