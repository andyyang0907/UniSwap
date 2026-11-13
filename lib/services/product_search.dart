import 'package:uniswap_app/models/product.dart';

/// 校园闲置搜索：支持同义词、品牌别名与中文字符重合度模糊匹配。
///
/// 例如搜索「书包」可以命中「Nike 运动双肩包」，
/// 搜索「耐克」可以命中标题中的「Nike」。
class ProductSearch {
  /// 近义词 / 上位词扩展
  static const Map<String, List<String>> _synonyms = {
    '书包': ['双肩包', '背包', '包'],
    '背包': ['双肩包', '书包', '包'],
    '双肩包': ['背包', '书包', '包'],
    '包': ['书包', '背包', '双肩包'],
    '耳机': ['耳麦', '头戴', '降噪', '无线'],
    '课本': ['教材', '书', '课本'],
    '教材': ['课本', '书', 'textbook'],
    '书': ['教材', '课本'],
    '电脑': ['笔记本', 'ipad', '平板', 'macbook'],
    '平板': ['ipad', '平板电脑', '电脑'],
    '手机': ['iphone', '手机壳'],
    '球拍': ['羽毛球拍', '网球拍', '拍子'],
    '羽毛球': ['羽毛球拍', '球拍'],
    '网球': ['网球拍', '球拍'],
    '台灯': ['灯', '照明'],
    '键盘': ['机械键盘', '静电容键盘'],
    '水杯': ['杯子', '保温杯'],
    '饭盒': ['保温饭盒', '便当盒'],
    '自行车': ['单车', '代步车'],
    '衣服': ['外套', '卫衣', '裤'],
    '桌': ['书桌', '桌子'],
  };

  /// 品牌中英文别名
  static const Map<String, List<String>> _brandAliases = {
    '耐克': ['nike'],
    'nike': ['耐克'],
    '阿迪': ['adidas'],
    '阿迪达斯': ['adidas'],
    'adidas': ['阿迪达斯'],
    '苹果': ['apple', 'iphone', 'ipad', 'mac', 'airpods'],
    'apple': ['苹果'],
    '索尼': ['sony'],
    'sony': ['索尼'],
    '宜家': ['ikea'],
    'ikea': ['宜家'],
    '尤尼克斯': ['yonex'],
    'yonex': ['尤尼克斯'],
  };

  static String _normalize(String input) {
    return input.toLowerCase().replaceAll(RegExp(r'[\s\-_/·。，,.]'), '');
  }

  /// 去掉「二手」「闲置」等无实际检索意义的修饰词
  static String _cleanQuery(String input) {
    var query = _normalize(input);
    for (final stop in ['二手', '闲置', '全新', '九成新', '八成新', '求购', '出售', '求', '收', '的']) {
      query = query.replaceAll(stop, '');
    }
    return query.isEmpty ? _normalize(input) : query;
  }

  /// 返回按相关度排序的结果
  static List<Product> search(List<Product> products, String keyword) {
    final query = _cleanQuery(keyword);
    if (query.isEmpty) return products;

    final scored = <MapEntry<Product, int>>[];
    for (final product in products) {
      final score = _score(product, query);
      if (score > 0) scored.add(MapEntry(product, score));
    }

    scored.sort((a, b) {
      final byScore = b.value.compareTo(a.value);
      if (byScore != 0) return byScore;
      return b.key.createdAt.compareTo(a.key.createdAt);
    });
    return scored.map((e) => e.key).toList();
  }

  static int _score(Product product, String query) {
    final title = _normalize(product.title);
    final desc = _normalize(product.description);
    final category = _normalize(product.category);
    final seller = _normalize(product.sellerName);
    final swapWish = _normalize(product.swapWish ?? '');

    // 查询词 + 同义词 + 品牌别名
    final terms = <String>{query};
    terms.addAll(_synonyms[query] ?? const []);
    terms.addAll(_brandAliases[query] ?? const []);
    // 多词拆分
    for (final part in query.split(RegExp(r'[\s,，]+'))) {
      if (part.isNotEmpty) terms.add(part);
    }
    // 单个汉字过于宽泛（例如“包”会命中“包装”），仅当原查询本身只有一个字时才允许
    final effectiveTerms = terms.where((t) => t.length >= 2 || t == query).toList();

    var best = 0;
    for (final term in effectiveTerms) {
      if (term.isEmpty) continue;
      var score = 0;
      if (title.contains(term)) {
        score = 120 + term.length * 8;
      } else if (category.contains(term)) {
        score = 70;
      } else if (swapWish.contains(term)) {
        score = 60;
      } else if (desc.contains(term)) {
        score = 45;
      } else if (seller.contains(term)) {
        score = 25;
      }
      if (score > best) best = score;
    }
    if (best > 0) return best;

    // 字符重合度兜底：搜索「书包」命中「双肩包」这类无直接子串的情况
    if (query.length < 2) return 0;
    final haystack = '$title$desc$category';
    final queryChars = query.split('').toSet();
    if (queryChars.isEmpty) return 0;
    final matched = queryChars.where(haystack.contains).length;
    final ratio = matched / queryChars.length;
    if (ratio >= 0.8) {
      return 30 + (ratio * 40).round();
    }
    return 0;
  }
}
