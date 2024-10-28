import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:rental_tax_port/screens/admin/admin_dashboard.dart';
import 'package:rental_tax_port/screens/agent/agent_dashboard.dart';
import 'package:rental_tax_port/screens/home/home_screen.dart';
import 'package:rental_tax_port/screens/landlord/landlord_dashboard.dart';
import 'package:rental_tax_port/screens/tenant/tenant_dashboard.dart';
import 'package:rental_tax_port/services/auth_service.dart';
import 'package:rental_tax_port/theme.dart';
import 'package:rental_tax_port/utils/input_validators.dart';
import 'package:rental_tax_port/widgets/custom_text_field.dart';
import 'package:rental_tax_port/screens/loading_screen.dart';
import 'package:animate_do/animate_do.dart';
import 'package:rental_tax_port/widgets/error_message.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  RegisterScreenState createState() => RegisterScreenState();
}

class RegisterScreenState extends State<RegisterScreen>
    with TickerProviderStateMixin {
  // Changed from SingleTickerProviderStateMixin
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  final List<FocusNode> _focusNodes = [];

  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late AnimationController _rotateController;

  // Animations
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  String userType = 'Tenant';
  String error = '';
  bool _isLoading = false;
  int _currentStep = 0;
  bool _isNonResident = false; // Added missing field

  // Track failed attempts for rate limiting
  int _failedAttempts = 0;
  DateTime? _lastAttemptTime;
  static const int _maxAttempts = 3;
  static const int _lockoutMinutes = 15;

  // Common Fields
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
  TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _idNumberController = TextEditingController();

  // Landlord Specific Fields
  final TextEditingController _kraPinController = TextEditingController();
  final TextEditingController _physicalAddressController =
  TextEditingController(); // Added missing controller

  // Property Fields (for Landlords)

  // Tenant Fields
  final TextEditingController _emergencyContactController =
  TextEditingController();
  final TextEditingController _emergencyPhoneController =
  TextEditingController();
  final TextEditingController _currentAddressController =
  TextEditingController();

  // Agent Fields
  final TextEditingController _companyNameController = TextEditingController();
  final TextEditingController _licenseNumberController =
  TextEditingController();
  final TextEditingController _businessAddressController =
  TextEditingController();

  // Admin Fields
  final TextEditingController _adminAccessCodeController =
  TextEditingController();
  final TextEditingController _departmentController = TextEditingController();
  final TextEditingController _employeeIdController = TextEditingController();

  final String onboardingSvg = '''
<svg viewBox="0 0 200 200" xmlns="http://www.w3.org/2000/svg">
  <!-- Define gradients using the app's theme colors -->
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
  
  <!-- Background card with balanced padding -->
  <rect width="160" height="160" x="20" y="20" rx="16" fill="white" stroke="url(#grad)" stroke-width="2"/>
  
  <!-- Form background moved up slightly -->
  <rect x="35" y="60" width="130" height="90" rx="12" fill="url(#grad2)"/>
  
  <!-- User avatar circle moved up slightly -->
  <circle cx="100" cy="50" r="22" fill="url(#grad)" opacity="0.9"/>
  <path d="M100 42 Q100 34 108 42 T116 42 Q116 50 108 54 T92 50 Q92 42 100 42" fill="white"/>
  
  <!-- Form lines moved up -->
  <rect x="45" y="88" width="110" height="8" rx="4" fill="url(#grad)" opacity="0.7"/>
  <rect x="45" y="103" width="110" height="8" rx="4" fill="url(#grad)" opacity="0.5"/>
  <rect x="45" y="118" width="110" height="8" rx="4" fill="url(#grad)" opacity="0.3"/>
  
  <!-- Submit button moved up -->
  <rect x="60" y="135" width="80" height="24" rx="12" fill="url(#grad)"/>
  <rect x="75" y="143" width="50" height="8" rx="4" fill="white"/>
  
  <!-- Plus icon moved up -->
  <circle cx="155" cy="45" r="12" fill="url(#grad)"/>
  <rect x="149" y="43.5" width="12" height="3" rx="1.5" fill="white"/>
  <rect x="153.5" y="39" width="3" height="12" rx="1.5" fill="white"/>
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
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    // Slide animation
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

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

  void _animateStepTransition() {
    _fadeController.reset();
    _slideController.reset();
    _scaleController.reset();

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
    _confirmPasswordController.dispose();
    _fullNameController.dispose();
    _phoneController.dispose();
    _idNumberController.dispose();
    _kraPinController.dispose();
    _physicalAddressController.dispose();
    _emergencyContactController.dispose();
    _emergencyPhoneController.dispose();
    _currentAddressController.dispose();
    _companyNameController.dispose();
    _licenseNumberController.dispose();
    _businessAddressController.dispose();
    _adminAccessCodeController.dispose();
    _departmentController.dispose();
    _employeeIdController.dispose();
    super.dispose();
  }

  void _handleSubmit() async {
    if (!_checkRateLimit()) return;

    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      // Show loading screen with animation
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              FadeTransition(
                opacity: animation,
                child: const LoadingScreen(
                  message: "Creating your account",
                ),
              ),
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );

      try {
        // Basic user data
        Map<String, dynamic> userData = {
          'email': _emailController.text,
          'fullName': _fullNameController.text,
          'phoneNumber': _phoneController.text,
          'idNumber': _idNumberController.text,
          'userType': userType,
          'registrationDate': DateTime.now().toIso8601String(),
          'isVerified': false,
        };

        // Add role-specific data
        switch (userType) {
          case 'Landlord':
            userData.addAll({
              'kraPin': _kraPinController.text,
              'physicalAddress': _physicalAddressController.text,
              'isNonResident': _isNonResident,
            });
            break;
          case 'Tenant':
            userData.addAll({
              'currentAddress': _currentAddressController.text,
              'emergencyContact': {
                'name': _emergencyContactController.text,
                'phone': _emergencyPhoneController.text,
              },
            });
            break;
          case 'Agent':
            userData.addAll({
              'companyName': _companyNameController.text,
              'licenseNumber': _licenseNumberController.text,
              'businessAddress': _businessAddressController.text,
            });
            break;
          case 'Admin':
          // Verify admin access code before proceeding
            if (!await _auth.verifyAdminCode(_adminAccessCodeController.text)) {
              throw Exception('Invalid admin access code');
            }
            userData.addAll({
              'department': _departmentController.text,
              'employeeId': _employeeIdController.text,
            });
            break;
        }

        dynamic result = await _auth.signUp(
          _emailController.text,
          _passwordController.text,
          userData,
        );

        // Pop loading screen
        Navigator.pop(context);

        if (result == null) {
          _handleFailedAttempt();
        } else {
          // Successful registration animation
          await _rotateController.forward();

          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  FadeTransition(
                    opacity: animation,
                    child: ScaleTransition(
                      scale: animation,
                      child: const HomeScreen(),
                    ),
                  ),
              transitionDuration: const Duration(milliseconds: 800),
            ),
          );
        }
      } catch (e) {
        // Pop loading screen
        Navigator.pop(context);
        _handleFailedAttempt();
      }
    }
  }

  void _handleFailedAttempt() {
    setState(() {
      _failedAttempts++;
      _lastAttemptTime = DateTime.now();
      error = 'Registration failed. Please try again.';
      _isLoading = false;
    });
  }

  // Add this method to show user type selection dialog
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

// Add this method to show admin code input dialog
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

  List<Step> buildSteps() {
    return [
      Step(
        title: const Text('Account', style: TextStyle(fontSize: 13)),
        content: _buildStepContent(
          icon: Icons.person_outline,
          title: 'Create Your Account',
          description: 'Enter your basic information to get started',
          form: Column(
            children: [
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
              const SizedBox(height: 16),
              CustomTextField(
                controller: _confirmPasswordController,
                label: 'Confirm Password',
                prefixIcon: Icons.lock_outline,
                isPassword: true,
                focusNode: _focusNodes[2],
                nextFocusNode: _focusNodes[3],
                validator: (value) => InputValidators.validateConfirmPassword(
                    value, _passwordController.text),
              ),
            ],
          ),
        ),
        isActive: _currentStep >= 0,
      ),
      Step(
        title: const Text('Details', style: TextStyle(fontSize: 13)),
        content: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Column(
              children: [
                CustomTextField(
                  controller: _fullNameController,
                  label: 'Full Name',
                  prefixIcon: Icons.person,
                  focusNode: _focusNodes[3],
                  nextFocusNode: _focusNodes[4],
                  validator: InputValidators.validateFullName,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _phoneController,
                  label: 'Phone Number',
                  prefixIcon: Icons.phone,
                  keyboardType: TextInputType.phone,
                  focusNode: _focusNodes[4],
                  nextFocusNode: _focusNodes[5],
                  validator: InputValidators.validatePhone,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _idNumberController,
                  label: 'ID Number',
                  prefixIcon: Icons.badge,
                  keyboardType: TextInputType.number,
                  focusNode: _focusNodes[5],
                  nextFocusNode: _focusNodes[6],
                  validator: InputValidators.validateIdNumber,
                ),
                const SizedBox(height: 16),
                _buildUserTypeSelector(),
              ],
            ),
          ),
        ),
        isActive: _currentStep >= 1,
      ),
      Step(
        title: const Text('More Info', style: TextStyle(fontSize: 13)),
        content: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: _buildAdditionalFields(),
          ),
        ),
        isActive: _currentStep >= 2,
      ),
    ];
  }

  Widget _buildStepContent({
    required IconData icon,
    required String title,
    required String description,
    required Widget form,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Icon(
                  icon,
                  size: 48,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                form,
              ],
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

  Widget _buildAdditionalFields() {
    switch (userType) {
      case 'Landlord':
        return Column(
          children: [
            CustomTextField(
              controller: _kraPinController,
              label: 'KRA PIN',
              prefixIcon: Icons.numbers,
              validator: InputValidators.validateKraPin,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _physicalAddressController,
              label: 'Physical Address',
              prefixIcon: Icons.location_on,
              validator: InputValidators.validateAddress,
            ),
            const SizedBox(height: 16),
            CheckboxListTile(
              title: const Text('Non-Resident Landlord'),
              value: _isNonResident,
              onChanged: (value) => setState(() => _isNonResident = value!),
              controlAffinity: ListTileControlAffinity.leading,
            ),
          ],
        );

      case 'Tenant':
        return Column(
          children: [
            CustomTextField(
              controller: _currentAddressController,
              label: 'Current Address',
              prefixIcon: Icons.home,
              validator: InputValidators.validateAddress,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _emergencyContactController,
              label: 'Emergency Contact Name',
              prefixIcon: Icons.contact_phone,
              validator: InputValidators.validateEmergencyContact,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _emergencyPhoneController,
              label: 'Emergency Contact Phone',
              prefixIcon: Icons.phone,
              validator: InputValidators.validatePhone,
            ),
          ],
        );

      case 'Agent':
        return Column(
          children: [
            CustomTextField(
              controller: _companyNameController,
              label: 'Company Name',
              prefixIcon: Icons.business,
              validator: InputValidators.validateCompanyName,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _licenseNumberController,
              label: 'License Number',
              prefixIcon: Icons.badge,
              validator: InputValidators.validateLicenseNumber,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _businessAddressController,
              label: 'Business Address',
              prefixIcon: Icons.location_on,
              validator: InputValidators.validateAddress,
            ),
          ],
        );

      case 'Admin':
        return Column(
          children: [
            CustomTextField(
              controller: _adminAccessCodeController,
              label: 'Admin Access Code',
              prefixIcon: Icons.security,
              isPassword: true,
              validator: InputValidators.validateAdminCode,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _departmentController,
              label: 'Department',
              prefixIcon: Icons.business_center,
              validator: InputValidators.validateDepartment,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _employeeIdController,
              label: 'Employee ID',
              prefixIcon: Icons.badge,
              validator: InputValidators.validateEmployeeId,
            ),
          ],
        );

      default:
        return Container();
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
          'Continue with Google',
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
              buildGoogleSignInButton(),
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
                  duration: const Duration(milliseconds: 800),
                  delay: const Duration(milliseconds: 300),
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Form(
                      key: _formKey,
                      child: Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: Theme.of(context).colorScheme.copyWith(
                            primary: AppColors.primaryGreen,
                            secondary: AppColors.secondaryOrange,
                          ),
                        ),
                        child: _buildStepperContent(),
                      ),
                    ),
                  ),
                ),
              ),
              _buildLoginLink(),
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

  Widget _buildStepperContent() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stepper(
          type: StepperType.horizontal,
          currentStep: _currentStep,
          onStepContinue: () {
            if (_currentStep < buildSteps().length - 1) {
              setState(() {
                _currentStep += 1;
                _animateStepTransition();
              });
            } else {
              _handleSubmit();
            }
          },
          onStepCancel: () {
            if (_currentStep > 0) {
              setState(() {
                _currentStep -= 1;
                _animateStepTransition();
              });
            }
          },
          steps: buildSteps(),
          elevation: 0,
          controlsBuilder: (context, controls) => _buildControls(controls),
        ),
      ),
    );
  }

  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0:
      // Validate Account Step
        return _emailController.text.isNotEmpty &&
            InputValidators.validateEmail(_emailController.text) == null &&
            _passwordController.text.isNotEmpty &&
            InputValidators.validatePassword(_passwordController.text) ==
                null &&
            _confirmPasswordController.text.isNotEmpty &&
            InputValidators.validateConfirmPassword(
                _confirmPasswordController.text,
                _passwordController.text) ==
                null;

      case 1:
      // Validate Details Step
        return _fullNameController.text.isNotEmpty &&
            InputValidators.validateFullName(_fullNameController.text) ==
                null &&
            _phoneController.text.isNotEmpty &&
            InputValidators.validatePhone(_phoneController.text) == null &&
            _idNumberController.text.isNotEmpty &&
            InputValidators.validateIdNumber(_idNumberController.text) == null;

      case 2:
      // Validate Additional Info Step based on user type
        switch (userType) {
          case 'Landlord':
            return _kraPinController.text.isNotEmpty &&
                InputValidators.validateKraPin(_kraPinController.text) ==
                    null &&
                _physicalAddressController.text.isNotEmpty &&
                InputValidators.validateAddress(
                    _physicalAddressController.text) ==
                    null;

          case 'Tenant':
            return _currentAddressController.text.isNotEmpty &&
                InputValidators.validateAddress(
                    _currentAddressController.text) ==
                    null &&
                _emergencyContactController.text.isNotEmpty &&
                _emergencyPhoneController.text.isNotEmpty &&
                InputValidators.validatePhone(_emergencyPhoneController.text) ==
                    null;

          case 'Agent':
            return _companyNameController.text.isNotEmpty &&
                InputValidators.validateCompanyName(
                    _companyNameController.text) ==
                    null &&
                _licenseNumberController.text.isNotEmpty &&
                InputValidators.validateLicenseNumber(
                    _licenseNumberController.text) ==
                    null &&
                _businessAddressController.text.isNotEmpty &&
                InputValidators.validateAddress(
                    _businessAddressController.text) ==
                    null;

          case 'Admin':
            return _adminAccessCodeController.text.isNotEmpty &&
                InputValidators.validateAdminCode(
                    _adminAccessCodeController.text) ==
                    null &&
                _departmentController.text.isNotEmpty &&
                _employeeIdController.text.isNotEmpty &&
                InputValidators.validateEmployeeId(
                    _employeeIdController.text) ==
                    null;

          default:
            return false;
        }

      default:
        return false;
    }
  }

  Widget _buildControls(ControlsDetails controls) {
    return Container(
      margin: const EdgeInsets.only(top: 24),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: _isLoading
                  ? null
                  : () {
                if (_validateCurrentStep()) {
                  controls.onStepContinue?.call();
                } else {
                  setState(() {
                    error =
                    'Please fill in all required fields correctly';
                  });
                }
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
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
                  : Text(
                _currentStep == buildSteps().length - 1
                    ? 'Create Account'
                    : 'Continue',
              ),
            ),
          ),
          if (_currentStep > 0) ...[
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton(
                onPressed: controls.onStepCancel,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: const BorderSide(color: AppColors.primaryGreen),
                  foregroundColor: AppColors.primaryGreen,
                ),
                child: const Text(
                  'Back',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: AppColors.primaryGreen,
                  ),
                ),
              ),
            ),
          ],
        ],
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
}