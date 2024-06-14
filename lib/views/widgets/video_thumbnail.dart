import 'package:connect/models/post_model.dart';
import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoThumbnail extends StatefulWidget {
  const VideoThumbnail({super.key, this.post});
  final Post? post;
  @override
  State<VideoThumbnail> createState() => _VideoThumbnailState();
}

class _VideoThumbnailState extends State<VideoThumbnail> {
  VideoPlayerController? _videoPlayerController;
  bool _isVideo = false;
  @override
  void initState() {
    super.initState();
    _isVideo = _checkIfVideo(widget.post!.imageUrl!);
    if (_isVideo) {
      _initializeVideoPlayer();
    }
  }

  bool _checkIfVideo(String url) {
    if (url.contains(".mp4") ||
        url.contains('.mov') ||
        url.contains("'.avi'")) {
      return true;
    } else {
      return false;
    }
  }

  void _initializeVideoPlayer() {
    _videoPlayerController =
        VideoPlayerController.networkUrl(Uri.parse(widget.post!.imageUrl!))
          ..initialize().then((value) {
            _videoPlayerController!.pause();
            _videoPlayerController!.setVolume(0);
            _videoPlayerController!.setLooping(false);
          });
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post!;
    final mediaQuery = MediaQuery.of(context).size;
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (post.imageUrl != null)
            Stack(
              children: [
                FittedBox(
                  fit: BoxFit.contain,
                  child: SizedBox(
                    height: mediaQuery.height * 0.17,
                    width: MediaQuery.of(context).size.width * 0.4,
                    child: _isVideo
                        ? VideoPlayer(_videoPlayerController!)
                        : FancyShimmerImage(
                            imageUrl: post.imageUrl!,
                            shimmerBaseColor: Colors.grey[200],
                          ),
                  ),
                ),
                if (_checkIfVideo(post.imageUrl!))
                  const Positioned(
                      right: 0,
                      top: 5,
                      child: Icon(
                        Icons.play_circle,
                        color: Colors.grey,
                      )),
              ],
            ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Text(
                  post.content,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w400),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                const Spacer(),
                const Icon(
                  Icons.favorite,
                  color: Colors.red,
                  size: 15,
                ),
                Text('${post.likes}'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
