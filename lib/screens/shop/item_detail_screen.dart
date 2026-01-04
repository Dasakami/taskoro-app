
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/shop_model.dart';
import '../../providers/shop_provider.dart';
import '../../providers/user_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/state_wrapper.dart';

class ShopItemDetailScreen extends StatelessWidget {
  final ShopItem item;

  const ShopItemDetailScreen({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundSecondary,
        title: Text(
          item.name,
          style: const TextStyle(color: AppColors.textPrimary),
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: Consumer2<ShopProvider, UserProvider>(
        builder: (context, shopProvider, userProvider, child) {
          final isOwned = shopProvider.ownsItem(item.id);
          final isEquipped = shopProvider.isItemEquipped(item.id);
          final canAfford = _canAfford(userProvider, item);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Item image
                Container(
                  width: double.infinity,
                  height: 250,
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: item.imageUrl != null
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      item.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          _buildItemIcon(item.category),
                    ),
                  )
                      : _buildItemIcon(item.category),
                ),
                const SizedBox(height: 20),

                // Item name and category
                Text(
                  item.name,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.accentPrimary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _getCategoryName(item.category),
                    style: const TextStyle(
                      color: AppColors.accentPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Description
                Text(
                  'Описание',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  item.description,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 20),

                // Special properties
                if (item.category == 'boost') ...[
                  _buildBoostInfo(),
                  const SizedBox(height: 20),
                ],

                // Price section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Цена',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            item.currency == 'coins' ? Icons.monetization_on : Icons.diamond,
                            color: item.currency == 'coins' ? Colors.yellow[700] : Colors.blue[400],
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${item.price}',
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            item.currency == 'coins' ? 'монет' : 'кристаллов',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      if (!canAfford && !isOwned) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Недостаточно средств',
                          style: TextStyle(
                            color: Colors.red[400],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // User balance
                _buildUserBalance(userProvider),
                const SizedBox(height: 30),

                // Action button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: _buildActionButton(context, shopProvider, userProvider, isOwned, isEquipped, canAfford),
                ),
              ],
            ),
          );
        },
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

    return Icon(icon, color: color, size: 100);
  }

  Widget _buildBoostInfo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Эффект буста',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          if (item.boostMultiplier != null)
            Row(
              children: [
                const Icon(Icons.trending_up, color: Colors.green, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Множитель: x${item.boostMultiplier}',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          if (item.boostDuration != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.access_time, color: Colors.blue, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Длительность: ${item.boostDuration} часов',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildUserBalance(UserProvider userProvider) {
    if (userProvider.user == null) return Container();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ваш баланс',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.monetization_on, color: Colors.yellow[700], size: 20),
              const SizedBox(width: 8),
              Text(
                '${userProvider.user!.coins} монет',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.diamond, color: Colors.blue[400], size: 20),
              const SizedBox(width: 8),
              Text(
                '${userProvider.user!.gems} кристаллов',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, ShopProvider shopProvider, UserProvider userProvider,
      bool isOwned, bool isEquipped, bool canAfford) {

    if (shopProvider.isLoading) {
      return ElevatedButton(
        onPressed: null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accentPrimary.withOpacity(0.5),
        ),
        child: const CircularProgressIndicator(color: AppColors.textPrimary),
      );
    }

    if (isOwned) {
      if (item.category == 'boost') {
        return ElevatedButton(
          onPressed: isEquipped ? null : () => _activateBoost(context, shopProvider),
          style: ElevatedButton.styleFrom(
            backgroundColor: isEquipped ? AppColors.textSecondary : AppColors.accentPrimary,
          ),
          child: Text(
            isEquipped ? 'Активен' : 'Активировать',
            style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
          ),
        );
      } else {
        return ElevatedButton(
          onPressed: () => _toggleEquip(context, shopProvider, isEquipped),
          style: ElevatedButton.styleFrom(
            backgroundColor: isEquipped ? AppColors.accentSecondary : AppColors.accentPrimary,
          ),
          child: Text(
            isEquipped ? 'Снять' : 'Экипировать',
            style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
          ),
        );
      }
    } else {
      return ElevatedButton(
        onPressed: canAfford ? () => _purchaseItem(context, shopProvider, userProvider) : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: canAfford ? AppColors.accentPrimary : AppColors.textSecondary,
        ),
        child: Text(
          canAfford ? 'Купить' : 'Недостаточно средств',
          style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
        ),
      );
    }
  }

  bool _canAfford(UserProvider userProvider, ShopItem item) {
    if (userProvider.user == null) return false;

    if (item.currency == 'coins') {
      return userProvider.user!.coins >= item.price;
    } else {
      return userProvider.user!.gems >= item.price;
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

  void _purchaseItem(BuildContext context, ShopProvider shopProvider, UserProvider userProvider) async {
    final success = await shopProvider.purchaseItem(item.id);

    if (success) {
      // Update user currency locally
      userProvider.updateCurrency(
        coins: item.currency == 'coins' ? -item.price : 0,
        gems: item.currency == 'gems' ? -item.price : 0,
      );

      AppSnackBar.showSuccess(context, message: '${item.name} успешно куплен!');
    } else {
      AppSnackBar.showError(context, shopProvider.error ?? 'Ошибка покупки');
    }
  }

  void _toggleEquip(BuildContext context, ShopProvider shopProvider, bool isEquipped) async {
    final purchase = shopProvider.purchases.firstWhere((p) => p.item.id == item.id);

    bool success;
    if (isEquipped) {
      success = await shopProvider.unequipItem(purchase.id);
    } else {
      success = await shopProvider.equipItem(purchase.id);
    }

    if (success) {
      AppSnackBar.showSuccess(context, message: isEquipped ? 'Предмет снят' : 'Предмет экипирован');
    } else {
      AppSnackBar.showError(context, shopProvider.error ?? 'Ошибка');
    }
  }

  void _activateBoost(BuildContext context, ShopProvider shopProvider) async {
    final purchase = shopProvider.purchases.firstWhere((p) => p.item.id == item.id);

    final success = await shopProvider.equipItem(purchase.id);

    if (success) {
      AppSnackBar.showSuccess(context, message: 'Буст активирован!');
    } else {
      AppSnackBar.showError(context, shopProvider.error ?? 'Ошибка активации');
    }
  }
}
