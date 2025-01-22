import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  final random = Random();

  // Map reel indexes to categories
  final Map<int, String> reelCategories = {
    0: 'Clothing',
    1: 'Food',
    2: 'Books',
    3: 'Blog',
    4: 'Hotels',
  };

  List<String> usernames = [];  // Fetched usernames from Firestore
  Map<int, String> reelUsernames = {};  // Map reel index to a username

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.index);
    _loadUsernames();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<List<String>> fetchUsernames() async {
    final querySnapshot = await FirebaseFirestore.instance.collection('users').get();
    return querySnapshot.docs.map((doc) => doc['username'] as String).toList();
  }

  Future<void> _loadUsernames() async {
    try {
      final fetchedUsernames = await fetchUsernames();
      setState(() {
        usernames = fetchedUsernames;
        // Assign a random username to each reel index
        for (int i = 0; i < widget.reels.length; i++) {
          reelUsernames[i] = usernames[random.nextInt(usernames.length)];
        }
      });
    } catch (e) {
      print('Error fetching usernames: $e');
      // You can display an error message or fallback logic here.
    }
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
          final userName = reelUsernames[index] ?? 'UserName'; // Use mapped username

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
                bottom: 20,
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
                    Text(
                      userName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 100,
                      child: FollowButton(
                        backgroundColor: Colors.transparent,
                        borderColor: Colors.grey,
                        text: 'Connect',
                        textColor: primaryColor,
                        function: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Connect request sent!')),
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
                            builder: (context) => ProductListScreen(category: category),
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