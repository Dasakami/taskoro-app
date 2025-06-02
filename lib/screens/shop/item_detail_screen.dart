import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/shop_model.dart';
import '../../providers/shop_provider.dart';
import '../../providers/user_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/magic_card.dart';

class ItemDetailScreen extends StatefulWidget {
  final ShopItem item;

  const ItemDetailScreen({
    super.key,
    required this.item,
  });

  @override
  State<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  int _quantity = 1;
  bool _isPurchasing = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _purchaseItem() async {
    setState(() {
      _isPurchasing = true;
    });

    final shopProvider = Provider.of<ShopProvider>(context, listen: false);
    final success = await shopProvider.purchaseItem(widget.item, quantity: _quantity);

    setState(() {
      _isPurchasing = false;
    });

    if (mounted) {
      if (success) {
        _showSuccessDialog();
      } else {
        _showErrorDialog(shopProvider.error ?? 'Ошибка покупки');
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundSecondary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('Покупка успешна!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Вы приобрели "${widget.item.name}"'),
            if (_quantity > 1) Text('Количество: $_quantity'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    widget.item.currency == 'coins' ? Icons.monetization_on : Icons.diamond,
                    color: widget.item.currency == 'coins' ? AppColors.accentPrimary : Colors.purple,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Потрачено: ${widget.item.finalPrice * _quantity}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
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
            Text('Ошибка покупки'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundSecondary,
      body: Consumer2<ShopProvider, UserProvider>(
        builder: (context, shopProvider, userProvider, child) {
          final canAfford = shopProvider.canAfford(widget.item, quantity: _quantity);

          return CustomScrollView(
            slivers: [
              // App Bar с изображением
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                backgroundColor: Colors.transparent,
                flexibleSpace: FlexibleSpaceBar(
                  background: AnimatedBuilder(
                    animation: _scaleAnimation,
                    builder: (context, child) => Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              widget.item.rarityColor.withOpacity(0.3),
                              widget.item.rarityColor.withOpacity(0.1),
                              Colors.transparent,
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                        child: widget.item.imageUrl != null
                            ? Image.network(
                          widget.item.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _buildItemIcon(),
                        )
                            : _buildItemIcon(),
                      ),
                    ),
                  ),
                ),
              ),

              // Контент
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Основная информация
                      _buildMainInfo(),

                      const SizedBox(height: 20),

                      // Описание
                      _buildDescription(),

                      const SizedBox(height: 20),

                      // Характеристики
                      _buildCharacteristics(),

                      const SizedBox(height: 20),

                      // Скидка (если есть)
                      if (widget.item.hasDiscount) ...[
                        _buildDiscountInfo(),
                        const SizedBox(height: 20),
                      ],

                      // Количество и покупка
                      _buildPurchaseSection(canAfford),

                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildItemIcon() {
    IconData icon;
    switch (widget.item.type) {
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
        size: 120,
        color: widget.item.rarityColor,
      ),
    );
  }

  Widget _buildMainInfo() {
    return MagicCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.item.name,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: widget.item.rarityColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: widget.item.rarityColor),
                  ),
                  child: Text(
                    widget.item.rarityName,
                    style: TextStyle(
                      color: widget.item.rarityColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Text(
              widget.item.typeName,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),

            const SizedBox(height: 16),

            // Цена
            Row(
              children: [
                Icon(
                  widget.item.currency == 'coins' ? Icons.monetization_on : Icons.diamond,
                  size: 24,
                  color: widget.item.currency == 'coins' ? AppColors.accentPrimary : Colors.purple,
                ),
                const SizedBox(width: 8),
                if (widget.item.hasDiscount) ...[
                  Text(
                    '${widget.item.price}',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 18,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                Text(
                  '${widget.item.finalPrice}',
                  style: TextStyle(
                    color: widget.item.currency == 'coins' ? AppColors.accentPrimary : Colors.purple,
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
                const Spacer(),
                if (widget.item.hasDiscount)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '-${widget.item.discountPercent}%',
                      style: const TextStyle(
                        color: Colors.white,
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

  Widget _buildDescription() {
    return MagicCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Описание',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              widget.item.description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCharacteristics() {
    return MagicCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Характеристики',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildCharacteristicRow('Тип', widget.item.typeName),
            _buildCharacteristicRow('Редкость', widget.item.rarityName),
            _buildCharacteristicRow('Валюта', widget.item.currency == 'coins' ? 'Монеты' : 'Гемы'),
            if (widget.item.metadata != null) ...[
              ...widget.item.metadata!.entries.map((entry) =>
                  _buildCharacteristicRow(entry.key, entry.value.toString())),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCharacteristicRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            '$label:',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiscountInfo() {
    final timeLeft = widget.item.discountEndDate!.difference(DateTime.now());
    final daysLeft = timeLeft.inDays;
    final hoursLeft = timeLeft.inHours % 24;

    return MagicCard(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [
              Colors.red.withOpacity(0.1),
              Colors.orange.withOpacity(0.1),
            ],
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.local_fire_department, color: Colors.red),
                const SizedBox(width: 8),
                Text(
                  'Ограниченное предложение!',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Скидка ${widget.item.discountPercent}% заканчивается через ${daysLeft}д ${hoursLeft}ч',
              style: const TextStyle(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPurchaseSection(bool canAfford) {
    return MagicCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Количество
            Row(
              children: [
                Text(
                  'Количество:',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                Row(
                  children: [
                    IconButton(
                      onPressed: _quantity > 1 ? () {
                        setState(() {
                          _quantity--;
                        });
                      } : null,
                      icon: const Icon(Icons.remove),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '$_quantity',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _quantity++;
                        });
                      },
                      icon: const Icon(Icons.add),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Общая стоимость
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.backgroundSecondary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Text(
                    'Итого:',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const Spacer(),
                  Icon(
                    widget.item.currency == 'coins' ? Icons.monetization_on : Icons.diamond,
                    color: widget.item.currency == 'coins' ? AppColors.accentPrimary : Colors.purple,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${widget.item.finalPrice * _quantity}',
                    style: TextStyle(
                      color: widget.item.currency == 'coins' ? AppColors.accentPrimary : Colors.purple,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Кнопка покупки
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: canAfford && !_isPurchasing ? _purchaseItem : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: canAfford ? AppColors.accentPrimary : Colors.grey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isPurchasing
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                  canAfford ? 'Купить' : 'Недостаточно средств',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}