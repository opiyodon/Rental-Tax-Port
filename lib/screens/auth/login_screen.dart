import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:animate_do/animate_do.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rental_tax_port/screens/admin/admin_dashboard.dart';
import 'package:rental_tax_port/screens/agent/agent_dashboard.dart';
import 'package:rental_tax_port/screens/landlord/landlord_dashboard.dart';
import 'package:rental_tax_port/screens/loading_screen.dart';
import 'package:rental_tax_port/screens/tenant/tenant_dashboard.dart';
import 'package:rental_tax_port/services/auth_service.dart';
import 'package:rental_tax_port/theme.dart';
import 'package:rental_tax_port/utils/input_validators.dart';
import 'package:rental_tax_port/widgets/custom_text_field.dart';
import 'package:rental_tax_port/widgets/error_message.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  final List<FocusNode> _focusNodes = [];

  // Common Fields
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String userType = 'Tenant';
  String error = '';
  bool _isLoading = false;

  // Track failed attempts for rate limiting
  int _failedAttempts = 0;
  DateTime? _lastAttemptTime;
  static const int _maxAttempts = 3;
  static const int _lockoutMinutes = 15;

  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late AnimationController _rotateController;

  // Animations
  late Animation<double> _scaleAnimation;

  final String onboardingSvg = '''
<svg viewBox="0 0 200 200" xmlns="http://www.w3.org/2000/svg">
  <!-- Define gradients using the same theme colors -->
  <defs>
    <linearGradient id="grad" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" style="stop-color:#4CAF50;stop-opacity:1" />
      <stop offset="100%" style="stop-color:#FF9800;stop-opacity:1" />
    </linearGradient>
    <linearGradient id="grad2" x1="0%" y1="0%" x2="100%" y2="0%">
      <stop offset="0%" style="stop-color:#4CAF50;stop-opacity:0.2" />
      <stop offset="100%" style="stop-color:#FF9800;stop-opacity:0.2" />
    </linearGradient>
  </defs>
  
  <!-- Background card -->
  <rect width="160" height="160" x="20" y="20" rx="16" fill="white" stroke="url(#grad)" stroke-width="2"/>
  
  <!-- Lock icon at the top moved up slightly -->
  <circle cx="100" cy="55" r="25" fill="url(#grad)" opacity="0.9"/>
  <rect x="88" y="50" width="24" height="20" rx="4" fill="white"/>
  <rect x="96" y="35" width="8" height="20" rx="4" fill="white"/>
  
  <!-- Form background moved up -->
  <rect x="35" y="90" width="130" height="60" rx="12" fill="url(#grad2)"/>
  
  <!-- Form lines moved up -->
  <rect x="45" y="105" width="110" height="8" rx="4" fill="url(#grad)" opacity="0.7"/>
  <rect x="45" y="125" width="110" height="8" rx="4" fill="url(#grad)" opacity="0.5"/>
  
  <!-- Login button moved up to create more bottom padding -->
  <rect x="60" y="145" width="80" height="24" rx="12" fill="url(#grad)"/>
  <rect x="75" y="153" width="50" height="8" rx="4" fill="white"/>
</svg>
''';

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeFocusNodes();
    _setupPasswordStrengthListener();
  }

  void _initializeAnimations() {
    // Fade animation
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Rotate animation
    _rotateController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    // Slide animation
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Scale animation
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    // Rotate animation
    _rotateController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Start animations
    _fadeController.forward();
    _slideController.forward();
    _scaleController.forward();
  }

  void _initializeFocusNodes() {
    for (int i = 0; i < 10; i++) {
      _focusNodes.add(FocusNode());
    }
  }

  void _setupPasswordStrengthListener() {
    _passwordController.addListener(() {
      // Implement password strength checking
      setState(() {});
    });
  }

