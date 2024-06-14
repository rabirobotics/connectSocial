import 'package:connect/models/post_model.dart';
import 'package:connect/services/database_service.dart';
import 'package:connect/views/profile/profile_page_view.dart';
import 'package:connect/views/widgets/media_diaplay_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:like_button/like_button.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:provider/provider.dart';

class SinglePostView extends StatelessWidget {
  const SinglePostView({
    super.key,
    required this.post,
    required this.uid,
  });
  final String uid;
  final Post post;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(10.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                  child:
                      MediaDisplayWidget(isFile: false, url: post.imageUrl!)),
              Row(
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(post.userProfilePic),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => ProfilePage(
                              userId: post.userId,
                            ))),
                    child: Text(
                      post.username,
                      style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ).paddingTop(5),
              const SizedBox(height: 10),
              Text(post.content, style: GoogleFonts.poppins()),
              Row(
                children: [
                  LikeButton(
                    onTap: (_) async {
                      return await Provider.of<DatabaseService>(context,
                              listen: false)
                          .likePost(post.id, uid);
                    },
                    isLiked:
                        post.likeList.any((element) => element.userId == uid),
                    bubblesColor: const BubblesColor(
                        dotPrimaryColor: Colors.red,
                        dotSecondaryColor: Colors.redAccent),
                    likeCount: post.likes,
                  ),
                ],
              ).paddingOnly(top: 3),
            ],
          ),
        ),
      ),
    );
  }
}
