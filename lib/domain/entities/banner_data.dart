class BannerData {
  final String shopId;
  final String imageUrl;
  final String title;
  final String linkUrl;

  const BannerData({
    required this.shopId,
    required this.imageUrl,
    this.title = '',
    this.linkUrl = '',
  });
}
