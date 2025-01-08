import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../screens/stories_screen.dart';
import '../utils/colors.dart';
import '../utils/page_animation.dart';

class Stories extends StatelessWidget {
  const Stories({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('stories').snapshots(),
        builder: (context,
            AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container();
          }

          // Group stories by UID
          final groupedStories = <String, List<Map<String, dynamic>>>{};
          for (var doc in snapshot.data!.docs) {
            final story = doc.data();
            final uid = story['uid'];
            if (!groupedStories.containsKey(uid)) {
              groupedStories[uid] = [];
            }
            groupedStories[uid]!.add(story);
          }

          return ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            scrollDirection: Axis.horizontal,
            shrinkWrap: true,
            itemCount: groupedStories.keys.length + 1, // +1 for "Connect"
            itemBuilder: (context, index) {
              if (index == 0) {
                // Default circular with "Connect"
                return GestureDetector(
                  onTap: () {
                    // Add your connect functionality here
                  },
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.grey,
                            width: 3,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: CircleAvatar(
                            backgroundColor: Colors.grey.shade300,
                            radius: 30,
                            child: Text(
                              'Connect',
                              style: GoogleFonts.meowScript(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }

              // Stories for a particular UID
              final uid = groupedStories.keys.elementAt(index - 1);
              final stories = groupedStories[uid]!;

              return StoriesCardGroup(stories: stories);
            },
          );
        },
      ),
    );
  }
}

class StoriesCardGroup extends StatefulWidget {
  const StoriesCardGroup({super.key, required this.stories});

  final List<Map<String, dynamic>> stories;

  @override
  State<StoriesCardGroup> createState() => _StoriesCardGroupState();
}

class _StoriesCardGroupState extends State<StoriesCardGroup> {
  final Set<String> _viewedStories = {};

  void _markAsViewed(String uid) {
    setState(() {
      _viewedStories.add(uid);
    });
  }

  @override
  Widget build(BuildContext context) {
    final firstStory = widget.stories[0];
    final uid = firstStory['uid'];
    final isViewed = _viewedStories.contains(uid);

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          PageAnimation.createRoute(
            page: StoriesScreen(
              username: firstStory['username'],
              profPic: firstStory['userimage'],
              uid: uid,
            ),
            beginOffset1: 0.0,
            beginOffset2: 1.0,
          ),
        );
        _markAsViewed(uid);
      },
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: isViewed
                ? Colors.transparent
                : const Color.fromARGB(255, 237, 101, 232),
            width: 3,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(2.0),
          child: CircleAvatar(
            backgroundImage: NetworkImage(firstStory['userimage']),
            backgroundColor: secondaryColor,
            radius: 40,
          ),
        ),
      ),
    );
  }
}
