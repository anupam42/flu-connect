import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

import '../utils/colors.dart';
import '../widgets/post_card.dart';
import '../utils/utils.dart';
import '../screens/chat_screen.dart';
import '../resources/firestore_methods.dart';
import '../widgets/add_story.dart';
import '../widgets/stories.dart';
import '../utils/page_animation.dart';

class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return SafeArea(
      child: Scaffold(
        appBar: width > webScreenSize
            ? null
            : AppBar(
                backgroundColor: mobileBackgroundColor,
                // title: SvgPicture.asset(
                //   'assets/insta_logo.svg',
                //   color: primaryColor,
                //   height: 32,
                // ),
                title: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Column(
                      mainAxisSize:
                          MainAxisSize.min, // Use min to wrap content tightly
                      crossAxisAlignment: CrossAxisAlignment
                          .start, // Center-align children horizontally
                      children: [
                        // Replace with your image asset path or network URL
                        Image.asset(
                          'assets/connuect.jpeg',
                          height: 23,
                        ),
                        const SizedBox(
                            height: 8), // Space between image and title
                        Text(
                          'Make Friend, Influence and Earn.',
                          style: GoogleFonts.aDLaMDisplay(
                            textStyle: Theme.of(context).textTheme.displayLarge,
                            fontSize: 5,
                            fontWeight: FontWeight.w700,
                          ),
                          textAlign: TextAlign.center, // Center text if needed
                        ),
                      ],
                    ),
                  ],
                ),
                actions: [
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.notifications,
                    ),
                  ),
                ],
              ),
        body: RefreshIndicator(
          onRefresh: () async {
            await FirestoreMethods().refreshStories();
          },
          child: GestureDetector(
            onHorizontalDragEnd: (details) {
              if (details.velocity.pixelsPerSecond.dx < 0) {
                Navigator.of(context).push(
                  PageAnimation.createRoute(
                      page: const ChatScreen(),
                      beginOffset1: 1.0,
                      beginOffset2: 0.0),
                );
              }
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 120,
                    width: double.infinity,
                    child: ListView(
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      children: const [
                        AddStory(),
                        Stories(),
                      ],
                    ),
                  ),
                  StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('posts')
                        .orderBy("datepublished", descending: true)
                        .snapshots(),
                    builder: (context,
                        AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>
                            snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      return ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) => Container(
                          margin: EdgeInsets.symmetric(
                            horizontal: width > webScreenSize ? width * 0.3 : 0,
                            vertical: width > webScreenSize ? 15 * 0.3 : 0,
                          ),
                          child: PostCard(
                            snap: snapshot.data!.docs[index].data(),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
