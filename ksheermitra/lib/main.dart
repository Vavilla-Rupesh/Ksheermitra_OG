import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'config/dairy_theme.dart';
import 'services/api_service.dart';
import 'providers/auth_provider.dart';
import 'providers/subscription_provider.dart';
import 'providers/product_provider.dart';
import 'providers/customer_provider.dart';
import 'providers/delivery_boy_provider.dart';
import 'providers/area_provider.dart';
import 'providers/invoice_provider.dart';
import 'providers/dashboard_provider.dart';
import 'providers/notification_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/customer/customer_home.dart';
import 'screens/delivery_boy/delivery_home.dart';
import 'screens/admin/admin_home.dart';
import 'core/delivery_verification/di/service_locator.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize ServiceLocator based on build mode
  // For production builds: AppEnvironment.production
  // For debug builds: AppEnvironment.development (uses real GPS but with logging)
  // For emulator testing with ADB: AppEnvironment.emulator
  if (kReleaseMode) {
    ServiceLocator.initialize(AppEnvironment.production);
  } else {
    // Development mode - uses real GPS, supports ADB injection
    ServiceLocator.initialize(AppEnvironment.development);
  }

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ApiService>.value(value: ApiService()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => SubscriptionProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => CustomerProvider()),
        ChangeNotifierProvider(create: (_) => DeliveryBoyProvider()),
        ChangeNotifierProvider(create: (_) => AreaProvider()),
        ChangeNotifierProvider(create: (_) => InvoiceProvider()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => DairyThemeProvider()),
      ],
      child: Consumer<DairyThemeProvider>(
        builder: (context, dairyThemeProvider, _) {
          return MaterialApp(
            title: 'KsheerMitra',
            theme: DairyTheme.lightTheme,
            darkTheme: DairyTheme.darkTheme,
            themeMode: dairyThemeProvider.themeMode,
            debugShowCheckedModeBanner: false,
            home: const SplashScreen(),
            routes: {
              '/login': (context) => const LoginScreen(),
              '/customer-home': (context) => const CustomerHome(),
              '/delivery-home': (context) => const DeliveryHome(),
              '/admin-home': (context) => const AdminHome(),
            },
          );
        },
      ),
    );
  }
}
