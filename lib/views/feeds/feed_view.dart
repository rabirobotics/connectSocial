import 'package:connect/models/post_model.dart';
import 'package:connect/models/user_model.dart';
import 'package:connect/services/auth_service.dart';
import 'package:connect/services/database_service.dart';
import 'package:connect/utils/constant.dart';
import 'package:connect/views/feeds/single_post_view.dart';
import 'package:connect/views/post/add_post.dart';
import 'package:connect/views/widgets/media_diaplay_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nb_utils/nb_utils.dart' as nb;
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

class FeedView extends StatefulWidget {
  const FeedView({super.key});

  @override
  _FeedViewState createState() => _FeedViewState();
}

class _FeedViewState extends State<FeedView> {
  final ScrollController _scrollController = ScrollController();

  List<Post> _posts = [];
  bool _isLoading = false;
  String uid = "";

  @override
  void initState() {
    super.initState();
    _fetchPosts();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          Provider.of<DatabaseService>(context, listen: false).hasMorePosts) {
        _fetchMorePosts();
      }
    });
  }

  Future<void> _fetchPosts() async {
    setState(() {
      _isLoading = true;
    });

    List<Post> posts =
        await Provider.of<DatabaseService>(context, listen: false).fetchPosts();
    final user = Provider.of<AuthService>(context, listen: false);
    for (int i = 0; i < posts.length; i++) {
      print(posts[i].imageUrl);
    }
    setState(() {
      uid = user.user!.uid;
      _posts = posts;
      _isLoading = false;
    });
  }

  Future<void> _fetchMorePosts() async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
    });

    List<Post> morePosts =
        await Provider.of<DatabaseService>(context, listen: false).fetchPosts(
      startAfter:
          Provider.of<DatabaseService>(context, listen: false).lastDocument,
    );
    setState(() {
      _posts.addAll(morePosts);
      _isLoading = false;
    });
  }

  Future<void> _pickMedia() async {
    final ImagePicker picker = ImagePicker();
    final file = await picker.pickMedia();
    if (file != null) {
      Navigator.of(context)
          .pushNamed(PostUploadPage.routeName, arguments: file);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: indigo,
        title: Text('Feeds', style: GoogleFonts.poppins(color: white)),
        actions: [
          IconButton(
              icon: const Icon(
                Icons.add,
                color: white,
              ),
              onPressed: () => _pickMedia()),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _fetchPosts(),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: _posts.length,
                itemBuilder: (context, index) {
                  Post post = _posts[index];
                  return SinglePostView(
                    post: post,
                    uid: uid,
                  );
                },
              ),
            ),
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: CircularProgressIndicator(),
              ),
          ],
        ),
      ),
    );
  }
}
