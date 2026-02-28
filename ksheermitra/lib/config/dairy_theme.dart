import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// KsheerMitra Premium Dairy Design System
/// Modern, Fresh, Clean Dairy Product App Theme
/// Inspired by Instacart-style freshness and Material 3 guidelines
///
/// Primary Brand: Fresh Dairy Green (#0AAD05)
/// Secondary Accent: Warm Energy Orange (#FF7009)

// ============================================================================
// COLOR TOKENS - Light Mode
// ============================================================================

class DairyColorsLight {
  DairyColorsLight._();

  // Primary Brand Colors - Fresh Dairy Green
  static const Color primary = Color(0xFF0AAD05);
  static const Color primaryLight = Color(0xFF4DD849);
  static const Color primaryDark = Color(0xFF088A04);
  static const Color primarySurface = Color(0xFFE8F8E8);

  // Secondary Accent - Warm Energy Orange (CTA highlights)
  static const Color secondary = Color(0xFFFF7009);
  static const Color secondaryLight = Color(0xFFFF9A4D);
  static const Color secondaryDark = Color(0xFFE56300);
  static const Color secondarySurface = Color(0xFFFFF4ED);

  // Background & Surface
  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFF8F9FA);
  static const Color surfaceVariant = Color(0xFFF1F3F5);
  static const Color card = Color(0xFFFFFFFF);
  static const Color cardHover = Color(0xFFF8F9FA);

  // Text Colors (with opacity feel)
  static const Color textPrimary = Color(0xFF111111);      // 87% opacity feel
  static const Color textSecondary = Color(0xFF6B7280);    // 60% opacity
  static const Color textTertiary = Color(0xFF9CA3AF);     // 40% opacity
  static const Color textDisabled = Color(0xFFBDBDBD);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textOnSecondary = Color(0xFFFFFFFF);

  // Border & Divider
  static const Color border = Color(0xFFE5E7EB);
  static const Color borderLight = Color(0xFFF3F4F6);
  static const Color divider = Color(0xFFE5E7EB);

  // Status Colors
  static const Color success = Color(0xFF22C55E);
  static const Color successSurface = Color(0xFFDCFCE7);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningSurface = Color(0xFFFEF3C7);
  static const Color error = Color(0xFFEF4444);
  static const Color errorSurface = Color(0xFFFEE2E2);
  static const Color info = Color(0xFF3B82F6);
  static const Color infoSurface = Color(0xFFDBEAFE);

  // Shadows for Light Mode
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: const Color(0xFF000000).withOpacity(0.04),
      blurRadius: 8,
      offset: const Offset(0, 2),
      spreadRadius: 0,
    ),
    BoxShadow(
      color: const Color(0xFF000000).withOpacity(0.02),
      blurRadius: 4,
      offset: const Offset(0, 1),
      spreadRadius: 0,
    ),
  ];

  static List<BoxShadow> get elevatedShadow => [
    BoxShadow(
      color: const Color(0xFF000000).withOpacity(0.08),
      blurRadius: 16,
      offset: const Offset(0, 4),
      spreadRadius: 0,
    ),
    BoxShadow(
      color: const Color(0xFF000000).withOpacity(0.04),
      blurRadius: 6,
      offset: const Offset(0, 2),
      spreadRadius: 0,
    ),
  ];

  static List<BoxShadow> get buttonShadow => [
    BoxShadow(
      color: primary.withOpacity(0.3),
      blurRadius: 8,
      offset: const Offset(0, 4),
      spreadRadius: 0,
    ),
  ];
}

// ============================================================================
// COLOR TOKENS - Dark Mode
// ============================================================================

class DairyColorsDark {
  DairyColorsDark._();

  // Primary Brand Colors - Fresh Dairy Green
  static const Color primary = Color(0xFF0AAD05);
  static const Color primaryLight = Color(0xFF4DD849);
  static const Color primaryDark = Color(0xFF088A04);
  static const Color primarySurface = Color(0xFF1A2E1A);

  // Secondary Accent - Warm Energy Orange
  static const Color secondary = Color(0xFFFF7009);
  static const Color secondaryLight = Color(0xFFFF9A4D);
  static const Color secondaryDark = Color(0xFFE56300);
  static const Color secondarySurface = Color(0xFF2E1F17);

  // Background & Surface
  static const Color background = Color(0xFF121212);
  static const Color surface = Color(0xFF1E1E1E);
  static const Color surfaceVariant = Color(0xFF2C2C2C);
  static const Color card = Color(0xFF1E1E1E);
  static const Color cardHover = Color(0xFF2C2C2C);

  // Text Colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0B0B0);
  static const Color textTertiary = Color(0xFF808080);
  static const Color textDisabled = Color(0xFF606060);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textOnSecondary = Color(0xFFFFFFFF);

  // Border & Divider
  static const Color border = Color(0xFF2C2C2C);
  static const Color borderLight = Color(0xFF3C3C3C);
  static const Color divider = Color(0xFF2C2C2C);

  // Status Colors
  static const Color success = Color(0xFF4ADE80);
  static const Color successSurface = Color(0xFF1A2E1A);
  static const Color warning = Color(0xFFFBBF24);
  static const Color warningSurface = Color(0xFF2E2617);
  static const Color error = Color(0xFFF87171);
  static const Color errorSurface = Color(0xFF2E1A1A);
  static const Color info = Color(0xFF60A5FA);
  static const Color infoSurface = Color(0xFF1A2438);

