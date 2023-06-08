import 'dart:io';
import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:chat_app/widgets/auth/user_image_picker.dart';

final _firebaseStorage = FirebaseStorage.instance;
final _firebaseAuth = FirebaseAuth.instance;
final _firebaseFs = FirebaseFirestore.instance;

class AuthForm extends StatefulWidget {
  const AuthForm({super.key});

  @override
  State<AuthForm> createState() {
    return _AuthFormState();
  }
}

class _AuthFormState extends State<AuthForm> {
  File? _selectedImage;
  final _form = GlobalKey<FormState>();

  var _isLogin = true;
  var _enteredEmail = '';
  var _enteredUsername = '';
  var _enteredPassword = '';
  var _isAuthenticating = false;
  var _selectedRole = 'student';

  void _submit() async {
    final isValid = _form.currentState!.validate();

    if (!isValid || (!_isLogin && _selectedImage == null)) {
      return;
    }

    _form.currentState!.save();

    try {
      setState(() {
        _isAuthenticating = true;
      });

      if (_isLogin) {
        await _firebaseAuth.signInWithEmailAndPassword(
            email: _enteredEmail, password: _enteredPassword);

        return;
      }

      // create user
      final userCredentials =
          await _firebaseAuth.createUserWithEmailAndPassword(
              email: _enteredEmail, password: _enteredPassword);

      // storage user's profile image
      final storageRef = _firebaseStorage
          .ref()
          .child('user_images')
          .child('${userCredentials.user!.uid}.jpg');

      await storageRef.putFile(_selectedImage!);

      // storage user's profile
      final imageUrl = await storageRef.getDownloadURL();
      final userData = {
        'username': _enteredUsername,
        'email': _enteredEmail,
        'image_url': imageUrl,
        'role': _selectedRole,
        'uid': userCredentials.user!.uid,
      };

      await _firebaseFs
          .collection('users')
          .doc(userCredentials.user!.uid)
          .set(userData);
    } on FirebaseAuthException catch (error) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.message ?? 'Authentication failed.'),
        ),
      );

      setState(() {
        _isAuthenticating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _form,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!_isLogin)
                  UserImagePicker(
                    onPickImage: (pickedImage) {
                      _selectedImage = pickedImage;
                    },
                  ),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Email Address',
                  ),
                  keyboardType: TextInputType.emailAddress,
                  textCapitalization: TextCapitalization.none,
                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty ||
                        !value.contains('@')) {
                      return 'Please enter a valid email address.';
                    }

                    return null;
                  },
                  onSaved: (value) {
                    _enteredEmail = value!;
                  },
                ),
                if (!_isLogin)
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Username',
                    ),
                    enableSuggestions: false,
                    validator: (value) {
                      if (value == null ||
                          value.isEmpty ||
                          value.trim().length < 4) {
                        return 'Please enter at least 4 characters.';
                      }

                      return null;
                    },
                    onSaved: (value) {
                      _enteredUsername = value!;
                    },
                  ),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Password',
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.trim().length < 6) {
                      return 'Password must be at least 6 characters longs.';
                    }

                    return null;
                  },
                  onSaved: (value) {
                    _enteredPassword = value!;
                  },
                ),
                if (!_isLogin)
                  DropdownButtonFormField(
                    value: _selectedRole,
                    items: const [
                      DropdownMenuItem(
                        value: 'teacher',
                        child: Text('Teacher'),
                      ),
                      DropdownMenuItem(
                        value: 'student',
                        child: Text('Student'),
                      ),
                    ],
                    onChanged: (value) {
                      _selectedRole = value!;
                    },
                  ),
                const SizedBox(
                  height: 12,
                ),
                if (_isAuthenticating) const CircularProgressIndicator(),
                if (!_isAuthenticating)
                  ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Theme.of(context).colorScheme.primaryContainer,
                    ),
                    child: Text(
                      _isLogin ? 'Login' : 'Signup',
                    ),
                  ),
                if (!_isAuthenticating)
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _isLogin = !_isLogin;
                      });
                    },
                    child: Text(
                      _isLogin
                          ? 'Create an account'
                          : 'I already have an account',
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
