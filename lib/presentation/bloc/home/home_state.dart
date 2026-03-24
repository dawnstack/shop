import 'package:shop/domain/entities/banner_data.dart';
import 'package:shop/domain/entities/category_data.dart';
import 'package:shop/domain/entities/product_data.dart';

class HomeState {
  final List<BannerData> bannerList;
  final List<CategoryData> categoryList;
  final List<ProductData> productList;
  final bool isLoadingBanner;
  final bool isLoadingCategory;
  final bool isLoadingProduct;
  final String? errorMessage;

  const HomeState({
    this.bannerList = const [],
    this.categoryList = const [],
    this.productList = const [],
    this.isLoadingBanner = false,
    this.isLoadingCategory = false,
    this.isLoadingProduct = false,
    this.errorMessage,
  });

  factory HomeState.initial() {
    return const HomeState(
      isLoadingBanner: true,
      isLoadingCategory: true,
      isLoadingProduct: true,
    );
  }

  HomeState copyWith({
    List<BannerData>? bannerList,
    List<CategoryData>? categoryList,
    List<ProductData>? productList,
    bool? isLoadingBanner,
    bool? isLoadingCategory,
    bool? isLoadingProduct,
    String? errorMessage,
  }) {
    return HomeState(
      bannerList: bannerList ?? this.bannerList,
      categoryList: categoryList ?? this.categoryList,
      productList: productList ?? this.productList,
      isLoadingBanner: isLoadingBanner ?? this.isLoadingBanner,
      isLoadingCategory: isLoadingCategory ?? this.isLoadingCategory,
      isLoadingProduct: isLoadingProduct ?? this.isLoadingProduct,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
