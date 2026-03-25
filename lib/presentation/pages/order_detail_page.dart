import 'package:flutter/material.dart';
import 'package:shop/common/di/injection_container.dart' as di;
import 'package:shop/data/datasources/remote/api_service.dart';
import 'package:shop/data/models/order_model.dart';

class OrderDetailPage extends StatelessWidget {
  final String orderId;

  const OrderDetailPage({super.key, required this.orderId});

  Future<OrderModel?> _loadOrder() async {
    final response = await di.getIt<ApiService>().getOrderDetail(orderId);
    return response.data;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('订单详情')),
      body: FutureBuilder<OrderModel?>(
        future: _loadOrder(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final order = snapshot.data;
          if (order == null) {
            return const Center(child: Text('订单不存在'));
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ListTile(title: const Text('订单号'), subtitle: Text(order.orderNo)),
              ListTile(title: const Text('状态'), subtitle: Text(order.status)),
              ListTile(
                title: const Text('总金额'),
                subtitle: Text('¥${(order.totalAmount / 100).toStringAsFixed(2)}'),
              ),
              const SizedBox(height: 16),
              Text('商品列表', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              ...order.items.map((item) {
                return Card(
                  child: ListTile(
                    title: Text(item.productName),
                    subtitle: Text('商品 ID: ${item.productId}  数量: ${item.quantity}'),
                    trailing: Text(
                      '¥${(item.productPrice / 100).toStringAsFixed(2)}',
                    ),
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }
}
