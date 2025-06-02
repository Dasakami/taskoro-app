import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/shop_model.dart';
import '../../providers/shop_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/magic_card.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  ItemType? _selectedType;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: ItemType.values.length + 1, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ShopProvider>(context, listen: false).fetchInventory();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<InventoryItem> _getFilteredItems(List<InventoryItem> items) {
    if (_selectedType == null) return items;
    return items.where((item) => item.item.type == _selectedType).toList();
  }

  void _showItemOptions(InventoryItem inventoryItem) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.backgroundSecondary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textSecondary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),

            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        inventoryItem.item.rarityColor.withOpacity(0.2),
                        inventoryItem.item.rarityColor.withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: _buildItemIcon(inventoryItem.item),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        inventoryItem.item.name,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        'Количество: ${inventoryItem.quantity}',
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            if (inventoryItem.item.type == ItemType.boost)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _useItem(inventoryItem);
                  },
                  icon: const Icon(Icons.flash_on),
                  label: const Text('Использовать'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentPrimary,
                  ),
                ),
              ),

            if (inventoryItem.item.type == ItemType.avatar ||
                inventoryItem.item.type == ItemType.theme ||
                inventoryItem.item.type == ItemType.decoration)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _equipItem(inventoryItem);
                  },
                  icon: Icon(inventoryItem.isEquipped ? Icons.check_circle : Icons.circle_outlined),
                  label: Text(inventoryItem.isEquipped ? 'Снять' : 'Экипировать'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: inventoryItem.isEquipped ? Colors.orange : AppColors.accentPrimary,
                  ),
                ),
              ),

            const SizedBox(height: 8),

            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _showItemDetails(inventoryItem);
                },
                icon: const Icon(Icons.info_outline),
                label: const Text('Подробнее'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _useItem(InventoryItem inventoryItem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Использован предмет: ${inventoryItem.item.name}'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _equipItem(InventoryItem inventoryItem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          inventoryItem.isEquipped
              ? 'Предмет снят: ${inventoryItem.item.name}'
              : 'Предмет экипирован: ${inventoryItem.item.name}',
        ),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _showItemDetails(InventoryItem inventoryItem) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundSecondary,
        title: Text(inventoryItem.item.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(inventoryItem.item.description),
            const SizedBox(height: 16),
            _buildDetailRow('Тип', inventoryItem.item.typeName),
            _buildDetailRow('Редкость', inventoryItem.item.rarityName),
            _buildDetailRow('Количество', '${inventoryItem.quantity}'),
            _buildDetailRow('Получено', _formatDate(inventoryItem.acquiredAt)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Закрыть'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}.${date.month}.${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundSecondary,
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.inventory, color: AppColors.accentPrimary),
            SizedBox(width: 8),
            Text('Инвентарь'),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: AppColors.accentPrimary,
          labelColor: AppColors.textPrimary,
          unselectedLabelColor: AppColors.textSecondary,
          onTap: (index) {
            setState(() {
              _selectedType = index == 0 ? null : ItemType.values[index - 1];
            });
          },
          tabs: [
            const Tab(text: 'Все'),
            ...ItemType.values.map((type) => Tab(text: _getTypeName(type))),
          ],
        ),
      ),
      body: Consumer<ShopProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.inventory.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          final filteredItems = _getFilteredItems(provider.inventory);

          if (filteredItems.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 64,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _selectedType == null
                        ? 'Инвентарь пуст'
                        : 'Нет предметов типа "${_getTypeName(_selectedType!)}"',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Купите предметы в магазине',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.8,
            ),
            itemCount: filteredItems.length,
            itemBuilder: (context, index) {
              final inventoryItem = filteredItems[index];
              return _buildInventoryCard(inventoryItem);
            },
          );
        },
      ),
    );
  }

  Widget _buildInventoryCard(InventoryItem inventoryItem) {
    return MagicCard(
      onTap: () => _showItemOptions(inventoryItem),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Статус экипировки
            if (inventoryItem.isEquipped)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle, size: 12, color: Colors.green),
                    SizedBox(width: 4),
                    Text(
                      'Экипировано',
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

            // Изображение предмета
            Expanded(
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      inventoryItem.item.rarityColor.withOpacity(0.2),
                      inventoryItem.item.rarityColor.withOpacity(0.1),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: inventoryItem.item.imageUrl != null
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    inventoryItem.item.imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _buildItemIcon(inventoryItem.item),
                  ),
                )
                    : _buildItemIcon(inventoryItem.item),
              ),
            ),

            // Название
            Text(
              inventoryItem.item.name,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 4),

            // Редкость и количество
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: inventoryItem.item.rarityColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    inventoryItem.item.rarityName,
                    style: TextStyle(
                      color: inventoryItem.item.rarityColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const Spacer(),
                if (inventoryItem.quantity > 1)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.accentPrimary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'x${inventoryItem.quantity}',
                      style: const TextStyle(
                        color: AppColors.accentPrimary,
                        fontSize: 10,
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
    IconData icon;
    switch (item.type) {
      case ItemType.avatar:
        icon = Icons.person;
        break;
      case ItemType.boost:
        icon = Icons.flash_on;
        break;
      case ItemType.decoration:
        icon = Icons.palette;
        break;
      case ItemType.theme:
        icon = Icons.color_lens;
        break;
      case ItemType.equipment:
        icon = Icons.build;
        break;
    }

    return Center(
      child: Icon(
        icon,
        size: 48,
        color: item.rarityColor,
      ),
    );
  }

  String _getTypeName(ItemType type) {
    switch (type) {
      case ItemType.avatar:
        return 'Аватары';
      case ItemType.boost:
        return 'Усиления';
      case ItemType.decoration:
        return 'Декорации';
      case ItemType.theme:
        return 'Темы';
      case ItemType.equipment:
        return 'Снаряжение';
    }
  }
}