  // No heavy shadows in dark mode - use subtle borders instead
  static List<BoxShadow> get cardShadow => [];

  static List<BoxShadow> get elevatedShadow => [
    BoxShadow(
      color: const Color(0xFF000000).withOpacity(0.3),
      blurRadius: 8,
      offset: const Offset(0, 2),
      spreadRadius: 0,
    ),
  ];

  static List<BoxShadow> get buttonShadow => [];
}

// ============================================================================
// SPACING SYSTEM - 8-Point Grid
// ============================================================================

class DairySpacing {
  DairySpacing._();

  /// Extra small spacing (4px)
  static const double xs = 4.0;

  /// Small spacing (8px)
  static const double sm = 8.0;

  /// Medium spacing (16px)
  static const double md = 16.0;

  /// Large spacing (24px)
  static const double lg = 24.0;

  /// Extra large spacing (32px)
  static const double xl = 32.0;

  /// Screen horizontal padding
  static const double screenPaddingH = 16.0;

  /// Screen vertical padding
  static const double screenPaddingV = 24.0;

  /// Card internal padding
  static const double cardPadding = 16.0;

  /// Button vertical padding
  static const double buttonPaddingV = 14.0;

  /// Button horizontal padding
  static const double buttonPaddingH = 24.0;

  /// Section spacing
  static const double sectionSpacing = 24.0;

  /// Element gap inside cards
  static const double cardElementGap = 8.0;

  /// Minimum touch target height
  static const double touchTarget = 48.0;

  // Preset EdgeInsets
  static const EdgeInsets screenPadding = EdgeInsets.symmetric(
    horizontal: screenPaddingH,
    vertical: screenPaddingV,
  );

  static const EdgeInsets cardContentPadding = EdgeInsets.all(cardPadding);

  static const EdgeInsets buttonInternalPadding = EdgeInsets.symmetric(
    vertical: buttonPaddingV,
    horizontal: buttonPaddingH,
  );

  static const EdgeInsets listItemPadding = EdgeInsets.symmetric(
    vertical: sm,
    horizontal: md,
  );
}

// ============================================================================
// BORDER & RADIUS SYSTEM
// ============================================================================

class DairyRadius {
  DairyRadius._();

  /// Small radius (8px) - for chips, tags, small elements
  static const double sm = 8.0;

  /// Default/Medium radius (12px) - for buttons, inputs
  static const double md = 12.0;

  /// Large radius (16px) - for cards
  static const double lg = 16.0;

  /// Extra large radius (20px) - for modals, bottom sheets
  static const double xl = 20.0;

  /// Pill radius (24px) - for pills, badges
  static const double pill = 24.0;

  /// Circle (for avatars, icons)
  static const double circle = 999.0;

  // BorderRadius presets
  static BorderRadius get smallBorderRadius => BorderRadius.circular(sm);
  static BorderRadius get defaultBorderRadius => BorderRadius.circular(md);
  static BorderRadius get largeBorderRadius => BorderRadius.circular(lg);
  static BorderRadius get xlBorderRadius => BorderRadius.circular(xl);
  static BorderRadius get pillBorderRadius => BorderRadius.circular(pill);
}

// ============================================================================
// TYPOGRAPHY SYSTEM
// Clean modern sans-serif (Inter/Roboto)
// ============================================================================

class DairyTypography {
  DairyTypography._();

  // Font family
  static String get fontFamily => GoogleFonts.inter().fontFamily ?? 'Inter';

  // ==================== HEADINGS ====================

  /// Heading Large - 24-28px, Weight: 600-700
  static TextStyle headingLarge({Color? color, bool isDark = false}) {
    return GoogleFonts.inter(
      fontSize: 26.0,
      fontWeight: FontWeight.w700,
      color: color ?? (isDark ? DairyColorsDark.textPrimary : DairyColorsLight.textPrimary),
      height: 1.3,
      letterSpacing: -0.5,
    );
  }

  /// Heading Medium - 20px, Weight: 600
  static TextStyle headingMedium({Color? color, bool isDark = false}) {
    return GoogleFonts.inter(
      fontSize: 20.0,
      fontWeight: FontWeight.w600,
      color: color ?? (isDark ? DairyColorsDark.textPrimary : DairyColorsLight.textPrimary),
      height: 1.4,
      letterSpacing: -0.3,
    );
  }

  /// Heading Small - 18px, Weight: 600
  static TextStyle headingSmall({Color? color, bool isDark = false}) {
    return GoogleFonts.inter(
      fontSize: 18.0,
      fontWeight: FontWeight.w600,
      color: color ?? (isDark ? DairyColorsDark.textPrimary : DairyColorsLight.textPrimary),
      height: 1.4,
      letterSpacing: -0.2,
    );
  }

  // ==================== BODY TEXT ====================

  /// Body Large - 16-17px, Weight: 400-500
  static TextStyle bodyLarge({Color? color, bool isDark = false}) {
    return GoogleFonts.inter(
      fontSize: 16.0,
      fontWeight: FontWeight.w400,
      color: color ?? (isDark ? DairyColorsDark.textPrimary : DairyColorsLight.textPrimary),
      height: 1.5,
      letterSpacing: 0.1,
    );
  }

