import 'package:flutter/material.dart';
import '../../models/product.dart';
import '../../services/customer_api_service.dart';
import '../../config/dairy_theme.dart';
import '../../widgets/product_card.dart';
import 'create_subscription_screen.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final CustomerApiService _apiService = CustomerApiService();
  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  bool _isLoading = true;
  bool _isGridView = true; // Toggle between grid and list view
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        actions: [
          IconButton(
            icon: Icon(_isGridView ? Icons.list : Icons.grid_view),
            onPressed: () {
              setState(() {
                _isGridView = !_isGridView;
              });
            },
            tooltip: _isGridView ? 'List View' : 'Grid View',
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: DairySpacing.md, vertical: DairySpacing.sm),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search products...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(DairyRadius.md),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: DairySpacing.md, vertical: DairySpacing.sm),
              ),
              onChanged: _filterProducts,
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _filteredProducts.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inventory_2_outlined,
                          size: 72, color: DairyColorsLight.textTertiary),
                      const SizedBox(height: DairySpacing.md),
                      Text(
                        _searchQuery.isEmpty
                            ? 'No products available'
                            : 'No products found',
                        style: DairyTypography.headingSmall(),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadProducts,
                  child: _isGridView ? _buildGridView() : _buildListView(),
                ),
    );
  }

  Widget _buildGridView() {
    return GridView.builder(
      padding: const EdgeInsets.all(DairySpacing.md),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: DairySpacing.md,
        mainAxisSpacing: DairySpacing.md,
      ),
      itemCount: _filteredProducts.length,
      itemBuilder: (context, index) {
        final product = _filteredProducts[index];
        return ProductCard(
          product: product,
          onTap: () => _showProductDetails(product),
          onAddPressed: () => _createSubscription(product),
          showAddButton: true,
        );
      },
    );
  }

  Widget _buildListView() {
    return ListView.builder(
      padding: const EdgeInsets.all(DairySpacing.md),
      itemCount: _filteredProducts.length,
      itemBuilder: (context, index) {
        final product = _filteredProducts[index];
        return ProductListCard(
          product: product,
          onTap: () => _showProductDetails(product),
          onAddPressed: () => _createSubscription(product),
          showAddButton: true,
        );
      },
    );
  }

  void _showProductDetails(Product product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(DairyRadius.xxl)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(DairySpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: DairyColorsLight.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: DairySpacing.lg),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: DairyColorsLight.primarySurface,
                      borderRadius: BorderRadius.circular(DairyRadius.md),
                    ),
                    child: _buildProductImage(product, fit: BoxFit.cover),
                  ),
                  const SizedBox(width: DairySpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          product.name,
                          style: DairyTypography.headingMedium(),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: DairySpacing.xs),
                        Text(
                          '₹${product.pricePerUnit.toStringAsFixed(2)} per ${product.unit}',
                          style: DairyTypography.label(color: DairyColorsLight.success),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (product.description != null && product.description!.isNotEmpty) ...[
                const SizedBox(height: DairySpacing.lg),
                Text(
                  'Description',
                  style: DairyTypography.headingSmall(),
                ),
                const SizedBox(height: DairySpacing.sm),
                Text(
                  product.description!,
                  style: DairyTypography.body(),
                ),
              ],
              const SizedBox(height: DairySpacing.lg),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, size: 20),
                      label: const Text('Close'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: DairySpacing.buttonPaddingV),
                      ),
                    ),
                  ),
                  const SizedBox(width: DairySpacing.md),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _createSubscription(product);
                      },
                      icon: const Icon(Icons.add_circle, size: 20),
                      label: const Text('Subscribe'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: DairySpacing.buttonPaddingV),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _createSubscription(Product product) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateSubscriptionScreen(product: product),
      ),
    );

    // Reload products if subscription was created
    if (result == true) {
      _loadProducts();
    }
  }

  Widget _buildProductImage(Product product, {BoxFit fit = BoxFit.contain}) {
    if (product.imageUrl != null && product.imageUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(DairyRadius.sm),
        child: Image.network(
          '${product.imageUrl}',
          fit: fit,
          errorBuilder: (context, error, stackTrace) {
            return Center(
              child: Icon(
                _getProductIcon(product.unit),
                size: 40,
                color: Theme.of(context).primaryColor,
              ),
            );
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
                strokeWidth: 2,
              ),
            );
          },
        ),
      );
    } else {
      return Center(
        child: Icon(
          _getProductIcon(product.unit),
          size: 40,
          color: Theme.of(context).primaryColor,
        ),
      );
    }
  }

  IconData _getProductIcon(String unit) {
    switch (unit.toLowerCase()) {
      case 'liter':
      case 'ml':
        return Icons.local_drink;
      case 'kg':
      case 'gm':
        return Icons.scale;
      case 'piece':
        return Icons.shopping_basket;
      default:
        return Icons.inventory_2;
    }
  }
}
