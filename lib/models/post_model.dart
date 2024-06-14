import 'package:cloud_firestore/cloud_firestore.dart';
import 'unlike_model.dart';
import 'like_model.dart'; // Assuming you have a Like model as well

class Post {
  final String id;
  final String userId;
  final String username;
  final String userProfilePic;
  final String content;
  final String? imageUrl;
  final int likes;
  final int unlikes; // Add unlikes count
  final List<Like> likeList; // List of likes
  final List<Unlike> unlikeList; // List of unlikes
  final DateTime timestamp;

  Post({
    required this.id,
    required this.userId,
    required this.username,
    required this.userProfilePic,
    required this.content,
    this.imageUrl,
    required this.likes,
    required this.unlikes, // Initialize unlikes count
    required this.likeList, // Initialize list of likes
    required this.unlikeList, // Initialize list of unlikes
    required this.timestamp,
  });

  factory Post.fromMap(Map<String, dynamic> data, String documentId) {
    return Post(
      id: documentId,
      userId: data['userId'],
      username: data['username'],
      userProfilePic: data['userProfilePic'],
      content: data['content'],
      imageUrl: data['imageUrl'],
      likes: data['likes'],
      unlikes: data['unlikes'], // Retrieve unlikes count
      likeList: (data['likeList'] as List<dynamic>)
          .map((like) => Like.fromMap(like))
          .toList(),
      unlikeList: (data['unlikeList'] as List<dynamic>)
          .map((unlike) => Unlike.fromMap(unlike))
          .toList(),
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'username': username,
      'userProfilePic': userProfilePic,
      'content': content,
      'imageUrl': imageUrl,
      'likes': likes,
      'unlikes': unlikes, // Store unlikes count
      'likeList': likeList.map((like) => like.toMap()).toList(),
      'unlikeList': unlikeList.map((unlike) => unlike.toMap()).toList(),
      'timestamp': timestamp,
    };
  }

  static Post fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Post.fromMap(data, doc.id);
  }

  Future<void> toFirestore() async {
    try {
      await FirebaseFirestore.instance.collection('posts').doc(id).set(toMap());
    } catch (e) {
      throw Exception('Error updating post: $e');
    }
  }
}
