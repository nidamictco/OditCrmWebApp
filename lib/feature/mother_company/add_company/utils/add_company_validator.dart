class AddCompanyValidator {
  static String? validateMobile(
      String? value,
      ) {
    if (value == null || value.isEmpty) {
      return "Mobile number required";
    }

    if (!RegExp(r'^[0-9]{10}$')
        .hasMatch(value)) {
      return "Enter valid mobile number";
    }

    return null;
  }

  static String? validatePassword(
      String? value,
      ) {
    if (value == null || value.isEmpty) {
      return "Password required";
    }

    if (value.length < 8) {
      return "Minimum 8 characters";
    }

    if (!RegExp(r'[A-Z]')
        .hasMatch(value)) {
      return "One uppercase required";
    }

    if (!RegExp(r'[a-z]')
        .hasMatch(value)) {
      return "One lowercase required";
    }

    if (!RegExp(r'[0-9]')
        .hasMatch(value)) {
      return "One number required";
    }

    if (!RegExp(r'[!@#\$&*~]')
        .hasMatch(value)) {
      return "One special character required";
    }

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
}