import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Ksheermitra Premium Design System
/// Complete theme configuration with colors, gradients, typography, and component styles

class AppTheme {
  // ==================== COLOR PALETTE ====================

  // Primary Brand Colors - Blue Theme
  static const Color primaryColor = Color(0xFF2196F3); // Bright Blue
  static const Color primaryLight = Color(0xFF64B5F6); // Light Blue
  static const Color primaryDark = Color(0xFF1976D2); // Dark Blue

  // Secondary - Accent Blue
  static const Color secondaryColor = Color(0xFF42A5F5); // Medium Blue
  static const Color secondaryLight = Color(0xFF90CAF9);
  static const Color secondaryDark = Color(0xFF1565C0);

  // Background Colors - Light Theme
  static const Color backgroundColor = Color(0xFFF5F9FF); // Very light blue tint
  static const Color surfaceColor = Color(0xFFFFFFFF); // Pure white
  static const Color cardColor = Color(0xFFFFFFFF); // White cards

  // Dark Theme Colors
  static const Color darkBackgroundColor = Color(0xFF0A1929); // Very dark blue (almost black)
  static const Color darkSurfaceColor = Color(0xFF1A2332); // Dark blue-gray
  static const Color darkCardColor = Color(0xFF1E2A3A); // Slightly lighter dark blue

  // Status Colors
  static const Color successGreen = Color(0xFF4CAF50);
  static const Color warningOrange = Color(0xFFFF9800);
  static const Color errorRed = Color(0xFFF44336);
  static const Color infoBlue = Color(0xFF2196F3);

  // Text Colors - Light Theme
  static const Color textPrimary = Color(0xFF1A1A1A); // Almost black
  static const Color textSecondary = Color(0xFF666666); // Medium grey
  static const Color textTertiary = Color(0xFF999999); // Light grey
  static const Color textOnPrimary = Color(0xFFFFFFFF); // White on colored backgrounds

  // Text Colors - Dark Theme
  static const Color darkTextPrimary = Color(0xFFE1E9F5); // Light blue-white
  static const Color darkTextSecondary = Color(0xFFB0BEC5); // Medium blue-grey
  static const Color darkTextTertiary = Color(0xFF78909C); // Darker blue-grey

  // ==================== GRADIENTS ====================

