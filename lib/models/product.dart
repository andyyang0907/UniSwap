import 'package:uuid/uuid.dart';

enum TradeType { sell, give, swap }

enum ProductCondition { newLike, good, fair, worn }

enum DeliveryType { campusMeetup, both }

class Product {
  final String id;
  final String title;
  final String description;
  final TradeType tradeType;
  final String category;
  final ProductCondition condition;
  final List<String> imageUrls;
  final double? price;
  final String? swapWish;
  final String sellerId;
  final String sellerName;
  final String? sellerAvatar;
  final String? sellerCampus;
  final String deliveryNote;
  final DateTime createdAt;
  final bool isFavorited;
  final DeliveryType deliveryType;

  Product({
    String? id,
    required this.title,
    required this.description,
    required this.tradeType,
    required this.category,
    this.condition = ProductCondition.good,
    required this.imageUrls,
    this.price,
    this.swapWish,
    required this.sellerId,
    required this.sellerName,
    this.sellerAvatar,
    this.sellerCampus,
    this.deliveryNote = '校园公共地点当面交付',
    DateTime? createdAt,
    this.isFavorited = false,
    this.deliveryType = DeliveryType.campusMeetup,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  factory Product.fake({
    String? id,
    required String title,
    required String description,
    TradeType tradeType = TradeType.sell,
    String category = '数码',
    ProductCondition condition = ProductCondition.good,
    double? price,
    String? swapWish,
    required String imageUrl,
    String sellerId = 'seller_demo',
    String sellerName = '同学小王',
    String? sellerAvatar,
    String sellerCampus = '枫林校区',
  }) {
    return Product(
      id: id,
      title: title,
      description: description,
      tradeType: tradeType,
      category: category,
      condition: condition,
      imageUrls: [imageUrl],
      price: tradeType == TradeType.sell ? (price ?? 99) : null,
      swapWish: tradeType == TradeType.swap ? swapWish : null,
      sellerId: sellerId,
      sellerName: sellerName,
      sellerAvatar: sellerAvatar,
      sellerCampus: sellerCampus,
    );
  }

  Product copyWith({bool? isFavorited}) {
    return Product(
      id: id,
      title: title,
      description: description,
      tradeType: tradeType,
      category: category,
      condition: condition,
      imageUrls: imageUrls,
      price: price,
      swapWish: swapWish,
      sellerId: sellerId,
      sellerName: sellerName,
      sellerAvatar: sellerAvatar,
      sellerCampus: sellerCampus,
      deliveryNote: deliveryNote,
      createdAt: createdAt,
      isFavorited: isFavorited ?? this.isFavorited,
      deliveryType: deliveryType,
    );
  }

  String get tradeTypeLabel {
    switch (tradeType) {
      case TradeType.sell:
        return '出售';
      case TradeType.give:
        return '赠送';
      case TradeType.swap:
        return '交换';
    }
  }

  String get conditionLabel {
    switch (condition) {
      case ProductCondition.newLike:
        return '九成新';
      case ProductCondition.good:
        return '良好';
      case ProductCondition.fair:
        return '一般';
      case ProductCondition.worn:
        return '较旧';
    }
  }

  String get priceDisplay {
    switch (tradeType) {
      case TradeType.sell:
        return '¥${price?.toStringAsFixed(0) ?? '0'}';
      case TradeType.give:
        return 'FREE';
      case TradeType.swap:
        return 'SWAP';
    }
  }
}
