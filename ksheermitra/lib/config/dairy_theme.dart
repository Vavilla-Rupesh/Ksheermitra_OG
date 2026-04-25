import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// KsheerMitra Premium Dairy Design System — Blue Ecosystem
/// Unified blue-based theming: Calm, trustworthy, Stripe-inspired
/// Clarity > Decoration | Spacing > Colors | Consistency > Creativity

// ============================================================================
// USER ROLE
// ============================================================================

enum UserRole { admin, deliveryBoy, customer, none }

// ============================================================================
// UNIFIED BLUE COLOR PALETTE
// ============================================================================

class _AdminPalette {
  _AdminPalette._();
  static const Color primary = Color(0xFF2563EB);        // Main blue
  static const Color primaryLight = Color(0xFF60A5FA);    // Hover/light
  static const Color primaryDark = Color(0xFF1E40AF);     // Deep/sidebar
  static const Color primarySurface = Color(0xFFEFF6FF);  // Soft surface
  static const Color secondary = Color(0xFF3B82F6);
  static const Color secondaryLight = Color(0xFF93C5FD);
  static const Color secondaryDark = Color(0xFF1D4ED8);
  static const Color secondarySurface = Color(0xFFDBEAFE);
  static const Color primaryDarkMode = Color(0xFF60A5FA);
  static const Color primarySurfaceDark = Color(0xFF172554);
  static const Color secondaryDarkMode = Color(0xFF93C5FD);
  static const Color secondarySurfaceDark = Color(0xFF1E3A5F);
}

class _DeliveryPalette {
  _DeliveryPalette._();
  static const Color primary = Color(0xFF2563EB);
  static const Color primaryLight = Color(0xFF60A5FA);
  static const Color primaryDark = Color(0xFF1E40AF);
  static const Color primarySurface = Color(0xFFEFF6FF);
  static const Color secondary = Color(0xFF0EA5E9);       // Sky blue accent
  static const Color secondaryLight = Color(0xFF7DD3FC);
  static const Color secondaryDark = Color(0xFF0369A1);
  static const Color secondarySurface = Color(0xFFE0F2FE);
  static const Color primaryDarkMode = Color(0xFF60A5FA);
  static const Color primarySurfaceDark = Color(0xFF172554);
  static const Color secondaryDarkMode = Color(0xFF7DD3FC);
  static const Color secondarySurfaceDark = Color(0xFF0C4A6E);
}

class _CustomerPalette {
  _CustomerPalette._();
  static const Color primary = Color(0xFF2563EB);
  static const Color primaryLight = Color(0xFF60A5FA);
  static const Color primaryDark = Color(0xFF1E40AF);
  static const Color primarySurface = Color(0xFFEFF6FF);
  static const Color secondary = Color(0xFF8B5CF6);       // Violet accent
  static const Color secondaryLight = Color(0xFFA78BFA);
  static const Color secondaryDark = Color(0xFF6D28D9);
  static const Color secondarySurface = Color(0xFFEDE9FE);
  static const Color primaryDarkMode = Color(0xFF60A5FA);
  static const Color primarySurfaceDark = Color(0xFF172554);
  static const Color secondaryDarkMode = Color(0xFFA78BFA);
  static const Color secondarySurfaceDark = Color(0xFF2E1A3E);
}

class _NeutralPalette {
  _NeutralPalette._();
  static const Color primary = Color(0xFF2563EB);
  static const Color primaryLight = Color(0xFF60A5FA);
  static const Color primaryDark = Color(0xFF1E40AF);
  static const Color primarySurface = Color(0xFFEFF6FF);
  static const Color secondary = Color(0xFF6366F1);       // Indigo accent
  static const Color secondaryLight = Color(0xFF818CF8);
  static const Color secondaryDark = Color(0xFF4F46E5);
  static const Color secondarySurface = Color(0xFFEEF2FF);
  static const Color primaryDarkMode = Color(0xFF60A5FA);
  static const Color primarySurfaceDark = Color(0xFF172554);
  static const Color secondaryDarkMode = Color(0xFF818CF8);
  static const Color secondarySurfaceDark = Color(0xFF1E1B4B);
}

// ============================================================================
// COLOR TOKENS - Light Mode
// ============================================================================

class DairyColorsLight {
  DairyColorsLight._();

  static const Color primary = Color(0xFF2563EB);         // Main blue
  static const Color primaryLight = Color(0xFF60A5FA);     // Hover/light
  static const Color primaryDark = Color(0xFF1E40AF);      // Deep/sidebar
  static const Color primarySurface = Color(0xFFEFF6FF);   // Soft blue bg

  static const Color secondary = Color(0xFF6366F1);        // Indigo accent
  static const Color secondaryLight = Color(0xFF818CF8);
  static const Color secondaryDark = Color(0xFF4F46E5);
  static const Color secondarySurface = Color(0xFFEEF2FF);

  static const Color background = Color(0xFFF8FAFC);       // Soft bg (Stripe)
  static const Color surface = Color(0xFFF1F5F9);
  static const Color surfaceVariant = Color(0xFFE2E8F0);
  static const Color card = Color(0xFFFFFFFF);
  static const Color cardHover = Color(0xFFF8FAFC);

  static const Color textPrimary = Color(0xFF0F172A);      // Slate-900
  static const Color textSecondary = Color(0xFF475569);    // Slate-600
  static const Color textTertiary = Color(0xFF94A3B8);     // Slate-400
  static const Color textDisabled = Color(0xFFCBD5E1);     // Slate-300
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textOnSecondary = Color(0xFFFFFFFF);

  static const Color border = Color(0xFFE2E8F0);          // Slate-200
  static const Color borderLight = Color(0xFFF1F5F9);     // Slate-100
  static const Color divider = Color(0xFFE2E8F0);