  // Main App Background Gradient - Light Theme (Blue-White)
  static const LinearGradient mainBackground = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFE3F2FD), // Very light blue
      Color(0xFFFFFFFF), // White
      Color(0xFFF5F9FF), // Slight blue tint
    ],
    stops: [0.0, 0.5, 1.0],
  );

  // Main App Background Gradient - Dark Theme (Dark Blue-Blackish Blue)
  static const LinearGradient darkMainBackground = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF0A1929), // Very dark blue (almost black)
      Color(0xFF0D2137), // Dark blue
      Color(0xFF0E1621), // Blackish blue
    ],
    stops: [0.0, 0.5, 1.0],
  );

  // Product Card Gradient - Light
  static const LinearGradient productCardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFFFFFF),
      Color(0xFFF0F7FF), // Subtle blue tint
    ],
  );

  // Product Card Gradient - Dark
  static const LinearGradient darkProductCardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF1E2A3A),
      Color(0xFF2A3647),
    ],
  );

  // Premium Subscription Card Gradient - Light
  static const LinearGradient premiumCardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF2196F3), // Bright blue
      Color(0xFF1976D2), // Dark blue
    ],
  );

  // Premium Subscription Card Gradient - Dark
  static const LinearGradient darkPremiumCardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF1565C0), // Deep blue
      Color(0xFF0D47A1), // Darker blue
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
    colors: [Color(0xFF2196F3), Color(0xFF42A5F5)],
  );

  // Button Gradients - Light
  static const LinearGradient primaryButtonGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      Color(0xFF2196F3), // Bright blue
      Color(0xFF1E88E5), // Medium blue
    ],
  );

  static const LinearGradient secondaryButtonGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      Color(0xFF42A5F5), // Light blue
      Color(0xFF1976D2), // Dark blue
    ],
  );

  // Button Gradients - Dark
  static const LinearGradient darkPrimaryButtonGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      Color(0xFF1976D2), // Dark blue
      Color(0xFF1565C0), // Deeper blue
    ],
  );

  static const LinearGradient dangerButtonGradient = LinearGradient(
    colors: [Color(0xFFF44336), Color(0xFFE53935)],
  );

  // Header Gradients - Light
  static const LinearGradient appBarGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF2196F3),
      Color(0xFF1976D2),
    ],
  );

  // Header Gradients - Dark
  static const LinearGradient darkAppBarGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF1565C0),
      Color(0xFF0D47A1),
    ],
  );

  static const LinearGradient dashboardHeaderGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF2196F3),
      Color(0xFF64B5F6),
      Color(0xFFF5F9FF), // Fades to background
    ],
    stops: [0.0, 0.6, 1.0],
  );

  // Dark Dashboard Header
  static const LinearGradient darkDashboardHeaderGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF1565C0),
      Color(0xFF1976D2),
      Color(0xFF0A1929), // Fades to dark background
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

  // ==================== DARK THEME ====================
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      primaryColor: primaryLight,
      scaffoldBackgroundColor: darkBackgroundColor,
      fontFamily: GoogleFonts.poppins().fontFamily,

      colorScheme: const ColorScheme(
        primary: primaryLight,
        secondary: secondaryLight,
        surface: darkSurfaceColor,
        error: errorRed,
        onPrimary: darkTextPrimary,
        onSecondary: darkTextPrimary,
        onSurface: darkTextPrimary,
        onError: textOnPrimary,
        brightness: Brightness.dark,
      ),

      textTheme: GoogleFonts.poppinsTextTheme(
        TextTheme(
          displayLarge: h1.copyWith(color: darkTextPrimary),
          displayMedium: h2.copyWith(color: darkTextPrimary),
          displaySmall: h3.copyWith(color: darkTextPrimary),
          headlineMedium: h4.copyWith(color: darkTextPrimary),
          headlineSmall: h5.copyWith(color: darkTextPrimary),
          bodyLarge: bodyLarge.copyWith(color: darkTextPrimary),
          bodyMedium: bodyMedium.copyWith(color: darkTextSecondary),
          bodySmall: bodySmall.copyWith(color: darkTextTertiary),
          labelLarge: buttonText.copyWith(color: darkTextPrimary),
          labelMedium: labelText.copyWith(color: darkTextSecondary),
          labelSmall: caption.copyWith(color: darkTextTertiary),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryLight,
          foregroundColor: darkBackgroundColor,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          elevation: 4,
          shadowColor: primaryLight.withValues(alpha: 0.4),
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
          foregroundColor: primaryLight,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          side: const BorderSide(color: primaryLight, width: 2),
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

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryLight,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      cardTheme: CardThemeData(
        elevation: 4,
        color: darkCardColor,
        shadowColor: const Color(0xFF000000).withValues(alpha: 0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLarge),
        ),
        margin: const EdgeInsets.all(space8),
      ),

      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: darkSurfaceColor,
        foregroundColor: darkTextPrimary,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: darkTextPrimary,
          letterSpacing: 0.15,
        ),
      ),

      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: darkSurfaceColor,
        selectedItemColor: primaryLight,
        unselectedItemColor: darkTextTertiary,
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
        fillColor: darkSurfaceColor,
        hintStyle: GoogleFonts.poppins(
          color: darkTextTertiary,
          fontSize: 14,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: BorderSide(color: darkTextTertiary.withValues(alpha: 0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: BorderSide(color: darkTextTertiary.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: primaryLight, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: errorRed, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: errorRed, width: 2),
        ),
        labelStyle: labelText.copyWith(color: darkTextSecondary),
      ),

      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryLight,
        foregroundColor: darkBackgroundColor,
        elevation: 6,
      ),

      dividerTheme: DividerThemeData(
        color: darkTextTertiary.withValues(alpha: 0.2),
        thickness: 1,
        space: space16,
      ),

      chipTheme: ChipThemeData(
        backgroundColor: darkSurfaceColor,
        selectedColor: primaryLight,
        labelStyle: bodySmall.copyWith(color: darkTextPrimary),
        padding: const EdgeInsets.symmetric(horizontal: space12, vertical: space8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusPill),
        ),
      ),
    );
  }
}

/// Extension methods for easy access to theme properties
extension BuildContextThemeExtension on BuildContext {
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => Theme.of(this).textTheme;
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
}