  /// Body Default - 15px, Weight: 400
  static TextStyle body({Color? color, bool isDark = false}) {
    return GoogleFonts.inter(
      fontSize: 15.0,
      fontWeight: FontWeight.w400,
      color: color ?? (isDark ? DairyColorsDark.textSecondary : DairyColorsLight.textSecondary),
      height: 1.5,
      letterSpacing: 0.1,
    );
  }

  /// Body Small - 14px, Weight: 400
  static TextStyle bodySmall({Color? color, bool isDark = false}) {
    return GoogleFonts.inter(
      fontSize: 14.0,
      fontWeight: FontWeight.w400,
      color: color ?? (isDark ? DairyColorsDark.textSecondary : DairyColorsLight.textSecondary),
      height: 1.4,
      letterSpacing: 0.1,
    );
  }

  // ==================== CAPTION ====================

  /// Caption - 12px, Weight: 400, Secondary color
  static TextStyle caption({Color? color, bool isDark = false}) {
    return GoogleFonts.inter(
      fontSize: 12.0,
      fontWeight: FontWeight.w400,
      color: color ?? (isDark ? DairyColorsDark.textTertiary : DairyColorsLight.textSecondary),
      height: 1.3,
      letterSpacing: 0.2,
    );
  }

  // ==================== SPECIAL STYLES ====================

  /// Button text - 16px, Bold
  static TextStyle button({Color? color, bool isDark = false}) {
    return GoogleFonts.inter(
      fontSize: 16.0,
      fontWeight: FontWeight.w600,
      color: color ?? (isDark ? DairyColorsDark.textOnPrimary : DairyColorsLight.textOnPrimary),
      height: 1.4,
      letterSpacing: 0.3,
    );
  }

  /// Price text - 18-20px, Bold, Green
  static TextStyle price({Color? color, bool isDark = false}) {
    return GoogleFonts.inter(
      fontSize: 18.0,
      fontWeight: FontWeight.w700,
      color: color ?? (isDark ? DairyColorsDark.primary : DairyColorsLight.primary),
      height: 1.3,
      letterSpacing: -0.2,
    );
  }

  /// Label text - 14px, Medium
  static TextStyle label({Color? color, bool isDark = false}) {
    return GoogleFonts.inter(
      fontSize: 14.0,
      fontWeight: FontWeight.w500,
      color: color ?? (isDark ? DairyColorsDark.textSecondary : DairyColorsLight.textSecondary),
      height: 1.4,
      letterSpacing: 0.1,
    );
  }

  /// Product name - 15px, SemiBold
  static TextStyle productName({Color? color, bool isDark = false}) {
    return GoogleFonts.inter(
      fontSize: 15.0,
      fontWeight: FontWeight.w600,
      color: color ?? (isDark ? DairyColorsDark.textPrimary : DairyColorsLight.textPrimary),
      height: 1.3,
      letterSpacing: 0,
    );
  }

  /// Navigation label - 12px, Medium
  static TextStyle navLabel({Color? color, bool isDark = false}) {
    return GoogleFonts.inter(
      fontSize: 12.0,
      fontWeight: FontWeight.w500,
      color: color ?? (isDark ? DairyColorsDark.textTertiary : DairyColorsLight.textTertiary),
      height: 1.3,
      letterSpacing: 0.1,
    );
  }

  /// Badge text - 11px, SemiBold
  static TextStyle badge({Color? color}) {
    return GoogleFonts.inter(
      fontSize: 11.0,
      fontWeight: FontWeight.w600,
      color: color ?? DairyColorsLight.textOnPrimary,
      height: 1.2,
      letterSpacing: 0.2,
    );
  }
}

// ============================================================================
// DAIRY THEME - Complete Material 3 Theme Configuration
// ============================================================================

class DairyTheme {
  DairyTheme._();

  // ==================== LIGHT THEME ====================
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: DairyColorsLight.primary,
      scaffoldBackgroundColor: DairyColorsLight.background,
      fontFamily: DairyTypography.fontFamily,

      // Color Scheme
      colorScheme: const ColorScheme.light(
        primary: DairyColorsLight.primary,
        onPrimary: DairyColorsLight.textOnPrimary,
        primaryContainer: DairyColorsLight.primarySurface,
        onPrimaryContainer: DairyColorsLight.primaryDark,
        secondary: DairyColorsLight.secondary,
        onSecondary: DairyColorsLight.textOnSecondary,
        secondaryContainer: DairyColorsLight.secondarySurface,
        onSecondaryContainer: DairyColorsLight.secondaryDark,
        surface: DairyColorsLight.surface,
        onSurface: DairyColorsLight.textPrimary,
        surfaceContainerHighest: DairyColorsLight.surfaceVariant,
        error: DairyColorsLight.error,
        onError: DairyColorsLight.textOnPrimary,
        outline: DairyColorsLight.border,
        outlineVariant: DairyColorsLight.borderLight,
      ),

      // Text Theme
      textTheme: TextTheme(
        displayLarge: DairyTypography.headingLarge(),
        displayMedium: DairyTypography.headingMedium(),
        displaySmall: DairyTypography.headingSmall(),
        headlineLarge: DairyTypography.headingLarge(),
        headlineMedium: DairyTypography.headingMedium(),
        headlineSmall: DairyTypography.headingSmall(),
        titleLarge: DairyTypography.headingSmall(),
        titleMedium: DairyTypography.bodyLarge(),
        titleSmall: DairyTypography.body(),
        bodyLarge: DairyTypography.bodyLarge(),
        bodyMedium: DairyTypography.body(),
        bodySmall: DairyTypography.bodySmall(),
        labelLarge: DairyTypography.button(),
        labelMedium: DairyTypography.label(),
        labelSmall: DairyTypography.caption(),
      ),

