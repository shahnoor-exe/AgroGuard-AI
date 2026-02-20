import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/crop_recommendation_screen.dart';
import 'screens/disease_detection_screen.dart';
import 'screens/sensor_dashboard_screen.dart';
import 'screens/govt_portal_screen.dart';
import 'core/lang_provider.dart';

void main() {
  runApp(const AgroGuardAIApp());
}

// ─────────────────────────────────────────────────────────────────────────────
// AgroGuard AI by CoderPirates – Professional Farming Theme
// ─────────────────────────────────────────────────────────────────────────────

class AgroGuardAIApp extends StatelessWidget {
  const AgroGuardAIApp({Key? key}) : super(key: key);

  // Earthy, warm farming palette
  static const Color primaryGreen   = Color(0xFF2D6A4F);
  static const Color accentGreen    = Color(0xFF40916C);
  static const Color lightGreen     = Color(0xFF52B788);
  static const Color warmAmber      = Color(0xFFD4A373);
  static const Color earthBrown     = Color(0xFF6B4226);
  static const Color creamBg        = Color(0xFFFAFAF5);
  static const Color deepText       = Color(0xFF1B2A1B);
  static const Color softText       = Color(0xFF4A5D4A);
  static const Color goldenYellow   = Color(0xFFE9C46A);
  static const Color sunsetOrange   = Color(0xFFE76F51);

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<String>(
      valueListenable: AppLang.current,
      builder: (_, __, ___) => MaterialApp(
      title: AppStrings.t('appName'),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryGreen,
          brightness: Brightness.light,
          primary: primaryGreen,
          secondary: accentGreen,
          tertiary: warmAmber,
          surface: creamBg,
        ),
        scaffoldBackgroundColor: creamBg,
        appBarTheme: const AppBarTheme(
          backgroundColor: primaryGreen,
          elevation: 0,
          centerTitle: true,
          scrolledUnderElevation: 2,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
          iconTheme: IconThemeData(color: Colors.white),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
          ),
        ),
        cardTheme: CardTheme(
          elevation: 2,
          shadowColor: primaryGreen.withValues(alpha: 0.15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          clipBehavior: Clip.antiAlias,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryGreen,
            foregroundColor: Colors.white,
            elevation: 2,
            shadowColor: primaryGreen.withValues(alpha: 0.3),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, letterSpacing: 0.3),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: primaryGreen.withValues(alpha: 0.2)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: primaryGreen.withValues(alpha: 0.2)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: primaryGreen, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: sunsetOrange, width: 1.5),
          ),
          labelStyle: const TextStyle(color: softText),
          prefixIconColor: accentGreen,
        ),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: deepText, letterSpacing: -0.5),
          headlineMedium: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: deepText),
          titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: deepText),
          titleMedium: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: softText),
          bodyLarge: TextStyle(fontSize: 15, color: deepText, height: 1.5),
          bodyMedium: TextStyle(fontSize: 13, color: softText, height: 1.4),
          labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.5),
        ),
        dividerTheme: DividerThemeData(color: primaryGreen.withValues(alpha: 0.1), thickness: 1),
        progressIndicatorTheme: const ProgressIndicatorThemeData(color: primaryGreen),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: primaryGreen,
          contentTextStyle: const TextStyle(color: Colors.white, fontSize: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          behavior: SnackBarBehavior.floating,
        ),
      ),
      home: const HomeScreen(),
      routes: {
        '/crop': (context) => const CropRecommendationScreen(),
        '/disease': (context) => const DiseaseDetectionScreen(),
        '/sensors': (context) => const SensorDashboardScreen(),
        '/govt': (context) => const GovtPortalScreen(),
      },
    ),
  );
}
