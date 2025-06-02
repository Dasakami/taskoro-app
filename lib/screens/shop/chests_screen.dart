import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/shop_model.dart';
import '../../providers/shop_provider.dart';
import '../../providers/user_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/magic_card.dart';

class ChestsScreen extends StatefulWidget {
  const ChestsScreen({super.key});

  @override
  State<ChestsScreen> createState() => _ChestsScreenState();
}

class _ChestsScreenState extends State<ChestsScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  bool _isOpening = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ShopProvider>(context, listen: false).fetchChests();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _openChest(Chest chest) async {
    setState(() {
      _isOpening = true;
    });

    _animationController.forward();

    final shopProvider = Provider.of<ShopProvider>(context, listen: false);
    final success = await shopProvider.purchaseChest(chest);

    await _animationController.reverse();

    setState(() {
      _isOpening = false;
    });

    if (mounted) {
      if (success) {
        _showRewardDialog();
      } else {
        _showErrorDialog(shopProvider.error ?? 'Ошибка покупки сундука');
      }
    }
  }

  void _showRewardDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundSecondary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.card_giftcard, color: Colors.amber),
            SizedBox(width: 8),
            Text('Поздравляем!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.amber, Colors.orange],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.star,
                size: 50,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            const Text('Вы получили награды!'),
            const SizedBox(height: 8),
            const Text(
              'Проверьте свой инвентарь',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Отлично!'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundSecondary,
        title: const Row(
          children: [
            Icon(Icons.error, color: Colors.red),
            SizedBox(width: 8),
            Text('Ошибка'),
          ],
        ),
        content: Text(error),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Понятно'),
          ),
        ],
      ),
    );
  }

  void _showChestInfo(Chest chest) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundSecondary,
        title: Text(chest.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(chest.description),
            const SizedBox(height: 16),
            const Text(
              'Возможные награды:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (chest.possibleRewards.isEmpty)
              const Text(
                '• Случайные предметы\n• Монеты и гемы\n• Усиления опыта',
                style: TextStyle(color: AppColors.textSecondary),
              )
            else
              ...chest.possibleRewards.map((reward) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text(
                  '• ${reward.itemName} (${(reward.dropChance * 100).toStringAsFixed(1)}%)',
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              )),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundSecondary,
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.card_giftcard, color: Colors.orange),
            SizedBox(width: 8),
            Text('Сундуки'),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Consumer2<ShopProvider, UserProvider>(
        builder: (context, shopProvider, userProvider, child) {
          if (shopProvider.isLoading && shopProvider.chests.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (shopProvider.chests.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 64,
                    color: AppColors.textSecondary,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Нет доступных сундуков',
                    style: TextStyle(
                      fontSize: 18,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Заголовок
                MagicCard(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Colors.orange, Colors.amber],
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.card_giftcard,
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
                                    'Магические сундуки',
                                    style: Theme.of(context).textTheme.titleLarge,
                                  ),
                                  Text(
                                    'Откройте и получите случайные награды!',
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
                                      '${userProvider.user?.coins ?? 0}',
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
                                      '${userProvider.user?.gems ?? 0}',
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
                ),

                const SizedBox(height: 20),

                // Сундуки
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: shopProvider.chests.length,
                  itemBuilder: (context, index) {
                    final chest = shopProvider.chests[index];
                    return _buildChestCard(chest, shopProvider.canAffordChest(chest));
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildChestCard(Chest chest, bool canAfford) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) => Transform.scale(
        scale: _isOpening ? 1.0 + (_animationController.value * 0.1) : 1.0,
        child: Transform.rotate(
          angle: _isOpening ? _animationController.value * 0.1 : 0.0,
          child: MagicCard(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Изображение сундука
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            _getChestColor(chest).withOpacity(0.2),
                            _getChestColor(chest).withOpacity(0.1),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: chest.imageUrl != null
                          ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          chest.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _buildChestIcon(chest),
                        ),
                      )
                          : _buildChestIcon(chest),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Название
                  Text(
                    chest.name,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 4),

                  // Описание
                  Text(
                    chest.description,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 12),

                  // Цена
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getPriceColor(chest).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          chest.currency == 'coins' ? Icons.monetization_on : Icons.diamond,
                          size: 16,
                          color: _getPriceColor(chest),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${chest.price}',
                          style: TextStyle(
                            color: _getPriceColor(chest),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Кнопки
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _showChestInfo(chest),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.border),
                          ),
                          child: const Icon(Icons.info_outline, size: 16),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: canAfford && !_isOpening ? () => _openChest(chest) : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: canAfford ? _getChestColor(chest) : Colors.grey,
                          ),
                          child: Text(
                            canAfford ? 'Открыть' : 'Нет средств',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChestIcon(Chest chest) {
    return Center(
      child: Icon(
        Icons.card_giftcard,
        size: 60,
        color: _getChestColor(chest),
      ),
    );
  }

  Color _getChestColor(Chest chest) {
    if (chest.price >= 200) return Colors.purple; // Легендарный
    if (chest.price >= 100) return Colors.orange; // Эпический
    if (chest.price >= 50) return Colors.blue; // Редкий
    return Colors.grey; // Обычный
  }

  Color _getPriceColor(Chest chest) {
    return chest.currency == 'coins' ? AppColors.accentPrimary : Colors.purple;
  }
}