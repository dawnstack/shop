class OrderItemModel {
  final String id;
  final String orderId;
  final String productId;
  final String productName;
  final int productPrice;
  final int quantity;

  const OrderItemModel({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.productName,
    required this.productPrice,
    required this.quantity,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: (json['id'] ?? '').toString(),
      orderId: (json['order_id'] ?? '').toString(),
      productId: (json['product_id'] ?? '').toString(),
      productName: (json['product_name'] ?? '').toString(),
      productPrice: (json['product_price'] as num?)?.toInt() ?? 0,
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
    );
  }
}

class OrderModel {
  final String id;
  final String userId;
  final String addressId;
  final String orderNo;
  final String status;
  final int totalAmount;
  final String idempotencyKey;
  final List<OrderItemModel> items;

  const OrderModel({
    required this.id,
    required this.userId,
    required this.addressId,
    required this.orderNo,
    required this.status,
    required this.totalAmount,
    required this.idempotencyKey,
    this.items = const [],
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: (json['id'] ?? '').toString(),
      userId: (json['user_id'] ?? '').toString(),
      addressId: (json['address_id'] ?? '').toString(),
      orderNo: (json['order_no'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      totalAmount: (json['total_amount'] as num?)?.toInt() ?? 0,
      idempotencyKey: (json['idempotency_key'] ?? '').toString(),
      items: (json['items'] is List)
          ? (json['items'] as List)
                .map(
                  (item) =>
                      OrderItemModel.fromJson(Map<String, dynamic>.from(item)),
                )
                .toList()
          : const [],
    );
  }
}
