import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ── Color System ──────────────────────────────────────────────────
class AppColors {
  AppColors._();

  // Primary palette (dark navy)
  static const Color primary900 = Color(0xFF0A0E27);
  static const Color primary800 = Color(0xFF0F1535);
  static const Color primary700 = Color(0xFF141C42);
  static const Color primary600 = Color(0xFF1A2456);
  static const Color primary500 = Color(0xFF1E3A5F);
  static const Color primary400 = Color(0xFF2B4C7E);
  static const Color primary300 = Color(0xFF3D6098);
  static const Color primary200 = Color(0xFF5A82B4);
  static const Color primary100 = Color(0xFF8BADD4);
  static const Color primary50 = Color(0xFFC5D8ED);

  // Accent — Cyan
  static const Color accent900 = Color(0xFF003B4D);
  static const Color accent800 = Color(0xFF005066);
  static const Color accent700 = Color(0xFF006B80);
  static const Color accent600 = Color(0xFF008599);
  static const Color accent500 = Color(0xFF00BCD4); // primary cyan
  static const Color accent400 = Color(0xFF26C6DA);
  static const Color accent300 = Color(0xFF4DD0E1);
  static const Color accent200 = Color(0xFF80DEEA);
  static const Color accent100 = Color(0xFFB2EBF2);
  static const Color accent50 = Color(0xFFE0F7FA);

  // Secondary — Teal
  static const Color secondary500 = Color(0xFF009688);
  static const Color secondary400 = Color(0xFF26A69A);
  static const Color secondary300 = Color(0xFF4DB6AC);
  static const Color secondary200 = Color(0xFF80CBC4);
  static const Color secondary100 = Color(0xFFB2DFDB);

  // Semantic
  static const Color success600 = Color(0xFF2E7D32);
  static const Color success500 = Color(0xFF4CAF50);
  static const Color success400 = Color(0xFF66BB6A);
  static const Color success100 = Color(0xFFC8E6C9);
  static const Color success50 = Color(0xFFE8F5E9);

  static const Color warning600 = Color(0xFFF57F17);
  static const Color warning500 = Color(0xFFFFC107);
  static const Color warning400 = Color(0xFFFFCA28);
  static const Color warning300 = Color(0xFFFFD54F);
  static const Color warning100 = Color(0xFFFFF9C4);

  static const Color error600 = Color(0xFFC62828);
  static const Color error500 = Color(0xFFF44336);
  static const Color error400 = Color(0xFFEF5350);
  static const Color error100 = Color(0xFFFFCDD2);
  static const Color error50 = Color(0xFFFFEBEE);

  static const Color info500 = Color(0xFF2196F3);
  static const Color info100 = Color(0xFFBBDEFB);

  // Neutrals
  static const Color neutral900 = Color(0xFF171717);
  static const Color neutral800 = Color(0xFF262626);
  static const Color neutral700 = Color(0xFF404040);
  static const Color neutral600 = Color(0xFF525252);
  static const Color neutral500 = Color(0xFF737373);
  static const Color neutral400 = Color(0xFFA3A3A3);
  static const Color neutral300 = Color(0xFFD4D4D4);
  static const Color white = Color(0xFFFFFFFF);

  // Convenience aliases
  static const Color background = primary900;
  static const Color surface = primary800;
  static const Color surfaceVariant = primary700;
  static const Color textPrimary = white;
  static const Color textSecondary = primary100;
  static const Color textMuted = primary200;
  static const Color cyan = accent500;
  static const Color teal = secondary500;
}

// ── Spacing System (4px base) ─────────────────────────────────────
class AppSpacing {
  AppSpacing._();

  static const double s1 = 4;
  static const double s2 = 8;
  static const double s3 = 12;
  static const double s4 = 16;
  static const double s5 = 20;
  static const double s6 = 24;
  static const double s7 = 28;
  static const double s8 = 32;
  static const double s10 = 40;
  static const double s12 = 48;
  static const double s14 = 56;
  static const double s16 = 64;
  static const double s20 = 80;
  static const double s24 = 96;
}

// ── Border Radius ─────────────────────────────────────────────────
class AppRadius {
  AppRadius._();

  static const double xs = 4;
  static const double sm = 6;
  static const double md = 8;
  static const double lg = 12;
  static const double xl = 16;
  static const double xl2 = 20;
  static const double xl3 = 24;
  static const double full = 9999;

  static const BorderRadius xsBorder = BorderRadius.all(Radius.circular(xs));
  static const BorderRadius smBorder = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius mdBorder = BorderRadius.all(Radius.circular(md));
  static const BorderRadius lgBorder = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius xlBorder = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius xl2Border = BorderRadius.all(Radius.circular(xl2));
  static const BorderRadius xl3Border = BorderRadius.all(Radius.circular(xl3));
  static const BorderRadius fullBorder = BorderRadius.all(
    Radius.circular(full),
  );
}

