import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:shimmer/shimmer.dart';
import 'package:shop/app_router.dart';
import 'package:shop/domain/entities/product_data.dart';
import 'package:shop/presentation/bloc/home/home_bloc.dart';
import 'package:shop/presentation/bloc/home/home_event.dart';
import 'package:shop/presentation/bloc/home/home_state.dart';
import 'package:shop/presentation/widgets/images/app_image.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    context.read<HomeBloc>().add(HomeEvent.loading());
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [_buildBanner(), _buildCategory(), _buildProduct()],
        ),
      ),
    );
  }

  Widget _buildBanner() {
    return BlocBuilder<HomeBloc, HomeState>(
      buildWhen: (previous, current) =>
          previous.isLoadingBanner != current.isLoadingBanner ||
          previous.bannerList != current.bannerList,
      builder: (context, state) {
        if (state.isLoadingBanner) {
          return SliverToBoxAdapter(
            child: Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                height: 200.h,
                margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.r),
                ),
              ),
            ),
          );
        }

        if (state.bannerList.isEmpty) {
          return const SliverToBoxAdapter(child: SizedBox.shrink());
        }

        return SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.only(top: 12.h),
            child: CarouselSlider(
              options: CarouselOptions(
                height: 200.h,
                aspectRatio: 16 / 9,
                viewportFraction: 0.88,
                autoPlay: true,
                autoPlayInterval: const Duration(seconds: 3),
                autoPlayAnimationDuration: const Duration(milliseconds: 800),
                autoPlayCurve: Curves.fastOutSlowIn,
                enlargeCenterPage: true,
                scrollDirection: Axis.horizontal,
              ),
              items: state.bannerList.map((bannerData) {
                return AppImage(
                  url: bannerData.imageUrl,
                  borderRadius: BorderRadius.circular(20.r),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCategory() {
    return BlocBuilder<HomeBloc, HomeState>(
      buildWhen: (previous, current) =>
          previous.isLoadingCategory != current.isLoadingCategory ||
          previous.categoryList != current.categoryList,
      builder: (context, state) {
        if (state.isLoadingCategory) {
          return SliverToBoxAdapter(
            child: SizedBox(
              height: 120.h,
              child: Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: ListView.separated(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (_, __) => Container(
                    width: 72.w,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18.r),
                    ),
                  ),
                  separatorBuilder: (_, __) => SizedBox(width: 12.w),
                  itemCount: 4,
                ),
              ),
            ),
          );
        }

        if (state.categoryList.isEmpty) {
          return const SliverToBoxAdapter(child: SizedBox.shrink());
        }

        return SliverPadding(
          padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 8.h),
          sliver: SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 16.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Wrap(
                spacing: 12.w,
                runSpacing: 12.h,
                children: state.categoryList.map((category) {
                  return SizedBox(
                    width: 72.w,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 56.w,
                          height: 56.w,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF1EB),
                            borderRadius: BorderRadius.circular(18.r),
                          ),
                          padding: EdgeInsets.all(12.w),
                          child: AppImage(
                            url: category.icon,
                            fit: BoxFit.contain,
                            errorWidget: Icon(
                              Icons.category_outlined,
                              color: const Color(0xFFFF5000),
                              size: 20.sp,
                            ),
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          category.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProduct() {
    return BlocBuilder<HomeBloc, HomeState>(
      buildWhen: (previous, current) =>
          previous.isLoadingProduct != current.isLoadingProduct ||
          previous.productList != current.productList,
      builder: (context, state) {
        if (state.isLoadingProduct) {
          return SliverPadding(
            padding: EdgeInsets.all(16.w),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12.h,
                crossAxisSpacing: 12.w,
                childAspectRatio: 0.72,
              ),
              delegate: SliverChildBuilderDelegate((context, index) {
                return Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                  ),
                );
              }, childCount: 4),
            ),
          );
        }

        if (state.productList.isEmpty) {
          return const SliverToBoxAdapter(child: SizedBox.shrink());
        }

        return SliverPadding(
          padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
          sliver: SliverMainAxisGroup(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.only(bottom: 12.h),
                  child: Text(
                    '猜你喜欢',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              SliverMasonryGrid.count(
                crossAxisCount: 2,
                mainAxisSpacing: 12.h,
                crossAxisSpacing: 12.w,
                childCount: state.productList.length,
                itemBuilder: (BuildContext context, int index) {
                  return _buildProductCard(context, state.productList[index]);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProductCard(BuildContext context, ProductData product) {
    return GestureDetector(
      onTap: () {
        context.push(
          AppRouter.detail,
          extra: {
            'id': product.id,
            'name': product.name,
            'imageUrl': product.imageUrl,
            'price': product.price,
            'originalPrice': product.originalPrice,
            'sales': product.sales,
          },
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
              child: AspectRatio(
                aspectRatio: 1,
                child: AppImage(url: product.imageUrl),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(12.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      height: 1.35,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Text(
                    '¥${product.price.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 18.sp,
                      color: const Color(0xFFFF5000),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '¥${product.originalPrice.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ),
                      Text(
                        '已售 ${product.sales}',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
