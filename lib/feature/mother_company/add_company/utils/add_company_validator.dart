class AddCompanyValidator {
  static String? validateMobile(String? value) {
    if (value == null || value.isEmpty) {
      return "Mobile number required";
    }

    if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) {
      return "Enter valid mobile number";
    }

    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return "Password required";
    }

    if (value.length < 6) {
      return "Minimum 6 characters";
    }

    // if (!RegExp(r'[A-Z]')
    //     .hasMatch(value)) {
    //   return "One uppercase required";
    // }

    // if (!RegExp(r'[a-z]')
    //     .hasMatch(value)) {
    //   return "One lowercase required";
    // }

    // if (!RegExp(r'[0-9]')
    //     .hasMatch(value)) {
    //   return "One number required";
    // }

    // if (!RegExp(r'[!@#\$&*~]')
    //     .hasMatch(value)) {
    //   return "One special character required";
    // }

    return null;
  }

  static String? validateConfirmPassword({
    required String password,
    required String confirmPassword,
  }) {
    if (password != confirmPassword) {
      return "Passwords do not match";
    }

    return null;
  }

  static String? validateCompanyName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Company name is required";
    }
    return null;
  }

  static String? validateDomain(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Domain is required";
    }
    final domainRegex = RegExp(r'^([a-zA-Z0-9-]+\.)+[a-zA-Z]{2,}$');
    if (!domainRegex.hasMatch(value.trim())) {
      return "Enter a valid domain (e.g. acme.com)";
    }
    return null;
  }

  static String? validateIndustry(String? value) {
    if (value == null || value.isEmpty) {
      return "Select an industry sector";
    }
    return null;
  }

  static String? validateAdminName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Administrator name is required";
    }
    return null;
  }

  static String? validateAdminEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Email is required";
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return "Enter a valid email address";
    }
    return null;
  }
}
