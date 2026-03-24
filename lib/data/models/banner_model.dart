import 'package:shop/domain/entities/banner_data.dart';

class BannerModel {
  final String id;
  final String title;
  final String imageUrl;
  final String linkUrl;

  const BannerModel({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.linkUrl,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      imageUrl: (json['image_url'] ?? '').toString(),
      linkUrl: (json['link_url'] ?? '').toString(),
    );
  }
}

extension BannerModelX on BannerModel {
  BannerData toEntity() => BannerData(
    shopId: id,
    imageUrl: imageUrl,
    title: title,
    linkUrl: linkUrl,
  );
}
