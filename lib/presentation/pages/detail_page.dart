import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasDiscount =
        originalPrice != null && price != null && originalPrice! > price!;

    return Scaffold(
      appBar: AppBar(title: Text(name)),
      body: ListView(
        padding: EdgeInsets.all(16.w),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20.r),
            child: AspectRatio(
              aspectRatio: 1,
              child: imageUrl?.isNotEmpty == true
                  ? AppImage(url: imageUrl!)
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
          Text(name, style: theme.textTheme.headlineSmall),
          SizedBox(height: 8.h),
          Text('商品 ID: $id', style: theme.textTheme.bodyMedium),
          if (price != null) ...[
            SizedBox(height: 16.h),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '¥${price!.toStringAsFixed(2)}',
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
                      '¥${originalPrice!.toStringAsFixed(2)}',
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
          if (sales != null) ...[
            SizedBox(height: 12.h),
            Text('已售 $sales 件', style: theme.textTheme.bodyMedium),
          ],
          SizedBox(height: 24.h),
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Text(
              '这里先补上详情页基础展示，后面可以继续接商品详情接口、规格选择和加入购物车能力。',
              style: theme.textTheme.bodyLarge,
            ),
          ),
        ],
      ),
    );
  }
}
