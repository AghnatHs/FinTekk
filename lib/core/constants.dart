import 'package:flutter/material.dart';

class ColorConst {
  static const Color primaryGreen = Color(0xFF2E7D32);
  static const Color primaryGreenLight = Color(0xFF4CAF50);
  static const Color primaryGreenDark = Color(0xFF1B5E20);

  static const Color gradientStart = Color(0xFF1B5E20);
  static const Color gradientMiddle = Color(0xFF2E7D32);
  static const Color gradientEnd = Color(0xFF4CAF50);

  static const Color accentBlue = Color(0xFF1976D2);
  static const Color accentOrange = Color(0xFFFF8F00);
  static const Color accentPurple = Color(0xFF7B1FA2);

  static const Color incomeGreen = Color(0xFF2E7D32);
  static const Color expenseRed = Color(0xFFD32F2F);
  static const Color neutralGray = Color(0xFF757575);
  static const Color balanceBlue = Color(0xFF1565C0);

  static const Color surfaceLight = Color(0xFFFAFAFA);
  static const Color surfaceDark = Color(0xFF303030);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color cardBackgroundDark = Color(0xFF424242);

  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  static const Color defaultAppColor = primaryGreen;
}

class DatabaseConst {
  static const List<String> defaultCategories = ['Needs', 'Fun', 'Transfer'];
  static const List<String> defaultAccounts = ['Primary', 'Savings'];
}

class TransactionConst {
  static const String income = 'Income';
  static const String expense = 'Expense';
}

class UIConst {
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXL = 32.0;
  static const double spacingXXL = 48.0;

  static const double radiusS = 8.0;
  static const double radiusM = 12.0;
  static const double radiusL = 16.0;
  static const double radiusXL = 20.0;

  static const double elevationLow = 2.0;
  static const double elevationMedium = 4.0;
  static const double elevationHigh = 8.0;
  static const double elevationVeryHigh = 16.0;
}
