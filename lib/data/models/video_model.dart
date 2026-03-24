class VideoModel {
  final String id;
  final String title;
  final String coverUrl;
  final String playbackUrl;
  final String productId;

  const VideoModel({
    required this.id,
    required this.title,
    required this.coverUrl,
    required this.playbackUrl,
    required this.productId,
  });

  factory VideoModel.fromJson(Map<String, dynamic> json) {
    return VideoModel(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      coverUrl: (json['cover_url'] ?? '').toString(),
      playbackUrl: (json['playback_url'] ?? '').toString(),
      productId: (json['product_id'] ?? '').toString(),
    );
  }
}
