import 'package:flutter/material.dart';
import '../models/product.dart';
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
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Product Image Section
            Expanded(
              flex: 6,
              child: Container(
                color: Colors.grey.shade100,
                padding: const EdgeInsets.all(16),
                child: Stack(
                  children: [
                    _buildProductImage(context),
                    // Stock badge for admin view
                    if (showStock && isAdminView)
                      Positioned(
                        top: 4,
                        right: 4,
                        child: _buildStockBadge(),
                      ),
                  ],
                ),
              ),
            ),

            // Product Info Section
            Expanded(
              flex: 4,
              child: Container(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Name
                    Expanded(
                      child: Text(
                        product.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Stock info for non-admin view
                    if (showStock && !isAdminView)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          _getStockText(),
                          style: TextStyle(
                            fontSize: 11,
                            color: _getStockColor(),
                            fontWeight: FontWeight.w500,
                          ),
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
                              // Price
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  Flexible(
                                    child: Text(
                                      '₹${product.pricePerUnit.toStringAsFixed(0)}',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              // Unit
                              Text(
                                product.unit,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
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
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: product.stock > 0
                                      ? Theme.of(context).primaryColor
                                      : Colors.grey.shade400,
                                  borderRadius: BorderRadius.circular(8),
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getStockColor(),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _getStockText(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
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
      return Colors.red;
    } else if (product.stock < 10) {
      return Colors.orange;
    } else {
      return Colors.green;
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
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Product Image
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(8),
                child: _buildProductImage(context),
              ),

              const SizedBox(width: 12),

              // Product Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Product Name
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 4),

                    // Description (if available)
                    if (product.description != null && product.description!.isNotEmpty)
                      Text(
                        product.description!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                    const SizedBox(height: 4),

                    // Stock info
                    if (showStock)
                      Row(
                        children: [
                          Icon(
                            Icons.inventory_2,
                            size: 14,
                            color: _getStockColor(),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _getStockText(),
                            style: TextStyle(
                              fontSize: 11,
                              color: _getStockColor(),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),

                    const SizedBox(height: 4),

                    // Price
                    Row(
                      children: [
                        Text(
                          '₹${product.pricePerUnit.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          ' /${product.unit}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
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
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: product.stock > 0
                            ? Theme.of(context).primaryColor
                            : Colors.grey.shade400,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 24,
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
      return Colors.red;
    } else if (product.stock < 10) {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }

  Widget _buildProductImage(BuildContext context) {
    if (product.imageUrl != null && product.imageUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(6),
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
