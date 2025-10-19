import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chat_app/viewmodel/profile_viewmodel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _displayNameController = TextEditingController();
  final _bioController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = _auth.currentUser;
    if (user != null) {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        _displayNameController.text = data['displayName'] ?? '';
        _bioController.text = data['bio'] ?? '';
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: Consumer<ProfileViewModel>(
        builder: (context, profileViewModel, child) {
          if (profileViewModel.isLoading) {
            return Center(child: CircularProgressIndicator());
          }
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                StreamBuilder<DocumentSnapshot>(
                  stream: _firestore.collection('users').doc(_auth.currentUser!.uid).snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return CircleAvatar(radius: 50, child: Icon(Icons.person));
                    }
                    final data = snapshot.data!.data() as Map<String, dynamic>;
                    final avatarUrl = data['avatarUrl'] as String?;
                    return CircleAvatar(
                      radius: 50,
                      backgroundImage: (avatarUrl != null && avatarUrl.isNotEmpty)
                          ? NetworkImage(avatarUrl)
                          : null,
                      child: (avatarUrl == null || avatarUrl.isEmpty)
                          ? Icon(Icons.person, size: 50)
                          : null,
                    );
                  },
                ),
                SizedBox(height: 20),
                TextField(
                  controller: _displayNameController,
                  decoration: InputDecoration(labelText: 'Display Name'),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: _bioController,
                  decoration: InputDecoration(labelText: 'Bio'),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    final success = await profileViewModel.updateProfile(
                      _displayNameController.text,
                      _bioController.text,
                    );
                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Profile updated successfully')),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(profileViewModel.errorMessage ?? 'Update failed')),
                      );
                    }
                  },
                  child: Text('Save Profile'),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    final success = await profileViewModel.pickAndUploadImage();
                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Avatar updated successfully')),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(profileViewModel.errorMessage ?? 'Upload failed')),
                      );
                    }
                  },
                  child: Text('Change Avatar'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
