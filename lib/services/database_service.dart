import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:connect/models/like_model.dart';
import 'package:connect/models/post_model.dart';
import 'package:connect/models/user_model.dart';

class DatabaseService with ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  DocumentSnapshot? _lastDocument;
  bool _hasMorePosts = true;
  static const int _postsLimit = 10;

  bool get hasMorePosts => _hasMorePosts;

  Future<List<Post>> fetchPosts({DocumentSnapshot? startAfter}) async {
    List<Post> posts = [];
    Query query = _db
        .collection('posts')
        .orderBy('timestamp', descending: true)
        .limit(_postsLimit);

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    QuerySnapshot querySnapshot = await query.get();
    print(querySnapshot.docs.length);
    if (querySnapshot.docs.length < _postsLimit) {
      _hasMorePosts = false;
      print("False");
    }

    if (querySnapshot.docs.isNotEmpty) {
      _lastDocument = querySnapshot.docs.last;

      print(querySnapshot.docs.last.data());
    }
    if (querySnapshot.docs.isNotEmpty) {
      for (int i = 0; i < querySnapshot.docs.length; i++) {
        print("Hello");
        posts.add(Post.fromFirestore(querySnapshot.docs[i]));
      }

      return posts;
    }
    return [];
  }

  DocumentSnapshot? get lastDocument => _lastDocument;

  Future<User?> getUserProfile(String uid) async {
    DocumentSnapshot doc = await _db.collection('users').doc(uid).get();
    if (doc.exists) {
      return User.fromFirestore(doc);
    }
    return null;
  }

  Future<void> updateUserProfile(User userProfile) async {
    await _db
        .collection('users')
        .doc(userProfile.id)
        .set(userProfile.toMap(), SetOptions(merge: true));
  }

  Future<void> createPost(Post post) async {
    await _db.collection('posts').add(post.toMap());
  }

  Future<bool> likePost(String postId, String userId) async {
    DocumentReference postRef = _db.collection('posts').doc(postId);
    DocumentSnapshot postSnapshot = await postRef.get();
    Post post = Post.fromFirestore(postSnapshot);
    List<Like> likes = post.likeList;
    int likescount = post.likes;
    print("Likes");
    print(likes);

    if (likes.any((element) => element.userId == userId)) {
      likes.removeWhere((element) => element.userId == userId);
      likescount -= 1;

      await postRef.update({'likeList': likes.map((e) => e.toMap())});
      await postRef.update({"likes": likescount});
      return false;
    } else {
      likes.add(Like(userId: userId, timestamp: DateTime.now()));
      likescount += 1;

      await postRef.update({'likeList': likes.map((e) => e.toMap())});
      await postRef.update({"likes": likescount});
      return true;
    }
  }

  Future<void> followUser(String currentUserId, String followUserId) async {
    try {
      await _db.collection('users').doc(followUserId).update({
        'followers': FieldValue.arrayUnion([currentUserId])
      }).then((value) async {
        print("added 2");
      });
      await _db.collection('users').doc(currentUserId).update({
        'following': FieldValue.arrayUnion([followUserId])
      }).then((value) async {
        print("added 1");
      });
    } catch (error) {
      print(error.toString());
    }
  }

  Future<void> unfollowUser(String currentUserId, String unfollowUserId) async {
    await _db.collection('users').doc(currentUserId).update({
      'following': FieldValue.arrayRemove([unfollowUserId])
    });
    await _db.collection('users').doc(unfollowUserId).update({
      'followers': FieldValue.arrayRemove([currentUserId])
    });
  }

  Future<Post> getPost(String postId) async {
    try {
      DocumentSnapshot postSnapshot =
          await _db.collection('posts').doc(postId).get();
      return Post.fromMap(
          postSnapshot.data() as Map<String, dynamic>, postSnapshot.id);
    } catch (e) {
      throw Exception('Error getting post: $e');
    }
  }

  Future<void> signup(String email, String password, String username,
      String bio, File? image) async {
    try {
      // Create user in Firebase Authentication
      auth.UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      auth.User? user = userCredential.user;

      if (user != null) {
        // Upload profile image to Firebase Storage
        String? imageUrl;
        if (image != null) {
          UploadTask uploadTask =
              _storage.ref('profile_images/${user.uid}').putFile(image);
          TaskSnapshot snapshot = await uploadTask;
          imageUrl = await snapshot.ref.getDownloadURL();
        }

        // Create user document in Firestore
        User userProfile = User(
          id: user.uid,
          email: user.email!,
          username: username,
          bio: bio,
          profilePic: imageUrl ?? "",
          followers: [],
          following: [],
        );

        await _db.collection('users').doc(user.uid).set(userProfile.toMap());
        await _db.collection("userNames").add({"username": username});
        notifyListeners();
      }
    } catch (e) {
      throw Exception('Error signing up: $e');
    }
  }

  Future<void> updateUserProfileField(
      String userId, Map<String, dynamic> updateData) async {
    await _db.collection('users').doc(userId).update(updateData);
  }

  Future<String> uploadProfileImage(String userId, File imageFile) async {
    try {
      UploadTask uploadTask =
          _storage.ref('profile_images/$userId').putFile(imageFile);
      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Error uploading profile image: $e');
    }
  }
}