// ── Gradients ─────────────────────────────────────────────────────
class AppGradients {
  AppGradients._();

  static const LinearGradient accent = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.accent500, AppColors.secondary500],
  );

  static const LinearGradient hero = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.primary900, AppColors.primary500, AppColors.accent500],
    stops: [0.0, 0.5, 1.0],
  );

  static const LinearGradient primary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.primary500, AppColors.primary800],
  );

  static const LinearGradient card = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0x1400BCD4), Color(0x0A1E3A5F)],
  );

  static const LinearGradient warm = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.accent500, AppColors.accent300, AppColors.accent200],
    stops: [0.0, 0.5, 1.0],
  );
}

// ── Shadows ───────────────────────────────────────────────────────
class AppShadows {
  AppShadows._();

  static List<BoxShadow> get sm => [
    BoxShadow(
      color: const Color(0xFF0A0E27).withValues(alpha: 0.1),
      blurRadius: 3,
      offset: const Offset(0, 1),
    ),
  ];

  static List<BoxShadow> get md => [
    BoxShadow(
      color: const Color(0xFF0A0E27).withValues(alpha: 0.1),
      blurRadius: 6,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get lg => [
    BoxShadow(
      color: const Color(0xFF0A0E27).withValues(alpha: 0.1),
      blurRadius: 15,
      offset: const Offset(0, 10),
    ),
  ];

  static List<BoxShadow> get glowCyan => [
    BoxShadow(
      color: AppColors.accent500.withValues(alpha: 0.3),
      blurRadius: 20,
      spreadRadius: 0,
    ),
    BoxShadow(
      color: AppColors.accent500.withValues(alpha: 0.1),
      blurRadius: 60,
      spreadRadius: 0,
    ),
  ];
}

// ── Typography ────────────────────────────────────────────────────
class AppTextStyles {
  AppTextStyles._();

  // Display — Sora (headings, logo)
  static TextStyle displayLarge = GoogleFonts.sora(
    fontSize: 40,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
    letterSpacing: -1,
  );

  static TextStyle displayMedium = GoogleFonts.sora(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
  );

  static TextStyle displaySmall = GoogleFonts.sora(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.3,
  );

  static TextStyle headlineLarge = GoogleFonts.sora(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static TextStyle headlineMedium = GoogleFonts.sora(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  // Body — Inter (body text, UI labels)
  static TextStyle bodyLarge = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.6,
  );

  static TextStyle bodyMedium = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.5,
  );

  static TextStyle bodySmall = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textMuted,
    height: 1.4,
  );

  static TextStyle labelLarge = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: 0.1,
  );

  static TextStyle labelMedium = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    letterSpacing: 0.5,
  );

  static TextStyle labelSmall = GoogleFonts.inter(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: AppColors.textMuted,
    letterSpacing: 1.5,
  );

  // Mono — JetBrains Mono (code, tokens)
  static TextStyle mono = GoogleFonts.jetBrainsMono(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.accent300,
  );

  // Special
  static TextStyle logoDisplay = GoogleFonts.sora(
    fontSize: 28,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.5,
    color: AppColors.textPrimary,
  );

  static TextStyle tagline = GoogleFonts.inter(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 3,
    color: AppColors.primary300,
  );

  static TextStyle buttonLabel = GoogleFonts.inter(
    fontSize: 15,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.3,
    color: AppColors.white,
  );
}

// ── Main Theme ────────────────────────────────────────────────────
class AppTheme {
  AppTheme._();

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,

      colorScheme: const ColorScheme.dark(
        primary: AppColors.accent500,
        onPrimary: AppColors.white,
        secondary: AppColors.secondary500,
        onSecondary: AppColors.white,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
        surfaceContainer: AppColors.surfaceVariant,
        error: AppColors.error500,
        onError: AppColors.white,
      ),

      // AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AppTextStyles.headlineMedium,
      ),

      // Bottom navigation
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.accent500,
        unselectedItemColor: AppColors.primary300,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),

      // Elevated button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent500,
          foregroundColor: AppColors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.s6,
            vertical: AppSpacing.s4,
          ),
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.lgBorder),
          textStyle: AppTextStyles.buttonLabel,
        ),
      ),

      // Outlined button
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.accent500,
          side: const BorderSide(color: AppColors.accent500),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.s6,
            vertical: AppSpacing.s4,
          ),
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.lgBorder),
        ),
      ),

      // Text button
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: AppColors.accent500),
      ),

      // Input fields
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceVariant,
        border: const OutlineInputBorder(
          borderRadius: AppRadius.lgBorder,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.lgBorder,
          borderSide: BorderSide(
            color: AppColors.primary400.withValues(alpha: 0.5),
          ),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: AppRadius.lgBorder,
          borderSide: BorderSide(color: AppColors.accent500),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: AppRadius.lgBorder,
          borderSide: BorderSide(color: AppColors.error500),
        ),
        labelStyle: AppTextStyles.bodyMedium,
        hintStyle: AppTextStyles.bodyMedium,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s4,
          vertical: AppSpacing.s4,
        ),
      ),

      // Card
      cardTheme: const CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.xlBorder),
        margin: EdgeInsets.all(AppSpacing.s2),
      ),

      // Chip
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceVariant,
        selectedColor: AppColors.accent500.withValues(alpha: 0.2),
        labelStyle: AppTextStyles.labelMedium,
        side: BorderSide(color: AppColors.primary400.withValues(alpha: 0.3)),
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.fullBorder),
      ),

      // Divider
      dividerTheme: DividerThemeData(
        color: AppColors.primary400.withValues(alpha: 0.3),
        thickness: 1,
      ),

      // Snackbar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.surfaceVariant,
        contentTextStyle: AppTextStyles.bodyMedium,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.lgBorder),
        behavior: SnackBarBehavior.floating,
      ),

      // Text theme
      textTheme: TextTheme(
        displayLarge: AppTextStyles.displayLarge,
        displayMedium: AppTextStyles.displayMedium,
        displaySmall: AppTextStyles.displaySmall,
        headlineLarge: AppTextStyles.headlineLarge,
        headlineMedium: AppTextStyles.headlineMedium,
        bodyLarge: AppTextStyles.bodyLarge,
        bodyMedium: AppTextStyles.bodyMedium,
        bodySmall: AppTextStyles.bodySmall,
        labelLarge: AppTextStyles.labelLarge,
        labelMedium: AppTextStyles.labelMedium,
        labelSmall: AppTextStyles.labelSmall,
      ),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFF5F7FF),
      colorScheme: const ColorScheme.light(
        primary: AppColors.accent500,
        onPrimary: AppColors.white,
        secondary: AppColors.secondary500,
        surface: AppColors.white,
        onSurface: Color(0xFF0A0E27),
        surfaceContainer: Color(0xFFEEF1FF),
        error: AppColors.error500,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.white,
        foregroundColor: const Color(0xFF0A0E27),
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AppTextStyles.headlineMedium.copyWith(
          color: const Color(0xFF0A0E27),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent500,
          foregroundColor: AppColors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.s6,
            vertical: AppSpacing.s4,
          ),
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.lgBorder),
          textStyle: AppTextStyles.buttonLabel,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFEEF1FF),
        border: const OutlineInputBorder(
          borderRadius: AppRadius.lgBorder,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.lgBorder,
          borderSide: BorderSide(
            color: AppColors.accent500.withValues(alpha: 0.2),
          ),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: AppRadius.lgBorder,
          borderSide: BorderSide(color: AppColors.accent500),
        ),
        labelStyle: const TextStyle(color: Color(0xFF5A82B4)),
        hintStyle: const TextStyle(color: Color(0xFF5A82B4)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s4,
          vertical: AppSpacing.s4,
        ),
      ),
      cardTheme: const CardThemeData(
        color: AppColors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.xlBorder),
      ),
      textTheme: TextTheme(
        displayLarge: AppTextStyles.displayLarge.copyWith(
          color: const Color(0xFF0A0E27),
        ),
        displayMedium: AppTextStyles.displayMedium.copyWith(
          color: const Color(0xFF0A0E27),
        ),
        displaySmall: AppTextStyles.displaySmall.copyWith(
          color: const Color(0xFF0A0E27),
        ),
        headlineLarge: AppTextStyles.headlineLarge.copyWith(
          color: const Color(0xFF0A0E27),
        ),
        headlineMedium: AppTextStyles.headlineMedium.copyWith(
          color: const Color(0xFF0A0E27),
        ),
        bodyLarge: AppTextStyles.bodyLarge.copyWith(
          color: const Color(0xFF0A0E27),
        ),
        bodyMedium: AppTextStyles.bodyMedium.copyWith(
          color: const Color(0xFF3D6098),
        ),
        bodySmall: AppTextStyles.bodySmall.copyWith(
          color: const Color(0xFF5A82B4),
        ),
        labelLarge: AppTextStyles.labelLarge.copyWith(
          color: const Color(0xFF0A0E27),
        ),
        labelMedium: AppTextStyles.labelMedium.copyWith(
          color: const Color(0xFF3D6098),
        ),
        labelSmall: AppTextStyles.labelSmall.copyWith(
          color: const Color(0xFF5A82B4),
        ),
      ),
    );
  }
}
