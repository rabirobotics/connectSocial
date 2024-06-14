import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connect/utils/constant.dart';
import 'package:connect/views/widgets/overlay_loader.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

import 'package:connect/models/user_model.dart';
import 'package:connect/services/auth_service.dart';
import 'package:connect/services/database_service.dart';
import 'package:connect/views/widgets/snackBar.dart';

class ProfileEditPage extends StatefulWidget {
  const ProfileEditPage({super.key});
  static const routeName = "/editProfile";

  @override
  State<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  late User userProfile;
  final ImagePicker _picker = ImagePicker();
  File? _imageFile;
  bool _isLoading = false;
  final bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
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

      userProfile = (await databaseService.getUserProfile(userId))!;
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

  Future<void> _updateProfileField(String field, String newValue) async {
    final databaseService =
        Provider.of<DatabaseService>(context, listen: false);

    try {
      LoadingOverlay.show(context);

      Map<String, dynamic> updateData = {field: newValue};
      await databaseService.updateUserProfileField(userProfile.id, updateData);

      // Update local userProfile object
      if (field == 'username') {
        userProfile = userProfile.copyWith(username: newValue);
      } else if (field == 'bio') {
        userProfile = userProfile.copyWith(bio: newValue);
      }

      LoadingOverlay.hide(context);

      snack(context, 'Profile updated successfully', Colors.green);
    } catch (e) {
      LoadingOverlay.hide(context);

      snack(context, 'Error updating profile: $e', Colors.red);
    }
  }

  Future<void> _updateProfileImage() async {
    final databaseService =
        Provider.of<DatabaseService>(context, listen: false);
    final authService = Provider.of<AuthService>(context, listen: false);
    final userId = authService.user!.uid;

    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        LoadingOverlay.show(context);

        setState(() {
          _imageFile = File(pickedFile.path);
        });

        String imageUrl =
            await databaseService.uploadProfileImage(userId, _imageFile!);
        await databaseService
            .updateUserProfileField(userId, {'profilePic': imageUrl});

        setState(() {
          userProfile = userProfile.copyWith(profilePic: imageUrl);
        });
        LoadingOverlay.hide(context);

        snack(context, 'Profile image updated successfully', Colors.green);
      }
    } catch (e) {
      LoadingOverlay.hide(context);

      snack(context, 'Error updating profile image: $e', Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: indigo,
        title: const Text(
          'Edit Profile',
          style: TextStyle(color: white),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Center(
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: userProfile.profilePic.isNotEmpty
                          ? NetworkImage(userProfile.profilePic)
                          : null,
                      child: userProfile.profilePic.isEmpty
                          ? const Icon(Icons.person, size: 50)
                          : null,
                    ),
                  ),
                  Center(
                    child: TextButton(
                      onPressed: _updateProfileImage,
                      child: const Text(
                        "Change Profile Image",
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildProfileField(
                      'Username', userProfile.username, 'username'),
                  _buildProfileField('Email', userProfile.email, null),
                  _buildProfileField('Bio', userProfile.bio, 'bio'),
                ],
              ),
            ),
    );
  }

  Widget _buildProfileField(String label, String value, String? field) {
    TextEditingController controller = TextEditingController(text: value);

    return ListTile(
      title: Text(label),
      subtitle: TextFormField(
        controller: controller,
        readOnly: true,
        maxLines: label == "Bio" ? 3 : 1,
        maxLength: label == "Bio"
            ? 100
            : label == "Email"
                ? 30
                : 18,
      ),
      trailing: field != null
          ? IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () async {
                String? updatedValue = await showDialog<String>(
                  context: context,
                  builder: (context) => _buildUpdateDialog(label, controller),
                );

                if (updatedValue != null && updatedValue.isNotEmpty) {
                  _updateProfileField(field, updatedValue);
                }
              },
            )
          : null,
    );
  }

  Widget _buildUpdateDialog(String label, TextEditingController controller) {
    return AlertDialog(
      title: Text('Update $label'),
      content: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: 'Enter new $label',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, controller.text),
          child: const Text('Update'),
        ),
      ],
    );
  }
}
