import 'package:connect/models/product.dart';
import 'package:connect/models/reels.dart';
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
                bottom: 20,
                right: 20,
                child: FloatingActionButton(
                  onPressed: () {
                    List<ProductItem> productsForReel = [];
                    if (index < productsByReel.length) {
                      productsForReel = productsByReel[index];
                    }
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ProductListScreen(productItems: productsForReel),
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