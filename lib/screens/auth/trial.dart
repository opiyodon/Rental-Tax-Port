// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:rental_tax_port/screens/home/home_screen.dart';
// import 'package:rental_tax_port/services/auth_service.dart';
// import 'package:rental_tax_port/theme.dart';
// import 'package:rental_tax_port/widgets/custom_text_field.dart';
//
// class RegisterScreen extends StatefulWidget {
//   const RegisterScreen({super.key});
//
//   @override
//   RegisterScreenState createState() => RegisterScreenState();
// }
//
// class RegisterScreenState extends State<RegisterScreen>
//     with SingleTickerProviderStateMixin {
//   final AuthService _auth = AuthService();
//   final _formKey = GlobalKey<FormState>();
//   final List<FocusNode> _focusNodes = [];
//   final List<TextEditingController> _controllers = [];
//
//   late AnimationController _animationController;
//   late Animation<double> _fadeAnimation;
//   late Animation<Offset> _slideAnimation;
//
//   String userType = 'Tenant';
//   String error = '';
//   bool _isLoading = false;
//   int _currentStep = 0;
//
//   // Common Fields
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   final _confirmPasswordController = TextEditingController();
//   final _fullNameController = TextEditingController();
//   final _phoneController = TextEditingController();
//   final _idNumberController = TextEditingController();
//
//   // Landlord Specific Fields
//   final _kraPinController = TextEditingController();
//   final _bankAccountController = TextEditingController();
//   final _bankNameController = TextEditingController();
//
//   // Property Fields (for Landlords)
//   final _plotNumberController = TextEditingController();
//   final _propertyNameController = TextEditingController();
//   String _selectedPropertyType = 'Residential';
//   final List<String> _selectedUnitTypes = [];
//
//   final String onboardingSvg = '''
// <svg viewBox="0 0 200 200" xmlns="http://www.w3.org/2000/svg">
//   <!-- Define gradients -->
//   <defs>
//     <linearGradient id="grad" x1="0%" y1="0%" x2="100%" y2="100%">
//       <stop offset="0%" style="stop-color:#4CAF50;stop-opacity:1" />
//       <stop offset="100%" style="stop-color:#FF9800;stop-opacity:1" />
//     </linearGradient>
//     <linearGradient id="grad2" x1="0%" y1="0%" x2="100%" y2="0%">
//       <stop offset="0%" style="stop-color:#4CAF50;stop-opacity:0.2" />
//       <stop offset="100%" style="stop-color:#FF9800;stop-opacity:0.2" />
//     </linearGradient>
//   </defs>
//
//   <!-- Background card -->
//   <rect width="180" height="180" x="10" y="10" rx="16" fill="white" stroke="url(#grad)" stroke-width="2"/>
//
//   <!-- Form background -->
//   <rect x="35" y="60" width="130" height="110" rx="12" fill="url(#grad2)"/>
//
//   <!-- User avatar circle -->
//   <circle cx="100" cy="45" r="25" fill="url(#grad)" opacity="0.9"/>
//   <path d="M100 35 Q100 25 110 35 T120 35 Q120 45 110 50 T90 45 Q90 35 100 35" fill="white"/>
//
//   <!-- Form lines -->
//   <rect x="45" y="100" width="110" height="8" rx="4" fill="url(#grad)" opacity="0.7"/>
//   <rect x="45" y="120" width="110" height="8" rx="4" fill="url(#grad)" opacity="0.5"/>
//   <rect x="45" y="140" width="110" height="8" rx="4" fill="url(#grad)" opacity="0.3"/>
//
//   <!-- Submit button -->
//   <rect x="60" y="160" width="80" height="24" rx="12" fill="url(#grad)"/>
//   <rect x="75" y="168" width="50" height="8" rx="4" fill="white"/>
//
//   <!-- Plus icon -->
//   <circle cx="160" cy="40" r="15" fill="url(#grad)"/>
//   <rect x="152" y="38" width="16" height="4" rx="2" fill="white"/>
//   <rect x="158" y="32" width="4" height="16" rx="2" fill="white"/>
// </svg>
// ''';
//
//   @override
//   void initState() {
//     super.initState();
//     _initializeAnimations();
//     _initializeFocusNodes();
//   }
//
//   void _initializeAnimations() {
//     _animationController = AnimationController(
//       duration: const Duration(milliseconds: 800),
//       vsync: this,
//     );
//
//     _fadeAnimation = Tween<double>(
//       begin: 0.0,
//       end: 1.0,
//     ).animate(CurvedAnimation(
//       parent: _animationController,
//       curve: Curves.easeInOut,
//     ));
//
//     _slideAnimation = Tween<Offset>(
//       begin: const Offset(0, 0.1),
//       end: Offset.zero,
//     ).animate(CurvedAnimation(
//       parent: _animationController,
//       curve: Curves.easeInOut,
//     ));
//
//     _animationController.forward();
//   }
//
//   void _initializeFocusNodes() {
//     for (int i = 0; i < 10; i++) {
//       _focusNodes.add(FocusNode());
//     }
//   }
//
//   @override
//   void dispose() {
//     _animationController.dispose();
//     for (var node in _focusNodes) {
//       node.dispose();
//     }
//     for (var controller in _controllers) {
//       controller.dispose();
//     }
//     super.dispose();
//   }
//
//   void _handleSubmit() async {
//     if (_formKey.currentState!.validate()) {
//       setState(() => _isLoading = true);
//
//       try {
//         // Create user data map based on user type
//         Map<String, dynamic> userData = {
//           'email': _emailController.text,
//           'fullName': _fullNameController.text,
//           'phoneNumber': _phoneController.text,
//           'idNumber': _idNumberController.text,
//           'userType': userType,
//         };
//
//         if (userType == 'Landlord') {
//           userData.addAll({
//             'kraPinNumber': _kraPinController.text,
//             'bankAccount': _bankAccountController.text,
//             'bankName': _bankNameController.text,
//             'properties': [
//               {
//                 'plotNumber': _plotNumberController.text,
//                 'propertyName': _propertyNameController.text,
//                 'propertyType': _selectedPropertyType,
//                 'unitTypes': _selectedUnitTypes,
//               }
//             ],
//           });
//         }
//
//         dynamic result = await _auth.signUp(
//           _emailController.text,
//           _passwordController.text,
//           userData,
//         );
//
//         if (result == null) {
//           setState(() {
//             error = 'Registration failed. Please try again.';
//             _isLoading = false;
//           });
//         } else {
//           Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(builder: (context) => const HomeScreen()),
//           );
//         }
//       } catch (e) {
//         setState(() {
//           error = e.toString();
//           _isLoading = false;
//         });
//       }
//     }
//   }
//
//   List<Step> buildSteps() {
//     return [
//       Step(
//         title: const Text('Account', style: TextStyle(fontSize: 13)),
//         content: _buildStepContent(
//           icon: Icons.person_outline,
//           title: 'Create Your Account',
//           description: 'Enter your basic information to get started',
//           form: Column(
//             children: [
//               CustomTextField(
//                 controller: _emailController,
//                 label: 'Email',
//                 prefixIcon: Icons.email,
//                 keyboardType: TextInputType.emailAddress,
//                 focusNode: _focusNodes[0],
//                 nextFocusNode: _focusNodes[1],
//               ),
//               const SizedBox(height: 16),
//               CustomTextField(
//                 controller: _passwordController,
//                 label: 'Password',
//                 prefixIcon: Icons.lock,
//                 isPassword: true,
//                 focusNode: _focusNodes[1],
//                 nextFocusNode: _focusNodes[2],
//               ),
//               const SizedBox(height: 16),
//               CustomTextField(
//                 controller: _confirmPasswordController,
//                 label: 'Confirm Password',
//                 prefixIcon: Icons.lock_outline,
//                 isPassword: true,
//                 focusNode: _focusNodes[2],
//                 nextFocusNode: _focusNodes[3],
//               ),
//             ],
//           ),
//         ),
//         isActive: _currentStep >= 0,
//       ),
//       Step(
//         title: const Text('Details',
//             style: TextStyle(
//                 fontSize: 13)), // Changed from 'Personal Details' to 'Details'
//         content: FadeTransition(
//           opacity: _fadeAnimation,
//           child: SlideTransition(
//             position: _slideAnimation,
//             child: Column(
//               children: [
//                 CustomTextField(
//                   controller: _fullNameController,
//                   label: 'Full Name',
//                   prefixIcon: Icons.person,
//                   focusNode: _focusNodes[3],
//                   nextFocusNode: _focusNodes[4],
//                 ),
//                 const SizedBox(height: 16),
//                 CustomTextField(
//                   controller: _phoneController,
//                   label: 'Phone Number',
//                   prefixIcon: Icons.phone,
//                   keyboardType: TextInputType.phone,
//                   focusNode: _focusNodes[4],
//                   nextFocusNode: _focusNodes[5],
//                 ),
//                 const SizedBox(height: 16),
//                 CustomTextField(
//                   controller: _idNumberController,
//                   label: 'ID Number',
//                   prefixIcon: Icons.badge,
//                   keyboardType: TextInputType.number,
//                   focusNode: _focusNodes[5],
//                   nextFocusNode: _focusNodes[6],
//                 ),
//                 const SizedBox(height: 16),
//                 _buildUserTypeSelector(),
//               ],
//             ),
//           ),
//         ),
//         isActive: _currentStep >= 1,
//       ),
//       Step(
//         title: const Text('More Info',
//             style: TextStyle(
//                 fontSize: 13)), // Changed from 'Additional Info' to 'More Info'
//         content: FadeTransition(
//           opacity: _fadeAnimation,
//           child: SlideTransition(
//             position: _slideAnimation,
//             child: _buildAdditionalFields(),
//           ),
//         ),
//         isActive: _currentStep >= 2,
//       ),
//     ];
//   }
//
//   Widget _buildStepContent({
//     required IconData icon,
//     required String title,
//     required String description,
//     required Widget form,
//   }) {
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 16),
//       child: Column(
//         children: [
//           Container(
//             padding: const EdgeInsets.all(16),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(16),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.05),
//                   blurRadius: 10,
//                   offset: const Offset(0, 2),
//                 ),
//               ],
//             ),
//             child: Column(
//               children: [
//                 Icon(
//                   icon,
//                   size: 48,
//                   color: Theme.of(context).colorScheme.primary,
//                 ),
//                 const SizedBox(height: 16),
//                 Text(
//                   title,
//                   style: Theme.of(context).textTheme.headlineSmall,
//                   textAlign: TextAlign.center,
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   description,
//                   style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                     color: Colors.grey[600],
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//                 const SizedBox(height: 24),
//                 form,
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildUserTypeSelector() {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 12),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(12),
//         color: Theme.of(context).cardColor,
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 10,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: DropdownButtonHideUnderline(
//         child: DropdownButton<String>(
//           value: userType,
//           isExpanded: true,
//           items: ['Landlord', 'Tenant', 'Agent', 'Admin']
//               .map<DropdownMenuItem<String>>((String value) {
//             return DropdownMenuItem<String>(
//               value: value,
//               child: Text(value),
//             );
//           }).toList(),
//           onChanged: (String? newValue) {
//             setState(() {
//               userType = newValue!;
//             });
//           },
//         ),
//       ),
//     );
//   }
//
//   Widget _buildAdditionalFields() {
//     if (userType == 'Landlord') {
//       return Column(
//         children: [
//           CustomTextField(
//             controller: _kraPinController,
//             label: 'KRA PIN Number',
//             prefixIcon: Icons.numbers,
//             focusNode: _focusNodes[6],
//             nextFocusNode: _focusNodes[7],
//           ),
//           const SizedBox(height: 16),
//           CustomTextField(
//             controller: _bankAccountController,
//             label: 'Bank Account Number',
//             prefixIcon: Icons.account_balance,
//             keyboardType: TextInputType.number,
//             focusNode: _focusNodes[7],
//             nextFocusNode: _focusNodes[8],
//           ),
//           const SizedBox(height: 16),
//           CustomTextField(
//             controller: _bankNameController,
//             label: 'Bank Name',
//             prefixIcon: Icons.account_balance_wallet,
//             focusNode: _focusNodes[8],
//             nextFocusNode: _focusNodes[9],
//           ),
//           const SizedBox(height: 16),
//           _buildPropertyFields(),
//         ],
//       );
//     } else if (userType == 'Tenant') {
//       return Column(
//         children: [
//           CustomTextField(
//             controller: TextEditingController(),
//             label: 'Current Address',
//             prefixIcon: Icons.home,
//             focusNode: _focusNodes[6],
//             nextFocusNode: _focusNodes[7],
//           ),
//           const SizedBox(height: 16),
//           CustomTextField(
//             controller: TextEditingController(),
//             label: 'Emergency Contact',
//             prefixIcon: Icons.contact_phone,
//             focusNode: _focusNodes[7],
//             nextFocusNode: _focusNodes[8],
//           ),
//         ],
//       );
//     }
//     // Add fields for Agent and Admin if needed
//     return Container();
//   }
//
//   Widget _buildPropertyFields() {
//     return Column(
//       children: [
//         CustomTextField(
//           controller: _plotNumberController,
//           label: 'Plot Number',
//           prefixIcon: Icons.home_work,
//           focusNode: _focusNodes[9],
//         ),
//         const SizedBox(height: 16),
//         CustomTextField(
//           controller: _propertyNameController,
//           label: 'Property Name',
//           prefixIcon: Icons.business,
//         ),
//         const SizedBox(height: 16),
//         _buildPropertyTypeSelector(),
//         const SizedBox(height: 16),
//         buildUnitTypesSelector(),
//       ],
//     );
//   }
//
//   Widget _buildPropertyTypeSelector() {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 12),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(12),
//         color: Theme.of(context).cardColor,
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 10,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: DropdownButtonHideUnderline(
//         child: DropdownButton<String>(
//           value: _selectedPropertyType,
//           isExpanded: true,
//           items: ['Residential', 'Commercial', 'Industrial', 'Mixed Use']
//               .map<DropdownMenuItem<String>>((String value) {
//             return DropdownMenuItem<String>(
//               value: value,
//               child: Text(value),
//             );
//           }).toList(),
//           onChanged: (String? newValue) {
//             setState(() {
//               _selectedPropertyType = newValue!;
//             });
//           },
//         ),
//       ),
//     );
//   }
//
//   Widget buildUnitTypesSelector() {
//     List<String> unitTypes = [
//       'Single Room',
//       'Bedsitter',
//       '1 Bedroom',
//       '2 Bedroom',
//       '3 Bedroom',
//       '4 Bedroom',
//       '5 Bedroom',
//       '6 Bedroom',
//       'Bungalow',
//       'Hotel Room',
//       'Shop',
//       'Office',
//       'Godown',
//       'Industrial Space',
//     ];
//
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 4),
//           child: Text(
//             'Unit Types Available',
//             style: Theme.of(context).textTheme.titleMedium?.copyWith(
//               color: AppColors.textDark,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//         ),
//         const SizedBox(height: 12),
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 4),
//           child: GridView.builder(
//             shrinkWrap: true, // Important to work inside Column
//             physics:
//             const NeverScrollableScrollPhysics(), // Disable grid scrolling
//             gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//               crossAxisCount: 2, // Number of chips per row
//               childAspectRatio: 3, // Adjust this value to control chip height
//               crossAxisSpacing: 8,
//               mainAxisSpacing: 8,
//             ),
//             itemCount: unitTypes.length,
//             itemBuilder: (context, index) {
//               final type = unitTypes[index];
//               final isSelected = _selectedUnitTypes.contains(type);
//
//               return FilterChip(
//                 label: Text(type),
//                 selected: isSelected,
//                 onSelected: (bool selected) {
//                   setState(() {
//                     if (selected) {
//                       _selectedUnitTypes.add(type);
//                     } else {
//                       _selectedUnitTypes.remove(type);
//                     }
//                   });
//                 },
//                 backgroundColor: Colors.white,
//                 selectedColor: AppColors.primaryGreen,
//                 checkmarkColor: Colors.white,
//                 padding:
//                 const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                 labelStyle: TextStyle(
//                   color: isSelected ? Colors.white : AppColors.textDark,
//                   fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
//                 ),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(20),
//                   side: BorderSide(
//                     color: isSelected
//                         ? AppColors.primaryGreen
//                         : AppColors.subtleGrey,
//                     width: 1,
//                   ),
//                 ),
//                 elevation: isSelected ? 2 : 0,
//                 pressElevation: 4,
//               );
//             },
//           ),
//         ),
//       ],
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//             colors: [
//               Theme.of(context).colorScheme.primary.withOpacity(0.1),
//               Theme.of(context).colorScheme.secondary.withOpacity(0.1),
//             ],
//           ),
//         ),
//         child: SafeArea(
//           child: Column(
//             children: [
//               Padding(
//                 padding: const EdgeInsets.all(24.0),
//                 child: SvgPicture.string(
//                   onboardingSvg,
//                   width: 120,
//                   height: 120,
//                 ),
//               ),
//               // Inside the Stepper widget in build method
//               Expanded(
//                 child: Form(
//                   key: _formKey,
//                   child: Theme(
//                     data: Theme.of(context).copyWith(
//                       colorScheme: Theme.of(context).colorScheme.copyWith(
//                         primary: AppColors.primaryGreen,
//                         secondary: AppColors.secondaryOrange,
//                       ),
//                     ),
//                     child: Container(
//                       margin: const EdgeInsets.symmetric(
//                           horizontal: 16, vertical: 8),
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(16),
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.black.withOpacity(0.05),
//                             blurRadius: 10,
//                             offset: const Offset(0, 2),
//                           ),
//                         ],
//                       ),
//                       child: ClipRRect(
//                         borderRadius: BorderRadius.circular(16),
//                         child: Stepper(
//                           type: StepperType.horizontal,
//                           currentStep: _currentStep,
//                           onStepContinue: () {
//                             if (_currentStep < buildSteps().length - 1) {
//                               setState(() => _currentStep += 1);
//                             } else {
//                               _handleSubmit();
//                             }
//                           },
//                           onStepCancel: () {
//                             if (_currentStep > 0) {
//                               setState(() => _currentStep -= 1);
//                             }
//                           },
//                           steps: buildSteps(),
//                           elevation: 0,
//                           controlsBuilder: (context, controls) =>
//                               _buildControls(controls),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//               if (error.isNotEmpty) _buildErrorMessage(),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildControls(ControlsDetails controls) {
//     return Container(
//       margin: const EdgeInsets.only(top: 24),
//       padding: const EdgeInsets.symmetric(horizontal: 16),
//       child: Row(
//         children: [
//           Expanded(
//             child: ElevatedButton(
//               onPressed: _isLoading ? null : controls.onStepContinue,
//               style: ElevatedButton.styleFrom(
//                 padding: const EdgeInsets.symmetric(vertical: 16),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//               ),
//               child: _isLoading
//                   ? const SizedBox(
//                 height: 20,
//                 width: 20,
//                 child: CircularProgressIndicator(
//                   strokeWidth: 2,
//                   valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                 ),
//               )
//                   : Text(
//                 _currentStep == buildSteps().length - 1
//                     ? 'Create Account'
//                     : 'Continue',
//               ),
//             ),
//           ),
//           if (_currentStep > 0) ...[
//             const SizedBox(width: 12),
//             Expanded(
//               child: OutlinedButton(
//                 onPressed: controls.onStepCancel,
//                 style: OutlinedButton.styleFrom(
//                   padding: const EdgeInsets.symmetric(vertical: 16),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   side: const BorderSide(color: AppColors.primaryGreen),
//                   foregroundColor: AppColors.primaryGreen,
//                 ),
//                 child: const Text(
//                   'Back',
//                   style: TextStyle(
//                     fontWeight: FontWeight.w500,
//                     color: AppColors.primaryGreen,
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ],
//       ),
//     );
//   }
//
//   Widget _buildErrorMessage() {
//     return Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: Container(
//         padding: const EdgeInsets.all(12),
//         decoration: BoxDecoration(
//           color: Theme.of(context).colorScheme.error.withOpacity(0.1),
//           borderRadius: BorderRadius.circular(8),
//         ),
//         child: Row(
//           children: [
//             Icon(
//               Icons.error_outline,
//               color: Theme.of(context).colorScheme.error,
//             ),
//             const SizedBox(width: 8),
//             Expanded(
//               child: Text(
//                 error,
//                 style: TextStyle(
//                   color: Theme.of(context).colorScheme.error,
//                   fontSize: 14.0,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
