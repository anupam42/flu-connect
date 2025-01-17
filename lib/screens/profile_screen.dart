import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connect/screens/edit_profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../resources/firestore_methods.dart';
import '../screens/login_screen.dart';
import '../utils/colors.dart';
import '../utils/utils.dart';
import '../widgets/follow_button.dart';
import '../utils/page_animation.dart';

class ProfileScreen extends StatefulWidget {
  final String uid;
  final int initialTabIndex;
  const ProfileScreen({
    required this.uid,
    this.initialTabIndex = 0,
    Key? key,
  }) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int postLen = 0;
  int followers = 0;
  int following = 0;
  bool isFollowing = false;

  // Helper: Create a stream for user document
  Stream<DocumentSnapshot<Map<String, dynamic>>> userStream() {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(widget.uid)
        .snapshots();
  }

  // Fetch post length separately since posts are not streamed here
  Future<void> updatePostLen() async {
    final postSnap = await FirebaseFirestore.instance
        .collection('posts')
        .where('uid', isEqualTo: widget.uid)
        .get();
    setState(() {
      postLen = postSnap.docs.length;
    });
  }

  @override
  void initState() {
    super.initState();
    // Initialize post count once. Posts updates can also be streamed similarly if needed.
    updatePostLen();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: userStream(),
      builder: (context, snapshot) {
        // Loading or error handling
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: mobileBackgroundColor,
              title: const Text('Profile'),
            ),
            body: const Center(child: Text('No user data found.')),
          );
        }

        // Extract user data from snapshot
        final data = snapshot.data!.data()!;
        final Map<String, dynamic> userData = {
          'uid': data['uid'] ?? '',
          'username': data['username'] ?? '',
          'photourl': data['photourl'],
          'bio': data['bio'] ?? '',
          'followers': data['followers'] ?? <dynamic>[],
          'following': data['following'] ?? <dynamic>[],
        };

        // Update follower/following count and state
        final followersList = (userData['followers'] is List)
            ? userData['followers'] as List
            : <dynamic>[];
        final followingList = (userData['following'] is List)
            ? userData['following'] as List
            : <dynamic>[];

        followers = followersList.length;
        following = followingList.length;
        isFollowing =
            followersList.contains(FirebaseAuth.instance.currentUser?.uid);

        return DefaultTabController(
          length: 2,
          initialIndex: widget.initialTabIndex,
          child: Scaffold(
            appBar: AppBar(
              backgroundColor: mobileBackgroundColor,
              title: Text(
                userData['username'] ?? '',
                style: GoogleFonts.meowScript(
                  textStyle: Theme.of(context).textTheme.displayLarge,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                ),
              ),
              centerTitle: false,
            ),
            body: Column(
              children: [
                _buildProfileHeader(userData),
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('carts')
                      .doc(FirebaseAuth.instance.currentUser!.uid)
                      .collection('items')
                      .snapshots(),
                  builder: (context, snapshot) {
                    int cartCount = 0;
                    if (snapshot.hasData) {
                      cartCount = snapshot.data!.docs.length;
                    }

                    return TabBar(
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.grey,
                      indicatorColor: Colors.white,
                      tabs: [
                        const Tab(
                          icon: Icon(Icons.grid_on),
                          text: 'Posts',
                        ),
                        Tab(
                          icon: Stack(
                            children: [
                              const Icon(Icons.shopping_cart),
                              if (cartCount > 0)
                                Positioned(
                                  right: 0,
                                  top: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(2.0),
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    constraints: const BoxConstraints(
                                      minWidth: 16,
                                      minHeight: 16,
                                    ),
                                    child: Text(
                                      '$cartCount',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          text: 'Cart',
                        ),
                      ],
                    );
                  },
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _buildPostsGrid(),
                      _buildCartTab(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileHeader(Map<String, dynamic> userData) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              // Profile Picture
              CircleAvatar(
                backgroundColor: Colors.grey,
                backgroundImage: (userData['photourl'] != null &&
                        (userData['photourl'] as String).isNotEmpty)
                    ? NetworkImage(userData['photourl'])
                    : null,
                radius: 40,
              ),
              Expanded(
                flex: 1,
                child: Column(
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        buildStatColumn(postLen, "Posts"),
                        buildStatColumn(followers, "Followers"),
                        buildStatColumn(following, "Following"),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        if (FirebaseAuth.instance.currentUser?.uid ==
                            widget.uid)
                          FollowButton(
                            backgroundColor: mobileBackgroundColor,
                            borderColor: Colors.grey,
                            text: 'Edit Profile',
                            textColor: primaryColor,
                            function: () {
                              Navigator.of(context)
                                  .push(
                                PageAnimation.createRoute(
                                  page: EditProfileScreen(userData: userData),
                                  beginOffset1: 0.0,
                                  beginOffset2: 1.0,
                                ),
                              )
                                  .then((result) {
                                if (result == true) {
                                  showSnackBar(
                                      'Profile updated successfully!', context);
                                  // No need to call getData() due to StreamBuilder
                                  updatePostLen(); // Refresh posts count in case posts changed
                                }
                              });
                            },
                          )
                        else
                          isFollowing
                              ? FollowButton(
                                  backgroundColor: Colors.white,
                                  borderColor: Colors.grey,
                                  text: 'Unfollow',
                                  textColor: Colors.black,
                                  function: () async {
                                    await FirestoreMethods().followUser(
                                      FirebaseAuth.instance.currentUser!.uid,
                                      userData['uid'],
                                    );
                                    setState(() {
                                      isFollowing = false;
                                      followers--;
                                    });
                                  },
                                )
                              : FollowButton(
                                  backgroundColor: Colors.blue,
                                  borderColor: Colors.blue,
                                  text: 'Follow',
                                  textColor: Colors.white,
                                  function: () async {
                                    await FirestoreMethods().followUser(
                                      FirebaseAuth.instance.currentUser!.uid,
                                      userData['uid'],
                                    );
                                    setState(() {
                                      isFollowing = true;
                                      followers++;
                                    });
                                  },
                                ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(top: 15),
            child: Text(
              userData['username'] ?? '',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(top: 1),
            child: Text(
              userData['bio'] ?? '',
            ),
          ),
        ],
      ),
    );
  }

  /// Posts tab: displays the user's posts in a grid
  Widget _buildPostsGrid() {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
          .collection('posts')
          .where('uid', isEqualTo: widget.uid)
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return const Center(child: Text('No posts yet.'));
        }

        final docs = snapshot.data!.docs;
        if (docs.isEmpty) {
          return const Center(child: Text('No posts yet.'));
        }

        return GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 5,
            mainAxisSpacing: 1.5,
            childAspectRatio: 1,
          ),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final snap = docs[index];
            final postUrl = snap['posturl'] ?? '';

            if (postUrl.isEmpty) {
              return Container(
                color: Colors.grey[300],
                child: const Center(child: Text('No image')),
              );
            }

            return Image(
              image: NetworkImage(postUrl),
              fit: BoxFit.cover,
            );
          },
        );
      },
    );
  }

  /// Cart tab: listens to Firestore for cart items, displays them in a list,
  /// and includes a "Proceed & Clear Cart" button.
  Widget _buildCartTab() {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('carts')
          .doc(uid)
          .collection('items')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return const Center(child: Text('No items in cart.'));
        }

        final docs = snapshot.data!.docs;
        if (docs.isEmpty) {
          return const Center(child: Text('No items in cart.'));
        }

        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final docData = docs[index].data() as Map<String, dynamic>;
                  final name = docData['name'] ?? 'No name';
                  final quantity = docData['quantity'] ?? 0;
                  final price = (docData['price'] != null)
                      ? docData['price'].toDouble()
                      : 0.0;

                  return ListTile(
                    title: Text(name),
                    subtitle: Text(
                      'Qty: $quantity   Price: \$${price.toStringAsFixed(2)}',
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: ElevatedButton(
                onPressed: _clearCartWithAnimation,
                child: const Text('Proceed & Clear Cart'),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Clears all items in the user's cart and displays a success message.
  Future<void> _clearCartWithAnimation() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final cartRef = FirebaseFirestore.instance
        .collection('carts')
        .doc(uid)
        .collection('items');

    // 1) Delete all items in the cart
    final snapshot = await cartRef.get();
    for (final doc in snapshot.docs) {
      await doc.reference.delete();
    }

    // 2) Show success message
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cart cleared!')),
      );
    }

    // 3) (Optional) Animate or show confetti here
  }

  /// Helper method to build a stat column (Posts, Followers, Following).
  Column buildStatColumn(int num, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          num.toString(),
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        Container(
          margin: const EdgeInsets.only(top: 4),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: Colors.grey,
            ),
          ),
        ),
      ],
    );
  }
}
