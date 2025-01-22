import 'package:flutter/material.dart';
import 'package:story_view/story_view.dart';

import '../resources/firestore_methods.dart';
import '../utils/colors.dart';

class StoriesScreen extends StatefulWidget {
  final String username;
  final String uid;
  final String profPic;
  final List<Map<String, dynamic>>? stories;

  const StoriesScreen(
      {required this.username,
      required this.uid,
      required this.profPic,
      this.stories,
      super.key});

  @override
  State<StoriesScreen> createState() => _StoriesScreenState();
}

class _StoriesScreenState extends State<StoriesScreen> {
  final StoryController controller = StoryController();

  List<StoryItem> items = [];

  @override
  void initState() {
    stories();
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void stories() async {
  try {
    if (widget.stories != null) {
      // Use dummy stories if provided
      setState(() {
        for (var element in widget.stories!) {
          items.add(StoryItem.pageImage(
            url: element['storyimg'],
            controller: controller,
            imageFit: BoxFit.contain,
            caption: null,
          ));
        }
      });
    } else {
      // Fetch stories from Firestore
      final list = await FirestoreMethods().getStories(widget.uid);
      setState(() {
        for (var element in list) {
          items.add(StoryItem.pageImage(
            url: element,
            controller: controller,
            imageFit: BoxFit.contain,
            caption: null,
          ));
        }
      });
    }
  } catch (e) {
    // Handle errors gracefully
    rethrow;
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: secondaryColor,
            backgroundImage: NetworkImage(widget.profPic),
          ),
        ),
        title: Text(
          widget.username,
        ),
      ),
      body: items.isEmpty
          ? Container()
          : StoryView(
              repeat: false,
              inline: true,
              storyItems: items,
              controller: controller,
              progressPosition: ProgressPosition.top,
              onComplete: () => Navigator.of(context).pop(),
              onVerticalSwipeComplete: (direction) {
                if (direction == Direction.down) {
                  Navigator.of(context).pop();
                }
              },
            ),
    );
  }
}
