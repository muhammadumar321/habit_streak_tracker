import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:habityne/blocs/habit/habit_bloc.dart';
import 'package:habityne/blocs/habit/habit_event.dart';
import 'package:habityne/blocs/settings/settings_bloc.dart';
import 'package:habityne/blocs/settings/settings_event.dart';
import 'package:habityne/blocs/settings/settings_state.dart';
import 'package:habityne/blocs/statistics/statistics_bloc.dart';
import 'package:habityne/blocs/statistics/statistics_event.dart';
import 'package:habityne/core/di/injection_container.dart';
import 'package:habityne/core/theme/app_theme.dart';
import 'package:habityne/presentation/screens/main_screen.dart';
import 'package:habityne/presentation/screens/onboarding/onboarding_screen.dart';

class MyApp extends StatelessWidget {
  final bool showOnboarding;

  const MyApp({super.key, this.showOnboarding = false});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<HabitBloc>()..add(LoadHabits())),
        BlocProvider(create: (_) => sl<SettingsBloc>()..add(LoadSettings())),
        BlocProvider(
          create: (_) => sl<StatisticsBloc>()..add(LoadStatistics()),
        ),
      ],
      child: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) {
          return MaterialApp(
            title: 'Habityne',
            theme: AppTheme.darkTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.dark, // Enforce dark mode
            initialRoute: showOnboarding ? '/onboarding' : '/',
            routes: {
              '/': (context) => const MainScreen(),
              '/onboarding': (context) => const OnboardingScreen(),
            },
          );
        },
      ),
    );
  }
}
