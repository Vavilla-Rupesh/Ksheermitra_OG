import 'package:flutter/material.dart';
import '../models/product.dart';
import '../config/dairy_theme.dart';
import '../utils/image_helper.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;
  final VoidCallback? onAddPressed;
  final bool showAddButton;
  final bool isAdminView;
  final bool showStock;

  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.onAddPressed,
    this.showAddButton = true,
    this.isAdminView = false,
    this.showStock = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DairyRadius.lg),
        side: BorderSide(color: DairyColorsLight.border, width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(DairyRadius.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Product Image Section
            Expanded(
              flex: 6,
              child: Container(
                color: DairyColorsLight.surface,
                padding: const EdgeInsets.all(DairySpacing.md),
                child: Stack(
                  children: [
                    _buildProductImage(context),
                    // Stock badge for admin view
                    if (showStock && isAdminView)
                      Positioned(
                        top: DairySpacing.xs,
                        right: DairySpacing.xs,
                        child: _buildStockBadge(),
                      ),
                  ],
                ),
              ),
            ),

            // Product Info Section
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.all(DairySpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Name
                    Expanded(
                      child: Text(
                        product.name,
                        style: DairyTypography.productName(),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    const SizedBox(height: DairySpacing.sm),

                    // Stock info for non-admin view
                    if (showStock && !isAdminView)
                      Padding(
                        padding: const EdgeInsets.only(bottom: DairySpacing.xs),
                        child: Text(
                          _getStockText(),
                          style: DairyTypography.caption(color: _getStockColor()),
                        ),
                      ),

                    // Price and Add Button Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Price Section
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '₹${product.pricePerUnit.toStringAsFixed(0)}',
                                style: DairyTypography.price(),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                product.unit,
                                style: DairyTypography.caption(),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),

                        // Add Button
                        if (showAddButton && onAddPressed != null)
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: product.stock > 0 ? onAddPressed : null,
                              borderRadius: BorderRadius.circular(DairyRadius.sm),
                              child: Container(
                                padding: const EdgeInsets.all(DairySpacing.sm),
                                decoration: BoxDecoration(
                                  color: product.stock > 0
                                      ? DairyColorsLight.primary
                                      : DairyColorsLight.textDisabled,
                                  borderRadius: BorderRadius.circular(DairyRadius.sm),
                                ),
                                child: const Icon(
                                  Icons.add,
                                  color: Colors.white,
                                  size: 20,
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
          ],
        ),
      ),
    );
  }

  Widget _buildStockBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: DairySpacing.sm, vertical: DairySpacing.xs),
      decoration: BoxDecoration(
        color: _getStockColor(),
        borderRadius: BorderRadius.circular(DairyRadius.pill),
      ),
      child: Text(
        _getStockText(),
        style: DairyTypography.badge(),
      ),
    );
  }

  String _getStockText() {
    if (product.stock == 0) {
      return 'Out of Stock';
    } else if (product.stock < 10) {
      return 'Stock: ${product.stock}';
    } else {
      return 'In Stock';
    }
  }

  Color _getStockColor() {
    if (product.stock == 0) {
      return DairyColorsLight.error;
    } else if (product.stock < 10) {
      return DairyColorsLight.warning;
    } else {
      return DairyColorsLight.success;
    }
  }

  Widget _buildProductImage(BuildContext context) {
    if (product.imageUrl != null && product.imageUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          ImageHelper.getImageUrl(product.imageUrl),
          headers: ImageHelper.imageHeaders,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return _buildPlaceholderIcon(context);
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
      return _buildPlaceholderIcon(context);
    }
  }

  Widget _buildPlaceholderIcon(BuildContext context) {
    return Center(
      child: Icon(
        _getProductIcon(product.unit),
        size: 48,
        color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
      ),
    );
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

// List view variant of product card
class ProductListCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;
  final VoidCallback? onAddPressed;
  final bool showAddButton;
  final Widget? trailing;
  final bool showStock;

  const ProductListCard({
    super.key,
    required this.product,
    this.onTap,
    this.onAddPressed,
    this.showAddButton = true,
    this.trailing,
    this.showStock = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: DairySpacing.md),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DairyRadius.lg),
        side: BorderSide(color: DairyColorsLight.border, width: 1),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(DairyRadius.lg),
        child: Padding(
          padding: const EdgeInsets.all(DairySpacing.md),
          child: Row(
            children: [
              // Product Image
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: DairyColorsLight.surface,
                  borderRadius: BorderRadius.circular(DairyRadius.md),
                ),
                padding: const EdgeInsets.all(DairySpacing.sm),
                child: _buildProductImage(context),
              ),

              const SizedBox(width: DairySpacing.md),

              // Product Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      product.name,
                      style: DairyTypography.productName(),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: DairySpacing.xs),

                    if (product.description != null && product.description!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: DairySpacing.xs),
                        child: Text(
                          product.description!,
                          style: DairyTypography.caption(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                    if (showStock)
                      Padding(
                        padding: const EdgeInsets.only(bottom: DairySpacing.xs),
                        child: Row(
                          children: [
                            Icon(
                              Icons.inventory_2,
                              size: 14,
                              color: _getStockColor(),
                            ),
                            const SizedBox(width: DairySpacing.xs),
                            Text(
                              _getStockText(),
                              style: DairyTypography.caption(color: _getStockColor()),
                            ),
                          ],
                        ),
                      ),

                    Row(
                      children: [
                        Text(
                          '₹${product.pricePerUnit.toStringAsFixed(0)}',
                          style: DairyTypography.price(),
                        ),
                        Text(
                          ' /${product.unit}',
                          style: DairyTypography.caption(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Add Button or Trailing Widget
              if (trailing != null)
                trailing!
              else if (showAddButton && onAddPressed != null)
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: product.stock > 0 ? onAddPressed : null,
                    borderRadius: BorderRadius.circular(DairyRadius.sm),
                    child: Container(
                      padding: const EdgeInsets.all(DairySpacing.sm + 4),
                      decoration: BoxDecoration(
                        color: product.stock > 0
                            ? DairyColorsLight.primary
                            : DairyColorsLight.textDisabled,
                        borderRadius: BorderRadius.circular(DairyRadius.sm),
                      ),
                      child: const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _getStockText() {
    if (product.stock == 0) {
      return 'Out of Stock';
    } else if (product.stock < 10) {
      return 'Low Stock: ${product.stock}';
    } else {
      return 'In Stock: ${product.stock}';
    }
  }

  Color _getStockColor() {
    if (product.stock == 0) {
      return DairyColorsLight.error;
    } else if (product.stock < 10) {
      return DairyColorsLight.warning;
    } else {
      return DairyColorsLight.success;
    }
  }

  Widget _buildProductImage(BuildContext context) {
    if (product.imageUrl != null && product.imageUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(DairyRadius.sm),
        child: Image.network(
          ImageHelper.getImageUrl(product.imageUrl),
          headers: ImageHelper.imageHeaders,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return _buildPlaceholderIcon(context);
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
      return _buildPlaceholderIcon(context);
    }
  }

  Widget _buildPlaceholderIcon(BuildContext context) {
    return Center(
      child: Icon(
        _getProductIcon(product.unit),
        size: 48,
        color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
      ),
    );
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
