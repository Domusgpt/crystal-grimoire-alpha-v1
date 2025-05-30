import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/app_state.dart';
import 'config/enhanced_theme.dart';
import 'screens/enhanced_home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Skip Firebase initialization for web demo
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState(),
      child: const CrystalGrimoireApp(),
    ),
  );
}

class CrystalGrimoireApp extends StatelessWidget {
  const CrystalGrimoireApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Crystal Grimoire ULTIMATE',
      theme: CrystalGrimoireTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      home: const EnhancedHomeScreen(),
    );
  }
}