  static const Color success = Color(0xFF22C55E);
  static const Color successSurface = Color(0xFFDCFCE7);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningSurface = Color(0xFFFEF3C7);
  static const Color error = Color(0xFFEF4444);
  static const Color errorSurface = Color(0xFFFEE2E2);
  static const Color info = Color(0xFF3B82F6);
  static const Color infoSurface = Color(0xFFDBEAFE);
  static const Color danger = Color(0xFFEF4444);           // Danger alias

  static List<BoxShadow> get cardShadow => [
    BoxShadow(color: const Color(0xFF000000).withValues(alpha: 0.06), blurRadius: 14, offset: const Offset(0, 4)),
    BoxShadow(color: const Color(0xFF000000).withValues(alpha: 0.02), blurRadius: 6, offset: const Offset(0, 2)),
  ];

  static List<BoxShadow> get cardHoverShadow => [
    BoxShadow(color: const Color(0xFF000000).withValues(alpha: 0.08), blurRadius: 30, offset: const Offset(0, 10)),
    BoxShadow(color: const Color(0xFF000000).withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4)),
  ];

  static List<BoxShadow> get elevatedShadow => [
    BoxShadow(color: const Color(0xFF000000).withValues(alpha: 0.08), blurRadius: 24, offset: const Offset(0, 8)),
    BoxShadow(color: const Color(0xFF000000).withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 4)),
  ];

  static List<BoxShadow> get buttonShadow => [
    BoxShadow(color: primary.withValues(alpha: 0.25), blurRadius: 12, offset: const Offset(0, 4)),
  ];
}

// ============================================================================
// COLOR TOKENS - Dark Mode
// ============================================================================

class DairyColorsDark {
  DairyColorsDark._();

  static const Color primary = Color(0xFF60A5FA);          // Lighter blue for dark mode
  static const Color primaryLight = Color(0xFF93C5FD);
  static const Color primaryDark = Color(0xFF3B82F6);
  static const Color primarySurface = Color(0xFF172554);   // Deep navy

  static const Color secondary = Color(0xFF818CF8);
  static const Color secondaryLight = Color(0xFFA5B4FC);
  static const Color secondaryDark = Color(0xFF6366F1);
  static const Color secondarySurface = Color(0xFF1E1B4B);

  static const Color background = Color(0xFF0F172A);
  static const Color surface = Color(0xFF1E293B);
  static const Color surfaceVariant = Color(0xFF334155);
  static const Color card = Color(0xFF1E293B);
  static const Color cardHover = Color(0xFF334155);

  static const Color textPrimary = Color(0xFFF1F5F9);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textTertiary = Color(0xFF64748B);
  static const Color textDisabled = Color(0xFF475569);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textOnSecondary = Color(0xFFFFFFFF);

  static const Color border = Color(0xFF334155);
  static const Color borderLight = Color(0xFF475569);
  static const Color divider = Color(0xFF334155);

  static const Color success = Color(0xFF4ADE80);
  static const Color successSurface = Color(0xFF1A2E1A);
  static const Color warning = Color(0xFFFBBF24);
  static const Color warningSurface = Color(0xFF2E2617);
  static const Color error = Color(0xFFF87171);
  static const Color errorSurface = Color(0xFF2E1A1A);
  static const Color info = Color(0xFF60A5FA);
  static const Color infoSurface = Color(0xFF1A2438);

  static List<BoxShadow> get cardShadow => [];
  static List<BoxShadow> get elevatedShadow => [
    BoxShadow(color: const Color(0xFF000000).withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4)),
  ];
  static List<BoxShadow> get buttonShadow => [];
}

// ============================================================================
// SPACING SYSTEM - 8-Point Grid (generous)
// ============================================================================

class DairySpacing {
  DairySpacing._();

  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 40.0;
  static const double xxxl = 48.0;

  static const double screenPaddingH = 16.0;      // Mobile-first 16px
  static const double screenPaddingV = 24.0;
  static const double cardPadding = 24.0;          // Premium card padding
  static const double cardGap = 24.0;              // Gap between cards
  static const double sectionSpacing = 40.0;       // Section separation
  static const double buttonPaddingV = 12.0;       // Button vertical
  static const double buttonPaddingH = 20.0;       // Button horizontal
  static const double cardElementGap = 10.0;
  static const double touchTarget = 44.0;          // Min 44px (WCAG)

  static const EdgeInsets screenPadding = EdgeInsets.symmetric(horizontal: screenPaddingH, vertical: screenPaddingV);
  static const EdgeInsets cardContentPadding = EdgeInsets.all(cardPadding);
  static const EdgeInsets buttonInternalPadding = EdgeInsets.symmetric(vertical: buttonPaddingV, horizontal: buttonPaddingH);
  static const EdgeInsets listItemPadding = EdgeInsets.symmetric(vertical: sm, horizontal: md);

  /// Responsive screen padding (Stripe-style: max 1280px container)
  static EdgeInsets responsivePadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= 1280) return const EdgeInsets.symmetric(horizontal: 48, vertical: 24);
    if (width >= 900) return const EdgeInsets.symmetric(horizontal: 32, vertical: 24);
    if (width >= 600) return const EdgeInsets.symmetric(horizontal: 24, vertical: 24);
    return screenPadding;
  }

  /// Max content width for premium layout
  static double get maxContentWidth => 1280.0;
}

// ============================================================================
// BORDER & RADIUS SYSTEM
// ============================================================================

class DairyRadius {
  DairyRadius._();

  static const double sm = 8.0;
  static const double md = 12.0;
  static const double button = 10.0;    // Button radius (per spec)
  static const double lg = 16.0;        // Cards (per spec)
  static const double xl = 20.0;        // Premium cards
  static const double xxl = 24.0;       // Modals
  static const double pill = 999.0;
  static const double circle = 999.0;

