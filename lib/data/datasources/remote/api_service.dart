import 'package:dio/dio.dart';
import 'package:shop/data/models/address_model.dart';
import 'package:shop/data/models/banner_model.dart';
import 'package:shop/data/models/base_response.dart';
import 'package:shop/data/models/cart_item_model.dart';
import 'package:shop/data/models/category_model.dart';
import 'package:shop/data/models/order_model.dart';
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

  Future<BaseResponse<UserModel>> register(
    String email,
    String password, {
    String? nickname,
  }) async {
    final response = await _dio.post(
      '/auth/register',
      data: {
        'email': email,
        'password': password,
        if (nickname != null && nickname.isNotEmpty) 'nickname': nickname,
      },
    );
    return BaseResponse.fromJson(
      _asMap(response.data),
      (json) => UserModel.fromJson(_asMap(json)),
    );
  }

  Future<BaseResponse<UserModel>> refreshToken(String refreshToken) async {
    final response = await _dio.post(
      '/auth/refresh',
      data: {'refresh_token': refreshToken},
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

  Future<BaseResponse<List<AddressModel>>> getAddresses() async {
    final response = await _dio.get('/user/addresses');
    return BaseResponse.fromJson(_asMap(response.data), (json) {
      return _asList(
        json,
      ).map((item) => AddressModel.fromJson(_asMap(item))).toList();
    });
  }

  Future<BaseResponse<Map<String, dynamic>>> createAddress(
    AddressModel address,
  ) async {
    final response = await _dio.post('/user/address', data: address.toPayload());
    return BaseResponse.fromJson(
      _asMap(response.data),
      (json) => _asMap(json),
    );
  }

  Future<BaseResponse<Map<String, dynamic>>> updateAddress(
    String id,
    AddressModel address,
  ) async {
    final response = await _dio.put(
      '/user/address/$id',
      data: address.toPayload(),
    );
    return BaseResponse.fromJson(
      _asMap(response.data),
      (json) => _asMap(json),
    );
  }

  Future<BaseResponse<Map<String, dynamic>>> deleteAddress(String id) async {
    final response = await _dio.delete('/user/address', queryParameters: {'id': id});
    return BaseResponse.fromJson(
      _asMap(response.data),
      (json) => _asMap(json),
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

  Future<BaseResponse<Map<String, dynamic>>> addToCart({
    required String productId,
    int quantity = 1,
    bool checked = true,
  }) async {
    final response = await _dio.post(
      '/cart',
      data: {
        'product_id': int.tryParse(productId) ?? productId,
        'quantity': quantity,
        'checked': checked,
      },
    );
    return BaseResponse.fromJson(
      _asMap(response.data),
      (json) => _asMap(json),
    );
  }

  Future<BaseResponse<Map<String, dynamic>>> updateCartItem(
    String id, {
    required int quantity,
    required bool checked,
  }) async {
    final response = await _dio.put(
      '/cart/$id',
      data: {'quantity': quantity, 'checked': checked},
    );
    return BaseResponse.fromJson(
      _asMap(response.data),
      (json) => _asMap(json),
    );
  }

  Future<BaseResponse<Map<String, dynamic>>> deleteCartItem(String id) async {
    final response = await _dio.delete('/cart', queryParameters: {'id': id});
    return BaseResponse.fromJson(
      _asMap(response.data),
      (json) => _asMap(json),
    );
  }

  Future<BaseResponse<List<OrderModel>>> getOrders() async {
    final response = await _dio.get('/orders');
    return BaseResponse.fromJson(_asMap(response.data), (json) {
      return _asList(
        json,
      ).map((item) => OrderModel.fromJson(_asMap(item))).toList();
    });
  }

  Future<BaseResponse<OrderModel>> getOrderDetail(String id) async {
    final response = await _dio.get('/orders/$id');
    return BaseResponse.fromJson(
      _asMap(response.data),
      (json) => OrderModel.fromJson(_asMap(json)),
    );
  }

  Future<BaseResponse<OrderModel>> createOrder({
    required String addressId,
    required String idempotencyKey,
  }) async {
    final response = await _dio.post(
      '/orders',
      data: {
        'address_id': int.tryParse(addressId) ?? addressId,
        'idempotency_key': idempotencyKey,
      },
    );
    return BaseResponse.fromJson(
      _asMap(response.data),
      (json) => OrderModel.fromJson(_asMap(json)),
    );
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
