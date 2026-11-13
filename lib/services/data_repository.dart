import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uniswap_app/models/product.dart';
import 'package:uniswap_app/models/message.dart';
import 'package:uniswap_app/models/transaction.dart';
import 'package:uniswap_app/models/user.dart';
import 'package:uniswap_app/services/mock_data.dart';
import 'package:uniswap_app/services/product_search.dart';

class DataRepository extends ChangeNotifier {
  DataRepository._();
  static final DataRepository instance = DataRepository._();

  List<Product> _products = [];
  final List<Product> _myProducts = [];
  final List<String> _favoriteIds = [];
  List<ChatSession> _sessions = [];
  List<TransactionIntent> _myTransactions = [];
  UniUser _me = UniUser.demo;

  // 设置项
  bool _notificationsEnabled = true;
  String _defaultDeliverySpot = '梓苑宿舍区';
  String _campusId = 'ynu_chenggong';

  void init() {
    _products = List.from(MockData.products);
    _sessions = List.from(MockData.sessions);
    _myTransactions = List.from(MockData.myTransactions);
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
    _defaultDeliverySpot = prefs.getString('default_delivery_spot') ?? '梓苑宿舍区';
    _campusId = prefs.getString('campus_id') ?? 'ynu_chenggong';
    final savedName = prefs.getString('profile_name');
    final savedBio = prefs.getString('profile_bio');
    final savedAvatar = prefs.getString('profile_avatar');
    if (savedName != null) _me = _me.copyWith(name: savedName);
    if (savedBio != null) _me = _me.copyWith(bio: savedBio);
    if (savedAvatar != null) _me = _me.copyWith(avatar: savedAvatar);
    notifyListeners();
  }

  UniUser get me => _me;

  bool get notificationsEnabled => _notificationsEnabled;
  String get defaultDeliverySpot => _defaultDeliverySpot;
  String get campusId => _campusId;

  Future<void> updateProfile({String? name, String? bio, String? avatar, String? campus}) async {
    if (name != null) _me = _me.copyWith(name: name);
    if (bio != null) _me = _me.copyWith(bio: bio);
    if (avatar != null) _me = _me.copyWith(avatar: avatar);
    if (campus != null) _me = _me.copyWith(campus: campus);
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    if (name != null) await prefs.setString('profile_name', name);
    if (bio != null) await prefs.setString('profile_bio', bio);
    if (avatar != null) await prefs.setString('profile_avatar', avatar);
  }

  Future<void> setNotificationsEnabled(bool value) async {
    _notificationsEnabled = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', value);
  }

  Future<void> setDefaultDeliverySpot(String spot, {String? campusId}) async {
    _defaultDeliverySpot = spot;
    if (campusId != null) _campusId = campusId;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('default_delivery_spot', spot);
    if (campusId != null) await prefs.setString('campus_id', campusId);
  }

  // ========== Products ==========
  List<Product> get products => List.unmodifiable(_products);

  Product? productById(String id) {
    try {
      return _products.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  List<Product> productsByCategory(String category) {
    if (category == '全部') return _products;
    return _products.where((p) => p.category == category).toList();
  }

  List<Product> favoriteProducts() {
    return _products.where((p) => _favoriteIds.contains(p.id)).toList();
  }

  bool isFavorite(String productId) => _favoriteIds.contains(productId);

  void toggleFavorite(String productId) {
    final product = productById(productId);
    if (product == null) return;
    if (_favoriteIds.contains(productId)) {
      _favoriteIds.remove(productId);
    } else {
      _favoriteIds.add(productId);
    }
    _products[_products.indexWhere((p) => p.id == productId)] =
        product.copyWith(isFavorited: _favoriteIds.contains(productId));
    notifyListeners();
  }

  void addProduct(Product product) {
    _products.insert(0, product);
    _myProducts.insert(0, product);
    notifyListeners();
  }

  List<Product> get myProducts => List.unmodifiable(_myProducts);

  List<Product> searchProducts(String keyword) {
    return ProductSearch.search(_products, keyword);
  }

  List<Product> filterProducts({
    List<TradeType>? tradeTypes,
    List<String>? categories,
    double? minPrice,
    double? maxPrice,
  }) {
    return _products.where((p) {
      if (tradeTypes != null && tradeTypes.isNotEmpty && !tradeTypes.contains(p.tradeType)) {
        return false;
      }
      if (categories != null && categories.isNotEmpty && !categories.contains(p.category)) {
        return false;
      }
      if (p.tradeType == TradeType.sell && p.price != null) {
        if (minPrice != null && p.price! < minPrice) return false;
        if (maxPrice != null && p.price! > maxPrice) return false;
      }
      return true;
    }).toList();
  }

  // ========== Sessions / Messages ==========
  List<ChatSession> get sessions => List.unmodifiable(_sessions);

  ChatSession? sessionById(String id) {
    try {
      return _sessions.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  // 根据卖家 ID 查找或创建会话
  ChatSession getOrCreateSessionBySeller({
    required String sellerId,
    required String sellerName,
    String? initialMessage,
  }) {
    // 先找已有会话
    for (final s in _sessions) {
      if (s.peerId == sellerId) return s;
    }
    // 没有就创建一个
    final session = ChatSession(
      id: 'session_${sellerId}_${DateTime.now().millisecondsSinceEpoch}',
      peerId: sellerId,
      peerName: sellerName,
      lastMessage: initialMessage ?? '',
      lastMessageAt: DateTime.now(),
      unreadCount: 0,
      messages: initialMessage != null
          ? [
              ChatMessage(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                sessionId: '',
                senderId: _me.id,
                content: initialMessage,
                isMine: true,
              ),
            ]
          : [],
    );
    _sessions.insert(0, session);
    notifyListeners();
    return session;
  }

  void markSessionAsRead(String sessionId) {
    final session = sessionById(sessionId);
    if (session == null || session.unreadCount == 0) return;
    session.unreadCount = 0;
    notifyListeners();
  }

  void sendMessage(String sessionId, String content) {
    final session = sessionById(sessionId);
    if (session == null) return;
    final msg = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      sessionId: sessionId,
      senderId: _me.id,
      content: content,
      isMine: true,
    );
    session.messages.add(msg);
    session.lastMessage = content;
    session.lastMessageAt = DateTime.now();
    notifyListeners();
  }

  // ========== Transactions ==========
  List<TransactionIntent> get myTransactions => List.unmodifiable(_myTransactions);

  void createIntent(TransactionIntent intent) {
    _myTransactions.insert(0, intent);
    notifyListeners();
  }

  void updateTransaction(String id, TransactionIntent updated) {
    final idx = _myTransactions.indexWhere((t) => t.id == id);
    if (idx >= 0) {
      _myTransactions[idx] = updated;
      notifyListeners();
    }
  }
}
