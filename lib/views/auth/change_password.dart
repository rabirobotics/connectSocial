import 'package:flutter/material.dart';
import 'package:connect/services/auth_service.dart';
import 'package:connect/views/widgets/snackBar.dart';
import 'package:provider/provider.dart';

class ChangePasswordScreen extends StatelessWidget {
  const ChangePasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Change Password'),
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: ChangePasswordForm(),
      ),
    );
  }
}

class ChangePasswordForm extends StatefulWidget {
  const ChangePasswordForm({super.key});

  @override
  _ChangePasswordFormState createState() => _ChangePasswordFormState();
}

class _ChangePasswordFormState extends State<ChangePasswordForm> {
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isVisible = false;
  void toggleVisibility() {
    setState(() {
      _isVisible = !_isVisible;
    });
  }

  void updatePassword(BuildContext context) async {
    final valid = _formKey.currentState!.validate();
    if (valid) {
      String oldPassword = _oldPasswordController.text;
      String newPassword = _newPasswordController.text;

      final authService = Provider.of<AuthService>(context, listen: false);
      try {
        // await authService.updatePassword(oldPassword, newPassword);
        // snack(context, 'Password updated successfully', Colors.green);
        Navigator.pop(context); // Pop the change password screen
      } catch (e) {
        snack(context, e.toString(), Colors.red);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: _oldPasswordController,
            obscureText: !_isVisible,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your old password';
              }
              // Add more validations as needed
              return null;
            },
            decoration: InputDecoration(
              labelText: 'Old Password',
              suffixIcon: IconButton(
                onPressed: () => toggleVisibility(),
                icon: Icon(
                  _isVisible ? Icons.visibility : Icons.visibility_off,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _newPasswordController,
            obscureText: !_isVisible,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a new password';
              } else if (value.length < 8) {
                return 'Password must be at least 8 characters long';
              }
              // Add more validations as needed
              return null;
            },
            decoration: InputDecoration(
              labelText: 'New Password',
              suffixIcon: IconButton(
                onPressed: () => toggleVisibility(),
                icon: Icon(
                  _isVisible ? Icons.visibility : Icons.visibility_off,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _confirmPasswordController,
            obscureText: !_isVisible,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please confirm your new password';
              } else if (value != _newPasswordController.text) {
                return 'Passwords do not match';
              }
              // Add more validations as needed
              return null;
            },
            decoration: InputDecoration(
              labelText: 'Confirm Password',
              suffixIcon: IconButton(
                onPressed: () => toggleVisibility(),
                icon: Icon(
                  _isVisible ? Icons.visibility : Icons.visibility_off,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => updatePassword(context),
            child: const Text('Update Password'),
          ),
        ],
      ),
    );
  }
}
