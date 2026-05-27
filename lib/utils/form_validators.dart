import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';

String? validateRequired(BuildContext context, String? value) {
  if (value == null || value.trim().isEmpty) {
    return tr('validation.required');
  }
  return null;
}

String? validateEmail(BuildContext context, String? value) {
  final required = validateRequired(context, value);
  if (required != null) return required;
  final email = value!.trim();
  final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  if (!emailRegex.hasMatch(email)) {
    return tr('validation.email');
  }
  return null;
}

String? validatePassword(BuildContext context, String? value) {
  final required = validateRequired(context, value);
  if (required != null) return required;
  if (value!.length < 6) {
    return tr('validation.passwordMin');
  }
  return null;
}

String? validateNif(BuildContext context, String? value) {
  final required = validateRequired(context, value);
  if (required != null) return required;
  final digits = value!.replaceAll(RegExp(r'\D'), '');
  if (!RegExp(r'^\d{9}$').hasMatch(digits)) {
    return tr('validation.nif');
  }
  return null;
}

String? validatePhone(BuildContext context, String? value) {
  final required = validateRequired(context, value);
  if (required != null) return required;
  final digits = value!.replaceAll(RegExp(r'\D'), '');
  if (!RegExp(r'^\d{9}$').hasMatch(digits)) {
    return tr('validation.phone');
  }
  return null;
}

String? validatePlate(BuildContext context, String? value) {
  final required = validateRequired(context, value);
  if (required != null) return required;
  final normalized = value!.trim().toUpperCase().replaceAll(' ', '');
  if (!RegExp(r'^[A-Z0-9]{2}-[A-Z0-9]{2}-[A-Z0-9]{2}$').hasMatch(normalized)) {
    return tr('validation.plate');
  }
  return null;
}

String? validateYear(BuildContext context, String? value) {
  final required = validateRequired(context, value);
  if (required != null) return required;
  final year = int.tryParse(value!.trim());
  final currentYear = DateTime.now().year + 1;
  if (year == null || year < 1980 || year > currentYear) {
    return tr('validation.year');
  }
  return null;
}

String normalizePlate(String value) {
  final cleaned = value.trim().toUpperCase().replaceAll(' ', '');
  if (RegExp(r'^[A-Z0-9]{2}-[A-Z0-9]{2}-[A-Z0-9]{2}$').hasMatch(cleaned)) {
    return cleaned;
  }
  final compact = cleaned.replaceAll('-', '');
  if (compact.length == 6) {
    return '${compact.substring(0, 2)}-${compact.substring(2, 4)}-${compact.substring(4, 6)}';
  }
  return cleaned;
}
