// File: Pages/Chat/Widgets/VideoPlayerItem.dart

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerItem extends StatefulWidget {
  final String videoUrl;
  const VideoPlayerItem({super.key, required this.videoUrl});

  @override
  State<VideoPlayerItem> createState() => _VideoPlayerItemState();
}

class _VideoPlayerItemState extends State<VideoPlayerItem> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
    await _videoPlayerController.initialize();

    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      aspectRatio: _videoPlayerController.value.aspectRatio,
      autoPlay: false,
      looping: false,
      showControls: true,
      materialProgressColors: ChewieProgressColors(
        playedColor: Colors.blueAccent,
        handleColor: Colors.blueAccent,
        backgroundColor: Colors.grey,
        bufferedColor: Colors.white30,
      ),
      placeholder: const Center(child: CircularProgressIndicator()),
      errorBuilder: (context, errorMessage) {
        return Center(child: Text(errorMessage, style: const TextStyle(color: Colors.white)));
      },
    );

    setState(() {
      _isInitialized = true;
    });
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 300), // Prevent videos from taking up the whole screen
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: _isInitialized && _chewieController != null
            ? Chewie(controller: _chewieController!)
            : const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}