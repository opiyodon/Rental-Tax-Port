import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:rental_tax_port/screens/home/home_screen.dart';
import 'package:rental_tax_port/services/auth_service.dart';
import 'package:rental_tax_port/theme.dart';
import 'package:rental_tax_port/widgets/custom_text_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  RegisterScreenState createState() => RegisterScreenState();
}

class RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  final List<FocusNode> _focusNodes = [];

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  String userType = 'Tenant';
  String error = '';
  bool _isLoading = false;
  int _currentStep = 0;
  bool _isNonResident = false; // Added missing field

  // Track failed attempts for rate limiting
  int _failedAttempts = 0;
  DateTime? _lastAttemptTime;

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
  final List<String> _selectedUnitTypes = [];

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
  <!-- Define gradients -->
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
  <rect width="180" height="180" x="10" y="10" rx="16" fill="white" stroke="url(#grad)" stroke-width="2"/>
  
  <!-- Form background -->
  <rect x="35" y="60" width="130" height="110" rx="12" fill="url(#grad2)"/>
  
  <!-- User avatar circle -->
  <circle cx="100" cy="45" r="25" fill="url(#grad)" opacity="0.9"/>
  <path d="M100 35 Q100 25 110 35 T120 35 Q120 45 110 50 T90 45 Q90 35 100 35" fill="white"/>
  
  <!-- Form lines -->
  <rect x="45" y="100" width="110" height="8" rx="4" fill="url(#grad)" opacity="0.7"/>
  <rect x="45" y="120" width="110" height="8" rx="4" fill="url(#grad)" opacity="0.5"/>
  <rect x="45" y="140" width="110" height="8" rx="4" fill="url(#grad)" opacity="0.3"/>
  
  <!-- Submit button -->
  <rect x="60" y="160" width="80" height="24" rx="12" fill="url(#grad)"/>
  <rect x="75" y="168" width="50" height="8" rx="4" fill="white"/>
  
  <!-- Plus icon -->
  <circle cx="160" cy="40" r="15" fill="url(#grad)"/>
  <rect x="152" y="38" width="16" height="4" rx="2" fill="white"/>
  <rect x="158" y="32" width="4" height="16" rx="2" fill="white"/>
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
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
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

  // Rate limiting check
  bool _checkRateLimit() {
    if (_failedAttempts >= 3) {
      final now = DateTime.now();
      if (_lastAttemptTime != null) {
        final difference = now.difference(_lastAttemptTime!);
        if (difference.inMinutes < 15) {
          setState(() {
            error =
                'Too many attempts. Please try again in ${15 - difference.inMinutes} minutes.';
          });
          return false;
        } else {
          _failedAttempts = 0;
        }
      }
    }
    return true;
  }

  @override
  void dispose() {
    _animationController.dispose();
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

        if (result == null) {
          _handleFailedAttempt();
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        }
      } catch (e) {
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
                validator: null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _passwordController,
                label: 'Password',
                prefixIcon: Icons.lock,
                isPassword: true,
                focusNode: _focusNodes[1],
                nextFocusNode: _focusNodes[2],
                validator: null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _confirmPasswordController,
                label: 'Confirm Password',
                prefixIcon: Icons.lock_outline,
                isPassword: true,
                focusNode: _focusNodes[2],
                nextFocusNode: _focusNodes[3],
                validator: null,
              ),
            ],
          ),
        ),
        isActive: _currentStep >= 0,
      ),
      Step(
        title: const Text('Details',
            style: TextStyle(
                fontSize: 13)), // Changed from 'Personal Details' to 'Details'
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
                  validator: null,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _phoneController,
                  label: 'Phone Number',
                  prefixIcon: Icons.phone,
                  keyboardType: TextInputType.phone,
                  focusNode: _focusNodes[4],
                  nextFocusNode: _focusNodes[5],
                  validator: null,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _idNumberController,
                  label: 'ID Number',
                  prefixIcon: Icons.badge,
                  keyboardType: TextInputType.number,
                  focusNode: _focusNodes[5],
                  nextFocusNode: _focusNodes[6],
                  validator: null,
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
        title: const Text('More Info',
            style: TextStyle(
                fontSize: 13)), // Changed from 'Additional Info' to 'More Info'
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
              validator: null,
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
              validator: null,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _emergencyContactController,
              label: 'Emergency Contact Name',
              prefixIcon: Icons.contact_phone,
              validator: null,
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
              validator: null,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _licenseNumberController,
              label: 'License Number',
              prefixIcon: Icons.badge,
              validator: null,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _businessAddressController,
              label: 'Business Address',
              prefixIcon: Icons.location_on,
              validator: null,
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
              validator: null,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _departmentController,
              label: 'Department',
              prefixIcon: Icons.business_center,
              validator: null,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _employeeIdController,
              label: 'Employee ID',
              prefixIcon: Icons.badge,
              validator: null,
            ),
          ],
        );

      default:
        return Container();
    }
  }

  Widget buildUnitTypesSelector() {
    List<String> unitTypes = [
      'Single Room',
      'Bedsitter',
      '1 Bedroom',
      '2 Bedroom',
      '3 Bedroom',
      '4 Bedroom',
      '5 Bedroom',
      '6 Bedroom',
      'Bungalow',
      'Hotel Room',
      'Shop',
      'Office',
      'Godown',
      'Industrial Space',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            'Unit Types Available',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.textDark,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: GridView.builder(
            shrinkWrap: true, // Important to work inside Column
            physics:
                const NeverScrollableScrollPhysics(), // Disable grid scrolling
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // Number of chips per row
              childAspectRatio: 3, // Adjust this value to control chip height
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: unitTypes.length,
            itemBuilder: (context, index) {
              final type = unitTypes[index];
              final isSelected = _selectedUnitTypes.contains(type);

              return FilterChip(
                label: Text(type),
                selected: isSelected,
                onSelected: (bool selected) {
                  setState(() {
                    if (selected) {
                      _selectedUnitTypes.add(type);
                    } else {
                      _selectedUnitTypes.remove(type);
                    }
                  });
                },
                backgroundColor: Colors.white,
                selectedColor: AppColors.primaryGreen,
                checkmarkColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textDark,
                  fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: isSelected
                        ? AppColors.primaryGreen
                        : AppColors.subtleGrey,
                    width: 1,
                  ),
                ),
                elevation: isSelected ? 2 : 0,
                pressElevation: 4,
              );
            },
          ),
        ),
      ],
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
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: SvgPicture.string(
                  onboardingSvg,
                  width: 120,
                  height: 120,
                ),
              ),
              // Inside the Stepper widget in build method
              Expanded(
                child: Form(
                  key: _formKey,
                  child: Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: Theme.of(context).colorScheme.copyWith(
                            primary: AppColors.primaryGreen,
                            secondary: AppColors.secondaryOrange,
                          ),
                    ),
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
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
                              setState(() => _currentStep += 1);
                            } else {
                              _handleSubmit();
                            }
                          },
                          onStepCancel: () {
                            if (_currentStep > 0) {
                              setState(() => _currentStep -= 1);
                            }
                          },
                          steps: buildSteps(),
                          elevation: 0,
                          controlsBuilder: (context, controls) =>
                              _buildControls(controls),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              if (error.isNotEmpty) _buildErrorMessage(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControls(ControlsDetails controls) {
    return Container(
      margin: const EdgeInsets.only(top: 24),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: _isLoading ? null : controls.onStepContinue,
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
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.error.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              Icons.error_outline,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                error,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontSize: 14.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Add input validators
class InputValidators {
  static String? validateKraPin(String? value) {
    if (value == null || value.isEmpty) {
      return 'KRA PIN is required';
    }
    // Add additional KRA PIN validation logic here
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    // Add additional phone number validation logic here
    return null;
  }
}
