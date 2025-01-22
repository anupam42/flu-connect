import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connuect/screens/edit_profile.dart';
import 'package:connuect/screens/product_listing_screen.dart';
import 'package:connuect/screens/settings_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../resources/firestore_methods.dart';
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

  Stream<DocumentSnapshot<Map<String, dynamic>>> userStream() {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(widget.uid)
        .snapshots();
  }

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
    updatePostLen();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: userStream(),
      builder: (context, snapshot) {
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

        final data = snapshot.data!.data()!;
        final Map<String, dynamic> userData = {
          'uid': data['uid'] ?? '',
          'username': data['username'] ?? '',
          'photourl': data['photourl'],
          'bio': data['bio'] ?? '',
          'followers': data['followers'] ?? <dynamic>[],
          'following': data['following'] ?? <dynamic>[],
        };

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
          length: 4,
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
              actions: [
                IconButton(
                  icon: const Icon(Icons.notifications),
                  onPressed: () {
                    showSnackBar('Favorite icon pressed!', context);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.message),
                  onPressed: () {
                    showSnackBar('Message icon pressed!', context);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.settings),
                  onPressed: () {
                    Navigator.of(context).push(
                      PageAnimation.createRoute(
                        page: const SettingsScreen(),
                        beginOffset1: 0.0,
                        beginOffset2: 1.0,
                      ),
                    );
                  },
                ),
              ],
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
                        Tab(
                          icon: const Icon(Icons.grid_on),
                          text: 'Posts ($postLen)',
                        ),
                        const Tab(
                          icon: Icon(Icons.video_library),
                          text: 'Videos',
                        ),
                        const Tab(
                          icon: Icon(Icons.shopping_bag),
                          text: 'Products',
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
                      _buildVideosTab(),
                      _buildProductsTab(),
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
                                  updatePostLen();
                                }
                              });
                            },
                          )
                        else if (isFollowing)
                          FollowButton(
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
                        else
                          FollowButton(
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
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No posts yet.'));
        }
        final docs = snapshot.data!.docs;
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

  Widget _buildVideosTab() {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
          .collection('videos')
          .where('uid', isEqualTo: widget.uid)
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No videos yet.'));
        }
        final docs = snapshot.data!.docs;
        return GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 5,
            mainAxisSpacing: 5,
            childAspectRatio: 1.5,
          ),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final snap = docs[index];
            final videoThumbnail = snap['thumbnail'] ?? '';
            return GestureDetector(
              onTap: () {
                // Add functionality to play video
              },
              child: Image(
                image: NetworkImage(videoThumbnail),
                fit: BoxFit.cover,
              ),
            );
          },
        );
      },
    );
  }

  // Widget _buildProductsTab() {
  //   return FutureBuilder<QuerySnapshot>(
  //     future: FirebaseFirestore.instance
  //         .collection('products')
  //         .where('uid', isEqualTo: widget.uid)
  //         .get(),
  //     builder: (context, snapshot) {
  //       if (snapshot.connectionState == ConnectionState.waiting) {
  //         return const Center(child: CircularProgressIndicator());
  //       }
  //       if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
  //         return const Center(child: Text('No products yet.'));
  //       }
  //       final docs = snapshot.data!.docs;
  //       return ListView.builder(
  //         itemCount: docs.length,
  //         itemBuilder: (context, index) {
  //           final docData = docs[index].data() as Map<String, dynamic>;
  //           final productName = docData['name'] ?? 'No name';
  //           final productPrice = docData['price'] ?? 0.0;
  //           return ListTile(
  //             leading: (docData['image'] != null)
  //                 ? Image.network(docData['image'], width: 50, fit: BoxFit.cover)
  //                 : const Icon(Icons.shopping_bag),
  //             title: Text(productName),
  //             subtitle: Text('\$${productPrice.toStringAsFixed(2)}'),
  //           );
  //         },
  //       );
  //     },
  //   );
  // }

  Widget _buildProductsTab() {
    return const ProductListScreen(category: 'Clothing');
  }

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
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No items in cart.'));
        }
        final docs = snapshot.data!.docs;
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
                        'Qty: $quantity   Price: \$${price.toStringAsFixed(2)}'),
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

  Future<void> _clearCartWithAnimation() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final cartRef = FirebaseFirestore.instance
        .collection('carts')
        .doc(uid)
        .collection('items');
    final snapshot = await cartRef.get();
    for (final doc in snapshot.docs) {
      await doc.reference.delete();
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cart cleared!')),
      );
    }
  }

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