import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';           
import 'package:image_picker/image_picker.dart';

enum AuthStatus { authenticated, unauthenticated, unknown }

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  AuthStatus _status = AuthStatus.unknown;
  String? _error;
  bool _isLoading = false;
  String? _profileImageBase64;

  // Getters
  AuthStatus get status => _status;
  String? get error => _error;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  String? get profileImageBase64 => _profileImageBase64;

  // Get current user details directly from Firebase
  String? get userEmail => _auth.currentUser?.email;
  String? get userName => _auth.currentUser?.displayName;

  // Check login status on app start
  Future<void> checkAuthStatus() async {
    final user = _auth.currentUser;
    if (user != null) {
      _status = AuthStatus.authenticated;
    } else {
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _error = message;
    notifyListeners();
  }

  // Register with Firebase Auth
  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      // Create user in Firebase Auth
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user;

      if (user == null) {
        _setError('Failed to create user account. Please try again.');
        return;
      }

      // Save display name to Firebase user profile
      await user.updateDisplayName(name);
      await user.reload();

      // save user details in firestore
      //collection = 'users' -> document = user.uid

      await _firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'name': name,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
      });

      _status = AuthStatus.authenticated;
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      _setError(_handleError(e));
    } catch (e) {
      _setError('Account created but failed to save profile. Try again.');
    } finally {
      _setLoading(false);
    }
  }

  // Login with Firebase Auth
  Future<void> login({required String email, required String password}) async {
    _setLoading(true);
    _setError(null);

    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);

      _status = AuthStatus.authenticated;
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      _setError(_handleError(e));
    } finally {
      _setLoading(false);
    }
  }

  // Logout
  Future<void> logout() async {
    await _auth.signOut();
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  Future<bool> uploadProfilePhoto() async {
  final user = _auth.currentUser;
  if (user == null) return false;

  try {
    // 1. Open gallery, pick image, compress + resize on the way in
    final picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
      maxWidth: 600,
    );

    // User cancelled the picker — not an error, just exit quietly
    if (pickedFile == null) return false;

    // 2. Read the picked file as raw bytes
    final bytes = await pickedFile.readAsBytes();

    // 3. Convert those bytes into a Base64 string
    final base64String = base64Encode(bytes);

    // 4. Save the string to this user's Firestore document
    await _firestore.collection('users').doc(user.uid).update({
      'profileImageBase64': base64String,
    });

    // 5. Update local state so UI reflects the new photo immediately
    _profileImageBase64 = base64String;
    notifyListeners();

    return true;
  } catch (e) {
    debugPrint('UPLOAD PHOTO ERROR: $e');
    return false;
  }
}

  // Convert Firebase error codes to readable messages
  String _handleError(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'invalid-credential':
        return 'Invalid email or password.';
      case 'too-many-requests':
        return 'Too many attempts. Try again later.';
      default:
        return 'Something went wrong. Try again.';
    }
  }
}