      // AppBar Theme
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        backgroundColor: DairyColorsLight.background,
        foregroundColor: DairyColorsLight.textPrimary,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: DairyTypography.headingSmall(),
        iconTheme: const IconThemeData(
          color: DairyColorsLight.textPrimary,
          size: 24,
        ),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: DairyColorsLight.primary,
          foregroundColor: DairyColorsLight.textOnPrimary,
          disabledBackgroundColor: DairyColorsLight.textDisabled,
          disabledForegroundColor: DairyColorsLight.textOnPrimary.withOpacity(0.4),
          elevation: 0,
          shadowColor: Colors.transparent,
          minimumSize: const Size(88, DairySpacing.touchTarget),
          padding: DairySpacing.buttonInternalPadding,
          shape: RoundedRectangleBorder(
            borderRadius: DairyRadius.defaultBorderRadius,
          ),
          textStyle: DairyTypography.button(),
        ),
      ),

      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: DairyColorsLight.primary,
          disabledForegroundColor: DairyColorsLight.textDisabled,
          minimumSize: const Size(88, DairySpacing.touchTarget),
          padding: DairySpacing.buttonInternalPadding,
          side: const BorderSide(
            color: DairyColorsLight.primary,
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: DairyRadius.defaultBorderRadius,
          ),
          textStyle: DairyTypography.button(color: DairyColorsLight.primary),
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: DairyColorsLight.primary,
          minimumSize: const Size(64, DairySpacing.touchTarget),
          padding: const EdgeInsets.symmetric(
            horizontal: DairySpacing.md,
            vertical: DairySpacing.sm,
          ),
          textStyle: DairyTypography.button(color: DairyColorsLight.primary),
        ),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        elevation: 0,
        color: DairyColorsLight.card,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: DairyRadius.largeBorderRadius,
        ),
        margin: const EdgeInsets.all(DairySpacing.sm),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: DairyColorsLight.surface,
        hintStyle: DairyTypography.body(color: DairyColorsLight.textTertiary),
        labelStyle: DairyTypography.label(),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: DairySpacing.md,
          vertical: DairySpacing.buttonPaddingV,
        ),
        border: OutlineInputBorder(
          borderRadius: DairyRadius.defaultBorderRadius,
          borderSide: const BorderSide(color: DairyColorsLight.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: DairyRadius.defaultBorderRadius,
          borderSide: const BorderSide(color: DairyColorsLight.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: DairyRadius.defaultBorderRadius,
          borderSide: const BorderSide(color: DairyColorsLight.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: DairyRadius.defaultBorderRadius,
          borderSide: const BorderSide(color: DairyColorsLight.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: DairyRadius.defaultBorderRadius,
          borderSide: const BorderSide(color: DairyColorsLight.error, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: DairyRadius.defaultBorderRadius,
          borderSide: const BorderSide(color: DairyColorsLight.borderLight),
        ),
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: DairyColorsLight.background,
        selectedItemColor: DairyColorsLight.primary,
        unselectedItemColor: DairyColorsLight.textTertiary,
        selectedLabelStyle: DairyTypography.navLabel(color: DairyColorsLight.primary),
        unselectedLabelStyle: DairyTypography.navLabel(),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        showUnselectedLabels: true,
      ),

      // Navigation Bar Theme (Material 3)
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: DairyColorsLight.background,
        surfaceTintColor: Colors.transparent,
        indicatorColor: DairyColorsLight.primarySurface,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return DairyTypography.navLabel(color: DairyColorsLight.primary);
          }
          return DairyTypography.navLabel();
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(
              color: DairyColorsLight.primary,
              size: 24,
            );
          }
          return const IconThemeData(
            color: DairyColorsLight.textTertiary,
            size: 24,
          );
        }),
        height: 80,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),

      // Floating Action Button Theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: DairyColorsLight.primary,
        foregroundColor: DairyColorsLight.textOnPrimary,
        elevation: 4,
        shape: CircleBorder(),
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: DairyColorsLight.surface,
        selectedColor: DairyColorsLight.primarySurface,
        disabledColor: DairyColorsLight.surfaceVariant,
        labelStyle: DairyTypography.label(),
        padding: const EdgeInsets.symmetric(
          horizontal: DairySpacing.sm,
          vertical: DairySpacing.xs,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: DairyRadius.pillBorderRadius,
          side: const BorderSide(color: DairyColorsLight.border),
        ),
      ),

      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: DairyColorsLight.divider,
        thickness: 1,
        space: DairySpacing.md,
      ),

      // Dialog Theme
      dialogTheme: DialogThemeData(
        backgroundColor: DairyColorsLight.background,
        surfaceTintColor: Colors.transparent,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: DairyRadius.xlBorderRadius,
        ),
        titleTextStyle: DairyTypography.headingMedium(),
        contentTextStyle: DairyTypography.body(),
      ),

      // Bottom Sheet Theme
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: DairyColorsLight.background,
        surfaceTintColor: Colors.transparent,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(DairyRadius.xl),
          ),
        ),
        showDragHandle: true,
        dragHandleColor: DairyColorsLight.border,
      ),

      // Snackbar Theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: DairyColorsLight.textPrimary,
        contentTextStyle: DairyTypography.body(color: DairyColorsLight.background),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: DairyRadius.defaultBorderRadius,
        ),
        insetPadding: const EdgeInsets.all(DairySpacing.md),
      ),

      // List Tile Theme
      listTileTheme: ListTileThemeData(
        contentPadding: DairySpacing.listItemPadding,
        minVerticalPadding: DairySpacing.sm,
        shape: RoundedRectangleBorder(
          borderRadius: DairyRadius.defaultBorderRadius,
        ),
        titleTextStyle: DairyTypography.bodyLarge(),
        subtitleTextStyle: DairyTypography.bodySmall(color: DairyColorsLight.textSecondary),
      ),

      // Switch Theme
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return DairyColorsLight.primary;
          }
          return DairyColorsLight.textTertiary;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return DairyColorsLight.primarySurface;
          }
          return DairyColorsLight.borderLight;
        }),
      ),

      // Checkbox Theme
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return DairyColorsLight.primary;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(DairyColorsLight.textOnPrimary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
        side: const BorderSide(color: DairyColorsLight.border, width: 1.5),
      ),

      // Radio Theme
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return DairyColorsLight.primary;
          }
          return DairyColorsLight.textTertiary;
        }),
      ),

      // Progress Indicator Theme
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: DairyColorsLight.primary,
        linearTrackColor: DairyColorsLight.primarySurface,
        circularTrackColor: DairyColorsLight.primarySurface,
      ),

      // Tab Bar Theme
      tabBarTheme: TabBarThemeData(
        labelColor: DairyColorsLight.primary,
        unselectedLabelColor: DairyColorsLight.textSecondary,
        labelStyle: DairyTypography.label(color: DairyColorsLight.primary),
        unselectedLabelStyle: DairyTypography.label(),
        indicator: UnderlineTabIndicator(
          borderSide: const BorderSide(
            color: DairyColorsLight.primary,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(2),
        ),
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: Colors.transparent,
      ),

      // Tooltip Theme
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: DairyColorsLight.textPrimary,
          borderRadius: DairyRadius.smallBorderRadius,
        ),
        textStyle: DairyTypography.caption(color: DairyColorsLight.background),
      ),
    );
  }

  // ==================== DARK THEME ====================
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: DairyColorsDark.primary,
      scaffoldBackgroundColor: DairyColorsDark.background,
      fontFamily: DairyTypography.fontFamily,

      // Color Scheme
      colorScheme: const ColorScheme.dark(
        primary: DairyColorsDark.primary,
        onPrimary: DairyColorsDark.textOnPrimary,
        primaryContainer: DairyColorsDark.primarySurface,
        onPrimaryContainer: DairyColorsDark.primaryLight,
        secondary: DairyColorsDark.secondary,
        onSecondary: DairyColorsDark.textOnSecondary,
        secondaryContainer: DairyColorsDark.secondarySurface,
        onSecondaryContainer: DairyColorsDark.secondaryLight,
        surface: DairyColorsDark.surface,
        onSurface: DairyColorsDark.textPrimary,
        surfaceContainerHighest: DairyColorsDark.surfaceVariant,
        error: DairyColorsDark.error,
        onError: DairyColorsDark.textOnPrimary,
        outline: DairyColorsDark.border,
        outlineVariant: DairyColorsDark.borderLight,
      ),

      // Text Theme
      textTheme: TextTheme(
        displayLarge: DairyTypography.headingLarge(isDark: true),
        displayMedium: DairyTypography.headingMedium(isDark: true),
        displaySmall: DairyTypography.headingSmall(isDark: true),
        headlineLarge: DairyTypography.headingLarge(isDark: true),
        headlineMedium: DairyTypography.headingMedium(isDark: true),
        headlineSmall: DairyTypography.headingSmall(isDark: true),
        titleLarge: DairyTypography.headingSmall(isDark: true),
        titleMedium: DairyTypography.bodyLarge(isDark: true),
        titleSmall: DairyTypography.body(isDark: true),
        bodyLarge: DairyTypography.bodyLarge(isDark: true),
        bodyMedium: DairyTypography.body(isDark: true),
        bodySmall: DairyTypography.bodySmall(isDark: true),
        labelLarge: DairyTypography.button(isDark: true),
        labelMedium: DairyTypography.label(isDark: true),
        labelSmall: DairyTypography.caption(isDark: true),
      ),

      // AppBar Theme
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        backgroundColor: DairyColorsDark.background,
        foregroundColor: DairyColorsDark.textPrimary,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: DairyTypography.headingSmall(isDark: true),
        iconTheme: const IconThemeData(
          color: DairyColorsDark.textPrimary,
          size: 24,
        ),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: DairyColorsDark.primary,
          foregroundColor: DairyColorsDark.textOnPrimary,
          disabledBackgroundColor: DairyColorsDark.textDisabled,
          disabledForegroundColor: DairyColorsDark.textOnPrimary.withOpacity(0.4),
          elevation: 0,
          shadowColor: Colors.transparent,
          minimumSize: const Size(88, DairySpacing.touchTarget),
          padding: DairySpacing.buttonInternalPadding,
          shape: RoundedRectangleBorder(
            borderRadius: DairyRadius.defaultBorderRadius,
          ),
          textStyle: DairyTypography.button(isDark: true),
        ),
      ),

      // Outlined Button Theme - White border in dark mode
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: DairyColorsDark.textPrimary,
          disabledForegroundColor: DairyColorsDark.textDisabled,
          minimumSize: const Size(88, DairySpacing.touchTarget),
          padding: DairySpacing.buttonInternalPadding,
          side: const BorderSide(
            color: DairyColorsDark.textPrimary,
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: DairyRadius.defaultBorderRadius,
          ),
          textStyle: DairyTypography.button(color: DairyColorsDark.textPrimary, isDark: true),
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: DairyColorsDark.primary,
          minimumSize: const Size(64, DairySpacing.touchTarget),
          padding: const EdgeInsets.symmetric(
            horizontal: DairySpacing.md,
            vertical: DairySpacing.sm,
          ),
          textStyle: DairyTypography.button(color: DairyColorsDark.primary, isDark: true),
        ),
      ),

      // Card Theme - Subtle border instead of shadow in dark mode
      cardTheme: CardThemeData(
        elevation: 0,
        color: DairyColorsDark.card,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: DairyRadius.largeBorderRadius,
          side: const BorderSide(
            color: DairyColorsDark.border,
            width: 1,
          ),
        ),
        margin: const EdgeInsets.all(DairySpacing.sm),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: DairyColorsDark.surface,
        hintStyle: DairyTypography.body(color: DairyColorsDark.textTertiary, isDark: true),
        labelStyle: DairyTypography.label(isDark: true),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: DairySpacing.md,
          vertical: DairySpacing.buttonPaddingV,
        ),
        border: OutlineInputBorder(
          borderRadius: DairyRadius.defaultBorderRadius,
          borderSide: const BorderSide(color: DairyColorsDark.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: DairyRadius.defaultBorderRadius,
          borderSide: const BorderSide(color: DairyColorsDark.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: DairyRadius.defaultBorderRadius,
          borderSide: const BorderSide(color: DairyColorsDark.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: DairyRadius.defaultBorderRadius,
          borderSide: const BorderSide(color: DairyColorsDark.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: DairyRadius.defaultBorderRadius,
          borderSide: const BorderSide(color: DairyColorsDark.error, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: DairyRadius.defaultBorderRadius,
          borderSide: const BorderSide(color: DairyColorsDark.borderLight),
        ),
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: DairyColorsDark.background,
        selectedItemColor: DairyColorsDark.primary,
        unselectedItemColor: DairyColorsDark.textTertiary,
        selectedLabelStyle: DairyTypography.navLabel(color: DairyColorsDark.primary, isDark: true),
        unselectedLabelStyle: DairyTypography.navLabel(isDark: true),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        showUnselectedLabels: true,
      ),

      // Navigation Bar Theme (Material 3)
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: DairyColorsDark.background,
        surfaceTintColor: Colors.transparent,
        indicatorColor: DairyColorsDark.primarySurface,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return DairyTypography.navLabel(color: DairyColorsDark.primary, isDark: true);
          }
          return DairyTypography.navLabel(isDark: true);
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(
              color: DairyColorsDark.primary,
              size: 24,
            );
          }
          return const IconThemeData(
            color: DairyColorsDark.textTertiary,
            size: 24,
          );
        }),
        height: 80,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),

      // Floating Action Button Theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: DairyColorsDark.primary,
        foregroundColor: DairyColorsDark.textOnPrimary,
        elevation: 4,
        shape: CircleBorder(),
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: DairyColorsDark.surface,
        selectedColor: DairyColorsDark.primarySurface,
        disabledColor: DairyColorsDark.surfaceVariant,
        labelStyle: DairyTypography.label(isDark: true),
        padding: const EdgeInsets.symmetric(
          horizontal: DairySpacing.sm,
          vertical: DairySpacing.xs,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: DairyRadius.pillBorderRadius,
          side: const BorderSide(color: DairyColorsDark.border),
        ),
      ),

      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: DairyColorsDark.divider,
        thickness: 1,
        space: DairySpacing.md,
      ),

      // Dialog Theme
      dialogTheme: DialogThemeData(
        backgroundColor: DairyColorsDark.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: DairyRadius.xlBorderRadius,
        ),
        titleTextStyle: DairyTypography.headingMedium(isDark: true),
        contentTextStyle: DairyTypography.body(isDark: true),
      ),

      // Bottom Sheet Theme
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: DairyColorsDark.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(DairyRadius.xl),
          ),
        ),
        showDragHandle: true,
        dragHandleColor: DairyColorsDark.borderLight,
      ),

      // Snackbar Theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: DairyColorsDark.surfaceVariant,
        contentTextStyle: DairyTypography.body(color: DairyColorsDark.textPrimary, isDark: true),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: DairyRadius.defaultBorderRadius,
        ),
        insetPadding: const EdgeInsets.all(DairySpacing.md),
      ),

      // List Tile Theme
      listTileTheme: ListTileThemeData(
        contentPadding: DairySpacing.listItemPadding,
        minVerticalPadding: DairySpacing.sm,
        shape: RoundedRectangleBorder(
          borderRadius: DairyRadius.defaultBorderRadius,
        ),
        titleTextStyle: DairyTypography.bodyLarge(isDark: true),
        subtitleTextStyle: DairyTypography.bodySmall(color: DairyColorsDark.textSecondary, isDark: true),
      ),

      // Switch Theme
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return DairyColorsDark.primary;
          }
          return DairyColorsDark.textTertiary;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return DairyColorsDark.primarySurface;
          }
          return DairyColorsDark.borderLight;
        }),
      ),

      // Checkbox Theme
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return DairyColorsDark.primary;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(DairyColorsDark.textOnPrimary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
        side: const BorderSide(color: DairyColorsDark.border, width: 1.5),
      ),

      // Radio Theme
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return DairyColorsDark.primary;
          }
          return DairyColorsDark.textTertiary;
        }),
      ),

      // Progress Indicator Theme
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: DairyColorsDark.primary,
        linearTrackColor: DairyColorsDark.primarySurface,
        circularTrackColor: DairyColorsDark.primarySurface,
      ),

      // Tab Bar Theme
      tabBarTheme: TabBarThemeData(
        labelColor: DairyColorsDark.primary,
        unselectedLabelColor: DairyColorsDark.textSecondary,
        labelStyle: DairyTypography.label(color: DairyColorsDark.primary, isDark: true),
        unselectedLabelStyle: DairyTypography.label(isDark: true),
        indicator: UnderlineTabIndicator(
          borderSide: const BorderSide(
            color: DairyColorsDark.primary,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(2),
        ),
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: Colors.transparent,
      ),

      // Tooltip Theme
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: DairyColorsDark.surfaceVariant,
          borderRadius: DairyRadius.smallBorderRadius,
        ),
        textStyle: DairyTypography.caption(color: DairyColorsDark.textPrimary, isDark: true),
      ),
    );
  }
}

