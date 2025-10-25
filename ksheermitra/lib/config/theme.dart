import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Ksheermitra Premium Design System
/// Complete theme configuration with colors, gradients, typography, and component styles

class AppTheme {
  // ==================== COLOR PALETTE ====================

  // Primary Brand Colors - Fresh Milk & Nature
  static const Color primaryColor = Color(0xFF2E7D32); // Deep Forest Green
  static const Color primaryLight = Color(0xFF60AD5E); // Light Green
  static const Color primaryDark = Color(0xFF005005); // Dark Green

  // Secondary - Creamy Accent
  static const Color secondaryColor = Color(0xFFFFA726); // Warm Orange
  static const Color secondaryLight = Color(0xFFFFD95B);
  static const Color secondaryDark = Color(0xFFC77800);

  // Background Colors
  static const Color backgroundColor = Color(0xFFF8F9FA); // Soft off-white
  static const Color surfaceColor = Color(0xFFFFFFFF); // Pure white
  static const Color cardColor = Color(0xFFFFFFFF); // White cards

  // Status Colors
  static const Color successGreen = Color(0xFF4CAF50);
  static const Color warningOrange = Color(0xFFFF9800);
  static const Color errorRed = Color(0xFFF44336);
  static const Color infoBlue = Color(0xFF2196F3);

  // Text Colors
  static const Color textPrimary = Color(0xFF1A1A1A); // Almost black
  static const Color textSecondary = Color(0xFF666666); // Medium grey
  static const Color textTertiary = Color(0xFF999999); // Light grey
  static const Color textOnPrimary = Color(0xFFFFFFFF); // White on colored backgrounds

  // ==================== GRADIENTS ====================

