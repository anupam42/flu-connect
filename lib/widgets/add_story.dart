import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/add_post_screen.dart';
import '../utils/colors.dart';
import '../providers/user_provider.dart';
import '../utils/page_animation.dart';

class AddStory extends StatelessWidget {
  const AddStory({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).getUser;
    return Align(
      alignment: Alignment.centerLeft,
      child: user != null
          ? GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  PageAnimation.createRoute(
                      page: const AddPost(isPost: false),
                      beginOffset1: 0.0,
                      beginOffset2: 1.0),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(4.5),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          backgroundColor: secondaryColor,
                          backgroundImage: NetworkImage(user.photoUrl),
                          radius: 30,
                        ),
                        const Positioned(
                          bottom: 4,
                          right: 0,
                          child: Icon(
                            size: 20,
                            Icons.add_circle_rounded,
                            color: primaryColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4), // Spacing between avatar and text
                    Text(
                      user.userName,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white, // Customize as needed
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          : Container(),
    );
  }
}