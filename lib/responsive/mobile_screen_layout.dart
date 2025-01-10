import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../screens/add_post_screen.dart';
import '../screens/feed_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/search_screen.dart';
import '../screens/reels_screen.dart';
import '../utils/colors.dart';
import '../api/reels.dart'; // Ensure you import your ReelService

class MobileScreenLayout extends StatefulWidget {
  const MobileScreenLayout({super.key});

  @override
  State<MobileScreenLayout> createState() => _MobileScreenLayoutState();
}

class _MobileScreenLayoutState extends State<MobileScreenLayout> {
  int _page = 0;
  late PageController pageController;

  // Initialize homeScreenItems with updated VideoReelPage using ReelService
  late List<Widget> homeScreenItems;

  @override
  void initState() {
    super.initState();
    pageController = PageController();

    // Initialize homeScreenItems after fetching reel data if needed
    homeScreenItems = [
      const FeedScreen(),
      const SearchScreen(),
      const AddPost(isPost: true),
      //Container(),
      //Updated VideoReelPage with ReelService values:
      VideoReelPage(
        index: 0, 
        reels: ReelService().getReels(),
      ),
      ProfileScreen(uid: FirebaseAuth.instance.currentUser!.uid),
    ];
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        physics: const NeverScrollableScrollPhysics(),
        controller: pageController,
        onPageChanged: onPageChanged,
        children: homeScreenItems,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _page,
        selectedFontSize: 0,
        backgroundColor: mobileBackgroundColor,
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home,
              color: _page == 0 ? primaryColor : secondaryColor,
            ),
            label: '',
            backgroundColor: mobileBackgroundColor,
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.search,
              color: _page == 1 ? primaryColor : secondaryColor,
            ),
            label: '',
            backgroundColor: mobileBackgroundColor,
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.add_circle,
              color: _page == 2 ? primaryColor : secondaryColor,
            ),
            label: '',
            backgroundColor: mobileBackgroundColor,
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.play_circle_outline,
              color: _page == 3 ? primaryColor : secondaryColor,
            ),
            label: '',
            backgroundColor: mobileBackgroundColor,
          ),
          // Added missing navigation item to sync with the sixth page (Container or any other page)
          BottomNavigationBarItem(
            icon: Icon(
              Icons.person_outline,
              color: _page == 4 ? primaryColor : secondaryColor,
            ),
            label: '',
            backgroundColor: mobileBackgroundColor,
          ),
          // // If you want a sixth tab for the ProfileScreen:
          // BottomNavigationBarItem(
          //   icon: Icon(
          //     Icons.person,
          //     color: _page == 5 ? primaryColor : secondaryColor,
          //   ),
          //   label: '',
          //   backgroundColor: mobileBackgroundColor,
          // ),
        ],
        onTap: navigationTapped,
      ),
    );
  }

  void navigationTapped(int page) {
    pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeIn,
    );
  }

  void onPageChanged(int page) {
    setState(() {
      _page = page;
    });
  }
}