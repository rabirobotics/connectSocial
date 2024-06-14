import 'dart:io';

import 'package:connect/utils/constant.dart';
import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:path/path.dart' as path;
import 'package:visibility_detector/visibility_detector.dart';

class MediaDisplayWidget extends StatefulWidget {
  final bool isFile;
  final String url;

  const MediaDisplayWidget({
    super.key,
    required this.isFile,
    required this.url,
  });

  @override
  _MediaDisplayWidgetState createState() => _MediaDisplayWidgetState();
}

class _MediaDisplayWidgetState extends State<MediaDisplayWidget> {
  VideoPlayerController? _videoPlayerController;

  bool _isVideo = false;
  bool _isMuted = false;

  @override
  void initState() {
    super.initState();
    _isVideo = _checkIfVideo(widget.url);
    if (_isVideo) {
      _initializeVideoPlayer();
    }
  }

  @override
  void dispose() {
    if (_videoPlayerController != null) {
      _videoPlayerController!.dispose();
    }

    super.dispose();
  }

  void pauseVideo() {
    _videoPlayerController!.pause();
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
    _videoPlayerController = widget.isFile
        ? VideoPlayerController.file(File(widget.url))
        : VideoPlayerController.networkUrl(Uri.parse(widget.url))
      ..initialize().then((value) {
        setState(() {
          _isMuted = false;
        });
        _videoPlayerController!.play();
        _videoPlayerController!.setVolume(1);
        _videoPlayerController!.setLooping(true);
        print(_videoPlayerController!.value.aspectRatio);
      });
  }

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
      _videoPlayerController!.setVolume(_isMuted ? 0 : 1);
    });
  }

  void playVideoFullScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            FullScreenVideoPlayer(controller: _videoPlayerController!),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _isVideo
        ? _videoPlayerController != null
            ? _videoPlayerController!.value.isInitialized
                ? VisibilityDetector(
                    key: Key(widget.url),
                    onVisibilityChanged: (visibilityInfo) {
                      if (visibilityInfo.visibleFraction > 0.5) {
                        _videoPlayerController!.play();
                      } else {
                        _videoPlayerController!.pause();
                      }
                    },
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: () => _videoPlayerController!.value.isPlaying
                              ? _videoPlayerController!.pause()
                              : _videoPlayerController!.play(),
                          child: FittedBox(
                            fit: BoxFit.contain,
                            child: SizedBox(
                              height:
                                  _videoPlayerController!.value.size.height / 2,
                              width:
                                  _videoPlayerController!.value.size.width / 2,
                              child: Stack(
                                children: [
                                  VideoPlayer(_videoPlayerController!),
                                  Positioned(
                                    bottom: 0,
                                    right: 10,
                                    child: IconButton(
                                        onPressed: () => _toggleMute(),
                                        icon: Icon(
                                          _isMuted
                                              ? Icons.volume_up_rounded
                                              : Icons.volume_off_rounded,
                                          color: white,
                                        )),
                                  ),
                                  Positioned(
                                    bottom: 10,
                                    left: 10,
                                    child: IconButton(
                                      icon: const Icon(Icons.fullscreen),
                                      color: Colors.white,
                                      onPressed: () =>
                                          playVideoFullScreen(context),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        VideoProgressIndicator(
                          _videoPlayerController!,
                          allowScrubbing: true,
                          colors: const VideoProgressColors(
                              playedColor: Colors.amber),
                          padding: const EdgeInsets.only(bottom: 5),
                        ),
                      ],
                    ),
                  )
                : Container(
                    color: Colors.grey[200],
                    height: 300,
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: Colors.amber,
                      ),
                    ),
                  )
            : Container(
                color: Colors.grey[200],
                height: 300,
                child: const Center(
                  child: CircularProgressIndicator(
                    color: Colors.amber,
                  ),
                ),
              )
        : widget.isFile
            ? Image.file(File(widget.url))
            : SizedBox(
                width: MediaQuery.of(context).size.width,
                child: FancyShimmerImage(
                  imageUrl: widget.url,
                  shimmerBaseColor: Colors.grey[200],
                ),
              );
  }
}

class FullScreenVideoPlayer extends StatefulWidget {
  final VideoPlayerController controller;

  const FullScreenVideoPlayer({super.key, required this.controller});

  @override
  State<FullScreenVideoPlayer> createState() => _FullScreenVideoPlayerState();
}

class _FullScreenVideoPlayerState extends State<FullScreenVideoPlayer> {
  @override
  Widget build(BuildContext context) {
    final mediaQuerry = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Column(
          children: [
            Center(
              child: widget.controller.value.isInitialized
                  ? GestureDetector(
                      onTap: () => widget.controller.value.isPlaying
                          ? widget.controller.pause()
                          : widget.controller.play(),
                      child: SizedBox(
                          height: mediaQuerry.height * 0.95,
                          width: mediaQuerry.width,
                          child: VideoPlayer(widget.controller)))
                  : const CircularProgressIndicator(),
            ),
            VideoProgressIndicator(
              widget.controller,
              allowScrubbing: true,
              colors: const VideoProgressColors(playedColor: Colors.amber),
              padding: const EdgeInsets.only(bottom: 5),
            ),
          ],
        ),
      ),
    );
  }
}
