import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/shop_model.dart';
import '../../providers/shop_provider.dart';
import '../../providers/user_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/magic_card.dart';
import 'shop_category_screen.dart';
import 'item_detail_screen.dart';
import 'inventory_screen.dart';
import 'chests_screen.dart';

class ShopHomeScreen extends StatefulWidget {
  const ShopHomeScreen({super.key});

  @override
  State<ShopHomeScreen> createState() => _ShopHomeScreenState();
}

class _ShopHomeScreenState extends State<ShopHomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshShop();
    });
  }

  Future<void> _refreshShop() async {
    final provider = Provider.of<ShopProvider>(context, listen: false);
    await provider.fetchShopItems();
    await provider.fetchChests();
    await provider.fetchInventory();
  }

  void _navigateToCategory(ItemType type) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ShopCategoryScreen(category: type),
      ),
    );
  }

  void _navigateToItem(ShopItem item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ItemDetailScreen(item: item),
      ),
    );
  }

  void _navigateToInventory() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const InventoryScreen(),
      ),
    );
  }

  void _navigateToChests() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ChestsScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Consumer2<ShopProvider, UserProvider>(
        builder: (context, shopProvider, userProvider, child) {
          return RefreshIndicator(
            onRefresh: _refreshShop,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Заголовок и баланс
                  _buildHeader(userProvider),

                  const SizedBox(height: 20),

                  // Быстрые действия
                  _buildQuickActions(),

                  const SizedBox(height: 24),

                  // Рекомендуемые товары
                  if (shopProvider.featuredItems.isNotEmpty) ...[
                    _buildSectionTitle('🔥 Горячие предложения'),
                    const SizedBox(height: 12),
                    _buildFeaturedItems(shopProvider.featuredItems),
                    const SizedBox(height: 24),
                  ],

                  // Категории
                  _buildSectionTitle('🛍️ Категории'),
                  const SizedBox(height: 12),
                  _buildCategories(),

                  const SizedBox(height: 24),

                  // Новые поступления
                  if (shopProvider.shopItems.isNotEmpty) ...[
                    _buildSectionTitle('✨ Новые поступления'),
                    const SizedBox(height: 12),
                    _buildNewItems(shopProvider.shopItems.take(4).toList()),
                  ],

                  const SizedBox(height: 100),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(UserProvider userProvider) {
    final user = userProvider.user;
    return MagicCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: AppColors.gradientPrimary),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.store,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Магазин',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(
                        'Улучшай свой опыт!',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Баланс
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.accentPrimary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.accentPrimary.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.monetization_on, color: AppColors.accentPrimary),
                        const SizedBox(width: 8),
                        Text(
                          '${user?.coins ?? 0}',
                          style: const TextStyle(
                            color: AppColors.accentPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.purple.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.purple.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.diamond, color: Colors.purple),
                        const SizedBox(width: 8),
                        Text(
                          '${user?.gems ?? 0}',
                          style: const TextStyle(
                            color: Colors.purple,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
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

  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          child: _buildActionCard(
            icon: Icons.inventory,
            title: 'Инвентарь',
            subtitle: 'Мои предметы',
            color: Colors.blue,
            onTap: _navigateToInventory,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionCard(
            icon: Icons.card_giftcard,
            title: 'Сундуки',
            subtitle: 'Открой сюрприз',
            color: Colors.orange,
            onTap: _navigateToChests,
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return MagicCard(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              subtitle,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildFeaturedItems(List<ShopItem> items) {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return Container(
            width: 160,
            margin: EdgeInsets.only(right: index < items.length - 1 ? 12 : 0),
            child: _buildItemCard(item, featured: true),
          );
        },
      ),
    );
  }

  Widget _buildCategories() {
    final categories = [
      {'type': ItemType.avatar, 'icon': Icons.person, 'name': 'Аватары'},
      {'type': ItemType.boost, 'icon': Icons.flash_on, 'name': 'Усиления'},
      {'type': ItemType.decoration, 'icon': Icons.palette, 'name': 'Декорации'},
      {'type': ItemType.theme, 'icon': Icons.color_lens, 'name': 'Темы'},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.5,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return MagicCard(
          onTap: () => _navigateToCategory(category['type'] as ItemType),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  category['icon'] as IconData,
                  size: 32,
                  color: AppColors.accentPrimary,
                ),
                const SizedBox(height: 8),
                Text(
                  category['name'] as String,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNewItems(List<ShopItem> items) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.75,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return _buildItemCard(items[index]);
      },
    );
  }

  Widget _buildItemCard(ShopItem item, {bool featured = false}) {
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

            // Название и редкость
            Text(
              item.name,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),

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

            const SizedBox(height: 4),

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
              ],
            ),

            if (item.hasDiscount)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '-${item.discountPercent}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
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
}