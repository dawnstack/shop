import 'package:shop/domain/entities/product_data.dart';

class ProductModel {
  final String id;
  final String categoryId;
  final String name;
  final String description;
  final int price;
  final int stock;
  final String imageUrl;
  final int sales;

  const ProductModel({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.description,
    required this.price,
    required this.stock,
    required this.imageUrl,
    required this.sales,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: (json['id'] ?? '').toString(),
      categoryId: (json['category_id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      price: (json['price'] as num?)?.toInt() ?? 0,
      stock: (json['stock'] as num?)?.toInt() ?? 0,
      imageUrl: (json['cover_url'] ?? '').toString(),
      sales: (json['sales'] as num?)?.toInt() ?? 0,
    );
  }
}

extension ProductModelX on ProductModel {
  ProductData toEntity() => ProductData(
    id: id,
    name: name,
    imageUrl: imageUrl,
    description: description,
    price: price / 100,
    originalPrice: price / 100,
    sales: sales,
    stock: stock,
  );
}
