
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/shop_provider.dart';
import '../../providers/user_provider.dart';
import '../../theme/app_theme.dart';
import 'chests_screen.dart';
import 'inventory_screen.dart';
import 'item_detail_screen.dart';

class ShopHomeScreen extends StatefulWidget {
  const ShopHomeScreen({Key? key}) : super(key: key);

  @override
  State<ShopHomeScreen> createState() => _ShopHomeScreenState();
}

class _ShopHomeScreenState extends State<ShopHomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> categories = ['all', 'title', 'avatar_frame', 'background', 'boost'];
  final List<String> categoryNames = ['Все', 'Титулы', 'Рамки', 'Фоны', 'Бусты'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: categories.length, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final shopProvider = Provider.of<ShopProvider>(context, listen: false);
      final userProvider = Provider.of<UserProvider>(context, listen: false);

      shopProvider.setAccessToken(userProvider.accessToken);
      shopProvider.fetchShopItems();
      shopProvider.fetchUserPurchases();
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
          'Магазин',
          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.inventory, color: AppColors.accentPrimary),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const UserInventoryScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.card_giftcard, color: AppColors.accentTertiary),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ChestScreen()),
              );
            },
          ),
          _buildCurrencyDisplay(),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: AppColors.accentPrimary,
          labelColor: AppColors.textPrimary,
          unselectedLabelColor: AppColors.textSecondary,
          tabs: categoryNames.map((name) => Tab(text: name)).toList(),
          onTap: (index) {
            final shopProvider = Provider.of<ShopProvider>(context, listen: false);
            final category = categories[index] == 'all' ? null : categories[index];
            shopProvider.fetchShopItems(category: category);
          },
        ),
      ),
      body: Consumer<ShopProvider>(
        builder: (context, shopProvider, child) {
          if (shopProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.accentPrimary),
            );
          }

          if (shopProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    shopProvider.error!,
                    style: const TextStyle(color: AppColors.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      shopProvider.clearError();
                      shopProvider.fetchShopItems();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentPrimary,
                    ),
                    child: const Text('Повторить'),
                  ),
                ],
              ),
            );
          }

          return TabBarView(
            controller: _tabController,
            children: categories.map((category) {
              final items = category == 'all'
                  ? shopProvider.items
                  : shopProvider.getItemsByCategory(category);

              return _buildItemGrid(items);
            }).toList(),
          );
        },
      ),
    );
  }

  Widget _buildCurrencyDisplay() {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        if (userProvider.user == null) return Container();

        return Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Row(
            children: [
              Icon(Icons.monetization_on, color: Colors.yellow[700], size: 20),
              const SizedBox(width: 4),
              Text(
                '${userProvider.user!.coins}',
                style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 12),
              Icon(Icons.diamond, color: Colors.blue[400], size: 20),
              const SizedBox(width: 4),
              Text(
                '${userProvider.user!.gems}',
                style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildItemGrid(List items) {
    if (items.isEmpty) {
      return const Center(
        child: Text(
          'Нет доступных товаров',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.7,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return _buildItemCard(item);
        },
      ),
    );
  }

  Widget _buildItemCard(item) {
    return Consumer<ShopProvider>(
      builder: (context, shopProvider, child) {
        final isOwned = shopProvider.ownsItem(item.id);
        final isEquipped = shopProvider.isItemEquipped(item.id);

        return Card(
          color: AppColors.cardBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: isEquipped
                ? const BorderSide(color: AppColors.accentPrimary, width: 2)
                : BorderSide.none,
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ShopItemDetailScreen(item: item),
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
                      child: item.imageUrl != null
                          ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          item.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              _buildItemIcon(item.category),
                        ),
                      )
                          : _buildItemIcon(item.category),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Item name
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

                  // Price and status
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            item.currency == 'coins' ? Icons.monetization_on : Icons.diamond,
                            color: item.currency == 'coins' ? Colors.yellow[700] : Colors.blue[400],
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${item.price}',
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      if (isOwned)
                        Icon(
                          isEquipped ? Icons.check_circle : Icons.inventory,
                          color: isEquipped ? AppColors.accentPrimary : AppColors.accentTertiary,
                          size: 20,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
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
}