  // Main App Background Gradient
  static const LinearGradient mainBackground = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFAFAFA),
      Color(0xFFF0F4F0), // Very light green tint
    ],
  );

  // Product Card Gradient
  static const LinearGradient productCardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFFFFFF),
      Color(0xFFF8FBF8), // Subtle green tint
    ],
  );

  // Premium Subscription Card Gradient
  static const LinearGradient premiumCardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF2E7D32), // Deep green
      Color(0xFF1B5E20), // Darker green
    ],
  );

  // Status Badge Gradients
  static const LinearGradient activeGradient = LinearGradient(
    colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
  );

  static const LinearGradient pendingGradient = LinearGradient(
    colors: [Color(0xFFFF9800), Color(0xFFFFB74D)],
  );

  static const LinearGradient deliveredGradient = LinearGradient(
    colors: [Color(0xFF2E7D32), Color(0xFF43A047)],
  );

  // Button Gradients
  static const LinearGradient primaryButtonGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      Color(0xFF2E7D32), // Deep green
      Color(0xFF388E3C), // Medium green
    ],
  );

  static const LinearGradient secondaryButtonGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      Color(0xFFFFA726), // Warm orange
      Color(0xFFFB8C00), // Deep orange
    ],
  );

  static const LinearGradient dangerButtonGradient = LinearGradient(
    colors: [Color(0xFFF44336), Color(0xFFE53935)],
  );

  // Header Gradients
  static const LinearGradient appBarGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF2E7D32),
      Color(0xFF1B5E20),
    ],
  );

  static const LinearGradient dashboardHeaderGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF2E7D32),
      Color(0xFF4CAF50),
      Color(0xFFF8F9FA), // Fades to background
    ],
    stops: [0.0, 0.6, 1.0],
  );

  // ==================== TYPOGRAPHY ====================

  // Heading Styles
  static const TextStyle h1 = TextStyle(
    fontSize: 32.0,
    fontWeight: FontWeight.bold, // 700
    color: textPrimary,
    letterSpacing: -0.5,
    height: 1.2,
  );

  static const TextStyle h2 = TextStyle(
    fontSize: 24.0,
    fontWeight: FontWeight.bold, // 700
    color: textPrimary,
    letterSpacing: -0.3,
    height: 1.3,
  );

  static const TextStyle h3 = TextStyle(
    fontSize: 20.0,
    fontWeight: FontWeight.w600, // SemiBold
    color: textPrimary,
    letterSpacing: -0.2,
    height: 1.4,
  );

  static const TextStyle h4 = TextStyle(
    fontSize: 18.0,
    fontWeight: FontWeight.w600,
    color: textPrimary,
    letterSpacing: 0.0,
    height: 1.4,
  );

  static const TextStyle h5 = TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.w600,
    color: textPrimary,
    letterSpacing: 0.1,
    height: 1.5,
  );

  // Body Text Styles
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.w400, // Regular
    color: textPrimary,
    letterSpacing: 0.1,
    height: 1.6,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14.0,
    fontWeight: FontWeight.w400,
    color: textSecondary,
    letterSpacing: 0.1,
    height: 1.5,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12.0,
    fontWeight: FontWeight.w400,
    color: textTertiary,
    letterSpacing: 0.2,
    height: 1.4,
  );

  // Special Text Styles
  static const TextStyle priceText = TextStyle(
    fontSize: 20.0,
    fontWeight: FontWeight.w700,
    color: primaryColor,
    letterSpacing: 0.0,
  );

  static const TextStyle buttonText = TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    letterSpacing: 0.5,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 11.0,
    fontWeight: FontWeight.w400,
    color: textTertiary,
    letterSpacing: 0.3,
    height: 1.3,
  );

  static const TextStyle labelText = TextStyle(
    fontSize: 13.0,
    fontWeight: FontWeight.w500,
    color: textSecondary,
    letterSpacing: 0.2,
  );

  // ==================== SPACING SYSTEM ====================
  static const double space4 = 4.0;
  static const double space8 = 8.0;
  static const double space12 = 12.0;
  static const double space16 = 16.0;
  static const double space20 = 20.0;
  static const double space24 = 24.0;
  static const double space32 = 32.0;
  static const double space48 = 48.0;
  static const double space64 = 64.0;

  // ==================== BORDER RADIUS ====================
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 20.0;
  static const double radiusPill = 24.0;

  // ==================== SHADOWS ====================
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: const Color(0xFF000000).withValues(alpha: 0.06),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get premiumCardShadow => [
    BoxShadow(
      color: primaryColor.withValues(alpha: 0.3),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> get buttonShadow => [
    BoxShadow(
      color: primaryColor.withValues(alpha: 0.4),
      blurRadius: 12,
      offset: const Offset(0, 6),
    ),
  ];

  static List<BoxShadow> productCardShadow(Color color) => [
    BoxShadow(
      color: color.withValues(alpha: 0.08),
      blurRadius: 20,
      offset: const Offset(0, 4),
    ),
  ];

  // ==================== COMPLETE THEME ====================
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      fontFamily: GoogleFonts.poppins().fontFamily,

      colorScheme: const ColorScheme(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: surfaceColor,
        error: errorRed,
        onPrimary: textOnPrimary,
        onSecondary: textOnPrimary,
        onSurface: textPrimary,
        onError: textOnPrimary,
        brightness: Brightness.light,
      ),
      
      textTheme: GoogleFonts.poppinsTextTheme(
        const TextTheme(
          displayLarge: h1,
          displayMedium: h2,
          displaySmall: h3,
          headlineMedium: h4,
          headlineSmall: h5,
          bodyLarge: bodyLarge,
          bodyMedium: bodyMedium,
          bodySmall: bodySmall,
          labelLarge: buttonText,
          labelMedium: labelText,
          labelSmall: caption,
        ),
      ),
      
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: textOnPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          elevation: 4,
          shadowColor: primaryColor.withValues(alpha: 0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
          ),
          textStyle: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          side: const BorderSide(color: primaryColor, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
          ),
          textStyle: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: primaryColor,
            letterSpacing: 0.5,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: primaryColor,
          ),
        ),
      ),

      cardTheme: CardThemeData(
        elevation: 4,
        color: cardColor,
        shadowColor: const Color(0xFF000000).withValues(alpha: 0.06),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLarge),
        ),
        margin: const EdgeInsets.all(space8),
      ),

      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: primaryColor,
        foregroundColor: textOnPrimary,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textOnPrimary,
          letterSpacing: 0.15,
        ),
      ),

      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surfaceColor,
        selectedItemColor: primaryColor,
        unselectedItemColor: textTertiary,
        selectedLabelStyle: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.w400,
        ),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF8F9FA),
        hintStyle: GoogleFonts.poppins(
          color: textTertiary,
          fontSize: 14,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: errorRed, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: errorRed, width: 2),
        ),
        labelStyle: labelText,
      ),

      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: textOnPrimary,
        elevation: 6,
      ),

      dividerTheme: DividerThemeData(
        color: textTertiary.withValues(alpha: 0.2),
        thickness: 1,
        space: space16,
      ),

      chipTheme: ChipThemeData(
        backgroundColor: backgroundColor,
        selectedColor: primaryLight,
        labelStyle: bodySmall,
        padding: const EdgeInsets.symmetric(horizontal: space12, vertical: space8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusPill),
        ),
      ),
    );
  }
}

// ==================== PREMIUM COMPONENTS ====================

/// Extension methods for easy access to theme properties
extension BuildContextThemeExtension on BuildContext {
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => Theme.of(this).textTheme;
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
}
