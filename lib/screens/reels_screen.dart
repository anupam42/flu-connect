import 'package:connuect/screens/product_listing_screen.dart';
import 'package:connuect/utils/colors.dart';
import 'package:connuect/widgets/follow_button.dart';
import 'package:flutter/material.dart';
import 'package:connuect/widgets/video_player.dart';

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

  void _onCommentPressed() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Comment action triggered!')),
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
              // Video Player
              Positioned.fill(
                child: VideoPlayerWidget(
                  key: Key(currentReelUrl),
                  reelUrl: currentReelUrl,
                ),
              ),
              // User info with Connect button beside the username
              Positioned(
                bottom: 20, // Some spacing from the bottom edge
                left: 20,
                right: 20,
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 24,
                      backgroundImage: NetworkImage(
                        'https://via.placeholder.com/150', // Replace with actual profile photo URL
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'UserName', // Replace with dynamic user name
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 100, // Adjust this value to set the desired width
                      child: FollowButton(
                        backgroundColor: Colors.transparent,
                        borderColor: Colors.grey,
                        text: 'Connect',
                        textColor: primaryColor,
                        function: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Connect request sent!')),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              // Bottom action buttons
              Positioned(
                bottom: 100,
                right: 20,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Favorite
                    IconButton(
                      icon: const Icon(
                        Icons.favorite_border,
                        color: Colors.white,
                        size: 30,
                      ),
                      onPressed: _onFavoritePressed,
                    ),
                    const SizedBox(height: 20),
                    // Product
                    IconButton(
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
                    const SizedBox(height: 20),
                    // Comment
                    IconButton(
                      icon: const Icon(
                        Icons.comment,
                        color: Colors.white,
                        size: 30,
                      ),
                      onPressed: _onCommentPressed,
                    ),
                    const SizedBox(height: 20),
                    // Share
                    IconButton(
                      icon: const Icon(
                        Icons.share,
                        color: Colors.white,
                        size: 30,
                      ),
                      onPressed: _onSharePressed,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
