import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uniswap_app/services/data_repository.dart';
import 'package:uniswap_app/theme/app_colors.dart';
import 'package:uniswap_app/widgets/product_card.dart';
import 'package:uniswap_app/widgets/empty_state.dart';

class SellerProfilePage extends StatelessWidget {
  final String sellerId;
  const SellerProfilePage({super.key, required this.sellerId});

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<DataRepository>();
    final products = repo.products.where((p) => p.sellerId == sellerId).toList();
    final hasProducts = products.isNotEmpty;
    final sellerName = hasProducts ? products.first.sellerName : '同学';
    final sellerCampus = hasProducts ? products.first.sellerCampus ?? '' : '';

    return Scaffold(
      backgroundColor: AppColors.pageBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('卖家主页'),
        centerTitle: true,
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
                child: Row(
                  children: [
                    Hero(
                      tag: 'seller_avatar_$sellerId',
                      child: Container(
                        width: 64,
                        height: 64,
                        decoration: const BoxDecoration(color: AppColors.lightGreenBg, shape: BoxShape.circle),
                        child: const Icon(Icons.person_rounded, color: AppColors.secondary, size: 34),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(sellerName, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 2),
                          Text('$sellerCampus · 信用良好 ⭐5.0', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.fromLTRB(20, 8, 20, 8), child: Text('他的闲置 (${products.length})', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)))),
          if (!hasProducts)
            const SliverToBoxAdapter(
              child: EmptyState(icon: Icons.inventory_2_outlined, title: '这位同学暂时没有发布闲置', subtitle: ''),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.72,
                ),
                delegate: SliverChildBuilderDelegate(
                  (_, i) {
                    final product = products[i];
                    return ProductCard(
                      product: product,
                      onTap: () => Navigator.of(context).pushNamed('/product', arguments: product.id),
                      onFavorite: () => repo.toggleFavorite(product.id),
                    );
                  },
                  childCount: products.length,
                ),
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }
}
