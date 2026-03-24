import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shop/common/di/injection_container.dart' as di;
import 'package:shop/data/datasources/remote/api_service.dart';
import 'package:shop/data/models/product_model.dart';
import 'package:shop/presentation/widgets/images/app_image.dart';

class DetailPage extends StatelessWidget {
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

  Future<ProductModel?> _loadProduct() async {
    final response = await di.getIt<ApiService>().getProductDetail(id);
    return response.data;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ProductModel?>(
      future: _loadProduct(),
      builder: (context, snapshot) {
        final product = snapshot.data;
        final resolvedName = product?.name ?? name;
        final resolvedImage = product?.imageUrl ?? imageUrl ?? '';
        final resolvedPrice = product != null ? product.price / 100 : price;
        final resolvedOriginalPrice =
            product != null ? product.price / 100 : originalPrice;
        final resolvedSales = product?.sales ?? sales;
        final description = product?.description ?? '暂无更多商品描述';
        final hasDiscount =
            resolvedOriginalPrice != null &&
            resolvedPrice != null &&
            resolvedOriginalPrice > resolvedPrice;
        final theme = Theme.of(context);

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
              Text('商品 ID: $id', style: theme.textTheme.bodyMedium),
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
            ],
          ),
        );
      },
    );
  }
}