// ============================================================================
// THEME PROVIDER
// ============================================================================

class DairyThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  ThemeData get lightTheme => DairyTheme.lightTheme;
  ThemeData get darkTheme => DairyTheme.darkTheme;

  ThemeData get currentTheme =>
      _themeMode == ThemeMode.dark ? darkTheme : lightTheme;

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) {
    if (_themeMode != mode) {
      _themeMode = mode;
      notifyListeners();
    }
  }

  void setLightMode() => setThemeMode(ThemeMode.light);
  void setDarkMode() => setThemeMode(ThemeMode.dark);
}

// ============================================================================
// CONTEXT EXTENSIONS
// ============================================================================

extension DairyThemeContext on BuildContext {
  /// Quick access to current theme
  ThemeData get theme => Theme.of(this);

  /// Quick access to color scheme
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  /// Quick access to text theme
  TextTheme get textTheme => Theme.of(this).textTheme;

  /// Check if dark mode
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  /// Get appropriate colors based on theme
  DairyColors get dairyColors => isDarkMode
      ? DairyColors.dark()
      : DairyColors.light();
}

/// Convenience class for accessing theme-aware colors
class DairyColors {
  final bool isDark;

  DairyColors._(this.isDark);

  factory DairyColors.light() => DairyColors._(false);
  factory DairyColors.dark() => DairyColors._(true);

