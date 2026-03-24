class ProductData {
  final String id;
  final String name;
  final String imageUrl;
  final String description;
  final double price;
  final double originalPrice;
  final int sales;
  final int stock;

  const ProductData({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.originalPrice,
    required this.sales,
    this.description = '',
    this.stock = 0,
  });
}
