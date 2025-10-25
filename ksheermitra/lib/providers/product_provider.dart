import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../services/admin_api_service.dart';

class ProductProvider with ChangeNotifier {
  final AdminApiService _adminApi = AdminApiService();

  List<Product> _products = [];
  bool _isLoading = false;
  String? _error;

  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<Product> get activeProducts =>
      _products.where((p) => p.isActive).toList();
  
  List<Product> get inactiveProducts =>
      _products.where((p) => !p.isActive).toList();

  Future<void> loadProducts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _products = await _adminApi.getProducts();
      _error = null;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error loading products: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createProduct({
    required String name,
    String? description,
    required String unit,
    required double pricePerUnit,
    int? stock,
    String? imagePath,
  }) async {
    try {
      final product = await _adminApi.createProduct(
        name: name,
        description: description,
        unit: unit,
        pricePerUnit: pricePerUnit,
        stock: stock,
        imagePath: imagePath,
      );
      _products.add(product);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error creating product: $e');
      return false;
    }
  }

  Future<bool> updateProduct({
    required String id,
    String? name,
    String? description,
    String? unit,
    double? pricePerUnit,
    int? stock,
    bool? isActive,
    String? imagePath,
  }) async {
    try {
      final updatedProduct = await _adminApi.updateProduct(
        id: id,
        name: name,
        description: description,
        unit: unit,
        pricePerUnit: pricePerUnit,
        stock: stock,
        isActive: isActive,
        imagePath: imagePath,
      );

      final index = _products.indexWhere((p) => p.id == id);
      if (index != -1) {
        _products[index] = updatedProduct;
        notifyListeners();
      }
      return true;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error updating product: $e');
      return false;
    }
  }

  Product? getProductById(String id) {
    try {
      return _products.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  List<Product> searchProducts(String query) {
    if (query.isEmpty) return _products;
    
    final lowerQuery = query.toLowerCase();
    return _products.where((product) {
      return product.name.toLowerCase().contains(lowerQuery) ||
          (product.description?.toLowerCase().contains(lowerQuery) ?? false);
    }).toList();
  }
}
