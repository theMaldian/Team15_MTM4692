import 'package:flutter/material.dart';

/// YTU institutional color palette. Modern minimal aesthetic.
class AppColors {
  AppColors._();

  // Primary — YTU Navy
  static const Color primary = Color(0xFF002D62); // YTU navy
  static const Color primaryDark = Color(0xFF001B3D);
  static const Color primaryLight = Color(0xFF1E4A8C);

  // Secondary — YTU Yellow/Gold
  static const Color secondary = Color(0xFFFFC72C); // YTU gold
  static const Color secondaryDark = Color(0xFFE0A800);

  // Neutrals
  static const Color background = Color(0xFFFAFAFA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceAlt = Color(0xFFF4F6F8);
  static const Color border = Color(0xFFE5E7EB);

  // Text
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Status
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Status pills (for application status: pending/approved/rejected)
  static const Color statusPending = Color(0xFFF59E0B);
  static const Color statusApproved = Color(0xFF10B981);
  static const Color statusRejected = Color(0xFFEF4444);
}
