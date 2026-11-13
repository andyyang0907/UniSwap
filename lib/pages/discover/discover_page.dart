import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uniswap_app/services/data_repository.dart';
import 'package:uniswap_app/theme/app_colors.dart';
import 'package:uniswap_app/widgets/product_card.dart';
import 'package:uniswap_app/widgets/empty_state.dart';
import 'package:uniswap_app/models/product.dart';

class DiscoverPage extends StatefulWidget {
  final TradeType? initialTradeType;
  final String? initialCategory;
  const DiscoverPage({super.key, this.initialTradeType, this.initialCategory});

  @override
  State<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage> {
  final _searchCtrl = TextEditingController();
  String _keyword = '';
  late List<TradeType> _selectedTradeTypes;
  late List<String> _selectedCategories;

  @override
  void initState() {
    super.initState();
    _selectedTradeTypes = widget.initialTradeType != null ? [widget.initialTradeType!] : [];
    _selectedCategories = widget.initialCategory != null ? [widget.initialCategory!] : [];
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<Product> _getResults(DataRepository repo) {
    List<Product> list;
    if (_keyword.isEmpty) {
      list = repo.products;
    } else {
      list = repo.searchProducts(_keyword);
    }
    if (_selectedTradeTypes.isNotEmpty) {
      list = list.where((p) => _selectedTradeTypes.contains(p.tradeType)).toList();
    }
    if (_selectedCategories.isNotEmpty) {
      list = list.where((p) => _selectedCategories.contains(p.category)).toList();
    }
    return list;
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      builder: (_) => _FilterSheet(
        initialTradeTypes: _selectedTradeTypes,
        initialCategories: _selectedCategories,
        onApply: (tradeTypes, categories) {
          setState(() {
            _selectedTradeTypes = tradeTypes;
            _selectedCategories = categories;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<DataRepository>();
    final results = _getResults(repo);

    return Scaffold(
      backgroundColor: AppColors.pageBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('发现'),
        actions: [
          IconButton(
            onPressed: _showFilterSheet,
            icon: const Icon(Icons.tune_rounded),
            color: AppColors.textPrimary,
          ),
        ],
      ),
      body: Column(
        children: [
          _searchBar(),
          _buildCategoryBar(),
          if (_keyword.isNotEmpty || _selectedTradeTypes.isNotEmpty || _selectedCategories.isNotEmpty)
            _activeFilters(),
          Expanded(
            child: results.isEmpty
                ? const EmptyState(
                    icon: Icons.search_off_rounded,
                    title: '没有找到匹配的物品',
                    subtitle: '试试换个关键词，或者清除筛选条件',
                  )
                : _resultGrid(results),
          ),
        ],
      ),
    );
  }

  Widget _searchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: Container(
        height: 46,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 14),
              child: Icon(Icons.search_rounded, size: 20, color: AppColors.textSecondary),
            ),
            Expanded(
              child: TextField(
                controller: _searchCtrl,
                onChanged: (v) => setState(() => _keyword = v.trim()),
                decoration: const InputDecoration(
                  hintText: '搜索教材、数码、生活用品…',
                  hintStyle: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 10),
                ),
              ),
            ),
            if (_keyword.isNotEmpty)
              GestureDetector(
                onTap: () {
                  _searchCtrl.clear();
                  setState(() => _keyword = '');
                },
                child: const Padding(
                  padding: EdgeInsets.only(right: 14),
                  child: Icon(Icons.close, size: 18, color: AppColors.textSecondary),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryBar() {
    const categories = ['数码', '教材', '生活用品', '运动', '其他'];
    return SizedBox(
      height: 38,
      child: Row(
        children: [
          Expanded(
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _categoryChip('全部', _selectedCategories.isEmpty, () {
                  setState(() => _selectedCategories = []);
                }),
                for (final c in categories)
                  _categoryChip(c, _selectedCategories.contains(c), () {
                    setState(() {
                      if (_selectedCategories.contains(c)) {
                        _selectedCategories.remove(c);
                      } else {
                        _selectedCategories.add(c);
                      }
                    });
                  }),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.of(context).pushNamed('/campus'),
            child: Container(
              margin: const EdgeInsets.only(right: 16, left: 4),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: AppColors.lightGreenBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                children: [
                  Icon(Icons.map_outlined, size: 14, color: AppColors.primary),
                  SizedBox(width: 4),
                  Text('校园地图', style: TextStyle(fontSize: 11.5, color: AppColors.primary, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _categoryChip(String label, bool selected, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: selected ? AppColors.primary : AppColors.divider),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
              color: selected ? Colors.white : AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _activeFilters() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Wrap(
        spacing: 6,
        runSpacing: 6,
        children: [
          ..._selectedTradeTypes.map((t) {
            final label = t == TradeType.sell
                ? '出售'
                : t == TradeType.give
                    ? '赠送'
                    : '交换';
            return _ActiveChip(label: label, onRemove: () {
              setState(() => _selectedTradeTypes.remove(t));
            });
          }),
          ..._selectedCategories.map((c) {
            return _ActiveChip(label: c, onRemove: () {
              setState(() => _selectedCategories.remove(c));
            });
          }),
        ],
      ),
    );
  }

  Widget _resultGrid(List<Product> results) {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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

class _ActiveChip extends StatelessWidget {
  final String label;
  final VoidCallback onRemove;
  const _ActiveChip({required this.label, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w500)),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(Icons.close, size: 14, color: AppColors.primary),
          ),
        ],
      ),
    );
  }
}

// ============ Filter Sheet ============
class _FilterSheet extends StatefulWidget {
  final List<TradeType> initialTradeTypes;
  final List<String> initialCategories;
  final void Function(List<TradeType>, List<String>) onApply;

  const _FilterSheet({
    required this.initialTradeTypes,
    required this.initialCategories,
    required this.onApply,
  });

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late List<TradeType> _tradeTypes;
  late List<String> _categories;

  @override
  void initState() {
    super.initState();
    _tradeTypes = List.from(widget.initialTradeTypes);
    _categories = List.from(widget.initialCategories);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                children: [
                  const Text('筛选', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _tradeTypes.clear();
                        _categories.clear();
                      });
                    },
                    child: const Text('重置', style: TextStyle(color: AppColors.textSecondary)),
                  ),
                ],
              ),
            ),
            _buildSectionTitle('交易方式'),
            _buildChipsRow<TradeType>(
              items: [TradeType.sell, TradeType.give, TradeType.swap],
              selected: _tradeTypes,
              label: (t) => t == TradeType.sell ? '出售' : t == TradeType.give ? '赠送' : '交换',
            ),
            _buildSectionTitle('分类'),
            _buildChipsRow<String>(
              items: ['数码', '教材', '生活用品', '运动', '其他'],
              selected: _categories,
              label: (s) => s,
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.divider),
                        foregroundColor: AppColors.textPrimary,
                        minimumSize: const Size.fromHeight(50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text('取消'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () {
                        widget.onApply(_tradeTypes, _categories);
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                      child: const Text('应用筛选', style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 10),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        ),
      ),
    );
  }

  Widget _buildChipsRow<T>({
    required List<T> items,
    required List<T> selected,
    required String Function(T) label,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: items.map((item) {
          final isSelected = selected.contains(item);
          return GestureDetector(
            onTap: () {
              setState(() {
                if (isSelected) {
                  selected.remove(item);
                } else {
                  selected.add(item);
                }
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: isSelected ? AppColors.primary : AppColors.divider),
              ),
              child: Text(
                label(item),
                style: TextStyle(
                  fontSize: 13,
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
