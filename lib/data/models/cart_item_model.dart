class CartItemModel {
  final String id;
  final String userId;
  final String productId;
  final int quantity;
  final bool checked;

  const CartItemModel({
    required this.id,
    required this.userId,
    required this.productId,
    required this.quantity,
    required this.checked,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      id: (json['id'] ?? '').toString(),
      userId: (json['user_id'] ?? '').toString(),
      productId: (json['product_id'] ?? '').toString(),
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      checked: json['checked'] == true,
    );
  }

  CartItemModel copyWith({
    String? id,
    String? userId,
    String? productId,
    int? quantity,
    bool? checked,
  }) {
    return CartItemModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      productId: productId ?? this.productId,
      quantity: quantity ?? this.quantity,
      checked: checked ?? this.checked,
    );
  }
}
