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
      id: json['id'],
      name: json['name'],
      description: json['description'],
      imageUrl: json['imageUrl'],
      unit: json['unit'],
      pricePerUnit: double.parse(json['pricePerUnit'].toString()),
      isActive: json['isActive'] ?? true,
      stock: json['stock'] ?? 0,
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
