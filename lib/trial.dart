// lib/services/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Existing methods remain the same...

  // Add new method for Google Sign In
  Future<User?> signInWithGoogle(String userType) async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential result = await _auth.signInWithCredential(credential);
      User? user = result.user;

      if (user != null) {
        // Check if user exists in Firestore
        DocumentSnapshot doc = await _firestore.collection('users').doc(user.uid).get();

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
}

// lib/screens/auth/register_screen.dart
// Add the following imports at the top of the file
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// Inside RegisterScreenState class, add this method:
Widget _buildGoogleSignInButton() {
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    child: ElevatedButton.icon(
      icon: const FaIcon(FontAwesomeIcons.google, size: 18),
      label: const Text('Continue with Google'),
      onPressed: _isLoading ? null : _handleGoogleSignIn,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 2,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey.shade300),
        ),
      ),
    ),
  );
}

// Add this method to handle Google Sign In
Future<void> _handleGoogleSignIn() async {
  setState(() {
    _isLoading = true;
    error = '';
  });

  try {
    final user = await _auth.signInWithGoogle(userType);
    if (user != null) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              FadeTransition(
                opacity: animation,
                child: const HomeScreen(),
              ),
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    }
  } catch (e) {
    setState(() {
      error = 'Failed to sign in with Google. Please try again.';
    });
  } finally {
    setState(() {
      _isLoading = false;
    });
  }
}

// Add this method to build the login link
Widget _buildLoginLink() {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 16),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Already have an account? ',
          style: TextStyle(color: Colors.grey[600]),
        ),
        GestureDetector(
          onTap: () {
            Navigator.pushReplacementNamed(context, '/login');
          },
          child: Text(
            'Login',
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    ),
  );
}

// Modify the build method to include the new widgets
@override
Widget build(BuildContext context) {
  return Scaffold(
    body: Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary.withOpacity(0.1),
            Theme.of(context).colorScheme.secondary.withOpacity(0.1),
          ],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Existing FadeInDown with SVG...

            _buildGoogleSignInButton(), // Add Google Sign In button

            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Expanded(child: Divider()),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text('OR', style: TextStyle(color: Colors.grey)),
                  ),
                  Expanded(child: Divider()),
                ],
              ),
            ),

            Expanded(
              child: FadeInUp(
                // Existing form content...
              ),
            ),

            _buildLoginLink(), // Add login link

            if (error.isNotEmpty)
              FadeIn(
                duration: const Duration(milliseconds: 300),
                child: _buildErrorMessage(),
              ),
          ],
        ),
      ),
    ),
  );
}