import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/shop_model.dart';
import '../../providers/shop_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/magic_card.dart';
import 'item_detail_screen.dart';

class ShopCategoryScreen extends StatefulWidget {
  final ItemType category;

  const ShopCategoryScreen({
    super.key,
    required this.category,
  });

  @override
  State<ShopCategoryScreen> createState() => _ShopCategoryScreenState();
}

class _ShopCategoryScreenState extends State<ShopCategoryScreen> {
  ItemRarity? _selectedRarity;
  String _sortBy = 'name'; // name, price, rarity

  String get _categoryName {
    switch (widget.category) {
      case ItemType.avatar_frame:
        return 'Аватары';
      case ItemType.boost:
        return 'Усиления';
      case ItemType.background:
        return 'Декорации';
      case ItemType.title:
        return 'Темы';
        case ItemType.effect:
        return 'Эффекты';
      case ItemType.equipment:
        return 'Снаряжение';
    }
  }

  IconData get _categoryIcon {
    switch (widget.category) {
      case ItemType.avatar_frame:
        return Icons.person;
      case ItemType.boost:
        return Icons.flash_on;
      case ItemType.background:
        return Icons.palette;
      case ItemType.title:
        return Icons.color_lens;
      case ItemType.equipment:
        return Icons.build;
        case ItemType.effect:
        return Icons.lightbulb;
    }
  }

  List<ShopItem> _getFilteredAndSortedItems(List<ShopItem> items) {
    var filtered = items.where((item) => item.type == widget.category).toList();

    if (_selectedRarity != null) {
      filtered = filtered.where((item) => item.rarity == _selectedRarity).toList();
    }

    filtered.sort((a, b) {
      switch (_sortBy) {
        case 'price':
          return a.finalPrice.compareTo(b.finalPrice);
        case 'rarity':
          return a.rarity.index.compareTo(b.rarity.index);
        default:
          return a.name.compareTo(b.name);
      }
    });

    return filtered;
  }

  void _navigateToItem(ShopItem item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ItemDetailScreen(item: item),
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundSecondary,
        title: const Text('Фильтры и сортировка'),
        content: StatefulBuilder(
          builder: (context, setDialogState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Фильтр по редкости
              const Text('Редкость:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  FilterChip(
                    label: const Text('Все'),
                    selected: _selectedRarity == null,
                    onSelected: (selected) {
                      setDialogState(() {
                        _selectedRarity = selected ? null : _selectedRarity;
                      });
                    },
                  ),
                  ...ItemRarity.values.map((rarity) => FilterChip(
                    label: Text(rarity.name),
                    selected: _selectedRarity == rarity,
                    selectedColor: _getRarityColor(rarity).withOpacity(0.3),
                    onSelected: (selected) {
                      setDialogState(() {
                        _selectedRarity = selected ? rarity : null;
                      });
                    },
                  )),
                ],
              ),

              const SizedBox(height: 16),

              // Сортировка
              const Text('Сортировка:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _sortBy,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'name', child: Text('По названию')),
                  DropdownMenuItem(value: 'price', child: Text('По цене')),
                  DropdownMenuItem(value: 'rarity', child: Text('По редкости')),
                ],
                onChanged: (value) {
                  setDialogState(() {
                    _sortBy = value!;
                  });
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {});
              Navigator.of(context).pop();
            },
            child: const Text('Применить'),
          ),
        ],
      ),
    );
  }

  Color _getRarityColor(ItemRarity rarity) {
    switch (rarity) {
      case ItemRarity.common:
        return Colors.grey;
      case ItemRarity.rare:
        return Colors.blue;
      case ItemRarity.epic:
        return Colors.purple;
      case ItemRarity.legendary:
        return Colors.orange;
      case ItemRarity.mythic:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundSecondary,
      appBar: AppBar(
        title: Row(
          children: [
            Icon(_categoryIcon, color: AppColors.accentPrimary),
            const SizedBox(width: 8),
            Text(_categoryName),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _showFilterDialog,
            icon: const Icon(Icons.filter_list),
          ),
        ],
      ),
      body: Consumer<ShopProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.shopItems.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          final items = _getFilteredAndSortedItems(provider.shopItems);

          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _categoryIcon,
                    size: 64,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Нет товаров в категории "$_categoryName"',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Попробуйте изменить фильтры',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Информация о фильтрах
              if (_selectedRarity != null)
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundSecondary,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.filter_list, color: AppColors.textSecondary, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        'Фильтр: ${_selectedRarity!.name}',
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedRarity = null;
                          });
                        },
                        child: const Icon(Icons.clear, color: AppColors.textSecondary, size: 16),
                      ),
                    ],
                  ),
                ),

              // Сетка товаров
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.75,
                  ),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return _buildItemCard(item);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildItemCard(ShopItem item) {
    return MagicCard(
      onTap: () => _navigateToItem(item),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Изображение товара
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      item.rarityColor.withOpacity(0.2),
                      item.rarityColor.withOpacity(0.1),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: item.imageUrl != null
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    item.imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _buildItemIcon(item),
                  ),
                )
                    : _buildItemIcon(item),
              ),
            ),

            const SizedBox(height: 8),

            // Название
            Text(
              item.name,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 4),

            // Редкость
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: item.rarityColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                item.rarityName,
                style: TextStyle(
                  color: item.rarityColor,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Цена
            Row(
              children: [
                Icon(
                  item.currency == 'coins' ? Icons.monetization_on : Icons.diamond,
                  size: 16,
                  color: item.currency == 'coins' ? AppColors.accentPrimary : Colors.purple,
                ),
                const SizedBox(width: 4),
                if (item.hasDiscount) ...[
                  Text(
                    '${item.price}',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                  const SizedBox(width: 4),
                ],
                Text(
                  '${item.finalPrice}',
                  style: TextStyle(
                    color: item.currency == 'coins' ? AppColors.accentPrimary : Colors.purple,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const Spacer(),
                if (item.hasDiscount)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '-${item.discountPercent}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemIcon(ShopItem item) {
    return Center(
      child: Icon(
        _categoryIcon,
        size: 48,
        color: item.rarityColor,
      ),
    );
  }
}