// Enhanced _checkRateLimit method
  bool _checkRateLimit() {
    if (_failedAttempts >= _maxAttempts) {
      final now = DateTime.now();
      if (_lastAttemptTime != null) {
        final difference = now.difference(_lastAttemptTime!);
        if (difference.inMinutes < _lockoutMinutes) {
          setState(() {
            error =
                'Too many attempts. Please try again in ${_lockoutMinutes - difference.inMinutes} minutes.';
          });
          return false;
        } else {
          _failedAttempts = 0;
          _lastAttemptTime = null;
        }
      }
    }
    return true;
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    _rotateController.dispose();
    for (var node in _focusNodes) {
      node.dispose();
    }
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleSubmit() async {
    if (!_checkRateLimit()) return;

    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        // Show loading screen
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                FadeTransition(
              opacity: animation,
              child: const LoadingScreen(
                message: "Signing in to your account",
              ),
            ),
            transitionDuration: const Duration(milliseconds: 500),
          ),
        );

        User? user = await _auth.signIn(
          _emailController.text,
          _passwordController.text,
          userType, // Pass the selected user type
        );

        if (user != null) {
          // Get user data from Firestore
          DocumentSnapshot userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();

          String userType = userDoc.get('userType') as String;

          // Pop loading screen
          Navigator.pop(context);

          // Navigate to appropriate dashboard
          Widget destinationScreen = _getDestinationScreen(userType);

          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  FadeTransition(
                opacity: animation,
                child: ScaleTransition(
                  scale: animation,
                  child: destinationScreen,
                ),
              ),
              transitionDuration: const Duration(milliseconds: 800),
            ),
          );
        } else {
          Navigator.pop(context);
          setState(() {
            error = 'Invalid email or password';
            _isLoading = false;
          });
          _handleFailedAttempt();
        }
      } catch (e) {
        Navigator.pop(context);
        String errorMessage = 'Invalid email or password';

        if (e.toString().contains('user-not-found')) {
          errorMessage = 'No user found with this email';
        } else if (e.toString().contains('wrong-password')) {
          errorMessage = 'Invalid password';
        } else if (e.toString().contains('Invalid user type')) {
          errorMessage = 'Selected user type does not match account type';
        } else if (e.toString().contains('Admin verification failed')) {
          errorMessage = 'Admin verification failed';
        } else if (e.toString().contains('User data not found')) {
          errorMessage = 'User account not found';
        }

        setState(() {
          error = errorMessage;
          _isLoading = false;
        });
        _handleFailedAttempt();
      }
    }
  }

  void _handleGoogleSignIn() async {
    final selectedUserType = await _showUserTypeDialog();

    if (selectedUserType == null) return;

    if (!_checkRateLimit()) return;

    setState(() {
      _isLoading = true;
      error = '';
    });

    try {
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              FadeTransition(
            opacity: animation,
            child: const LoadingScreen(
              message: "Signing in with Google",
            ),
          ),
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );

      UserCredential? userCredential;

      if (selectedUserType == 'Admin') {
        final adminCode = await _showAdminCodeDialog();
        if (adminCode == null) {
          Navigator.pop(context);
          setState(() {
            _isLoading = false;
          });
          return;
        }

        userCredential = await _auth.signInWithGoogleAdmin(adminCode);
      } else {
        userCredential = await _auth.signInWithGoogle(selectedUserType);
      }

      if (userCredential?.user != null) {
        final user = userCredential!.user!;

        // Check if user exists in Firestore
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        // Handle new user registration
        if (!userDoc.exists) {
          // Create new user data
          Map<String, dynamic> userData = {
            'email': user.email ?? '',
            'fullName': user.displayName ?? '',
            'phoneNumber': user.phoneNumber ?? '',
            'userType': selectedUserType,
            'registrationDate': DateTime.now().toIso8601String(),
            'lastLogin': DateTime.now().toIso8601String(),
            'isVerified': user.emailVerified,
          };

          // Add role-specific fields
          switch (selectedUserType) {
            case 'Landlord':
              userData.addAll({
                'kraPin': '',
                'physicalAddress': '',
                'isNonResident': false,
              });
              break;
            case 'Tenant':
              userData.addAll({
                'currentAddress': '',
                'emergencyContact': {
                  'name': '',
                  'phone': '',
                },
              });
              break;
            case 'Agent':
              userData.addAll({
                'companyName': '',
                'licenseNumber': '',
                'businessAddress': '',
              });
              break;
            case 'Admin':
              userData.addAll({
                'department': '',
                'employeeId': '',
                'adminVerified': true,
              });
              break;
          }

          // Save new user data
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .set(userData);

          // Update userDoc with the new data
          userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();
        } else {
          // For existing users, update last login
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .update({
            'lastLogin': DateTime.now().toIso8601String(),
          });
        }

        // Get user type from Firestore document
        String userType = userDoc.get('userType') as String;
        bool isAdminVerified = userType == 'Admin'
            ? (userDoc.get('adminVerified') as bool? ?? false)
            : true;

        // Verify admin status
        if (userType == 'Admin' && !isAdminVerified) {
          await _auth.signOut();
          setState(() {
            error = 'Admin verification failed';
            _isLoading = false;
          });
          return;
        }

        Navigator.pop(context); // Pop loading screen

        // Navigate to appropriate dashboard
        Widget destinationScreen = _getDestinationScreen(userType);

        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                FadeTransition(
              opacity: animation,
              child: ScaleTransition(
                scale: animation,
                child: destinationScreen,
              ),
            ),
            transitionDuration: const Duration(milliseconds: 800),
          ),
        );
      } else {
        Navigator.pop(context);
        setState(() {
          error = 'Failed to sign in with Google';
          _isLoading = false;
        });
        _handleFailedAttempt();
      }
    } catch (e) {
      Navigator.pop(context);
      setState(() {
        error = 'Error during sign in: ${e.toString()}';
        _isLoading = false;
      });
      _handleFailedAttempt();
    }
  }

  Widget _getDestinationScreen(String userType) {
    switch (userType) {
      case 'Landlord':
        return const LandlordDashboard();
      case 'Tenant':
        return const TenantDashboard();
      case 'Agent':
        return const AgentDashboard();
      case 'Admin':
        return const AdminDashboard();
      default:
        throw Exception('Invalid user type');
    }
  }

  Future<String?> _showUserTypeDialog() {
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        String? selectedType = userType;

        return AlertDialog(
          title: const Text('Select User Type'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Theme.of(context).cardColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedType,
                    isExpanded: true,
                    items: ['Landlord', 'Tenant', 'Agent', 'Admin']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedType = newValue!;
                      });
                    },
                  ),
                ),
              );
            },
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: const Text('Continue'),
              onPressed: () => Navigator.of(context).pop(selectedType),
            ),
          ],
        );
      },
    );
  }

  Future<String?> _showAdminCodeDialog() {
    final adminCodeController = TextEditingController();

    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Admin Access Code'),
          content: TextField(
            controller: adminCodeController,
            decoration: const InputDecoration(
              labelText: 'Enter admin access code',
              border: OutlineInputBorder(),
            ),
            obscureText: true,
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: const Text('Verify'),
              onPressed: () =>
                  Navigator.of(context).pop(adminCodeController.text),
            ),
          ],
        );
      },
    );
  }

  void _handleFailedAttempt() {
    setState(() {
      _failedAttempts++;
      _lastAttemptTime = DateTime.now();
      error = 'Login failed. Please try again.';
      _isLoading = false;
    });
  }

  Widget buildGoogleSignInButton() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: ElevatedButton.icon(
        icon: Image.asset(
          'assets/images/google.png',
          height: 20,
          width: 20,
        ),
        label: Text(
          'Sign in with Google',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.textDark,
                fontWeight: FontWeight.w500,
              ),
        ),
        onPressed: _isLoading ? null : _handleGoogleSignIn,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: AppColors.textDark,
          elevation: 1,
          shadowColor: Colors.black.withOpacity(0.15),
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(
              color: Colors.grey.withOpacity(0.2),
              width: 1,
            ),
          ),
          minimumSize: const Size(double.infinity, 48),
        ),
      ),
    );
  }

  Widget _buildRegisterLink() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Don\'t have an account? ',
            style: TextStyle(color: Colors.grey[600]),
          ),
          GestureDetector(
            onTap: () {
              Navigator.pushReplacementNamed(context, '/register');
            },
            child: Text(
              'Register',
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

  Widget _buildUserTypeSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: userType,
          isExpanded: true,
          items: ['Landlord', 'Tenant', 'Agent', 'Admin']
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              userType = newValue!;
            });
          },
        ),
      ),
    );
  }

  Widget _buildErrorMessage() {
    if (error.isEmpty) {
      return const SizedBox.shrink();
    }

    return AnimatedErrorMessage(
      error: error,
      onDismissed: () {
        setState(() {
          error = '';
        });
      },
    );
  }

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
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FadeInDown(
                    duration: const Duration(milliseconds: 800),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: SvgPicture.string(
                        onboardingSvg,
                        width: 120,
                        height: 120,
                      ),
                    ),
                  ),
                  FadeInDown(
                    duration: const Duration(milliseconds: 800),
                    delay: const Duration(milliseconds: 200),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        'Welcome Back!',
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                      ),
                    ),
                  ),
                  buildGoogleSignInButton(),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Expanded(child: Divider()),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child:
                              Text('OR', style: TextStyle(color: Colors.grey)),
                        ),
                        Expanded(child: Divider()),
                      ],
                    ),
                  ),
                  FadeInUp(
                    duration: const Duration(milliseconds: 800),
                    delay: const Duration(milliseconds: 300),
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: Theme.of(context).colorScheme.copyWith(
                                primary: AppColors.primaryGreen,
                                secondary: AppColors.secondaryOrange,
                              ),
                        ),
                        child: _buildLoginForm(),
                      ),
                    ),
                  ),
                  _buildRegisterLink(),
                  if (error.isNotEmpty)
                    FadeIn(
                      duration: const Duration(milliseconds: 300),
                      child: _buildErrorMessage(),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min, // This is important
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildUserTypeSelector(),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _emailController,
              label: 'Email',
              prefixIcon: Icons.email,
              keyboardType: TextInputType.emailAddress,
              focusNode: _focusNodes[0],
              nextFocusNode: _focusNodes[1],
              validator: InputValidators.validateEmail,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _passwordController,
              label: 'Password',
              prefixIcon: Icons.lock,
              isPassword: true,
              focusNode: _focusNodes[1],
              nextFocusNode: _focusNodes[2],
              validator: InputValidators.validatePassword,
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  // Navigator.pushNamed(context, '/forgot_password');
                },
                child: Text(
                  'Forgot Password?',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _handleSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                minimumSize: const Size(double.infinity, 48),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'Login',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
