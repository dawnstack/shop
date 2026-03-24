class CartItemModel {
  final String id;
  final String productId;
  final int quantity;
  final bool checked;

  const CartItemModel({
    required this.id,
    required this.productId,
    required this.quantity,
    required this.checked,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      id: (json['id'] ?? '').toString(),
      productId: (json['product_id'] ?? '').toString(),
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      checked: json['checked'] == true,
    );
  }
}