  static BorderRadius get smallBorderRadius => BorderRadius.circular(sm);
  static BorderRadius get defaultBorderRadius => BorderRadius.circular(md);
  static BorderRadius get buttonBorderRadius => BorderRadius.circular(button);
  static BorderRadius get largeBorderRadius => BorderRadius.circular(lg);
  static BorderRadius get xlBorderRadius => BorderRadius.circular(xl);
  static BorderRadius get xxlBorderRadius => BorderRadius.circular(xxl);
  static BorderRadius get pillBorderRadius => BorderRadius.circular(pill);
}

// ============================================================================
// TYPOGRAPHY SYSTEM — Headings: Poppins | Body: Inter
// ============================================================================

class DairyTypography {
  DairyTypography._();

  static String get fontFamily => GoogleFonts.inter().fontFamily ?? 'Inter';
  static String get headingFontFamily => GoogleFonts.poppins().fontFamily ?? 'Poppins';

  static TextStyle headingXLarge({Color? color, bool isDark = false}) {
    return GoogleFonts.poppins(fontSize: 30.0, fontWeight: FontWeight.w600, color: color ?? (isDark ? DairyColorsDark.textPrimary : DairyColorsLight.textPrimary), height: 1.25, letterSpacing: -0.5);
  }

  static TextStyle headingLarge({Color? color, bool isDark = false}) {
    return GoogleFonts.poppins(fontSize: 26.0, fontWeight: FontWeight.w600, color: color ?? (isDark ? DairyColorsDark.textPrimary : DairyColorsLight.textPrimary), height: 1.3, letterSpacing: -0.4);
  }

  static TextStyle headingMedium({Color? color, bool isDark = false}) {
    return GoogleFonts.poppins(fontSize: 20.0, fontWeight: FontWeight.w600, color: color ?? (isDark ? DairyColorsDark.textPrimary : DairyColorsLight.textPrimary), height: 1.35, letterSpacing: -0.3);
  }

  static TextStyle headingSmall({Color? color, bool isDark = false}) {
    return GoogleFonts.poppins(fontSize: 18.0, fontWeight: FontWeight.w600, color: color ?? (isDark ? DairyColorsDark.textPrimary : DairyColorsLight.textPrimary), height: 1.4, letterSpacing: -0.2);
  }

  static TextStyle bodyLarge({Color? color, bool isDark = false}) {
    return GoogleFonts.inter(fontSize: 17.0, fontWeight: FontWeight.w400, color: color ?? (isDark ? DairyColorsDark.textPrimary : DairyColorsLight.textPrimary), height: 1.5, letterSpacing: 0.1);
  }

  static TextStyle body({Color? color, bool isDark = false}) {
    return GoogleFonts.inter(fontSize: 15.0, fontWeight: FontWeight.w400, color: color ?? (isDark ? DairyColorsDark.textSecondary : DairyColorsLight.textSecondary), height: 1.5, letterSpacing: 0.1);
  }

  static TextStyle bodySmall({Color? color, bool isDark = false}) {
    return GoogleFonts.inter(fontSize: 14.0, fontWeight: FontWeight.w400, color: color ?? (isDark ? DairyColorsDark.textSecondary : DairyColorsLight.textSecondary), height: 1.45, letterSpacing: 0.1);
  }

  static TextStyle caption({Color? color, bool isDark = false}) {
    return GoogleFonts.inter(fontSize: 13.0, fontWeight: FontWeight.w400, color: color ?? (isDark ? DairyColorsDark.textTertiary : DairyColorsLight.textSecondary), height: 1.35, letterSpacing: 0.2);
  }

  static TextStyle button({Color? color, bool isDark = false}) {
    return GoogleFonts.inter(fontSize: 16.0, fontWeight: FontWeight.w600, color: color ?? (isDark ? DairyColorsDark.textOnPrimary : DairyColorsLight.textOnPrimary), height: 1.4, letterSpacing: 0.2);
  }

  static TextStyle price({Color? color, bool isDark = false}) {
    return GoogleFonts.poppins(fontSize: 20.0, fontWeight: FontWeight.w700, color: color ?? (isDark ? DairyColorsDark.primary : DairyColorsLight.primary), height: 1.3, letterSpacing: -0.2);
  }

  static TextStyle label({Color? color, bool isDark = false}) {
    return GoogleFonts.inter(fontSize: 14.0, fontWeight: FontWeight.w500, color: color ?? (isDark ? DairyColorsDark.textSecondary : DairyColorsLight.textSecondary), height: 1.4, letterSpacing: 0.1);
  }

  static TextStyle productName({Color? color, bool isDark = false}) {
    return GoogleFonts.inter(fontSize: 16.0, fontWeight: FontWeight.w600, color: color ?? (isDark ? DairyColorsDark.textPrimary : DairyColorsLight.textPrimary), height: 1.3);
  }

  static TextStyle navLabel({Color? color, bool isDark = false}) {
    return GoogleFonts.inter(fontSize: 12.0, fontWeight: FontWeight.w500, color: color ?? (isDark ? DairyColorsDark.textTertiary : DairyColorsLight.textTertiary), height: 1.3, letterSpacing: 0.1);
  }

  static TextStyle badge({Color? color}) {
    return GoogleFonts.inter(fontSize: 11.0, fontWeight: FontWeight.w600, color: color ?? DairyColorsLight.textOnPrimary, height: 1.2, letterSpacing: 0.2);
  }
}

// ============================================================================
// DAIRY THEME - Role-Aware Material 3 Theme
// ============================================================================

class DairyTheme {
  DairyTheme._();

