import 'package:connect/screens/product_listing_screen.dart';
import 'package:flutter/material.dart';
import 'package:connect/widgets/video_player.dart';

class VideoReelPage extends StatefulWidget {
  const VideoReelPage({super.key, required this.reels, required this.index});
  final List<String> reels;
  final int index;

  @override
  _VideoReelPageState createState() => _VideoReelPageState();
}

class _VideoReelPageState extends State<VideoReelPage> {
  late PageController _pageController;

  // Map reel indexes to categories
  final Map<int, String> reelCategories = {
    0: 'Food',
    1: 'Household',
    2: 'Appliances',
    3: 'Groceries',
    4: 'Electronics',
    5: 'Clothing',
  };

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

  void _onFavoritePressed() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Favorited!')),
    );
  }

  void _onSharePressed() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Share action triggered!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView.builder(
        scrollDirection: Axis.vertical,
        controller: _pageController,
        itemCount: widget.reels.length,
        itemBuilder: (context, index) {
          final currentReelUrl = widget.reels[index];
          return Stack(
            children: [
              Positioned.fill(
                child: VideoPlayerWidget(
                  key: Key(currentReelUrl),
                  reelUrl: currentReelUrl,
                ),
              ),
              Positioned(
                bottom: 100,
                right: 20,
                child: IconButton(
                  icon: const Icon(
                    Icons.favorite_border,
                    color: Colors.white,
                    size: 30,
                  ),
                  onPressed: _onFavoritePressed,
                ),
              ),
              Positioned(
                bottom: 180,
                right: 20,
                child: IconButton(
                  icon: const Icon(
                    Icons.shopping_bag_rounded,
                    color: Colors.white,
                    size: 30,
                  ),
                  onPressed: () {
                    final category = reelCategories[index] ?? 'Food';
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) =>
                            ProductListScreen(category: category),
                      ),
                    );
                  },
                ),
              ),
              Positioned(
                bottom: 240,
                right: 20,
                child: IconButton(
                  icon: const Icon(
                    Icons.share,
                    color: Colors.white,
                    size: 30,
                  ),
                  onPressed: _onSharePressed,
                ),
              ),
              // Positioned(
              //   bottom: 20,
              //   right: 20,
              //   child: FloatingActionButton(
              //     onPressed: () {
              //       // Use the mapped category based on reel index or default to 'Food'
              //       final category = reelCategories[index] ?? 'Food';
              //       Navigator.of(context).push(
              //         MaterialPageRoute(
              //           builder: (context) => ProductListScreen(category: category),
              //         ),
              //       );
              //     },
              //     child: const Icon(Icons.shopping_bag_rounded),
              //   ),
              // ),
            ],
          );
        },
      ),
    );
  }
}
