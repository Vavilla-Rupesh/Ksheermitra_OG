import 'package:flutter/material.dart';
import '../../models/product.dart';
import '../../services/customer_api_service.dart';
import '../../config/dairy_theme.dart';
import '../../config/app_config.dart';
import '../../utils/image_helper.dart';
import '../../widgets/premium_widgets.dart';
import 'subscription_schedule_screen.dart';

class ProductSelectionScreen extends StatefulWidget {
  const ProductSelectionScreen({super.key});

  @override
  State<ProductSelectionScreen> createState() => _ProductSelectionScreenState();
}

class _ProductSelectionScreenState extends State<ProductSelectionScreen> {
  final CustomerApiService _apiService = CustomerApiService();
  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  Map<String, int> _selectedProducts = {};
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() => _isLoading = true);
    try {
      final products = await _apiService.getProducts();
      setState(() {
        _products = products.where((p) => p.isActive).toList();
        _filteredProducts = _products;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading products: $e')),
        );
      }
    }
  }

  void _filterProducts(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredProducts = _products;
      } else {
        _filteredProducts = _products
            .where((product) =>
                product.name.toLowerCase().contains(query.toLowerCase()) ||
                (product.description?.toLowerCase().contains(query.toLowerCase()) ?? false))
            .toList();
      }
    });
  }

  void _updateQuantity(String productId, int change) {
    setState(() {
      final currentQuantity = _selectedProducts[productId] ?? 0;
      final newQuantity = (currentQuantity + change).clamp(0, 10);

      if (newQuantity == 0) {
        _selectedProducts.remove(productId);
      } else {
        _selectedProducts[productId] = newQuantity;
      }
    });
  }

  void _toggleProduct(String productId, bool selected) {
    setState(() {
      if (selected) {
        _selectedProducts[productId] = 1;
      } else {
        _selectedProducts.remove(productId);
      }
    });
  }

  int get _selectedCount => _selectedProducts.length;

  bool get _canContinue => _selectedProducts.isNotEmpty &&
      _selectedProducts.values.every((qty) => qty > 0);

  void _continueToSchedule() {
    if (!_canContinue) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one product')),
      );
      return;
    }

    final selectedProductsList = _products
        .where((p) => _selectedProducts.containsKey(p.id))
        .map((p) => {
              'product': p,
              'quantity': _selectedProducts[p.id]!,
            })
        .toList();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SubscriptionScheduleScreen(
          selectedProducts: selectedProductsList,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Products'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search Bar with Premium Styling
          Container(
            padding: const EdgeInsets.all(DairySpacing.md),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [DairyColorsLight.primary, DairyColorsLight.primaryDark]),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(DairyRadius.lg),
                bottomRight: Radius.circular(DairyRadius.lg),
              ),
            ),
            child: PremiumInput(
              hint: 'Search products...',
              prefixIcon: const Icon(Icons.search, color: Colors.white),
              onChanged: _filterProducts,
            ),
          ),

          // Products List
          Expanded(
            child: _isLoading
                ? const PremiumLoadingWidget(message: 'Loading products...')
                : _filteredProducts.isEmpty
                    ? PremiumEmptyState(
                        icon: Icons.inventory_2_outlined,
                        title: _searchQuery.isEmpty
                            ? 'No Products Available'
                            : 'No Products Found',
                        message: _searchQuery.isEmpty
                            ? 'Products will be available soon'
                            : 'Try a different search term',
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(DairySpacing.md),
                        itemCount: _filteredProducts.length,
                        itemBuilder: (context, index) {
                          final product = _filteredProducts[index];
                          final quantity = _selectedProducts[product.id] ?? 0;
                          final isSelected = quantity > 0;

                          return Padding(
                            padding: EdgeInsets.only(bottom: DairySpacing.sm + 4),
                            child: ProductCard(
                              onTap: () => _toggleProduct(product.id, !isSelected),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      // Product Image or Icon with gradient
                                      product.imageUrl != null && product.imageUrl!.isNotEmpty
                                          ? ClipRRect(
                                              borderRadius: DairyRadius.defaultBorderRadius,
                                              child: Image.network(
                                                '${AppConfig.baseUrl}${product.imageUrl}',
                                                headers: ImageHelper.imageHeaders,
                                                width: 60,
                                                height: 60,
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error, stackTrace) {
                                                  return Container(
                                                    width: 60,
                                                    height: 60,
                                                    decoration: BoxDecoration(
                                                      gradient: isSelected
                                                          ? const LinearGradient(colors: [DairyColorsLight.success, Color(0xFF66BB6A)])
                                                          : LinearGradient(
                                                              colors: [
                                                                DairyColorsLight.primary.withValues(alpha: 0.1),
                                                                DairyColorsLight.primary.withValues(alpha: 0.05),
                                                              ],
                                                            ),
                                                      borderRadius: DairyRadius.defaultBorderRadius,
                                                    ),
                                                    child: Icon(
                                                      Icons.local_drink,
                                                      size: 32,
                                                      color: isSelected
                                                          ? Colors.white
                                                          : DairyColorsLight.primary,
                                                    ),
                                                  );
                                                },
                                                loadingBuilder: (context, child, loadingProgress) {
                                                  if (loadingProgress == null) return child;
                                                  return Container(
                                                    width: 60,
                                                    height: 60,
                                                    decoration: BoxDecoration(
                                                      color: Colors.grey.shade200,
                                                      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                                                    ),
                                                    child: const Center(
                                                      child: CircularProgressIndicator(strokeWidth: 2),
                                                    ),
                                                  );
                                                },
                                              ),
                                            )
                                          : Container(
                                              width: 60,
                                              height: 60,
                                              decoration: BoxDecoration(
                                                gradient: isSelected
                                                    ? AppTheme.activeGradient
                                                    : LinearGradient(
                                                        colors: [
                                                          AppTheme.primaryColor.withValues(alpha: 0.1),
                                                          AppTheme.primaryColor.withValues(alpha: 0.05),
                                                        ],
                                                      ),
                                                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                                              ),
                                              child: Icon(
                                                Icons.local_drink,
                                                size: 32,
                                                color: isSelected
                                                    ? Colors.white
                                                    : AppTheme.primaryColor,
                                              ),
                                            ),
                                      const SizedBox(width: AppTheme.space12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              product.name,
                                              style: AppTheme.h5,
                                            ),
                                            if (product.description != null) ...[
                                              const SizedBox(height: AppTheme.space4),
                                              Text(
                                                product.description!,
                                                style: AppTheme.bodySmall,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                            const SizedBox(height: AppTheme.space8),
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.currency_rupee,
                                                  size: 16,
                                                  color: AppTheme.primaryColor,
                                                ),
                                                Text(
                                                  '${product.pricePerUnit.toStringAsFixed(2)}/${product.unit}',
                                                  style: AppTheme.priceText.copyWith(
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      // Quantity Selector
                                      if (isSelected)
                                        Container(
                                          decoration: BoxDecoration(
                                            gradient: AppTheme.activeGradient,
                                            borderRadius: BorderRadius.circular(AppTheme.radiusPill),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              IconButton(
                                                icon: const Icon(Icons.remove, color: Colors.white),
                                                onPressed: () => _updateQuantity(product.id, -1),
                                                padding: EdgeInsets.zero,
                                                constraints: const BoxConstraints(
                                                  minWidth: 36,
                                                  minHeight: 36,
                                                ),
                                              ),
                                              Container(
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: AppTheme.space8,
                                                ),
                                                child: Text(
                                                  quantity.toString(),
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                              IconButton(
                                                icon: const Icon(Icons.add, color: Colors.white),
                                                onPressed: () => _updateQuantity(product.id, 1),
                                                padding: EdgeInsets.zero,
                                                constraints: const BoxConstraints(
                                                  minWidth: 36,
                                                  minHeight: 36,
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      else
                                        Container(
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: AppTheme.primaryColor,
                                              width: 2,
                                            ),
                                            borderRadius: BorderRadius.circular(AppTheme.radiusPill),
                                          ),
                                          child: IconButton(
                                            icon: const Icon(Icons.add),
                                            color: AppTheme.primaryColor,
                                            onPressed: () => _toggleProduct(product.id, true),
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(
                                              minWidth: 36,
                                              minHeight: 36,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      bottomNavigationBar: _selectedCount > 0
          ? Container(
              padding: const EdgeInsets.all(AppTheme.space16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    PremiumCard(
                      padding: const EdgeInsets.all(AppTheme.space12),
                      backgroundColor: AppTheme.backgroundColor,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '$_selectedCount Product${_selectedCount > 1 ? 's' : ''} Selected',
                            style: AppTheme.h5,
                          ),
                          PremiumBadge.active(
                            'Total: ${_selectedProducts.values.reduce((a, b) => a + b)}',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppTheme.space12),
                    PremiumButton(
                      text: 'Continue to Schedule',
                      icon: Icons.arrow_forward,
                      onPressed: _canContinue ? _continueToSchedule : null,
                      width: double.infinity,
                    ),
                  ],
                ),
              ),
            )
          : null,
    );
  }
}
