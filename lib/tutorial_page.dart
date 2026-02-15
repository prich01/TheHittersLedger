import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class TutorialPage extends StatefulWidget {
  @override
  _TutorialPageState createState() => _TutorialPageState();
}

class _TutorialPageState extends State<TutorialPage> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    // Replace 'VIDEO_ID' with the actual ID from your YouTube URL
    // e.g., if URL is youtube.com/watch?v=dQw4w9WgXcQ, the ID is dQw4w9WgXcQ
    _controller = YoutubePlayerController(
      initialVideoId: 'A8JpOg_8K-g',
      flags: const YoutubePlayerFlags(autoPlay: false, mute: false),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: const Text("App Tutorial"), backgroundColor: Colors.transparent),
      body: Center(
        child: YoutubePlayer(
          controller: _controller,
          showVideoProgressIndicator: true,
          progressIndicatorColor: Colors.red, // Matches the baseball theme
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}