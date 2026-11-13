import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uniswap_app/services/data_repository.dart';
import 'package:uniswap_app/theme/app_colors.dart';
import 'package:uniswap_app/widgets/product_card.dart';
import 'package:uniswap_app/widgets/empty_state.dart';
import 'package:uniswap_app/widgets/app_buttons.dart';
import 'package:uniswap_app/widgets/app_image.dart';
import 'package:uniswap_app/models/transaction.dart';
import 'package:uniswap_app/pages/publish/publish_entry_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<DataRepository>();
    final me = repo.me;

    return Scaffold(
      backgroundColor: AppColors.pageBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('我的'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            color: AppColors.textPrimary,
            onPressed: () => Navigator.of(context).pushNamed('/settings'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Profile card
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: GestureDetector(
              onTap: () => Navigator.of(context).pushNamed('/profile_edit'),
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: const BoxDecoration(
                        color: AppColors.lightGreenBg,
                        shape: BoxShape.circle,
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: (me.avatar == null || me.avatar!.isEmpty)
                          ? const Icon(Icons.person_rounded, color: AppColors.secondary, size: 34)
                          : (me.avatar!.startsWith('http')
                              ? Image.network(me.avatar!, fit: BoxFit.cover)
                              : Image.file(File(me.avatar!), fit: BoxFit.cover)),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(me.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 2),
                          Text('云南大学 · ${me.campus} · 信用 ⭐${me.rating}',
                              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                          const SizedBox(height: 4),
                          Text(me.bio, maxLines: 1, overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                    const Icon(Icons.edit_outlined, size: 18, color: AppColors.textSecondary),
                  ],
                ),
              ),
            ),
          ),
          // Tab bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: TabBar(
              controller: _tabCtrl,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textSecondary,
              labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              unselectedLabelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
              indicatorColor: AppColors.primary,
              indicatorSize: TabBarIndicatorSize.label,
              indicatorPadding: const EdgeInsets.only(top: 6),
              tabs: const [
                Tab(text: '我的发布'),
                Tab(text: '我的收藏'),
                Tab(text: '我的交易'),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: TabBarView(
              controller: _tabCtrl,
              children: [
                _MyProductsTab(repo: repo),
                _MyFavoritesTab(repo: repo),
                _MyTransactionsTab(repo: repo),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MyProductsTab extends StatelessWidget {
  final DataRepository repo;
  const _MyProductsTab({required this.repo});

  @override
  Widget build(BuildContext context) {
    final list = repo.myProducts;
    if (list.isEmpty) {
      return EmptyState(
        icon: Icons.shopping_bag_outlined,
        title: '还没有发布过闲置',
        subtitle: '发布你的第一个闲置物品，让它找到新主人',
        action: PrimaryButton(
          text: '去发布',
          fullWidth: false,
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const PublishEntryPage()),
          ),
        ),
      );
    }
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 12,
        childAspectRatio: 0.72,
      ),
      itemCount: list.length,
      itemBuilder: (context, i) => ProductCard(
        product: list[i],
        onTap: () => Navigator.of(context).pushNamed('/product', arguments: list[i].id),
      ),
    );
  }
}

class _MyFavoritesTab extends StatelessWidget {
  final DataRepository repo;
  const _MyFavoritesTab({required this.repo});

  @override
  Widget build(BuildContext context) {
    final list = repo.favoriteProducts();
    if (list.isEmpty) {
      return const EmptyState(icon: Icons.favorite_border, title: '还没有收藏', subtitle: '看到喜欢的闲置，可以先收藏起来');
    }
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 12,
        childAspectRatio: 0.72,
      ),
      itemCount: list.length,
      itemBuilder: (context, i) => ProductCard(
        product: list[i],
        onTap: () => Navigator.of(context).pushNamed('/product', arguments: list[i].id),
        onFavorite: () => repo.toggleFavorite(list[i].id),
      ),
    );
  }
}

class _MyTransactionsTab extends StatelessWidget {
  final DataRepository repo;
  const _MyTransactionsTab({required this.repo});

  @override
  Widget build(BuildContext context) {
    final list = repo.myTransactions;
    if (list.isEmpty) {
      return const EmptyState(icon: Icons.handshake_outlined, title: '还没有进行中的交易', subtitle: '对心仪的闲置表达意向，开启交易吧');
    }
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      itemCount: list.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, i) => _TransactionTile(tx: list[i]),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final TransactionIntent tx;
  const _TransactionTile({required this.tx});

  @override
  Widget build(BuildContext context) {
    final accentColor = tx.status == TransactionStatus.completed
        ? AppColors.secondary
        : tx.status == TransactionStatus.cancelled
            ? AppColors.error
            : AppColors.primary;
    return GestureDetector(
      onTap: () => Navigator.of(context).pushNamed('/tx_detail', arguments: tx.id),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image(image: appImageProvider(tx.productImage), width: 60, height: 60, fit: BoxFit.cover),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(tx.productTitle, maxLines: 1, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(color: accentColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(6)),
                        child: Text(tx.statusLabel, style: TextStyle(fontSize: 11, color: accentColor, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('与 ${tx.toUserName}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  if (tx.appointment != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      '📅 ${_fmtDate(tx.appointment!.date)} · ${tx.appointment!.timeSlot}',
                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _fmtDate(DateTime dt) {
    return '${dt.month}/${dt.day}';
  }
}
