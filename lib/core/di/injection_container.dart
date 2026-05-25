import 'package:get_it/get_it.dart';
import '../../data/datasources/local/database_helper.dart';
import '../../data/repositories/habit_repository.dart';
import '../../data/repositories/habit_repository_impl.dart';
import '../../blocs/habit/habit_bloc.dart';
import '../../blocs/settings/settings_bloc.dart';

import '../../data/repositories/settings_repository.dart';
import '../../data/repositories/settings_repository_impl.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Blocs
  sl.registerFactory(() => HabitBloc(repository: sl()));
  sl.registerFactory(() => SettingsBloc(repository: sl()));
  sl.registerFactory(() => StatisticsBloc(repository: sl()));

  // Repositories
  sl.registerLazySingleton<HabitRepository>(
    () => HabitRepositoryImpl(databaseHelper: sl()),
  );
  sl.registerLazySingleton<SettingsRepository>(
    () => SettingsRepositoryImpl(databaseHelper: sl()),
  );

  // Data sources
  sl.registerLazySingleton(() => DatabaseHelper());
}
