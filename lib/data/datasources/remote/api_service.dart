import 'package:dio/dio.dart';
import 'package:shop/data/models/banner_model.dart';
import 'package:shop/data/models/base_response.dart';
import 'package:shop/data/models/cart_item_model.dart';
import 'package:shop/data/models/category_model.dart';
import 'package:shop/data/models/product_model.dart';
import 'package:shop/data/models/user_model.dart';
import 'package:shop/data/models/video_model.dart';

class ApiService {
  final Dio _dio;

  ApiService(this._dio);

  Future<BaseResponse<UserModel>> login(String email, String password) async {
    final response = await _dio.post(
      '/auth/login',
      data: {'email': email, 'password': password},
    );
    return BaseResponse.fromJson(
      _asMap(response.data),
      (json) => UserModel.fromJson(_asMap(json)),
    );
  }

  Future<BaseResponse<List<BannerModel>>> getBanner() async {
    final response = await _dio.get('/home/banners');
    return BaseResponse.fromJson(_asMap(response.data), (json) {
      return _asList(
        json,
      ).map((item) => BannerModel.fromJson(_asMap(item))).toList();
    });
  }

  Future<BaseResponse<List<CategoryModel>>> getCategory() async {
    final response = await _dio.get('/home/categories');
    return BaseResponse.fromJson(_asMap(response.data), (json) {
      return _asList(
        json,
      ).map((item) => CategoryModel.fromJson(_asMap(item))).toList();
    });
  }

  Future<BaseResponse<List<ProductModel>>> getProduct() async {
    final response = await _dio.get('/home/recommend');
    return BaseResponse.fromJson(_asMap(response.data), (json) {
      return _asList(
        json,
      ).map((item) => ProductModel.fromJson(_asMap(item))).toList();
    });
  }

  Future<BaseResponse<ProductModel>> getProductDetail(String id) async {
    final response = await _dio.get('/products/$id');
    return BaseResponse.fromJson(
      _asMap(response.data),
      (json) => ProductModel.fromJson(_asMap(json)),
    );
  }

  Future<BaseResponse<UserModel>> getProfile() async {
    final response = await _dio.get('/user/profile');
    return BaseResponse.fromJson(
      _asMap(response.data),
      (json) => UserModel.fromJson(_asMap(json)),
    );
  }

  Future<BaseResponse<List<CartItemModel>>> getCart() async {
    final response = await _dio.get('/cart');
    return BaseResponse.fromJson(_asMap(response.data), (json) {
      return _asList(
        json,
      ).map((item) => CartItemModel.fromJson(_asMap(item))).toList();
    });
  }

  Future<BaseResponse<List<VideoModel>>> getRecommendedVideos() async {
    final response = await _dio.get('/videos/recommend');
    return BaseResponse.fromJson(_asMap(response.data), (json) {
      return _asList(
        json,
      ).map((item) => VideoModel.fromJson(_asMap(item))).toList();
    });
  }

  Map<String, dynamic> _asMap(Object? value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return value.map((key, val) => MapEntry(key.toString(), val));
    }
    return <String, dynamic>{};
  }

  List<dynamic> _asList(Object? value) {
    return value is List ? value : <dynamic>[];
  }
}
