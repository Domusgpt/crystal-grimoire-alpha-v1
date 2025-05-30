import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:universal_platform/universal_platform.dart';

// Services
import 'services/app_state.dart';
import 'services/auth_service.dart';
import 'services/payment_service.dart';
import 'services/ads_service.dart';
import 'firebase_options.dart';

// Screens
import 'screens/home_screen.dart';
import 'config/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase (skip for web in development)
  try {
    if (!UniversalPlatform.isWeb) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  } catch (e) {
    print('Firebase initialization failed: $e');
  }
  
  // Initialize services
  await _initializeServices();
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF0F0F23),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  
  runApp(const CrystalGrimoireApp());
}

Future<void> _initializeServices() async {
  try {
    // Initialize payment service (mobile only)
    if (UniversalPlatform.isAndroid || UniversalPlatform.isIOS) {
      await PaymentService.initialize();
    }
    
    // Initialize ads service (mobile only)
    if (UniversalPlatform.isAndroid || UniversalPlatform.isIOS) {
      await AdsService.initialize();
    }
  } catch (e) {
    print('Service initialization failed: $e');
  }
}

class CrystalGrimoireApp extends StatelessWidget {
  const CrystalGrimoireApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppState()),
      ],
      child: MaterialApp(
        title: 'Crystal Grimoire',
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark(),
        home: const HomeScreen(),
        routes: {
          '/home': (context) => const HomeScreen(),
        },
      ),
    );
  }
}