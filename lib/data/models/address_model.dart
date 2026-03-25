class AddressModel {
  final String id;
  final String userId;
  final String receiverName;
  final String phone;
  final String province;
  final String city;
  final String district;
  final String detail;
  final bool isDefault;

  const AddressModel({
    required this.id,
    required this.userId,
    required this.receiverName,
    required this.phone,
    required this.province,
    required this.city,
    required this.district,
    required this.detail,
    required this.isDefault,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: (json['id'] ?? '').toString(),
      userId: (json['user_id'] ?? '').toString(),
      receiverName: (json['receiver_name'] ?? '').toString(),
      phone: (json['phone'] ?? '').toString(),
      province: (json['province'] ?? '').toString(),
      city: (json['city'] ?? '').toString(),
      district: (json['district'] ?? '').toString(),
      detail: (json['detail'] ?? '').toString(),
      isDefault: json['is_default'] == true,
    );
  }

  Map<String, dynamic> toPayload() {
    return {
      'receiver_name': receiverName,
      'phone': phone,
      'province': province,
      'city': city,
      'district': district,
      'detail': detail,
      'is_default': isDefault,
    };
  }

  AddressModel copyWith({
    String? id,
    String? userId,
    String? receiverName,
    String? phone,
    String? province,
    String? city,
    String? district,
    String? detail,
    bool? isDefault,
  }) {
    return AddressModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      receiverName: receiverName ?? this.receiverName,
      phone: phone ?? this.phone,
      province: province ?? this.province,
      city: city ?? this.city,
      district: district ?? this.district,
      detail: detail ?? this.detail,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}
