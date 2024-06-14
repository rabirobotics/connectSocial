import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String id;
  final String username;
  final String email;
  final String profilePic;
  final String bio;
  final List<String> followers;
  final List<String> following;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.profilePic,
    required this.bio,
    required this.followers,
    required this.following,
  });

  factory User.fromMap(Map<String, dynamic> data, String documentId) {
    return User(
      id: documentId,
      username: data['username'],
      email: data['email'],
      profilePic: data['profilePic'],
      bio: data['bio'],
      followers: List<String>.from(data['followers']),
      following: List<String>.from(data['following']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'email': email,
      'profilePic': profilePic,
      'bio': bio,
      'followers': followers,
      'following': following,
    };
  }

  static Future<User> fromFirestore(DocumentSnapshot doc) async {
    final data = doc.data() as Map<String, dynamic>;
    return User(
      id: doc.id,
      username: data['username'],
      email: data['email'],
      profilePic: data['profilePic'],
      bio: data['bio'],
      followers: List<String>.from(data['followers']),
      following: List<String>.from(data['following']),
    );
  }

  Future<void> toFirestore() async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(id).set(toMap());
    } catch (e) {
      throw Exception('Error updating user: $e');
    }
  }

  // Define the copyWith method for immutable updates
  User copyWith({
    String? id,
    String? username,
    String? email,
    String? profilePic,
    String? bio,
    List<String>? followers,
    List<String>? following,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      profilePic: profilePic ?? this.profilePic,
      bio: bio ?? this.bio,
      followers: followers ?? this.followers,
      following: following ?? this.following,
    );
  }
}
