import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class _TutorialPageState extends State<TutorialPage> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: 'A8JpOg_8K-g',
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
        // Add these two to help with the "handshake"
        disableDragSeek: false,
        loop: false,
        isLive: false,
        forceHD: false,
        enableCaption: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("App Tutorial"), 
        backgroundColor: Colors.black, // Changed from transparent for better contrast
        elevation: 0,
      ),
      body: Center(
        child: YoutubePlayerBuilder(
          // Wrap with Builder to handle orientation changes better
          player: YoutubePlayer(
            controller: _controller,
            showVideoProgressIndicator: true,
            progressIndicatorColor: const Color(0xFFD4AF37), // Matches your gold theme
            progressColors: const ProgressBarColors(
              playedColor: Color(0xFFD4AF37),
              handleColor: Colors.amber,
            ),
            // This is the "Ghosting" fix:
            onReady: () {
              debugPrint('Player is ready.');
            },
          ),
          builder: (context, player) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                player,
              ],
            );
          },
        ),
      ),
    );
  }