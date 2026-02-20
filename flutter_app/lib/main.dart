import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/providers/app_providers.dart';
import 'core/services/api_service.dart';
import 'core/services/notification_service.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AgroGuardAI());
}

class AgroGuardAI extends StatelessWidget {
  const AgroGuardAI({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PredictionProvider()),
        ChangeNotifierProvider(create: (_) => SensorProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => NotificationService()),
        Provider<ApiService>(create: (_) => ApiService()),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, _) => MaterialApp(
            title: 'AgroGuard AI By CoderPirate',
            debugShowCheckedModeBanner: false,
            themeMode: settingsProvider.themeMode,
            theme: _buildLightTheme(),
            darkTheme: _buildDarkTheme(),
            home: const HomeScreen(),
          ),
      ),
    );

  ThemeData _buildLightTheme() => ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF2D822D),
        brightness: Brightness.light,
      ),
      appBarTheme: const AppBarTheme(
        elevation: 2,
        backgroundColor: Color(0xFF2D822D),
        foregroundColor: Colors.white,
      ),
      scaffoldBackgroundColor: const Color(0xFFFAFAFA),
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );

  ThemeData _buildDarkTheme() => ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF4CAF50),
        brightness: Brightness.dark,
      ),
      appBarTheme: const AppBarTheme(
        elevation: 2,
        backgroundColor: Color(0xFF1a1a1a),
        foregroundColor: Colors.white,
      ),
      scaffoldBackgroundColor: const Color(0xFF121212),
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: const Color(0xFF1e1e1e),
      ),
    );
}
