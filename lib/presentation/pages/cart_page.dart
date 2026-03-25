import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shop/app_router.dart';
import 'package:shop/common/di/injection_container.dart' as di;
import 'package:shop/data/datasources/local/token_manager.dart';
import 'package:shop/data/datasources/remote/api_service.dart';
import 'package:shop/data/models/address_model.dart';
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

  Future<void> _updateItem(CartItemModel item, {int? quantity, bool? checked}) async {
    await di.getIt<ApiService>().updateCartItem(
      item.id,
      quantity: quantity ?? item.quantity,
      checked: checked ?? item.checked,
    );
    await _refresh();
  }

  Future<void> _deleteItem(CartItemModel item) async {
    await di.getIt<ApiService>().deleteCartItem(item.id);
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('购物车项已删除')));
    await _refresh();
  }

  Future<void> _checkout(List<CartItemModel> items) async {
    final checkedItems = items.where((item) => item.checked).toList();
    if (checkedItems.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('请先勾选要下单的商品')));
      return;
    }

    final addresses = (await di.getIt<ApiService>().getAddresses()).data ?? [];
    if (!mounted) return;
    if (addresses.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('请先新增收货地址')));
      return;
    }

    final address = await showDialog<AddressModel>(
      context: context,
      builder: (context) => _AddressPickerDialog(addresses: addresses),
    );
    if (address == null) {
      return;
    }

    final order = await di.getIt<ApiService>().createOrder(
      addressId: address.id,
      idempotencyKey: 'checkout-${DateTime.now().millisecondsSinceEpoch}',
    );
    if (!mounted) return;
    final created = order.data;
    if (created == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('下单失败')));
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('订单已创建')));
    await _refresh();
    if (!mounted) return;
    context.push('${AppRouter.orders}/${created.id}');
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
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                ...items.map((item) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      tileColor: Colors.white,
                      leading: Checkbox(
                        value: item.checked,
                        onChanged: (value) =>
                            _updateItem(item, checked: value ?? false),
                      ),
                      title: Text('商品 ID: ${item.productId}'),
                      subtitle: Row(
                        children: [
                          IconButton(
                            onPressed: item.quantity > 1
                                ? () => _updateItem(
                                    item,
                                    quantity: item.quantity - 1,
                                  )
                                : null,
                            icon: const Icon(Icons.remove_circle_outline),
                          ),
                          Text('数量 ${item.quantity}'),
                          IconButton(
                            onPressed: () =>
                                _updateItem(item, quantity: item.quantity + 1),
                            icon: const Icon(Icons.add_circle_outline),
                          ),
                        ],
                      ),
                      trailing: IconButton(
                        onPressed: () => _deleteItem(item),
                        icon: const Icon(Icons.delete_outline),
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => _checkout(items),
                  child: const Text('提交订单'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _AddressPickerDialog extends StatefulWidget {
  final List<AddressModel> addresses;

  const _AddressPickerDialog({required this.addresses});

  @override
  State<_AddressPickerDialog> createState() => _AddressPickerDialogState();
}

class _AddressPickerDialogState extends State<_AddressPickerDialog> {
  String? _selectedId;

  @override
  void initState() {
    super.initState();
    _selectedId =
        widget.addresses.firstWhere(
          (item) => item.isDefault,
          orElse: () => widget.addresses.first,
        ).id;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('选择收货地址'),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: widget.addresses.map((address) {
            return RadioListTile<String>(
              value: address.id,
              groupValue: _selectedId,
              onChanged: (value) => setState(() => _selectedId = value),
              title: Text(address.receiverName),
              subtitle: Text(
                '${address.province}${address.city}${address.district}${address.detail}',
              ),
            );
          }).toList(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        ElevatedButton(
          onPressed: () {
            final selected = widget.addresses.firstWhere(
              (item) => item.id == _selectedId,
            );
            Navigator.of(context).pop(selected);
          },
          child: const Text('确定'),
        ),
      ],
    );
  }
}
