class InputValidators {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+',
    );
    if (!emailRegex.hasMatch(value)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Password must contain at least one lowercase letter';
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Password must contain at least one number';
    }
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
      return 'Password must contain at least one special character';
    }
    return null;
  }

  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != password) {
      return 'Passwords do not match';
    }
    return null;
  }

  static String? validateKraPin(String? value) {
    if (value == null || value.isEmpty) {
      return 'KRA PIN is required';
    }
    final kraRegex = RegExp(r'^[A-Z][0-9]{9}[A-Z]$');
    if (!kraRegex.hasMatch(value)) {
      return 'Enter a valid KRA PIN (Format: A123456789B)';
    }
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    final phoneRegex = RegExp(r'^\+254[17][0-9]{8}$');
    if (!phoneRegex.hasMatch(value)) {
      return 'Enter a valid Kenyan phone number (+254XXXXXXXXX)';
    }
    return null;
  }

  static String? validateIdNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'ID number is required';
    }
    final idRegex = RegExp(r'^[0-9]{8}$');
    if (!idRegex.hasMatch(value)) {
      return 'Enter a valid 8-digit ID number';
    }
    return null;
  }

  static String? validateFullName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Full name is required';
    }
    if (value.length < 3) {
      return 'Name must be at least 3 characters';
    }
    final nameRegex = RegExp(r'^[a-zA-Z\s]{3,50}$');
    if (!nameRegex.hasMatch(value)) {
      return 'Enter a valid name (letters only)';
    }
    return null;
  }

  static String? validateAddress(String? value) {
    if (value == null || value.isEmpty) {
      return 'Address is required';
    }
    if (value.length < 5) {
      return 'Address must be at least 5 characters';
    }
    final addressRegex = RegExp(r'^[a-zA-Z0-9\s,.-]{5,100}$');
    if (!addressRegex.hasMatch(value)) {
      return 'Enter a valid address';
    }
    return null;
  }

  static String? validateCompanyName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Company name is required';
    }
    if (value.length < 3) {
      return 'Company name must be at least 3 characters';
    }
    final companyRegex = RegExp(r'^[a-zA-Z0-9\s&.-]{3,50}$');
    if (!companyRegex.hasMatch(value)) {
      return 'Enter a valid company name';
    }
    return null;
  }

  static String? validateLicenseNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'License number is required';
    }
    final licenseRegex = RegExp(r'^[A-Z0-9]{6,15}$');
    if (!licenseRegex.hasMatch(value)) {
      return 'Enter a valid license number';
    }
    return null;
  }

  static String? validateAdminCode(String? value) {
    if (value == null || value.isEmpty) {
      return 'Admin access code is required';
    }
    if (value.length < 8) {
      return 'Admin code must be at least 8 characters';
    }
    return null;
  }

  static String? validateEmployeeId(String? value) {
    if (value == null || value.isEmpty) {
      return 'Employee ID is required';
    }
    final employeeIdRegex = RegExp(r'^EMP[0-9]{6}$');
    if (!employeeIdRegex.hasMatch(value)) {
      return 'Enter a valid Employee ID (Format: EMPXXXXXX)';
    }
    return null;
  }
}