import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:shop/app_router.dart';
import 'package:shop/common/di/injection_container.dart' as di;
import 'package:shop/data/datasources/remote/api_service.dart';
import 'package:shop/data/models/address_model.dart';
import 'package:shop/data/models/product_model.dart';
import 'package:shop/presentation/widgets/images/app_image.dart';

class DetailPage extends StatefulWidget {
  final String id;
  final String name;
  final String? imageUrl;
  final double? price;
  final double? originalPrice;
  final int? sales;

  const DetailPage({
    super.key,
    required this.id,
    required this.name,
    this.imageUrl,
    this.price,
    this.originalPrice,
    this.sales,
  });

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  int _quantity = 1;

  Future<ProductModel?> _loadProduct() async {
    final response = await di.getIt<ApiService>().getProductDetail(widget.id);
    return response.data;
  }

  Future<void> _addToCart() async {
    try {
      await di.getIt<ApiService>().addToCart(
        productId: widget.id,
        quantity: _quantity,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('已加入购物车')));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('请先登录后再操作')));
    }
  }

  Future<void> _seckillNow() async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final addresses = (await di.getIt<ApiService>().getAddresses()).data ?? [];
      if (!mounted) return;

      if (addresses.isEmpty) {
        messenger.showSnackBar(
          const SnackBar(content: Text('请先新增收货地址')),
        );
        return;
      }

      final selectedAddress = await showDialog<AddressModel>(
        context: context,
        builder: (context) => _SeckillAddressDialog(addresses: addresses),
      );
      if (selectedAddress == null) {
        return;
      }

      final result = await di.getIt<ApiService>().createSeckillOrder(
        productId: widget.id,
        quantity: _quantity,
        addressId: selectedAddress.id,
        idempotencyKey: 'seckill-${DateTime.now().millisecondsSinceEpoch}',
      );
      if (!mounted) return;

      if (result.code != 0) {
        messenger.showSnackBar(SnackBar(content: Text(result.msg)));
        return;
      }

      final order = result.data?['order'];
      final orderId = order is Map ? (order['id'] ?? '').toString() : '';
      messenger.showSnackBar(const SnackBar(content: Text('秒杀下单成功')));
      if (orderId.isNotEmpty) {
        context.push('${AppRouter.orders}/$orderId');
      }
    } catch (_) {
      if (!mounted) return;
      messenger.showSnackBar(const SnackBar(content: Text('请先登录后再操作')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ProductModel?>(
      future: _loadProduct(),
      builder: (context, snapshot) {
        final product = snapshot.data;
        final resolvedName = product?.name ?? widget.name;
        final resolvedImage = product?.imageUrl ?? widget.imageUrl ?? '';
        final resolvedPrice = product != null ? product.price / 100 : widget.price;
        final resolvedOriginalPrice =
            product != null ? product.price / 100 : widget.originalPrice;
        final resolvedSales = product?.sales ?? widget.sales;
        final description = product?.description ?? '暂无更多商品描述';
        final hasDiscount =
            resolvedOriginalPrice != null &&
            resolvedPrice != null &&
            resolvedOriginalPrice > resolvedPrice;
        final theme = Theme.of(context);

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          appBar: AppBar(title: Text(resolvedName)),
          body: ListView(
            padding: EdgeInsets.all(16.w),
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20.r),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: resolvedImage.isNotEmpty
                      ? AppImage(url: resolvedImage)
                      : Container(
                          color: Colors.grey.shade200,
                          alignment: Alignment.center,
                          child: Icon(
                            Icons.image_outlined,
                            size: 56.sp,
                            color: Colors.grey.shade500,
                          ),
                        ),
                ),
              ),
              SizedBox(height: 20.h),
              Text(resolvedName, style: theme.textTheme.headlineSmall),
              SizedBox(height: 8.h),
              Text('商品 ID: ${widget.id}', style: theme.textTheme.bodyMedium),
              if (resolvedPrice != null) ...[
                SizedBox(height: 16.h),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '¥${resolvedPrice.toStringAsFixed(2)}',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: const Color(0xFFFF5000),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (hasDiscount) ...[
                      SizedBox(width: 12.w),
                      Padding(
                        padding: EdgeInsets.only(bottom: 4.h),
                        child: Text(
                          '¥${resolvedOriginalPrice!.toStringAsFixed(2)}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.grey,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
              if (resolvedSales != null) ...[
                SizedBox(height: 12.h),
                Text('已售 $resolvedSales 件', style: theme.textTheme.bodyMedium),
              ],
              SizedBox(height: 24.h),
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Text(description, style: theme.textTheme.bodyLarge),
              ),
              SizedBox(height: 24.h),
              Row(
                children: [
                  const Text('数量'),
                  const SizedBox(width: 12),
                  IconButton(
                    onPressed: _quantity > 1
                        ? () => setState(() => _quantity -= 1)
                        : null,
                    icon: const Icon(Icons.remove_circle_outline),
                  ),
                  Text('$_quantity'),
                  IconButton(
                    onPressed: () => setState(() => _quantity += 1),
                    icon: const Icon(Icons.add_circle_outline),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _seckillNow,
                      child: const Text('秒杀下单'),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _addToCart,
                      child: const Text('加入购物车'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SeckillAddressDialog extends StatefulWidget {
  final List<AddressModel> addresses;

  const _SeckillAddressDialog({required this.addresses});

  @override
  State<_SeckillAddressDialog> createState() => _SeckillAddressDialogState();
}

class _SeckillAddressDialogState extends State<_SeckillAddressDialog> {
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
      title: const Text('选择秒杀收货地址'),
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
