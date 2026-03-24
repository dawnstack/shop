import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shop/app_router.dart';
import 'package:shop/common/di/injection_container.dart' as di;
import 'package:shop/data/datasources/local/token_manager.dart';
import 'package:shop/data/datasources/remote/api_service.dart';
import 'package:shop/data/models/cart_item_model.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<StatefulWidget> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage>
    with AutomaticKeepAliveClientMixin {
  late Future<List<CartItemModel>?> _cartFuture;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _cartFuture = _loadCart();
  }

  Future<List<CartItemModel>?> _loadCart() async {
    final isLoggedIn = await di.getIt<TokenManager>().isLoggedIn();
    if (!isLoggedIn) {
      return null;
    }

    final response = await di.getIt<ApiService>().getCart();
    return response.data ?? <CartItemModel>[];
  }

  Future<void> _refresh() async {
    setState(() {
      _cartFuture = _loadCart();
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(title: const Text('购物车')),
      body: FutureBuilder<List<CartItemModel>?>(
        future: _cartFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final items = snapshot.data;
          if (items == null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('登录后才能查看购物车'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () async {
                      await context.push(AppRouter.login);
                      await _refresh();
                    },
                    child: const Text('去登录'),
                  ),
                ],
              ),
            );
          }

          if (items.isEmpty) {
            return const Center(child: Text('购物车还是空的'));
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) {
                final item = items[index];
                return ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  tileColor: Colors.white,
                  leading: Icon(
                    item.checked
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    color: item.checked ? const Color(0xFFFF5000) : Colors.grey,
                  ),
                  title: Text('商品 ID: ${item.productId}'),
                  subtitle: Text('数量 ${item.quantity}'),
                  trailing: Text('购物车项 ${item.id}'),
                );
              },
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemCount: items.length,
            ),
          );
        },
      ),
    );
  }
}
