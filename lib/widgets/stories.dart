import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../screens/stories_screen.dart';
import '../utils/page_animation.dart';

class Stories extends StatelessWidget {
  const Stories({super.key});

  // Define dummy stories for the "Connect" avatar
  final List<Map<String, dynamic>> dummyConnectStories = const [
    {
      'uid': 'connect_dummy_1',
      'username': 'Alice',
      'userimage': 'https://cdn.pixabay.com/photo/2024/08/15/19/19/highland-cow-8972000_1280.jpg',
      'storyContent': 'Story content for Alice',
    },
    {
      'uid': 'connect_dummy_2',
      'username': 'Bob',
      'userimage': 'https://cdn.pixabay.com/photo/2021/10/02/21/00/ural-owl-6676441_1280.jpg',
      'storyContent': 'Story content for Bob',
    },
  ];

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

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                // "Connect" Story Avatar
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      PageAnimation.createRoute(
                        page: const StoriesScreen(
                          username: 'Connect',
                          profPic: 'assets/connuect.jpeg',
                          uid: 'connect',
                        ),
                        beginOffset1: 0.0,
                        beginOffset2: 1.0,
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.grey,
                              width: 3,
                            ),
                          ),
                          child: CircleAvatar(
                            backgroundColor: Colors.grey.shade300,
                            radius: 35,
                            child: ClipOval(
                              child: Image.asset(
                                'assets/connuect.jpeg',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Connect',
                          style: GoogleFonts.roboto(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
                // User Stories
                ...groupedStories.keys.map((uid) {
                  final stories = groupedStories[uid]!;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: StoriesCardGroup(stories: stories),
                  );
                }).toList(),
              ],
            ),
          );
        },
      ),
    );
  }
}

class StoriesCardGroup extends StatelessWidget {
  const StoriesCardGroup({super.key, required this.stories});

  final List<Map<String, dynamic>> stories;

  @override
  Widget build(BuildContext context) {
    final firstStory = stories[0];

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          PageAnimation.createRoute(
            page: StoriesScreen(
              username: firstStory['username'],
              profPic: firstStory['userimage'],
              uid: firstStory['uid'],
            ),
            beginOffset1: 0.0,
            beginOffset2: 1.0,
          ),
        );
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color.fromARGB(255, 237, 101, 232),
                width: 3,
              ),
            ),
            child: CircleAvatar(
              backgroundImage: NetworkImage(firstStory['userimage']),
              backgroundColor: Colors.grey.shade300,
              radius: 35,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            firstStory['username'],
            style: GoogleFonts.roboto(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}