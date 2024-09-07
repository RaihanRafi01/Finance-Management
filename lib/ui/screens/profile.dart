import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<DocumentSnapshot> _userData;
  File? _pickedImageFile;
  final picker = ImagePicker();

  // Editing Controllers
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();

  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser!;
    final userDoc = FirebaseFirestore.instance.collection('users').doc(user.uid);
    _userData = userDoc.get().then((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>;
        _usernameController.text = data['username'] ?? '';
        _emailController.text = data['email'] ?? '';
      }
      return snapshot;
    });
  }

  Future<void> _pickImage() async {
    final pickedImage = await picker.pickImage(
      source: ImageSource.gallery, // or ImageSource.gallery
      imageQuality: 50,
      maxWidth: 150,
    );
    if (pickedImage != null) {
      setState(() {
        _pickedImageFile = File(pickedImage.path);
      });
      await _uploadProfilePic(_pickedImageFile!);
    }
  }

  Future<void> _uploadProfilePic(File imageFile) async {
    final user = FirebaseAuth.instance.currentUser!;
    final storageRef = FirebaseStorage.instance
        .ref()
        .child('user_profile_pics')
        .child('${user.uid}.jpg');

    await storageRef.putFile(imageFile);

    final downloadUrl = await storageRef.getDownloadURL();
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .update({'picture': downloadUrl});

    setState(() {
      _userData = FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    });
  }

  Future<void> _saveChanges() async {
    final user = FirebaseAuth.instance.currentUser!;
    await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
      'username': _usernameController.text,
      'email': _emailController.text,
    });

    setState(() {
      _isEditing = false;
      _userData = FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    });
  }

  void _cancelChanges() {
    setState(() {
      _isEditing = false;
      // Optionally reset the text fields to original values
    });
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildInfoBox(String label, String content) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      decoration: BoxDecoration(
        color: Colors.white24,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text('$label: $content',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: _userData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('No user data found. Please try again later'));
          }

          final userData = snapshot.data!.data() as Map<String, dynamic>;
          final profilePicUrl = userData['picture'] as String?;
          final hasProfilePic = profilePicUrl != null && profilePicUrl.isNotEmpty;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Profile Picture
                InkWell(
                  onTap: _pickImage,
                  borderRadius: BorderRadius.circular(50),
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: _pickedImageFile != null
                        ? FileImage(_pickedImageFile!)
                        : (hasProfilePic
                        ? NetworkImage(profilePicUrl)
                        : const AssetImage('assets/images/add_image.png')) as ImageProvider,
                    backgroundColor: Colors.grey[200],
                  ),
                ),
                const SizedBox(height: 16),

                // Card with Gradient and User Info
                Expanded(
                  child: GestureDetector(
                    onLongPress: () {
                      setState(() {
                        _isEditing = true;
                      });
                    },
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 5,
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(16.0),
                        decoration: BoxDecoration(color: Colors.white60,
                          borderRadius: BorderRadius.circular(20),
                      gradient: const LinearGradient(
                      colors: [Colors.tealAccent, Colors.deepOrangeAccent],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomRight,
                      ),
                    ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Username in a Box
                            _isEditing
                                ? _buildTextField('Username', _usernameController)
                                : _buildInfoBox('Name', userData['username'] ?? 'No Username'),
                            const SizedBox(height: 16),

                            // Email in a Box
                            _isEditing
                                ? _buildTextField('Email', _emailController)
                                : _buildInfoBox('Mail', userData['email'] ?? 'No Email'),
                            const SizedBox(height: 16),

                            // Balance in a Box
                            _buildInfoBox('Balance', '\$${userData['balance'] ?? 0}'),
                            const SizedBox(height: 16),

                            // Save Changes Button and Cancel Button
                            if (_isEditing)
                              Column(
                                children: [
                                  ElevatedButton(
                                    onPressed: _saveChanges,
                                    child: const Text('Save Changes'),
                                  ),
                                  const SizedBox(height: 8),
                                  ElevatedButton(
                                    onPressed: _cancelChanges,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.deepOrangeAccent, // Change color to red for cancel button
                                    ),
                                    child: Text('Cancel'),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
