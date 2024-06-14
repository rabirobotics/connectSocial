import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connect/models/post_model.dart';
import 'package:connect/services/auth_service.dart';
import 'package:connect/services/database_service.dart';
import 'package:connect/views/widgets/media_diaplay_widget.dart';
import 'package:connect/views/widgets/snackBar.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class PostUploadPage extends StatefulWidget {
  const PostUploadPage({super.key});
  static const routeName = "postUpload";

  @override
  State<PostUploadPage> createState() => _PostUploadPageState();
}

class _PostUploadPageState extends State<PostUploadPage> {
  @override
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  XFile? _imageFile;

  Future<void> _uploadPost(BuildContext context) async {
    if (_imageFile == null || _descriptionController.text.isEmpty) {
      // Handle case where any of the fields are empty
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: const Text('Please fill all fields and select a media.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }
    final FirebaseFirestore db = FirebaseFirestore.instance;
    final auth = Provider.of<AuthService>(context, listen: false);
    final dataservice = Provider.of<DatabaseService>(context, listen: false);
    final user = await dataservice.getUserProfile(auth.user!.uid);
    // Show loading indicator while uploading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // Upload image to Firebase Storage
      String mediaName = _imageFile!.name;
      Reference ref =
          FirebaseStorage.instance.ref().child('posts').child(mediaName);
      UploadTask uploadTask = ref.putFile(File(_imageFile!.path));
      TaskSnapshot snapshot = await uploadTask;
      String imageUrl = await snapshot.ref.getDownloadURL();

      // Perform other actions with imageUrl like saving to Firestore, etc.
      // For now, we'll just print the imageUrl
      print('Uploaded image url: $imageUrl');
      final post = Post(
          id: DateTime.now().toIso8601String(),
          userId: auth.user!.uid,
          username: user!.username,
          userProfilePic: user.profilePic,
          content: _descriptionController.text,
          imageUrl: imageUrl,
          likes: 0,
          unlikes: 0,
          likeList: [],
          unlikeList: [],
          timestamp: Timestamp.now().toDate());
      await db.collection("posts").add(post.toMap()).then((val) {
        Navigator.of(context)
          ..pop()
          ..pop();
        snack(context, "Post Uploaded Successfully.", Colors.green);
      });
    } catch (error) {
      // Handle error
      Navigator.of(context).pop();
      print('Error uploading post: $error');
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: const Text('Failed to upload post. Please try again later.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  bool _isInit = false;
  bool _isLoading = false;

  @override
  void didChangeDependencies() async {
    if (!_isInit) {
      setState(() {
        _isLoading = true;
      });
      final filedata = ModalRoute.of(context)!.settings.arguments as XFile;
      setState(() {
        _imageFile = filedata;
        _isLoading = false;
        _isInit = true;
      });
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Post'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                ),
                child: MediaDisplayWidget(isFile: true, url: _imageFile!.path),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Caption'),
                maxLines: 5,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _uploadPost(context),
                child: const Text('Upload Post'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
