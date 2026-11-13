import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:uniswap_app/services/data_repository.dart';
import 'package:uniswap_app/theme/app_colors.dart';
import 'package:uniswap_app/models/product.dart';
import 'package:uniswap_app/pages/transaction/transaction_intent_page.dart';
import 'package:uniswap_app/widgets/app_image.dart';

class ProductDetailPage extends StatefulWidget {
  final String productId;
  const ProductDetailPage({super.key, required this.productId});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  int _imageIndex = 0;
  bool _descExpanded = false;

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<DataRepository>();
    final product = repo.productById(widget.productId);
    if (product == null) return const Scaffold(body: Center(child: Text('物品不存在')));

    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        leading: _floatingIcon(Icons.arrow_back_ios_new_rounded, () => Navigator.of(context).pop()),
        actions: [
          Consumer<DataRepository>(
            builder: (_, r, __) {
              final fav = r.isFavorite(product.id);
              return _floatingIcon(fav ? Icons.favorite : Icons.favorite_border,
                  () => r.toggleFavorite(product.id), color: fav ? Colors.redAccent : Colors.white);
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildImageArea(product),
                _buildInfoSection(product),
                _buildDescription(product),
                _buildSellerSection(product),
                const SizedBox(height: 32),
              ],
            ),
          ),
          _buildBottomBar(product),
        ],
      ),
    );
  }

  Widget _floatingIcon(IconData icon, VoidCallback onTap, {Color color = Colors.white}) {
    return Container(
      margin: const EdgeInsets.only(left: 8, top: 4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.35),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: color, size: 20),
        onPressed: onTap,
      ),
    );
  }

  Widget _buildImageArea(Product product) {
    final images = product.imageUrls;
    final screenW = MediaQuery.of(context).size.width;
    return SizedBox(
      height: screenW,
      child: Stack(
        children: [
          PageView.builder(
            itemCount: images.length,
            onPageChanged: (i) => setState(() => _imageIndex = i),
            itemBuilder: (_, i) => Hero(
              tag: 'product_image_${product.id}',
              child: Image(
                image: appImageProvider(images[i]),
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                gaplessPlayback: true,
                errorBuilder: (_, __, ___) => Container(
                  color: AppColors.lightGreenBg,
                  alignment: Alignment.center,
                  child: const Icon(Icons.image_outlined, color: AppColors.secondary, size: 48),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(images.length, (i) {
                final active = i == _imageIndex;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: active ? 22 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: active ? Colors.white : Colors.white.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(3),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(Product product) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 价格
          Text(
            product.priceDisplay,
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w800,
              color: product.tradeType == TradeType.sell
                  ? AppColors.primary
                  : product.tradeType == TradeType.give
                      ? AppColors.secondary
                      : AppColors.warmOrange,
            ),
          ),
          const SizedBox(height: 8),
          // 标题
          Text(
            product.title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, height: 1.4),
          ),
          const SizedBox(height: 10),
          // 标签行
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _tag(product.category),
              _tag(product.conditionLabel),
              _tag('${_timeAgo(product.createdAt)}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _tag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.pageBg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(text, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
    );
  }

  Widget _buildDescription(Product product) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 10),
            child: Text('物品描述', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeInOut,
            alignment: Alignment.topLeft,
            child: Text(
              product.description,
              maxLines: _descExpanded ? null : 4,
              overflow: _descExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 14.5, color: AppColors.textPrimary, height: 1.7),
            ),
          ),
          if (product.description.length > 80)
            GestureDetector(
              onTap: () => setState(() => _descExpanded = !_descExpanded),
              child: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  _descExpanded ? '收起' : '展开全部',
                  style: const TextStyle(fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.w500),
                ),
              ),
            ),
          if (product.tradeType == TradeType.swap && product.swapWish != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.warmOrange.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.swap_horiz_rounded, color: AppColors.warmOrange, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('想交换', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.warmOrange)),
                        const SizedBox(height: 2),
                        Text(product.swapWish!, style: const TextStyle(fontSize: 13.5, color: AppColors.textPrimary, height: 1.5)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSellerSection(Product product) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: GestureDetector(
        onTap: () => Navigator.of(context).pushNamed('/seller', arguments: product.sellerId),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.pageBg,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Hero(
                tag: 'seller_avatar_${product.sellerId}',
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(color: AppColors.lightGreenBg, shape: BoxShape.circle),
                  child: const Icon(Icons.person_rounded, color: AppColors.secondary, size: 24),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product.sellerName, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text('${product.sellerCampus} · 当面交付', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary, size: 22),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar(Product product) {
    String mainLabel;
    IconData mainIcon;
    Color mainColor;
    if (product.tradeType == TradeType.sell) {
      mainLabel = '我想要';
      mainIcon = Icons.shopping_bag_outlined;
      mainColor = AppColors.primary;
    } else if (product.tradeType == TradeType.give) {
      mainLabel = '申请领取';
      mainIcon = Icons.card_giftcard_outlined;
      mainColor = AppColors.secondary;
    } else {
      mainLabel = '提出交换';
      mainIcon = Icons.swap_horiz_rounded;
      mainColor = AppColors.warmOrange;
    }

    return Container(
      padding: EdgeInsets.fromLTRB(14, 8, 14, 8 + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 16, offset: const Offset(0, -2)),
        ],
      ),
      child: Row(
        children: [
          _bottomIcon(Icons.chat_bubble_outline, '聊聊', () {
            final session = context.read<DataRepository>().getOrCreateSessionBySeller(
                  sellerId: product.sellerId,
                  sellerName: product.sellerName,
                );
            Navigator.of(context).pushNamed('/chat', arguments: session.id);
          }),
          const SizedBox(width: 8),
          _bottomIcon(Icons.storefront_outlined, '卖家', () => Navigator.of(context).pushNamed('/seller', arguments: product.sellerId)),
          const SizedBox(width: 12),
          Expanded(
            child: SizedBox(
              height: 44,
              child: ElevatedButton(
                onPressed: () => _showIntentSheet(product),
                style: ElevatedButton.styleFrom(
                  backgroundColor: mainColor,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(mainIcon, size: 18),
                    const SizedBox(width: 6),
                    Text(mainLabel, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showIntentSheet(Product product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: true,
      builder: (_) => TransactionIntentPage(productId: product.id),
    );
  }

  Widget _bottomIcon(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 52,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppColors.textPrimary, size: 22),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return '刚刚';
    if (diff.inMinutes < 60) return '${diff.inMinutes}分钟前';
    if (diff.inHours < 24) return '${diff.inHours}小时前';
    if (diff.inDays < 7) return '${diff.inDays}天前';
    return '${diff.inDays ~/ 7}周前';
  }
}
