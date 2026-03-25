import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shop/app_router.dart';
import 'package:shop/common/di/injection_container.dart' as di;
import 'package:shop/data/datasources/remote/api_service.dart';
import 'package:shop/data/models/order_model.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  late Future<List<OrderModel>> _ordersFuture;

  @override
  void initState() {
    super.initState();
    _ordersFuture = _loadOrders();
  }

  Future<List<OrderModel>> _loadOrders() async {
    final response = await di.getIt<ApiService>().getOrders();
    return response.data ?? <OrderModel>[];
  }

  Future<void> _refresh() async {
    setState(() {
      _ordersFuture = _loadOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('我的订单')),
      body: FutureBuilder<List<OrderModel>>(
        future: _ordersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final orders = snapshot.data ?? <OrderModel>[];
          if (orders.isEmpty) {
            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                children: const [
                  SizedBox(height: 160),
                  Center(child: Text('还没有订单')),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: orders.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final order = orders[index];
                return ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  tileColor: Colors.white,
                  title: Text('订单号 ${order.orderNo}'),
                  subtitle: Text('状态 ${order.status}'),
                  trailing: Text('¥${(order.totalAmount / 100).toStringAsFixed(2)}'),
                  onTap: () => context.push('${AppRouter.orders}/${order.id}'),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
