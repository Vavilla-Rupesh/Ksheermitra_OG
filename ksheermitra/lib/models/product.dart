class Product {
  final String id;
  final String name;
  final String? description;
  final String? imageUrl;
  final String unit;
  final double pricePerUnit;
  final bool isActive;
  final int stock;

  Product({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
    required this.unit,
    required this.pricePerUnit,
    required this.isActive,
    required this.stock,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Unknown Product',
      description: json['description']?.toString(),
      imageUrl: json['imageUrl']?.toString(),
      unit: json['unit']?.toString() ?? 'unit',
      pricePerUnit: json['pricePerUnit'] != null
          ? double.tryParse(json['pricePerUnit'].toString()) ?? 0.0
          : 0.0,
      isActive: json['isActive'] ?? true,
      stock: json['stock'] != null
          ? int.tryParse(json['stock'].toString()) ?? 0
          : 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'unit': unit,
      'pricePerUnit': pricePerUnit,
      'isActive': isActive,
      'stock': stock,
    };
  }
}
