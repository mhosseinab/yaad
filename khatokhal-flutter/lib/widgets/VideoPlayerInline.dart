import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:video_player/video_player.dart';

import '../services/backend.dart';

class VideoPlayerInline extends StatefulWidget {
  final String url;
  final VoidCallback? onPlay;

  const VideoPlayerInline({Key? key, required this.url, this.onPlay})
      : super(key: key);

  @override
  _VideoPlayerInlineState createState() => _VideoPlayerInlineState(url, onPlay);
}

class _VideoPlayerInlineState extends State<VideoPlayerInline> {
  final url;
  final VoidCallback? onPlay;
  bool _isActive = false;

  _VideoPlayerInlineState(this.url, [this.onPlay]);

  @override
  Widget build(BuildContext context) {
    // print(url);
    final double _width = MediaQuery.of(context).size.width - 24;
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Container(
        width: _width,
        height: _width / 16 * 9,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(15),
        ),
        child: _isActive
            ? VideoPlayer(url, onPlay)
            : ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: VideoPlaceHolder(
                  url: url,
                  onPressed: () {
                    setState(() {
                      _isActive = true;
                    });
                  },
                ),
              ),
      ),
    );
  }
}

class VideoPlaceHolder extends StatelessWidget {
  final VoidCallback onPressed;
  final String url;

  VideoPlaceHolder({required this.onPressed, required this.url});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        AspectRatio(
          aspectRatio: 16 / 9,
          child: CachedNetworkImage(
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
            imageUrl: BackendService.BASE_URL +
                '/get/media/thumbnail/?url=${base64Url.encode(utf8.encode(url))}',
            placeholder: (context, url) => SizedBox.shrink(),
            errorWidget: (context, url, error) => SizedBox.shrink(),
          ),
        ),
        Positioned(
          child: FaIcon(
            FontAwesomeIcons.video,
            size: 30,
            color: Colors.black12,
          ),
          left: 16,
          top: 16,
        ),
        Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                color: Colors.white,
                width: 32,
                height: 32,
              ),
              IconButton(
                padding: EdgeInsets.zero,
                icon: const FaIcon(FontAwesomeIcons.youtube),
                color: Colors.red,
                iconSize: 64,
                onPressed: onPressed,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class VideoPlayer extends StatefulWidget {
  final url;
  final VoidCallback? onPlay;
  VideoPlayer(this.url, this.onPlay);

  @override
  _VideoPlayerState createState() => _VideoPlayerState(url, onPlay);
}

class _VideoPlayerState extends State<VideoPlayer> {
  final url;
  final VoidCallback? onPlay;
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;

  _VideoPlayerState(this.url, [this.onPlay]);

  @override
  void initState() {
    _initializePlayer();
    super.initState();
  }

  @override
  void dispose() {
    try {
      _videoPlayerController.dispose();
    } catch (_) {}
    _chewieController?.dispose();
    super.dispose();
  }

  Future<void> _initializePlayer() async {
    _videoPlayerController = VideoPlayerController.network(url);
    await Future.wait([
      _videoPlayerController.initialize(),
    ]);
    _createChewieController();
    setState(() {});
  }

  void _createChewieController() {
    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      autoPlay: true,
      looping: false,
      showOptions: false,
      // Try playing around with some of these other options:

      // showControls: false,
      // materialProgressColors: ChewieProgressColors(
      //   playedColor: Colors.red,
      //   handleColor: Colors.blue,
      //   backgroundColor: Colors.grey,
      //   bufferedColor: Colors.lightGreen,
      // ),
      // placeholder: Container(
      //   color: Colors.grey,
      // ),
      // autoInitialize: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    // print(url);
    final double _width = MediaQuery.of(context).size.width;
    return Container(
      width: _width,
      height: _width / 16 * 9 + _width * 0.1,
      color: Colors.black,
      child: Center(
        child: _chewieController != null &&
                _chewieController!.videoPlayerController.value.isInitialized
            ? Chewie(
                controller: _chewieController!,
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  CircularProgressIndicator(),
                  SizedBox(height: 8),
                  Text('Loading'),
                ],
              ),
      ),
    );
  }
}
