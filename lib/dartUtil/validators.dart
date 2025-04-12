import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class Validators {
  // Basic static validators for email and simple password check
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Email is required.";
    }
    final emailRegex =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return "Please enter a valid email.";
    }
    return null;
  }

  static String? validatePasswordSimple(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Password is required.";
    }
    return null;
  }

  // Full password validation for registration
  static String? validatePassword(String? value, BuildContext? context) {
    final l10n = context != null ? AppLocalizations.of(context) : null;

    if (value == null || value.trim().isEmpty) {
      return l10n?.passwordRequired ?? "Password is required.";
    }

    // Check minimum length
    if (value.length < 8) {
      return l10n?.passwordTooShort ??
          "Password must be at least 8 characters.";
    }

    // Check for at least one number
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return l10n?.passwordRequiresNumber ??
          "Password must contain at least one number.";
    }

    // Check for at least one uppercase letter
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return l10n?.passwordRequiresUppercase ??
          "Password must contain at least one uppercase letter.";
    }

    // Check for at least one special character
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
      return l10n?.passwordRequiresSpecial ??
          "Password must contain at least one special character.";
    }

    return null;
  }

  // Factory method to create localized validators
  static LocalizedValidators of(BuildContext context) {
    return LocalizedValidators(context);
  }
}

/// Localized validators that use the current app locale
class LocalizedValidators {
  final BuildContext context;

  LocalizedValidators(this.context);

  String? validateEmail(String? value) {
    final l10n = AppLocalizations.of(context);

    if (value == null || value.trim().isEmpty) {
      return l10n?.emailRequired ?? "Email is required.";
    }

    final emailRegex =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return l10n?.invalidEmail ?? "Please enter a valid email.";
    }

    return null;
  }

  // Simple password validator for login screen
  String? validatePasswordSimple(String? value) {
    final l10n = AppLocalizations.of(context);

    if (value == null || value.trim().isEmpty) {
      return l10n?.passwordRequired ?? "Password is required.";
    }

    return null;
  }

  // Full password validator for registration
  String? validatePassword(String? value) {
    final l10n = AppLocalizations.of(context);

    if (value == null || value.trim().isEmpty) {
      return l10n?.passwordRequired ?? "Password is required.";
    }

    // Check minimum length
    if (value.length < 8) {
      return l10n?.passwordTooShort ??
          "Password must be at least 8 characters.";
    }

    // Check for at least one number
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return l10n?.passwordRequiresNumber ??
          "Password must contain at least one number.";
    }

    // Check for at least one uppercase letter
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return l10n?.passwordRequiresUppercase ??
          "Password must contain at least one uppercase letter.";
    }

    // Check for at least one special character
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
      return l10n?.passwordRequiresSpecial ??
          "Password must contain at least one special character.";
    }

    return null;
  }

  String? validateName(String? value) {
    final l10n = AppLocalizations.of(context);

    if (value == null || value.trim().isEmpty) {
      return l10n?.nameRequired ?? "Name is required.";
    }

    return null;
  }

  String? validateConfirmPassword(String? value, String password) {
    final l10n = AppLocalizations.of(context);

    if (value == null || value.trim().isEmpty) {
      return l10n?.confirmPasswordRequired ?? "Confirm Password is required.";
    }

    if (value.trim() != password.trim()) {
      return l10n?.passwordsDoNotMatch ?? "Passwords do not match.";
    }

    return null;
  }
}