  static ThemeData get lightTheme => buildLightTheme();
  static ThemeData get darkTheme => buildDarkTheme();

  static ThemeData buildLightTheme([UserRole role = UserRole.none]) {
    final palette = _getRolePalette(role, isDark: false);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: palette.primary,
      scaffoldBackgroundColor: DairyColorsLight.background,
      fontFamily: DairyTypography.fontFamily,
      colorScheme: ColorScheme.light(
        primary: palette.primary, onPrimary: DairyColorsLight.textOnPrimary,
        primaryContainer: palette.primarySurface, onPrimaryContainer: palette.primaryDark,
        secondary: palette.secondary, onSecondary: DairyColorsLight.textOnSecondary,
        secondaryContainer: palette.secondarySurface, onSecondaryContainer: palette.secondaryDark,
        surface: DairyColorsLight.surface, onSurface: DairyColorsLight.textPrimary,
        surfaceContainerHighest: DairyColorsLight.surfaceVariant,
        error: DairyColorsLight.error, onError: DairyColorsLight.textOnPrimary,
        outline: DairyColorsLight.border, outlineVariant: DairyColorsLight.borderLight,
      ),
      textTheme: TextTheme(
        displayLarge: DairyTypography.headingXLarge(), displayMedium: DairyTypography.headingLarge(),
        displaySmall: DairyTypography.headingMedium(), headlineLarge: DairyTypography.headingLarge(),
        headlineMedium: DairyTypography.headingMedium(), headlineSmall: DairyTypography.headingSmall(),
        titleLarge: DairyTypography.headingSmall(), titleMedium: DairyTypography.bodyLarge(),
        titleSmall: DairyTypography.body(), bodyLarge: DairyTypography.bodyLarge(),
        bodyMedium: DairyTypography.body(), bodySmall: DairyTypography.bodySmall(),
        labelLarge: DairyTypography.button(), labelMedium: DairyTypography.label(),
        labelSmall: DairyTypography.caption(),
      ),
      appBarTheme: AppBarTheme(
        elevation: 0, scrolledUnderElevation: 0, centerTitle: true,
        backgroundColor: DairyColorsLight.background, foregroundColor: DairyColorsLight.textPrimary,
        surfaceTintColor: Colors.transparent, titleTextStyle: DairyTypography.headingSmall(),
        iconTheme: const IconThemeData(color: DairyColorsLight.textPrimary, size: 24),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(style: ElevatedButton.styleFrom(
        backgroundColor: palette.primary, foregroundColor: DairyColorsLight.textOnPrimary,
        disabledBackgroundColor: DairyColorsLight.textDisabled,
        disabledForegroundColor: DairyColorsLight.textOnPrimary.withValues(alpha: 0.4),
        elevation: 0, shadowColor: Colors.transparent,
        minimumSize: const Size(88, DairySpacing.touchTarget),
        padding: DairySpacing.buttonInternalPadding,
        shape: RoundedRectangleBorder(borderRadius: DairyRadius.buttonBorderRadius),
        textStyle: DairyTypography.button(),
      )),
      outlinedButtonTheme: OutlinedButtonThemeData(style: OutlinedButton.styleFrom(
        foregroundColor: palette.primary, disabledForegroundColor: DairyColorsLight.textDisabled,
        minimumSize: const Size(88, DairySpacing.touchTarget),
        padding: DairySpacing.buttonInternalPadding,
        side: BorderSide(color: DairyColorsLight.border, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: DairyRadius.buttonBorderRadius),
        textStyle: DairyTypography.button(color: palette.primary),
      )),
      textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(
        foregroundColor: palette.primary, minimumSize: const Size(64, DairySpacing.touchTarget),
        padding: const EdgeInsets.symmetric(horizontal: DairySpacing.md, vertical: DairySpacing.sm),
        textStyle: DairyTypography.button(color: palette.primary),
      )),
      cardTheme: CardThemeData(
        elevation: 0, color: DairyColorsLight.card, surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: DairyRadius.xlBorderRadius),
        margin: const EdgeInsets.all(DairySpacing.sm),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true, fillColor: DairyColorsLight.surface,
        hintStyle: DairyTypography.body(color: DairyColorsLight.textTertiary),
        labelStyle: DairyTypography.label(),
        contentPadding: const EdgeInsets.symmetric(horizontal: DairySpacing.md, vertical: DairySpacing.buttonPaddingV),
        border: OutlineInputBorder(borderRadius: DairyRadius.defaultBorderRadius, borderSide: const BorderSide(color: DairyColorsLight.border)),
        enabledBorder: OutlineInputBorder(borderRadius: DairyRadius.defaultBorderRadius, borderSide: const BorderSide(color: DairyColorsLight.border)),
        focusedBorder: OutlineInputBorder(borderRadius: DairyRadius.defaultBorderRadius, borderSide: BorderSide(color: palette.primary, width: 2)),
        errorBorder: OutlineInputBorder(borderRadius: DairyRadius.defaultBorderRadius, borderSide: const BorderSide(color: DairyColorsLight.error)),
        focusedErrorBorder: OutlineInputBorder(borderRadius: DairyRadius.defaultBorderRadius, borderSide: const BorderSide(color: DairyColorsLight.error, width: 2)),
        disabledBorder: OutlineInputBorder(borderRadius: DairyRadius.defaultBorderRadius, borderSide: const BorderSide(color: DairyColorsLight.borderLight)),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: DairyColorsLight.background, selectedItemColor: palette.primary,
        unselectedItemColor: DairyColorsLight.textTertiary,
        selectedLabelStyle: DairyTypography.navLabel(color: palette.primary),
        unselectedLabelStyle: DairyTypography.navLabel(),
        type: BottomNavigationBarType.fixed, elevation: 0, showUnselectedLabels: true,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: DairyColorsLight.background, surfaceTintColor: Colors.transparent,
        indicatorColor: palette.primarySurface,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return DairyTypography.navLabel(color: palette.primary);
          return DairyTypography.navLabel();
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return IconThemeData(color: palette.primary, size: 24);
          return const IconThemeData(color: DairyColorsLight.textTertiary, size: 24);
        }),
        height: 80, labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(backgroundColor: palette.primary, foregroundColor: DairyColorsLight.textOnPrimary, elevation: 4, shape: const StadiumBorder()),
      chipTheme: ChipThemeData(
        backgroundColor: DairyColorsLight.surface, selectedColor: palette.primarySurface,
        disabledColor: DairyColorsLight.surfaceVariant, labelStyle: DairyTypography.label(),
        padding: const EdgeInsets.symmetric(horizontal: DairySpacing.sm, vertical: DairySpacing.xs),
        shape: RoundedRectangleBorder(borderRadius: DairyRadius.pillBorderRadius, side: const BorderSide(color: DairyColorsLight.border)),
      ),
      dividerTheme: const DividerThemeData(color: DairyColorsLight.divider, thickness: 1, space: DairySpacing.md),
      dialogTheme: DialogThemeData(
        backgroundColor: DairyColorsLight.background, surfaceTintColor: Colors.transparent, elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: DairyRadius.xxlBorderRadius),
        titleTextStyle: DairyTypography.headingMedium(), contentTextStyle: DairyTypography.body(),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: DairyColorsLight.background, surfaceTintColor: Colors.transparent, elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(DairyRadius.xxl))),
        showDragHandle: true, dragHandleColor: DairyColorsLight.border,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: DairyColorsLight.textPrimary,
        contentTextStyle: DairyTypography.body(color: DairyColorsLight.background),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: DairyRadius.defaultBorderRadius),
        insetPadding: const EdgeInsets.all(DairySpacing.md),
      ),
      listTileTheme: ListTileThemeData(
        contentPadding: DairySpacing.listItemPadding, minVerticalPadding: DairySpacing.sm,
        shape: RoundedRectangleBorder(borderRadius: DairyRadius.defaultBorderRadius),
        titleTextStyle: DairyTypography.bodyLarge(), subtitleTextStyle: DairyTypography.bodySmall(color: DairyColorsLight.textSecondary),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? palette.primary : DairyColorsLight.textTertiary),
        trackColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? palette.primarySurface : DairyColorsLight.borderLight),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? palette.primary : Colors.transparent),
        checkColor: WidgetStateProperty.all(DairyColorsLight.textOnPrimary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        side: const BorderSide(color: DairyColorsLight.border, width: 1.5),
      ),
      radioTheme: RadioThemeData(fillColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? palette.primary : DairyColorsLight.textTertiary)),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: palette.primary, linearTrackColor: palette.primarySurface, circularTrackColor: palette.primarySurface),
      tabBarTheme: TabBarThemeData(
        labelColor: palette.primary, unselectedLabelColor: DairyColorsLight.textSecondary,
        labelStyle: DairyTypography.label(color: palette.primary), unselectedLabelStyle: DairyTypography.label(),
        indicator: UnderlineTabIndicator(borderSide: BorderSide(color: palette.primary, width: 2), borderRadius: BorderRadius.circular(2)),
        indicatorSize: TabBarIndicatorSize.label, dividerColor: Colors.transparent,
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(color: DairyColorsLight.textPrimary, borderRadius: DairyRadius.smallBorderRadius),
        textStyle: DairyTypography.caption(color: DairyColorsLight.background),
      ),
    );
  }

  static ThemeData buildDarkTheme([UserRole role = UserRole.none]) {
    final palette = _getRolePalette(role, isDark: true);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: palette.primary,
      scaffoldBackgroundColor: DairyColorsDark.background,
      fontFamily: DairyTypography.fontFamily,
      colorScheme: ColorScheme.dark(
        primary: palette.primary, onPrimary: DairyColorsDark.textOnPrimary,
        primaryContainer: palette.primarySurface, onPrimaryContainer: palette.primaryLight,
        secondary: palette.secondary, onSecondary: DairyColorsDark.textOnSecondary,
        secondaryContainer: palette.secondarySurface, onSecondaryContainer: palette.secondaryLight,
        surface: DairyColorsDark.surface, onSurface: DairyColorsDark.textPrimary,
        surfaceContainerHighest: DairyColorsDark.surfaceVariant,
        error: DairyColorsDark.error, onError: DairyColorsDark.textOnPrimary,
        outline: DairyColorsDark.border, outlineVariant: DairyColorsDark.borderLight,
      ),
      textTheme: TextTheme(
        displayLarge: DairyTypography.headingXLarge(isDark: true), displayMedium: DairyTypography.headingLarge(isDark: true),
        displaySmall: DairyTypography.headingMedium(isDark: true), headlineLarge: DairyTypography.headingLarge(isDark: true),
        headlineMedium: DairyTypography.headingMedium(isDark: true), headlineSmall: DairyTypography.headingSmall(isDark: true),
        titleLarge: DairyTypography.headingSmall(isDark: true), titleMedium: DairyTypography.bodyLarge(isDark: true),
        titleSmall: DairyTypography.body(isDark: true), bodyLarge: DairyTypography.bodyLarge(isDark: true),
        bodyMedium: DairyTypography.body(isDark: true), bodySmall: DairyTypography.bodySmall(isDark: true),
        labelLarge: DairyTypography.button(isDark: true), labelMedium: DairyTypography.label(isDark: true),
        labelSmall: DairyTypography.caption(isDark: true),
      ),
      appBarTheme: AppBarTheme(
        elevation: 0, scrolledUnderElevation: 0, centerTitle: true,
        backgroundColor: DairyColorsDark.background, foregroundColor: DairyColorsDark.textPrimary,
        surfaceTintColor: Colors.transparent, titleTextStyle: DairyTypography.headingSmall(isDark: true),
        iconTheme: const IconThemeData(color: DairyColorsDark.textPrimary, size: 24),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(style: ElevatedButton.styleFrom(
        backgroundColor: palette.primary, foregroundColor: DairyColorsDark.textOnPrimary,
        disabledBackgroundColor: DairyColorsDark.textDisabled,
        disabledForegroundColor: DairyColorsDark.textOnPrimary.withValues(alpha: 0.4),
        elevation: 0, shadowColor: Colors.transparent,
        minimumSize: const Size(88, DairySpacing.touchTarget),
        padding: DairySpacing.buttonInternalPadding,
        shape: RoundedRectangleBorder(borderRadius: DairyRadius.buttonBorderRadius),
        textStyle: DairyTypography.button(isDark: true),
      )),
      outlinedButtonTheme: OutlinedButtonThemeData(style: OutlinedButton.styleFrom(
        foregroundColor: DairyColorsDark.textPrimary, disabledForegroundColor: DairyColorsDark.textDisabled,
        minimumSize: const Size(88, DairySpacing.touchTarget),
        padding: DairySpacing.buttonInternalPadding,
        side: const BorderSide(color: DairyColorsDark.border, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: DairyRadius.buttonBorderRadius),
        textStyle: DairyTypography.button(color: DairyColorsDark.textPrimary, isDark: true),
      )),
      textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(
        foregroundColor: palette.primary, minimumSize: const Size(64, DairySpacing.touchTarget),
        padding: const EdgeInsets.symmetric(horizontal: DairySpacing.md, vertical: DairySpacing.sm),
        textStyle: DairyTypography.button(color: palette.primary, isDark: true),
      )),
      cardTheme: CardThemeData(
        elevation: 0, color: DairyColorsDark.card, surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: DairyRadius.xlBorderRadius, side: const BorderSide(color: DairyColorsDark.border, width: 1)),
        margin: const EdgeInsets.all(DairySpacing.sm),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true, fillColor: DairyColorsDark.surface,
        hintStyle: DairyTypography.body(color: DairyColorsDark.textTertiary, isDark: true),
        labelStyle: DairyTypography.label(isDark: true),
        contentPadding: const EdgeInsets.symmetric(horizontal: DairySpacing.md, vertical: DairySpacing.buttonPaddingV),
        border: OutlineInputBorder(borderRadius: DairyRadius.defaultBorderRadius, borderSide: const BorderSide(color: DairyColorsDark.border)),
        enabledBorder: OutlineInputBorder(borderRadius: DairyRadius.defaultBorderRadius, borderSide: const BorderSide(color: DairyColorsDark.border)),
        focusedBorder: OutlineInputBorder(borderRadius: DairyRadius.defaultBorderRadius, borderSide: BorderSide(color: palette.primary, width: 2)),
        errorBorder: OutlineInputBorder(borderRadius: DairyRadius.defaultBorderRadius, borderSide: const BorderSide(color: DairyColorsDark.error)),
        focusedErrorBorder: OutlineInputBorder(borderRadius: DairyRadius.defaultBorderRadius, borderSide: const BorderSide(color: DairyColorsDark.error, width: 2)),
        disabledBorder: OutlineInputBorder(borderRadius: DairyRadius.defaultBorderRadius, borderSide: const BorderSide(color: DairyColorsDark.borderLight)),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: DairyColorsDark.background, selectedItemColor: palette.primary,
        unselectedItemColor: DairyColorsDark.textTertiary,
        selectedLabelStyle: DairyTypography.navLabel(color: palette.primary, isDark: true),
        unselectedLabelStyle: DairyTypography.navLabel(isDark: true),
        type: BottomNavigationBarType.fixed, elevation: 0, showUnselectedLabels: true,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: DairyColorsDark.background, surfaceTintColor: Colors.transparent,
        indicatorColor: palette.primarySurface,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return DairyTypography.navLabel(color: palette.primary, isDark: true);
          return DairyTypography.navLabel(isDark: true);
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return IconThemeData(color: palette.primary, size: 24);
          return const IconThemeData(color: DairyColorsDark.textTertiary, size: 24);
        }),
        height: 80, labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(backgroundColor: palette.primary, foregroundColor: DairyColorsDark.textOnPrimary, elevation: 4, shape: const StadiumBorder()),
      chipTheme: ChipThemeData(
        backgroundColor: DairyColorsDark.surface, selectedColor: palette.primarySurface,
        disabledColor: DairyColorsDark.surfaceVariant, labelStyle: DairyTypography.label(isDark: true),
        padding: const EdgeInsets.symmetric(horizontal: DairySpacing.sm, vertical: DairySpacing.xs),
        shape: RoundedRectangleBorder(borderRadius: DairyRadius.pillBorderRadius, side: const BorderSide(color: DairyColorsDark.border)),
      ),
      dividerTheme: const DividerThemeData(color: DairyColorsDark.divider, thickness: 1, space: DairySpacing.md),
      dialogTheme: DialogThemeData(
        backgroundColor: DairyColorsDark.surface, surfaceTintColor: Colors.transparent, elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: DairyRadius.xxlBorderRadius),
        titleTextStyle: DairyTypography.headingMedium(isDark: true), contentTextStyle: DairyTypography.body(isDark: true),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: DairyColorsDark.surface, surfaceTintColor: Colors.transparent, elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(DairyRadius.xxl))),
        showDragHandle: true, dragHandleColor: DairyColorsDark.borderLight,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: DairyColorsDark.surfaceVariant,
        contentTextStyle: DairyTypography.body(color: DairyColorsDark.textPrimary, isDark: true),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: DairyRadius.defaultBorderRadius),
        insetPadding: const EdgeInsets.all(DairySpacing.md),
      ),
      listTileTheme: ListTileThemeData(
        contentPadding: DairySpacing.listItemPadding, minVerticalPadding: DairySpacing.sm,
        shape: RoundedRectangleBorder(borderRadius: DairyRadius.defaultBorderRadius),
        titleTextStyle: DairyTypography.bodyLarge(isDark: true),
        subtitleTextStyle: DairyTypography.bodySmall(color: DairyColorsDark.textSecondary, isDark: true),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? palette.primary : DairyColorsDark.textTertiary),
        trackColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? palette.primarySurface : DairyColorsDark.borderLight),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? palette.primary : Colors.transparent),
        checkColor: WidgetStateProperty.all(DairyColorsDark.textOnPrimary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        side: const BorderSide(color: DairyColorsDark.border, width: 1.5),
      ),
      radioTheme: RadioThemeData(fillColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? palette.primary : DairyColorsDark.textTertiary)),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: palette.primary, linearTrackColor: palette.primarySurface, circularTrackColor: palette.primarySurface),
      tabBarTheme: TabBarThemeData(
        labelColor: palette.primary, unselectedLabelColor: DairyColorsDark.textSecondary,
        labelStyle: DairyTypography.label(color: palette.primary, isDark: true), unselectedLabelStyle: DairyTypography.label(isDark: true),
        indicator: UnderlineTabIndicator(borderSide: BorderSide(color: palette.primary, width: 2), borderRadius: BorderRadius.circular(2)),
        indicatorSize: TabBarIndicatorSize.label, dividerColor: Colors.transparent,
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(color: DairyColorsDark.surfaceVariant, borderRadius: DairyRadius.smallBorderRadius),
        textStyle: DairyTypography.caption(color: DairyColorsDark.textPrimary, isDark: true),
      ),
    );
  }

  static _RolePalette _getRolePalette(UserRole role, {required bool isDark}) {
    switch (role) {
      case UserRole.admin:
        return isDark
            ? _RolePalette(primary: _AdminPalette.primaryDarkMode, primaryLight: _AdminPalette.primaryLight, primaryDark: _AdminPalette.primaryDark, primarySurface: _AdminPalette.primarySurfaceDark, secondary: _AdminPalette.secondaryDarkMode, secondaryLight: _AdminPalette.secondaryLight, secondaryDark: _AdminPalette.secondaryDark, secondarySurface: _AdminPalette.secondarySurfaceDark)
            : _RolePalette(primary: _AdminPalette.primary, primaryLight: _AdminPalette.primaryLight, primaryDark: _AdminPalette.primaryDark, primarySurface: _AdminPalette.primarySurface, secondary: _AdminPalette.secondary, secondaryLight: _AdminPalette.secondaryLight, secondaryDark: _AdminPalette.secondaryDark, secondarySurface: _AdminPalette.secondarySurface);
      case UserRole.deliveryBoy:
        return isDark
            ? _RolePalette(primary: _DeliveryPalette.primaryDarkMode, primaryLight: _DeliveryPalette.primaryLight, primaryDark: _DeliveryPalette.primaryDark, primarySurface: _DeliveryPalette.primarySurfaceDark, secondary: _DeliveryPalette.secondaryDarkMode, secondaryLight: _DeliveryPalette.secondaryLight, secondaryDark: _DeliveryPalette.secondaryDark, secondarySurface: _DeliveryPalette.secondarySurfaceDark)
            : _RolePalette(primary: _DeliveryPalette.primary, primaryLight: _DeliveryPalette.primaryLight, primaryDark: _DeliveryPalette.primaryDark, primarySurface: _DeliveryPalette.primarySurface, secondary: _DeliveryPalette.secondary, secondaryLight: _DeliveryPalette.secondaryLight, secondaryDark: _DeliveryPalette.secondaryDark, secondarySurface: _DeliveryPalette.secondarySurface);
      case UserRole.customer:
        return isDark
            ? _RolePalette(primary: _CustomerPalette.primaryDarkMode, primaryLight: _CustomerPalette.primaryLight, primaryDark: _CustomerPalette.primaryDark, primarySurface: _CustomerPalette.primarySurfaceDark, secondary: _CustomerPalette.secondaryDarkMode, secondaryLight: _CustomerPalette.secondaryLight, secondaryDark: _CustomerPalette.secondaryDark, secondarySurface: _CustomerPalette.secondarySurfaceDark)
            : _RolePalette(primary: _CustomerPalette.primary, primaryLight: _CustomerPalette.primaryLight, primaryDark: _CustomerPalette.primaryDark, primarySurface: _CustomerPalette.primarySurface, secondary: _CustomerPalette.secondary, secondaryLight: _CustomerPalette.secondaryLight, secondaryDark: _CustomerPalette.secondaryDark, secondarySurface: _CustomerPalette.secondarySurface);
      case UserRole.none:
        return isDark
            ? _RolePalette(primary: _NeutralPalette.primaryDarkMode, primaryLight: _NeutralPalette.primaryLight, primaryDark: _NeutralPalette.primaryDark, primarySurface: _NeutralPalette.primarySurfaceDark, secondary: _NeutralPalette.secondaryDarkMode, secondaryLight: _NeutralPalette.secondaryLight, secondaryDark: _NeutralPalette.secondaryDark, secondarySurface: _NeutralPalette.secondarySurfaceDark)
            : _RolePalette(primary: _NeutralPalette.primary, primaryLight: _NeutralPalette.primaryLight, primaryDark: _NeutralPalette.primaryDark, primarySurface: _NeutralPalette.primarySurface, secondary: _NeutralPalette.secondary, secondaryLight: _NeutralPalette.secondaryLight, secondaryDark: _NeutralPalette.secondaryDark, secondarySurface: _NeutralPalette.secondarySurface);
    }
  }
}

