import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

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

  // Sign In with Google
  Future<User?> signInWithGoogle(String userType) async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential result = await _auth.signInWithCredential(credential);
      User? user = result.user;

      if (user != null) {
        // Check if user exists in Firestore
        DocumentSnapshot doc =
            await _firestore.collection('users').doc(user.uid).get();

        if (!doc.exists) {
          // Create basic user data from Google account
          Map<String, dynamic> userData = {
            'email': user.email ?? '',
            'fullName': user.displayName ?? '',
            'phoneNumber': user.phoneNumber ?? '',
            'idNumber': '',
            'userType': userType,
            'registrationDate': DateTime.now().toIso8601String(),
            'isVerified': user.emailVerified,
            // Add empty fields based on user type
            ...getEmptyFieldsForUserType(userType),
          };

          await _firestore.collection('users').doc(user.uid).set(userData);
        }
        return user;
      }
      return null;
    } catch (e) {
      print('Error during Google sign in: ${e.toString()}');
      rethrow;
    }
  }

  Map<String, dynamic> getEmptyFieldsForUserType(String userType) {
    switch (userType) {
      case 'Landlord':
        return {
          'kraPin': '',
          'physicalAddress': '',
          'isNonResident': false,
        };
      case 'Tenant':
        return {
          'currentAddress': '',
          'emergencyContact': {
            'name': '',
            'phone': '',
          },
        };
      case 'Agent':
        return {
          'companyName': '',
          'licenseNumber': '',
          'businessAddress': '',
        };
      case 'Admin':
        return {
          'department': '',
          'employeeId': '',
        };
      default:
        return {};
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
  Future<void> updateUserProfile(Map<String, dynamic> userData,
      Map<String, dynamic> additionalData) async {
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
