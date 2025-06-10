
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/shop_model.dart';
import '../../providers/shop_provider.dart';
import '../../theme/app_theme.dart';
import 'item_detail_screen.dart';


class UserInventoryScreen extends StatefulWidget {
  const UserInventoryScreen({super.key});

  @override
  State<UserInventoryScreen> createState() => _UserInventoryScreenState();
}

class _UserInventoryScreenState extends State<UserInventoryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> categories = ['all', 'title', 'avatar_frame', 'background', 'boost'];
  final List<String> categoryNames = ['Все', 'Титулы', 'Рамки', 'Фоны', 'Бусты'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: categories.length, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final shopProvider = Provider.of<ShopProvider>(context, listen: false);
      shopProvider.fetchUserPurchases();
      shopProvider.fetchActiveBoosts();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundSecondary,
        title: const Text(
          'Инвентарь',
          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: AppColors.accentPrimary,
          labelColor: AppColors.textPrimary,
          unselectedLabelColor: AppColors.textSecondary,
          tabs: categoryNames.map((name) => Tab(text: name)).toList(),
        ),
      ),
      body: Consumer<ShopProvider>(
        builder: (context, shopProvider, child) {
          if (shopProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.accentPrimary),
            );
          }

          return TabBarView(
            controller: _tabController,
            children: categories.map((category) {
              List<Purchase> purchases;
              if (category == 'all') {
                purchases = shopProvider.userInventory;
              } else {
                purchases = shopProvider.userInventory
                    .where((p) => p.item.category == category)
                    .toList();
              }

              return _buildInventoryGrid(purchases, category);
            }).toList(),
          );
        },
      ),
    );
  }

  Widget _buildInventoryGrid(List<Purchase> purchases, String category) {
    if (purchases.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getCategoryIcon(category),
              size: 64,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              category == 'all' ? 'Инвентарь пуст' : 'Нет предметов этой категории',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Active boosts section for boost category
        if (category == 'boost') _buildActiveBoostsSection(),

        // Inventory items
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: purchases.length,
              itemBuilder: (context, index) {
                final purchase = purchases[index];
                return _buildInventoryItemCard(purchase);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActiveBoostsSection() {
    return Consumer<ShopProvider>(
      builder: (context, shopProvider, child) {
        if (shopProvider.activeBoosts.isEmpty) {
          return Container();
        }

        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Активные бусты',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              ...shopProvider.activeBoosts.map((boost) => _buildActiveBoostItem(boost)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActiveBoostItem(ActiveBoost boost) {
    final timeLeft = boost.expiresAt.difference(DateTime.now());
    final hoursLeft = timeLeft.inHours;
    final minutesLeft = timeLeft.inMinutes % 60;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.flash_on, color: Colors.orange, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  boost.boostItem.name,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'x${boost.multiplier} | ${hoursLeft}ч ${minutesLeft}м',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInventoryItemCard(Purchase purchase) {
    return Card(
      color: AppColors.cardBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: purchase.isEquipped
            ? const BorderSide(color: AppColors.accentPrimary, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ShopItemDetailScreen(item: purchase.item),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Item image or icon
              Expanded(
                flex: 3,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.backgroundSecondary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: purchase.item.imageUrl != null
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      purchase.item.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          _buildItemIcon(purchase.item.category),
                    ),
                  )
                      : _buildItemIcon(purchase.item.category),
                ),
              ),
              const SizedBox(height: 8),

              // Item name
              Text(
                purchase.item.name,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),

              // Status and purchase date
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _getCategoryName(purchase.item.category),
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  Icon(
                    purchase.isEquipped ? Icons.check_circle : Icons.inventory,
                    color: purchase.isEquipped ? AppColors.accentPrimary : AppColors.textSecondary,
                    size: 16,
                  ),
                ],
              ),
              if (purchase.quantity > 1) ...[
                const SizedBox(height: 4),
                Text(
                  'Количество: ${purchase.quantity}',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItemIcon(String category) {
    IconData icon;
    Color color;

    switch (category) {
      case 'title':
        icon = Icons.title;
        color = AppColors.accentPrimary;
        break;
      case 'avatar_frame':
        icon = Icons.account_circle;
        color = AppColors.accentSecondary;
        break;
      case 'background':
        icon = Icons.wallpaper;
        color = AppColors.accentTertiary;
        break;
      case 'boost':
        icon = Icons.flash_on;
        color = Colors.orange;
        break;
      default:
        icon = Icons.shopping_bag;
        color = AppColors.textSecondary;
    }

    return Icon(icon, color: color, size: 48);
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'title':
        return Icons.title;
      case 'avatar_frame':
        return Icons.account_circle;
      case 'background':
        return Icons.wallpaper;
      case 'boost':
        return Icons.flash_on;
      default:
        return Icons.inventory;
    }
  }

  String _getCategoryName(String category) {
    switch (category) {
      case 'title':
        return 'Титул';
      case 'avatar_frame':
        return 'Рамка';
      case 'background':
        return 'Фон';
      case 'boost':
        return 'Буст';
      default:
        return 'Предмет';
    }
  }
}