class _RolePalette {
  final Color primary, primaryLight, primaryDark, primarySurface;
  final Color secondary, secondaryLight, secondaryDark, secondarySurface;
  const _RolePalette({required this.primary, required this.primaryLight, required this.primaryDark, required this.primarySurface, required this.secondary, required this.secondaryLight, required this.secondaryDark, required this.secondarySurface});
}

// ============================================================================
// THEME PROVIDER — Role-aware
// ============================================================================

class DairyThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  UserRole _role = UserRole.none;

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  UserRole get userRole => _role;

  ThemeData get lightTheme => DairyTheme.buildLightTheme(_role);
  ThemeData get darkTheme => DairyTheme.buildDarkTheme(_role);
  ThemeData get currentTheme => _themeMode == ThemeMode.dark ? darkTheme : lightTheme;

  void setRole(UserRole role) {
    if (_role != role) { _role = role; notifyListeners(); }
  }

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) {
    if (_themeMode != mode) { _themeMode = mode; notifyListeners(); }
  }

  void setLightMode() => setThemeMode(ThemeMode.light);
  void setDarkMode() => setThemeMode(ThemeMode.dark);
}

// ============================================================================
// CONTEXT EXTENSIONS
// ============================================================================

extension DairyThemeContext on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  TextTheme get textTheme => Theme.of(this).textTheme;
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;
  DairyColors get dairyColors => isDarkMode ? DairyColors.dark() : DairyColors.light();
}

