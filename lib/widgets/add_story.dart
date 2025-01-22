import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
                      child: Stack(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.grey.shade300,
                            backgroundImage: NetworkImage(user.photoUrl),
                            radius: 35,
                          ),
                          const Positioned(
                            bottom: 4,
                            right: 0,
                            child: Icon(
                              Icons.add_circle_rounded,
                              size: 20,
                              color: primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.userName,
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
            )
          : Container(),
    );
  }
}
