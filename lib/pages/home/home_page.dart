import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:uniswap_app/services/data_repository.dart';
import 'package:uniswap_app/theme/app_colors.dart';
import 'package:uniswap_app/widgets/product_card.dart';
import 'package:uniswap_app/pages/discover/discover_page.dart';
import 'package:uniswap_app/models/product.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _scrollCtrl = ScrollController();

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _openDiscover({TradeType? tradeType, String? category}) {
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (_) => DiscoverPage(initialTradeType: tradeType, initialCategory: category),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<DataRepository>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        color: AppColors.primary,
        backgroundColor: Colors.white,
        onRefresh: () async {
          await Future.delayed(const Duration(milliseconds: 600));
        },
        child: ListView(
          controller: _scrollCtrl,
          padding: EdgeInsets.zero,
          children: [
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 6, 20, 0),
                child: Row(
                  children: [
                    SvgPicture.asset(
                      'UniSwap_Design_Package/assets/uniswap_logo.svg',
                      width: 24,
                      height: 24,
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'UniSwap',
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pushNamed('/campus'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.pageBg,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.location_on_outlined, size: 13, color: AppColors.primary),
                            const SizedBox(width: 3),
                            Text(
                              '云南大学 · ${repo.me.campus}',
                              style: const TextStyle(
                                fontSize: 11.5,
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Icon(Icons.chevron_right_rounded, size: 14, color: AppColors.primary),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            _buildSearchBar(),
            const SizedBox(height: 16),
            _buildQuickActions(),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GestureDetector(
                onTap: () => _openDiscover(),
                behavior: HitTestBehavior.opaque,
                child: const Row(
                  children: [
                    Text('最新闲置', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                    Spacer(),
                    Text('全部', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    Icon(Icons.chevron_right_rounded, size: 16, color: AppColors.textSecondary),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            _buildProductGrid(repo.products),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => Navigator.of(context).pushNamed('/search'),
          child: Container(
            height: 42,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.pageBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(Icons.search_rounded, color: AppColors.textSecondary, size: 18),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '搜索教材、数码、生活用品…',
                    style: TextStyle(fontSize: 13.5, color: AppColors.textSecondary),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    final items = [
      _Quick(Icons.shopping_bag_outlined, 'Buy', '二手', AppColors.primary, TradeType.sell),
      _Quick(Icons.card_giftcard_outlined, 'Give', '赠送', AppColors.secondary, TradeType.give),
      _Quick(Icons.swap_horiz_rounded, 'Swap', '交换', AppColors.warmOrange, TradeType.swap),
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          for (int i = 0; i < items.length; i++) ...[
            Expanded(child: _actionCard(items[i])),
            if (i < items.length - 1) const SizedBox(width: 10),
          ],
        ],
      ),
    );
  }

  Widget _actionCard(_Quick item) {
    return GestureDetector(
      onTap: () => _openDiscover(tradeType: item.type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: item.color.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(item.icon, color: item.color, size: 19),
            const SizedBox(width: 7),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.en,
                    style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: item.color),
                  ),
                  Text(
                    item.zh,
                    style: TextStyle(fontSize: 10.5, color: item.color.withValues(alpha: 0.8)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductGrid(List<Product> products) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 12,
          childAspectRatio: 0.68,
        ),
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return ProductCard(
            product: product,
            onTap: () => Navigator.of(context).pushNamed('/product', arguments: product.id),
            onFavorite: () => context.read<DataRepository>().toggleFavorite(product.id),
          );
        },
      ),
    );
  }
}

class _Quick {
  final IconData icon;
  final String en;
  final String zh;
  final Color color;
  final TradeType type;
  _Quick(this.icon, this.en, this.zh, this.color, this.type);
}
