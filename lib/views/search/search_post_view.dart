import 'package:connect/models/post_model.dart';
import 'package:connect/models/user_model.dart';
import 'package:connect/services/auth_service.dart';
import 'package:connect/views/feeds/single_post_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SearchPostView extends StatefulWidget {
  const SearchPostView({super.key, required this.post});
  final Post post;

  @override
  State<SearchPostView> createState() => _SearchPostViewState();
}

class _SearchPostViewState extends State<SearchPostView> {
  String? user;
  @override
  void initState() {
    _fetchUser();
    super.initState();
  }

  Future<void> _fetchUser() async {
    final auth = Provider.of<AuthService>(context);
    setState(() {
      user = auth.user!.uid;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SinglePostView(
        post: widget.post,
        uid: user ?? "",
      ),
    );
  }
}