  Color get primary => isDark ? DairyColorsDark.primary : DairyColorsLight.primary;
  Color get primaryLight => isDark ? DairyColorsDark.primaryLight : DairyColorsLight.primaryLight;
  Color get primarySurface => isDark ? DairyColorsDark.primarySurface : DairyColorsLight.primarySurface;
  Color get secondary => isDark ? DairyColorsDark.secondary : DairyColorsLight.secondary;
  Color get secondarySurface => isDark ? DairyColorsDark.secondarySurface : DairyColorsLight.secondarySurface;
  Color get background => isDark ? DairyColorsDark.background : DairyColorsLight.background;
  Color get surface => isDark ? DairyColorsDark.surface : DairyColorsLight.surface;
  Color get surfaceVariant => isDark ? DairyColorsDark.surfaceVariant : DairyColorsLight.surfaceVariant;
  Color get card => isDark ? DairyColorsDark.card : DairyColorsLight.card;
  Color get textPrimary => isDark ? DairyColorsDark.textPrimary : DairyColorsLight.textPrimary;
  Color get textSecondary => isDark ? DairyColorsDark.textSecondary : DairyColorsLight.textSecondary;
  Color get textTertiary => isDark ? DairyColorsDark.textTertiary : DairyColorsLight.textTertiary;
  Color get textDisabled => isDark ? DairyColorsDark.textDisabled : DairyColorsLight.textDisabled;
  Color get textOnPrimary => isDark ? DairyColorsDark.textOnPrimary : DairyColorsLight.textOnPrimary;
  Color get textOnSecondary => isDark ? DairyColorsDark.textOnSecondary : DairyColorsLight.textOnSecondary;
  Color get border => isDark ? DairyColorsDark.border : DairyColorsLight.border;
  Color get borderLight => isDark ? DairyColorsDark.borderLight : DairyColorsLight.borderLight;
  Color get divider => isDark ? DairyColorsDark.divider : DairyColorsLight.divider;
  Color get success => isDark ? DairyColorsDark.success : DairyColorsLight.success;
  Color get successSurface => isDark ? DairyColorsDark.successSurface : DairyColorsLight.successSurface;
  Color get warning => isDark ? DairyColorsDark.warning : DairyColorsLight.warning;
  Color get warningSurface => isDark ? DairyColorsDark.warningSurface : DairyColorsLight.warningSurface;
  Color get error => isDark ? DairyColorsDark.error : DairyColorsLight.error;
  Color get errorSurface => isDark ? DairyColorsDark.errorSurface : DairyColorsLight.errorSurface;
  Color get info => isDark ? DairyColorsDark.info : DairyColorsLight.info;
  Color get infoSurface => isDark ? DairyColorsDark.infoSurface : DairyColorsLight.infoSurface;

