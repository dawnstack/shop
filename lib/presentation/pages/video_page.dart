import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shop/app_router.dart';
import 'package:shop/common/di/injection_container.dart' as di;
import 'package:shop/data/datasources/remote/api_service.dart';
import 'package:shop/data/models/video_model.dart';
import 'package:shop/presentation/widgets/images/app_image.dart';

class VideoPage extends StatefulWidget {
  const VideoPage({super.key});

  @override
  State<VideoPage> createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage>
    with AutomaticKeepAliveClientMixin {
  late Future<List<VideoModel>> _videoFuture;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _videoFuture = _loadVideos();
  }

  Future<List<VideoModel>> _loadVideos() async {
    final response = await di.getIt<ApiService>().getRecommendedVideos();
    return response.data ?? <VideoModel>[];
  }

  Future<void> _refresh() async {
    setState(() {
      _videoFuture = _loadVideos();
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(title: const Text('视频推荐')),
      body: FutureBuilder<List<VideoModel>>(
        future: _videoFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final videos = snapshot.data ?? <VideoModel>[];
          if (videos.isEmpty) {
            return const Center(child: Text('暂无推荐视频'));
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) {
                final video = videos[index];
                return InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () {
                    context.push(
                      AppRouter.detail,
                      extra: {'id': video.productId, 'name': video.title},
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AspectRatio(
                          aspectRatio: 16 / 9,
                          child: AppImage(url: video.coverUrl),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                video.title,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 8),
                              Text('关联商品: ${video.productId}'),
                              const SizedBox(height: 4),
                              Text(
                                video.playbackUrl,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemCount: videos.length,
            ),
          );
        },
      ),
    );
  }
}
