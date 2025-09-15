// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:device_preview/device_preview.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import 'core/theme/app_theme.dart';
import 'core/services/database_service.dart';
import 'core/services/auth_service.dart';
import 'core/services/notification_service.dart';
import 'core/utils/app_router.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/theme_provider.dart';
import 'presentation/providers/event_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize services
  try {
    await DatabaseService.instance.initDatabase();
    print('Database initialized successfully');
  } catch (e) {
    print('Database initialization failed: $e');
    // Continue app startup even if database fails
  }
  
  try {
    await NotificationService.instance.initialize();
    print('Notification service initialized successfully');
  } catch (e) {
    print('Notification service initialization failed: $e');
    // Continue app startup even if notifications fail
  }

  // Set preferred orientations
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(
    DevicePreview(
      enabled: true, // Set to false for production
      tools: const [...DevicePreview.defaultTools],
      builder: (context) => const FusionFiestaApp(),
    ),
  );
}

class FusionFiestaApp extends StatelessWidget {
  const FusionFiestaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => EventProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp.router(
            title: 'FusionFiesta',
            debugShowCheckedModeBanner: false,

            // Device Preview Integration
            useInheritedMediaQuery: true,
            locale: DevicePreview.locale(context),

            // Theme Configuration
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,

            // Router Configuration
            routerConfig: AppRouter.router,

            // Combined builder for Device Preview and Text Theme
            builder: (context, child) {
              return DevicePreview.appBuilder(
                context,
                MediaQuery(
                  data: MediaQuery.of(
                    context,
                  ).copyWith(textScaler: TextScaler.linear(1.0)),
                  child: child!,
                ),
              );
            },
          );
        },
      ),
    );
  }
}

/// Global App Configuration
class AppConfig {
  static const String appName = 'fusion_fiesta_application_new';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'College Event Management System';

  // API Configuration (if needed in future)
  static const String baseUrl = 'https://api.fusionfiesta.com';
  static const String apiVersion = 'v1';

  // App Constants
  static const int maxFileSize = 10 * 1024 * 1024; // 10MB
  static const int maxImageSize = 5 * 1024 * 1024; // 5MB
  static const int defaultPageSize = 20;

  // Cache Configuration
  static const Duration cacheExpiry = Duration(hours: 24);
  static const Duration sessionTimeout = Duration(hours: 8);
}
