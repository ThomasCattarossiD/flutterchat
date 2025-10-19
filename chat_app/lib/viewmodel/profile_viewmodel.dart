import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class ProfileViewModel with ChangeNotifier {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<bool> updateProfile(String displayName, String bio) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = _auth.currentUser!;
      await _firestore.collection('users').doc(user.uid).update({
        'displayName': displayName,
        'bio': bio,
      });
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> pickAndUploadImage() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final imagePicker = ImagePicker();
      final pickedFile = await imagePicker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        final user = _auth.currentUser!;
        final file = File(pickedFile.path);
        final ref = _storage.ref().child('avatars').child('${user.uid}.jpg');
        await ref.putFile(file);
        final url = await ref.getDownloadURL();
        await _firestore.collection('users').doc(user.uid).update({
          'avatarUrl': url,
        });
      }
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