  List<BoxShadow> get cardShadow => isDark ? DairyColorsDark.cardShadow : DairyColorsLight.cardShadow;
  List<BoxShadow> get elevatedShadow => isDark ? DairyColorsDark.elevatedShadow : DairyColorsLight.elevatedShadow;
  List<BoxShadow> get buttonShadow => isDark ? DairyColorsDark.buttonShadow : DairyColorsLight.buttonShadow;
}

// ============================================================================
// BACKWARD COMPATIBILITY - AppTheme Aliases
// Provides compatibility with legacy code using AppTheme
// ============================================================================

class AppTheme {
  AppTheme._();

  // Colors
  static const Color primaryColor = DairyColorsLight.primary;
  static const Color primaryLight = DairyColorsLight.primaryLight;
  static const Color primaryDark = DairyColorsLight.primaryDark;
  static const Color secondaryColor = DairyColorsLight.secondary;
  static const Color backgroundColor = DairyColorsLight.background;
  static const Color surfaceColor = DairyColorsLight.surface;
  static const Color cardColor = DairyColorsLight.card;
  static const Color textPrimary = DairyColorsLight.textPrimary;
  static const Color textSecondary = DairyColorsLight.textSecondary;
  static const Color textTertiary = DairyColorsLight.textTertiary;
  static const Color successGreen = DairyColorsLight.success;
  static const Color warningOrange = DairyColorsLight.warning;
  static const Color errorRed = DairyColorsLight.error;
  static const Color infoBlue = DairyColorsLight.info;

