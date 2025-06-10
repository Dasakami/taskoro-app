
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/shop_model.dart';
import '../../providers/shop_provider.dart';
import '../../providers/user_provider.dart';
import '../../theme/app_theme.dart';

class ChestScreen extends StatefulWidget {
  const ChestScreen({Key? key}) : super(key: key);

  @override
  State<ChestScreen> createState() => _ChestScreenState();
}

class _ChestScreenState extends State<ChestScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final shopProvider = Provider.of<ShopProvider>(context, listen: false);
      shopProvider.fetchChests();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundSecondary,
        title: const Text(
          'Сундуки',
          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        actions: [
          _buildCurrencyDisplay(),
        ],
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
                      shopProvider.fetchChests();
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

          if (shopProvider.chests.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.card_giftcard,
                    size: 64,
                    color: AppColors.textSecondary,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Нет доступных сундуков',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(16),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.8,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: shopProvider.chests.length,
              itemBuilder: (context, index) {
                final chest = shopProvider.chests[index];
                return _buildChestCard(chest);
              },
            ),
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

  Widget _buildChestCard(Chest chest) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final canAfford = _canAfford(userProvider, chest);

        return Card(
          color: AppColors.cardBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => _showChestDetails(context, chest, canAfford),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Chest image or icon
                  Expanded(
                    flex: 3,
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.backgroundSecondary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: chest.imageUrl != null
                          ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          chest.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.card_giftcard, color: AppColors.accentTertiary, size: 48),
                        ),
                      )
                          : const Icon(Icons.card_giftcard, color: AppColors.accentTertiary, size: 48),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Chest name
                  Text(
                    chest.name,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),

                  // Price
                  Row(
                    children: [
                      if (chest.priceCoins > 0) ...[
                        Icon(Icons.monetization_on, color: Colors.yellow[700], size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '${chest.priceCoins}',
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      if (chest.priceGems > 0) ...[
                        Icon(Icons.diamond, color: Colors.blue[400], size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '${chest.priceGems}',
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Reward range
                  Text(
                    'Награда: ${chest.minCoinsReward}-${chest.maxCoinsReward} монет',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  if (chest.maxGemsReward > 0)
                    Text(
                      '${chest.minGemsReward}-${chest.maxGemsReward} кристаллов',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  bool _canAfford(UserProvider userProvider, Chest chest) {
    if (userProvider.user == null) return false;

    return userProvider.user!.coins >= chest.priceCoins &&
        userProvider.user!.gems >= chest.priceGems;
  }

  void _showChestDetails(BuildContext context, Chest chest, bool canAfford) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildChestDetailsSheet(chest, canAfford),
    );
  }

  Widget _buildChestDetailsSheet(Chest chest, bool canAfford) {
    return Consumer2<ShopProvider, UserProvider>(
      builder: (context, shopProvider, userProvider, child) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  const Icon(Icons.card_giftcard, color: AppColors.accentTertiary, size: 32),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      chest.name,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Description
              Text(
                chest.description,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 16,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),

              // Price section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.backgroundSecondary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Цена',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (chest.priceCoins > 0)
                      Row(
                        children: [
                          Icon(Icons.monetization_on, color: Colors.yellow[700], size: 20),
                          const SizedBox(width: 8),
                          Text(
                            '${chest.priceCoins} монет',
                            style: const TextStyle(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    if (chest.priceGems > 0) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.diamond, color: Colors.blue[400], size: 20),
                          const SizedBox(width: 8),
                          Text(
                            '${chest.priceGems} кристаллов',
                            style: const TextStyle(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Rewards section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.backgroundSecondary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Возможные награды',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.monetization_on, color: Colors.yellow[700], size: 20),
                        const SizedBox(width: 8),
                        Text(
                          '${chest.minCoinsReward} - ${chest.maxCoinsReward} монет',
                          style: const TextStyle(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                    if (chest.maxGemsReward > 0) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.diamond, color: Colors.blue[400], size: 20),
                          const SizedBox(width: 8),
                          Text(
                            '${chest.minGemsReward} - ${chest.maxGemsReward} кристаллов',
                            style: const TextStyle(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Action button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: (canAfford && !shopProvider.isLoading)
                      ? () => _openChest(context, chest, shopProvider, userProvider)
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: canAfford ? AppColors.accentPrimary : AppColors.textSecondary,
                  ),
                  child: shopProvider.isLoading
                      ? const CircularProgressIndicator(color: AppColors.textPrimary)
                      : Text(
                    canAfford ? 'Открыть сундук' : 'Недостаточно средств',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _openChest(BuildContext context, Chest chest, ShopProvider shopProvider, UserProvider userProvider) async {
    final opening = await shopProvider.openChest(chest.id);

    if (opening != null) {
      // Update user currency locally
      userProvider.updateCurrency(
        coins: opening.coinsReward - chest.priceCoins,
        gems: opening.gemsReward - chest.priceGems,
      );

      Navigator.pop(context); // Close bottom sheet
      _showRewardDialog(context, opening);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(shopProvider.error ?? 'Ошибка открытия сундука'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showRewardDialog(BuildContext context, ChestOpening opening) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.celebration, color: AppColors.accentTertiary),
            SizedBox(width: 8),
            Text(
              'Поздравляем!',
              style: TextStyle(color: AppColors.textPrimary),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Вы получили из сундука "${opening.chest.name}":',
              style: const TextStyle(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            if (opening.coinsReward > 0)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.monetization_on, color: Colors.yellow[700]),
                  const SizedBox(width: 8),
                  Text(
                    '+${opening.coinsReward} монет',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            if (opening.gemsReward > 0) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.diamond, color: Colors.blue[400]),
                  const SizedBox(width: 8),
                  Text(
                    '+${opening.gemsReward} кристаллов',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Отлично!',
              style: TextStyle(color: AppColors.accentPrimary),
            ),
          ),
        ],
      ),
    );
  }
}