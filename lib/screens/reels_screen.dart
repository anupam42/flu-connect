import 'package:connect/screens/food_listing_screen.dart';
import 'package:flutter/material.dart';
import 'package:connect/widgets/video_player.dart'; // Ensure this imports your VideoPlayerWidget

class VideoReelPage extends StatefulWidget {
  const VideoReelPage({super.key, required this.reels, required this.index});
  final List<String> reels;
  final int index;

  @override
  _VideoReelPageState createState() => _VideoReelPageState();
}

class _VideoReelPageState extends State<VideoReelPage> {
  late PageController _pageController;
  int currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.index);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      // No global floatingActionButton here since we want one per reel
      body: PageView.builder(
        scrollDirection: Axis.vertical,
        controller: _pageController,
        itemCount: widget.reels.length,
        onPageChanged: (index) {
          setState(() {
            currentPage = index;
          });
        },
        itemBuilder: (context, index) {
          return Stack(
            children: [
              // Video player occupies the full screen
              Positioned.fill(
                child: VideoPlayerWidget(
                  key: Key(widget.reels[index]),
                  reelUrl: widget.reels[index],
                ),
              ),
              // Positioned FloatingActionButton over the video
              Positioned(
                bottom: 20,
                right: 20,
                child: FloatingActionButton(
                  onPressed: () {
                    // Navigate to FoodListScreen when icon is pressed
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const FoodListScreen(),
                      ),
                    );
                  },
                  child: const Icon(Icons.shopping_bag_rounded),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}