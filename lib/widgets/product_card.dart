import 'package:flutter/material.dart';
import 'package:uniswap_app/models/product.dart';
import 'package:uniswap_app/theme/app_colors.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;
  final VoidCallback? onFavorite;
  final bool showHero;

  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.onFavorite,
    this.showHero = true,
  });

  @override
  Widget build(BuildContext context) {
    final heroTag = 'product_image_${product.id}';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 图片区
            Expanded(
              child: LayoutBuilder(
                builder: (_, constraints) {
                  final img = _buildImage(constraints.maxWidth);
                  return Hero(
                    tag: showHero ? heroTag : 'noop_$heroTag',
                    child: img,
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            // 标题（单行，超出渐隐）
            Text(
              product.title,
              maxLines: 1,
              overflow: TextOverflow.fade,
              softWrap: false,
              style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, height: 1.3),
            ),
            const SizedBox(height: 4),
            // 价格
            Text(
              product.priceDisplay,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: product.tradeType == TradeType.sell
                    ? AppColors.primary
                    : product.tradeType == TradeType.give
                        ? AppColors.secondary
                        : AppColors.warmOrange,
              ),
            ),
            const SizedBox(height: 2),
            // 卖家 · 交付方式
            Row(
              children: [
                Container(
                  width: 14,
                  height: 14,
                  decoration: const BoxDecoration(color: AppColors.lightGreenBg, shape: BoxShape.circle),
                  child: const Icon(Icons.person, size: 9, color: AppColors.secondary),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    product.sellerName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                  decoration: BoxDecoration(
                    color: AppColors.lightGreenBg,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    '面交',
                    style: TextStyle(fontSize: 9, color: AppColors.primary, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(double width) {
    final height = width * 1.25; // 4:5
    final img = Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.lightGreenBg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Image.network(
          product.imageUrls.first,
          fit: BoxFit.cover,
          width: width,
          height: height,
          loadingBuilder: (_, child, progress) {
            if (progress == null) return child;
            return Container(
              color: AppColors.lightGreenBg,
              alignment: Alignment.center,
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(AppColors.secondary.withValues(alpha: 0.5)),
                ),
              ),
            );
          },
          errorBuilder: (_, __, ___) => Container(
            color: AppColors.lightGreenBg,
            alignment: Alignment.center,
            child: const Icon(Icons.image_outlined, color: AppColors.secondary, size: 32),
          ),
        ),
      ),
    );

    return Stack(
      children: [
        img,
        // 收藏按钮
        Positioned(
          top: 8,
          right: 8,
          child: _FavoriteButton(isFavorited: product.isFavorited, onTap: onFavorite),
        ),
        // FREE/SWAP 标签
        if (product.tradeType != TradeType.sell)
          Positioned(
            top: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: product.tradeType == TradeType.give ? AppColors.secondary : AppColors.warmOrange,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                product.tradeType == TradeType.give ? 'FREE' : 'SWAP',
                style: const TextStyle(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.w700),
              ),
            ),
          ),
      ],
    );
  }
}

class _FavoriteButton extends StatefulWidget {
  final bool isFavorited;
  final VoidCallback? onTap;
  const _FavoriteButton({required this.isFavorited, this.onTap});

  @override
  State<_FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<_FavoriteButton> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 150));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _handleTap() {
    _ctrl.forward(from: 0).then((_) => _ctrl.reverse());
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: ScaleTransition(
        scale: Tween<double>(begin: 1, end: 0.8).animate(
          CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
        ),
        child: Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.4),
            shape: BoxShape.circle,
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            child: Icon(
              widget.isFavorited ? Icons.favorite : Icons.favorite_border,
              key: ValueKey(widget.isFavorited),
              color: widget.isFavorited ? Colors.redAccent : Colors.white,
              size: 16,
            ),
          ),
        ),
      ),
    );
  }
}
