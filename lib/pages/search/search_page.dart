import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uniswap_app/services/data_repository.dart';
import 'package:uniswap_app/theme/app_colors.dart';
import 'package:uniswap_app/widgets/product_card.dart';
import 'package:uniswap_app/widgets/empty_state.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _ctrl = TextEditingController();
  String _keyword = '';
  final List<String> _history = ['耳机', '教材', 'iPad', '自行车'];

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<DataRepository>();
    final results = _keyword.isEmpty ? <Never>[] : repo.searchProducts(_keyword);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Container(
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.pageBg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const SizedBox(width: 12),
              const Icon(Icons.search_rounded, size: 18, color: AppColors.textSecondary),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  autofocus: true,
                  controller: _ctrl,
                  onChanged: (v) => setState(() => _keyword = v.trim()),
                  decoration: const InputDecoration(
                    hintText: '搜索闲置物品',
                    hintStyle: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                    border: InputBorder.none,
                  ),
                ),
              ),
              if (_keyword.isNotEmpty)
                GestureDetector(
                  onTap: () {
                    _ctrl.clear();
                    setState(() => _keyword = '');
                  },
                  child: const Padding(
                    padding: EdgeInsets.only(right: 10),
                    child: Icon(Icons.close, size: 18, color: AppColors.textSecondary),
                  ),
                ),
            ],
          ),
        ),
      ),
      body: _keyword.isEmpty ? _buildSuggestions() : _buildResults(results),
    );
  }

  Widget _buildSuggestions() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text('搜索历史', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _history.map((h) {
            return GestureDetector(
              onTap: () {
                _ctrl.text = h;
                setState(() => _keyword = h);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.pageBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(h, style: const TextStyle(fontSize: 13, color: AppColors.textPrimary)),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 24),
        const Text('热门搜索', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        ...['双肩包', '耳机', '教材', '台灯', '球拍'].map((h) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: GestureDetector(
              onTap: () {
                _ctrl.text = h;
                setState(() => _keyword = h);
              },
              child: Row(
                children: [
                  const Icon(Icons.trending_up, size: 16, color: AppColors.warmOrange),
                  const SizedBox(width: 8),
                  Text(h, style: const TextStyle(fontSize: 14)),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildResults(results) {
    if (results.isEmpty) {
      return const EmptyState(
        icon: Icons.search_off_rounded,
        title: '没有找到相关物品',
        subtitle: '试试换个关键词吧',
      );
    }
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 12,
        childAspectRatio: 0.72,
      ),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final product = results[index];
        return ProductCard(
          product: product,
          onTap: () => Navigator.of(context).pushNamed('/product', arguments: product.id),
          onFavorite: () => context.read<DataRepository>().toggleFavorite(product.id),
        );
      },
    );
  }
}