/// Convenience class for theme-aware color access
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
  List<BoxShadow> get cardHoverShadow => isDark ? DairyColorsDark.elevatedShadow : DairyColorsLight.cardHoverShadow;
  List<BoxShadow> get elevatedShadow => isDark ? DairyColorsDark.elevatedShadow : DairyColorsLight.elevatedShadow;
  List<BoxShadow> get buttonShadow => isDark ? DairyColorsDark.buttonShadow : DairyColorsLight.buttonShadow;
  Color get danger => isDark ? DairyColorsDark.error : DairyColorsLight.danger;
}

// ============================================================================
// BACKWARD COMPATIBILITY - AppTheme Aliases
// ============================================================================

class AppTheme {
  AppTheme._();
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
  static const Color dangerRed = DairyColorsLight.danger;

  static const double space4 = DairySpacing.xs;
  static const double space8 = DairySpacing.sm;
  static const double space12 = 12.0;
  static const double space16 = DairySpacing.md;
  static const double space20 = 20.0;
  static const double space24 = DairySpacing.lg;
  static const double space32 = DairySpacing.xl;
  static const double space48 = DairySpacing.xxxl;
  static const double space64 = 64.0;

  static const double radiusSmall = DairyRadius.sm;
  static const double radiusMedium = DairyRadius.md;
  static const double radiusButton = DairyRadius.button;
  static const double radiusLarge = DairyRadius.lg;
  static const double radiusXLarge = DairyRadius.xl;
  static const double radiusPill = DairyRadius.pill;

