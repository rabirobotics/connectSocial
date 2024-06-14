import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connect/models/post_model.dart';
import 'package:connect/models/user_model.dart';
import 'package:connect/services/auth_service.dart';
import 'package:connect/services/database_service.dart';
import 'package:connect/utils/constant.dart';
import 'package:connect/views/auth/login_view.dart';
import 'package:connect/views/profile/edit_profile.dart';
import 'package:connect/views/search/search_post_view.dart';
import 'package:connect/views/widgets/snackBar.dart';
import 'package:connect/views/widgets/video_thumbnail.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:nb_utils/nb_utils.dart' as nb;
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key, this.userId});
  final String? userId;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  User? userProfile;
  final bool _isFetchingPost = false;
  List<Post> userPosts = [];
  bool _isLoading = false;
  bool _isFollowing = false;
  bool _isFollowStatusChanging = false;

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
    checkFollowing();
    fetchPosts();
  }

  Future<void> _fetchUserProfile() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final databaseService =
        Provider.of<DatabaseService>(context, listen: false);
    final userId = authService.user!.uid;

    try {
      setState(() {
        _isLoading = true;
      });
      print(widget.userId);
      userProfile =
          (await databaseService.getUserProfile(widget.userId ?? userId))!;
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      snack(context, 'Error fetching user profile: $e', Colors.red);
    }
  }

  Future<List<Post>> fetchPosts() async {
    final authService = Provider.of<AuthService>(context, listen: false);

    final userId = authService.user!.uid;
    List<Post> posts = [];
    final FirebaseFirestore db = FirebaseFirestore.instance;
    Query query = db
        .collection('posts')
        .where("userId", isEqualTo: widget.userId ?? userId)
        .orderBy('timestamp', descending: true);

    QuerySnapshot querySnapshot = await query.get();
    print(querySnapshot.docs.length);

    if (querySnapshot.docs.isNotEmpty) {
      for (int i = 0; i < querySnapshot.docs.length; i++) {
        posts.add(Post.fromFirestore(querySnapshot.docs[i]));
      }
      userPosts = posts;
      return posts;
    }
    return [];
  }

  Widget item(String title, String val) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            val,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 16,
            ),
          )
        ],
      ),
    );
  }

  Future<void> logout() async {
    final auth = Provider.of<AuthService>(context, listen: false);
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
              title: const Text(
                "Are you sure you want to logout?",
                style: TextStyle(color: indigo, fontSize: 16),
              ),
              actions: [
                TextButton(
                  onPressed: () async {
                    await auth.logout().then(
                      (value) {
                        Navigator.of(context).pop();
                        if (widget.userId != null) {
                          Navigator.of(context).pop();
                        }
                        Navigator.of(context)
                            .popAndPushNamed(LoginScreen.routeName);
                        snack(
                            context, "Logged Out successfully.", Colors.green);
                      },
                    );
                  },
                  child: const Text("Yes"),
                ),
                TextButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                  },
                  child: const Text("No"),
                )
              ]);
        });
  }

  Future<void> checkFollowing() async {
    if (widget.userId != null) {
      final auth = Provider.of<AuthService>(context, listen: false);
      final FirebaseFirestore db = FirebaseFirestore.instance;

      DocumentSnapshot userSnapshot =
          await db.collection("users").doc(widget.userId).get();
      User user = await User.fromFirestore(userSnapshot);
      print("USer FOllowers ${user.followers}");
      if (user.followers.any((element) => element == auth.user!.uid)) {
        print(
            "isfollowing${user.followers.any((element) => element == auth.user!.uid)}");
        setState(() {
          _isFollowing = true;
        });
      }
    }
  }

  Future<void> _follow() async {
    final dataService = Provider.of<DatabaseService>(context, listen: false);
    final auth = Provider.of<AuthService>(context, listen: false);
    setState(() {
      _isFollowStatusChanging = true;
    });
    try {
      if (_isFollowing) {
        await dataService.unfollowUser(auth.user!.uid, widget.userId!).then(
              (value) => setState(() {
                _isFollowing = false;
                _isFollowStatusChanging = false;
              }),
            );
      } else {
        await dataService.followUser(auth.user!.uid, widget.userId!).then(
              (_) => setState(() {
                _isFollowing = true;
                _isFollowStatusChanging = false;
              }),
            );
      }
    } catch (error) {
      setState(() {
        _isFollowStatusChanging = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final user = Provider.of<AuthService>(context);
    print("User Id form here: ${user.user!.uid}");
    print(" Id form here: ${widget.userId}");
    return Scaffold(
      appBar: AppBar(
        backgroundColor: indigo,
        title: const Text(
          'Profile',
          style: TextStyle(color: white),
        ),
        actions: [
          if (widget.userId == null || (user.user!.uid == widget.userId))
            IconButton(
                onPressed: () =>
                    Navigator.of(context).pushNamed(ProfileEditPage.routeName),
                icon: const Icon(
                  Icons.settings,
                  color: Colors.white,
                )),
          if (widget.userId == null || (user.user!.uid == widget.userId))
            IconButton(
                onPressed: () => logout(),
                icon: const Icon(
                  Icons.logout,
                  color: Colors.white,
                ))
        ],
      ),
      body: (_isLoading || (userProfile == null))
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: userProfile!.profilePic.isNotEmpty
                              ? NetworkImage(userProfile!.profilePic)
                              : null,
                          child: userProfile!.profilePic.isEmpty
                              ? const Icon(Icons.person, size: 50)
                              : null,
                        ),
                        const Spacer(),
                        item("Followers",
                            userProfile!.followers.length.toString()),
                        item("Following",
                            userProfile!.following.length.toString()),
                        item("Posts", "${userPosts.length}"),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      userProfile!.username,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ).paddingOnly(left: 10, bottom: 5),
                    // Text(userProfile.email),
                    Text(userProfile!.bio).paddingLeft(10),
                    if (widget.userId == null ||
                        (widget.userId == user.user!.uid))
                      const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "My Posts",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Divider(),
                        ],
                      ).paddingSymmetric(vertical: 10, horizontal: 8),
                    if (widget.userId != null
                        ? (widget.userId != user.user!.uid)
                        : false)
                      GestureDetector(
                        onTap: () => _follow(),
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                              color: _isFollowing
                                  ? Colors.grey[300]
                                  : Colors.indigo,
                              borderRadius: BorderRadius.circular(15)),
                          // height: 50,
                          width: MediaQuery.of(context).size.width * 0.9,
                          child: Center(
                            child: _isFollowStatusChanging
                                ? const CircularProgressIndicator(
                                    color: white,
                                    strokeWidth: 3,
                                  ).paddingAll(10)
                                : Text(
                                    _isFollowing ? "Unfollow" : "Follow",
                                    style: TextStyle(
                                        color: _isFollowing ? black : white),
                                  ).paddingAll(10),
                          ),
                        ),
                      ),
                    FutureBuilder<List<Post>>(
                      future: fetchPosts(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        if (snapshot.hasError) {
                          return Center(
                              child: Text(
                                  'Error fetching posts: ${snapshot.error}'));
                        }

                        final posts = snapshot.data;

                        if (posts == null || posts.isEmpty) {
                          return const Center(child: Text('No posts found'));
                        }

                        return GridView.builder(
                          shrinkWrap: true,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 10,
                            crossAxisSpacing: 10,
                            childAspectRatio: 0.75,
                          ),
                          itemCount: posts.length,
                          itemBuilder: (context, index) {
                            final post = posts[index];
                            return GestureDetector(
                                onTap: () => Navigator.of(context)
                                    .push(MaterialPageRoute(
                                        builder: (_) => SearchPostView(
                                              post: post,
                                            ))),
                                child: VideoThumbnail(post: post));
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
