import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Sign up new user
  Future<User?> signUp(
      String email, String password, Map<String, dynamic> userData) async {
    try {
      // Create auth user
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user;

      if (user != null) {
        // Create user document in Firestore
        await _firestore.collection('users').doc(user.uid).set(userData);

        // If user is a landlord, create properties collection
        if (userData['userType'] == 'Landlord' &&
            userData['properties'] != null) {
          await _firestore
              .collection('users')
              .doc(user.uid)
              .collection('properties')
              .add(userData['properties'][0]);
        }

        return user;
      }
      return null;
    } catch (e) {
      print('Error during sign up: ${e.toString()}');
      rethrow;
    }
  }

  // Sign in existing user
  Future<User?> signIn(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } catch (e) {
      print('Error during sign in: ${e.toString()}');
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print('Error during sign out: ${e.toString()}');
      rethrow;
    }
  }

  // Get current user
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Get user type
  Future<String?> getUserType() async {
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser != null) {
        DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(currentUser.uid).get();
        return userDoc.get('userType') as String?;
      }
      return null;
    } catch (e) {
      print('Error getting user type: ${e.toString()}');
      rethrow;
    }
  }

  // Verify KRA PIN
  Future<bool> verifyKraPinNumber(String kraPinNumber) async {
    try {
      // This is a placeholder for KRA PIN verification
      // In a production environment, this should make an API call to KRA's systems

      // Basic validation rules for KRA PIN:
      // 1. Must be 11 characters long
      // 2. Should start with 'A' or 'P'
      // 3. Should contain only alphanumeric characters

      if (kraPinNumber.length != 11) return false;

      if (!kraPinNumber.startsWith('A') && !kraPinNumber.startsWith('P')) {
        return false;
      }

      // Check if the rest of the characters are alphanumeric
      String restOfPin = kraPinNumber.substring(1);
      RegExp alphanumeric = RegExp(r'^[a-zA-Z0-9]+$');
      return alphanumeric.hasMatch(restOfPin);
    } catch (e) {
      print('Error verifying KRA PIN: ${e.toString()}');
      return false;
    }
  }

  // Get user profile data
  Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser != null) {
        DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(currentUser.uid).get();
        return userDoc.data() as Map<String, dynamic>?;
      }
      return null;
    } catch (e) {
      print('Error getting user profile: ${e.toString()}');
      rethrow;
    }
  }

  // Update user profile
  Future<void> updateUserProfile(Map<String, dynamic> userData) async {
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser != null) {
        await _firestore
            .collection('users')
            .doc(currentUser.uid)
            .update(userData);
      }
    } catch (e) {
      print('Error updating user profile: ${e.toString()}');
      rethrow;
    }
  }

  verifyAdminCode(String text) {}
}