  // Spacing
  static const double space4 = DairySpacing.xs;
  static const double space8 = DairySpacing.sm;
  static const double space12 = 12.0;
  static const double space16 = DairySpacing.md;
  static const double space20 = 20.0;
  static const double space24 = DairySpacing.lg;
  static const double space32 = DairySpacing.xl;

  // Radius
  static const double radiusSmall = DairyRadius.sm;
  static const double radiusMedium = DairyRadius.md;
  static const double radiusLarge = DairyRadius.lg;
  static const double radiusXLarge = DairyRadius.xl;
  static const double radiusPill = DairyRadius.pill;

  // Gradients
  static const LinearGradient primaryButtonGradient = LinearGradient(
    colors: [DairyColorsLight.primary, DairyColorsLight.primaryDark],
  );

  static const LinearGradient activeGradient = LinearGradient(
    colors: [DairyColorsLight.success, Color(0xFF66BB6A)],
  );

  static const LinearGradient pendingGradient = LinearGradient(
    colors: [DairyColorsLight.warning, Color(0xFFFFB74D)],
  );

  static const LinearGradient deliveredGradient = LinearGradient(
    colors: [DairyColorsLight.primary, DairyColorsLight.primaryLight],
  );

  static const LinearGradient dangerButtonGradient = LinearGradient(
    colors: [DairyColorsLight.error, Color(0xFFE53935)],
  );

  static const LinearGradient appBarGradient = LinearGradient(
    colors: [DairyColorsLight.primary, DairyColorsLight.primaryDark],
  );

  static const LinearGradient premiumCardGradient = LinearGradient(
    colors: [DairyColorsLight.primary, DairyColorsLight.primaryDark],
  );

  static const LinearGradient mainBackground = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFE8F8E8),
      DairyColorsLight.background,
      DairyColorsLight.surface,
    ],
  );

  static const LinearGradient productCardGradient = LinearGradient(
    colors: [DairyColorsLight.card, Color(0xFFF0F7FF)],
  );

  static const LinearGradient dashboardHeaderGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      DairyColorsLight.primary,
      DairyColorsLight.primaryLight,
      Color(0xFFF5F9FF),
    ],
    stops: [0.0, 0.6, 1.0],
  );

  static const LinearGradient secondaryButtonGradient = LinearGradient(
    colors: [DairyColorsLight.secondary, DairyColorsLight.secondaryDark],
  );

  // Shadows
  static List<BoxShadow> get cardShadow => DairyColorsLight.cardShadow;
  static List<BoxShadow> get premiumCardShadow => DairyColorsLight.elevatedShadow;
  static List<BoxShadow> get buttonShadow => DairyColorsLight.buttonShadow;

  static List<BoxShadow> productCardShadow(Color color) => [
    BoxShadow(
      color: color.withValues(alpha: 0.1),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];

  // Typography Styles
  static TextStyle get h1 => DairyTypography.headingLarge();
  static TextStyle get h2 => DairyTypography.headingLarge();
  static TextStyle get h3 => DairyTypography.headingMedium();
  static TextStyle get h4 => DairyTypography.headingSmall();
  static TextStyle get h5 => DairyTypography.bodyLarge();
  static TextStyle get bodyLarge => DairyTypography.bodyLarge();
  static TextStyle get bodyMedium => DairyTypography.body();
  static TextStyle get bodySmall => DairyTypography.bodySmall();
  static TextStyle get buttonText => DairyTypography.button();
  static TextStyle get labelText => DairyTypography.label();
  static TextStyle get captionText => DairyTypography.caption();
  static TextStyle get priceText => DairyTypography.price();
}