  // Blue ecosystem gradients
  static const LinearGradient primaryButtonGradient = LinearGradient(colors: [Color(0xFF2563EB), Color(0xFF1E40AF)]);
  static const LinearGradient activeGradient = LinearGradient(colors: [DairyColorsLight.success, Color(0xFF16A34A)]);
  static const LinearGradient pendingGradient = LinearGradient(colors: [DairyColorsLight.warning, Color(0xFFD97706)]);
  static const LinearGradient deliveredGradient = LinearGradient(colors: [Color(0xFF2563EB), Color(0xFF60A5FA)]);
  static const LinearGradient dangerButtonGradient = LinearGradient(colors: [Color(0xFFEF4444), Color(0xFFDC2626)]);
  static const LinearGradient appBarGradient = LinearGradient(colors: [Color(0xFF2563EB), Color(0xFF1E40AF)]);
  static const LinearGradient premiumCardGradient = LinearGradient(colors: [Color(0xFF2563EB), Color(0xFF1E40AF)]);
  static const LinearGradient mainBackground = LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFFEFF6FF), Color(0xFFF8FAFC), Color(0xFFF1F5F9)]);
  static const LinearGradient productCardGradient = LinearGradient(colors: [DairyColorsLight.card, Color(0xFFEFF6FF)]);
  static const LinearGradient dashboardHeaderGradient = LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF2563EB), Color(0xFF60A5FA), Color(0xFFF8FAFC)], stops: [0.0, 0.6, 1.0]);
  static const LinearGradient secondaryButtonGradient = LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF4F46E5)]);
  static const LinearGradient sidebarGradient = LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF1E40AF), Color(0xFF172554)]);

  static List<BoxShadow> get cardShadow => DairyColorsLight.cardShadow;
  static List<BoxShadow> get cardHoverShadow => DairyColorsLight.cardHoverShadow;
  static List<BoxShadow> get premiumCardShadow => DairyColorsLight.elevatedShadow;
  static List<BoxShadow> get buttonShadow => DairyColorsLight.buttonShadow;
  static List<BoxShadow> productCardShadow(Color color) => [BoxShadow(color: color.withValues(alpha: 0.1), blurRadius: 12, offset: const Offset(0, 4))];

  static TextStyle get h1 => DairyTypography.headingXLarge();
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
  static TextStyle get caption => DairyTypography.caption();
}
