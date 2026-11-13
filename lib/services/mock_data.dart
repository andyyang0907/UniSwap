import 'package:uniswap_app/models/product.dart';
import 'package:uniswap_app/models/message.dart';
import 'package:uniswap_app/models/transaction.dart';
import 'package:uniswap_app/models/user.dart';

class MockData {
  static final List<Product> products = [
    Product.fake(
      title: 'Sony WH-1000XM4 降噪耳机',
      description: '去年双十一购入，成色非常好，几乎没怎么使用过。音质和降噪都很顶级，适合自习和通勤。全套包装都在，附赠原装收纳盒和充电线。可当面验货。',
      tradeType: TradeType.sell,
      category: '数码',
      condition: ProductCondition.newLike,
      price: 1299,
      imageUrl: 'assets/images/products/product_02_headphone.jpg',
      sellerId: 'seller_1',
      sellerName: '小李学长',
      sellerCampus: '呈贡校区',
    ),
    Product.fake(
      title: 'Nike 运动双肩包 9成新',
      description: '去年买的，后来又收到一个更合适的，这个就闲置了。容量很大，电脑仓保护得很好，运动和通勤都能用。没有明显磨损。',
      tradeType: TradeType.sell,
      category: '生活用品',
      condition: ProductCondition.good,
      price: 199,
      imageUrl: 'assets/images/products/product_03_backpack.jpg',
      sellerId: 'seller_sport',
      sellerName: '运动少年',
      sellerCampus: '呈贡校区',
    ),
    Product.fake(
      title: '高等数学上下册 同济七版',
      description: '课本+习题全解，上课用的，笔记都在旁边。适合大一大二同学。书脊有轻微磨损，内页干净整洁。',
      tradeType: TradeType.give,
      category: '教材',
      condition: ProductCondition.good,
      imageUrl: 'assets/images/products/product_04_textbook.jpg',
      sellerId: 'seller_2',
      sellerName: '数学系学姐',
      sellerCampus: '呈贡校区',
    ),
    Product.fake(
      title: 'iPad Air 4 64G 银色',
      description: '自用两年，平时看网课和记笔记用，屏幕有一处小划痕不影响使用。配一代 Apple Pencil 一起出，有原装充电器。',
      tradeType: TradeType.sell,
      category: '数码',
      condition: ProductCondition.good,
      price: 2699,
      imageUrl: 'assets/images/products/product_05_ipad.jpg',
      sellerId: 'seller_kaoyan',
      sellerName: '考研党',
      sellerCampus: '东陆校区',
    ),
    Product.fake(
      title: '宜家书桌台灯 暖光',
      description: '毕业搬走带不走了，免费送给有需要的同学。功能正常，灯泡刚换过，亮度三档可调。',
      tradeType: TradeType.give,
      category: '生活用品',
      condition: ProductCondition.good,
      imageUrl: 'assets/images/products/product_06_lamp.jpg',
      sellerId: 'seller_grad',
      sellerName: '即将离校的大四生',
      sellerCampus: '呈贡校区',
    ),
    Product.fake(
      title: 'Yonex 羽毛球拍 闲置',
      description: '用了大概半年，换了新拍想交换一把入门级网球拍。成色良好，线刚拉过不久，磅数 24。',
      tradeType: TradeType.swap,
      category: '运动',
      condition: ProductCondition.good,
      swapWish: '想换一把入门级网球拍',
      imageUrl: 'assets/images/products/product_07_racket.jpg',
      sellerId: 'seller_3',
      sellerName: '羽球爱好者',
      sellerCampus: '呈贡校区',
    ),
    Product.fake(
      title: 'HHKB 静电容键盘',
      description: '买了之后发现宿舍里用太吵了，基本全新没用过几次。键帽全原装，手感非常好，配 Type-C 线。',
      tradeType: TradeType.sell,
      category: '数码',
      condition: ProductCondition.newLike,
      price: 599,
      imageUrl: 'assets/images/products/product_08_keyboard.jpg',
      sellerId: 'seller_dev',
      sellerName: '程序员小哥',
      sellerCampus: '东陆校区',
    ),
    Product.fake(
      title: '保温饭盒 三层 不锈钢',
      description: '之前带饭用的，现在公司有食堂闲置了。不锈钢内胆，保温效果很好，冬天也能让饭菜温热。',
      tradeType: TradeType.give,
      category: '生活用品',
      condition: ProductCondition.fair,
      imageUrl: 'assets/images/products/product_01_thermos.jpg',
      sellerId: 'seller_intern',
      sellerName: '实习狗',
      sellerCampus: '呈贡校区',
    ),
  ];

  static final List<ChatSession> sessions = [
    ChatSession(
      id: 'session_1',
      peerId: 'seller_1',
      peerName: '小李学长',
      lastMessage: '好的，那周六下午三点在图书馆门口见？',
      lastMessageAt: DateTime.now().subtract(const Duration(minutes: 12)),
      unreadCount: 2,
      messages: [
        ChatMessage(id: 'm1', sessionId: 'session_1', senderId: 'me_demo', content: '你好，耳机还在吗？', isMine: true),
        ChatMessage(id: 'm2', sessionId: 'session_1', senderId: 'seller_1', content: '在的，有意向？我可以今天下午在图书馆见面'),
        ChatMessage(id: 'm3', sessionId: 'session_1', senderId: 'me_demo', content: '好的，我明天下午过来方便吗？', isMine: true),
        ChatMessage(id: 'm4', sessionId: 'session_1', senderId: 'seller_1', content: '好的，那周六下午三点在图书馆门口见？'),
      ],
    ),
    ChatSession(
      id: 'session_2',
      peerId: 'seller_2',
      peerName: '数学系学姐',
      lastMessage: '已经有同学在联系啦，不好意思～',
      lastMessageAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    ChatSession(
      id: 'session_3',
      peerId: 'seller_3',
      peerName: '羽球爱好者',
      lastMessage: '交换的事可以聊聊，你有网球拍吗？',
      lastMessageAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  static final List<TransactionIntent> myTransactions = [
    TransactionIntent(
      id: 'tx_1',
      productId: products.first.id,
      productTitle: products.first.title,
      productImage: products.first.imageUrls.first,
      fromUserId: 'me_demo',
      fromUserName: UniUser.demo.name,
      toUserId: 'seller_1',
      toUserName: '小李学长',
      message: '很有意向购买，周六方便面谈吗？',
      status: TransactionStatus.appointed,
      appointment: Appointment(
        location: '图书馆东门',
        date: DateTime.now().add(const Duration(days: 2)),
        timeSlot: '15:00 - 15:30',
      ),
    ),
  ];

  static const List<String> categories = ['数码', '教材', '生活用品', '运动', '其他'];
  static const List<String> campusLocations = [
    '图书馆东门', '食堂一楼门口', '体育馆前台', '教学楼大厅', '宿舍楼下', '校门口保安亭旁',
  ];
}
