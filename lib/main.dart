import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'data/datasources/local/database_helper.dart';
import 'presentation/app.dart';
import 'core/services/reward_service.dart';
import 'core/services/ad_service.dart';
import 'core/di/injection_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init(); // Initialize DI container
  
  // Initialize monetization services
  await RewardService().init();
  await AdService().init();
  
  // Database
  // DatabaseHelper initializes lazily on first access
  final dbHelper = DatabaseHelper();
  // Ensure db is ready (optional but good for startup)
  await dbHelper.database;
  
  // Check if onboarding is complete
  final prefs = await SharedPreferences.getInstance();
  final onboardingComplete = prefs.getBool('onboarding_complete') ?? false;
  
  runApp(MyApp(showOnboarding: !onboardingComplete));
}
