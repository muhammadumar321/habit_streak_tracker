import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:habit_streak_tracker/data/repositories/habit_repository_impl.dart';
import 'package:habit_streak_tracker/data/datasources/local/database_helper.dart';
import 'package:habit_streak_tracker/data/models/habit_model.dart';
import 'package:habit_streak_tracker/core/constants/database_constants.dart';

class MockDatabaseHelper extends Mock implements DatabaseHelper {}

void main() {
  late HabitRepositoryImpl repository;
  late MockDatabaseHelper mockDatabaseHelper;

  setUp(() {
    mockDatabaseHelper = MockDatabaseHelper();
    repository = HabitRepositoryImpl(databaseHelper: mockDatabaseHelper);
  });

  final testHabit = Habit(
    id: 1,
    name: 'Test Habit',
    description: 'Description',
    iconName: 'star',
    colorHex: '#000000',
    frequency: 'daily',
    createdAt: DateTime(2023, 1, 1),
  );

  group('HabitRepositoryImpl', () {
    test('getHabits returns list of habits from database', () async {
      final habitMap = testHabit.toMap();
      when(() => mockDatabaseHelper.queryAll(DatabaseConstants.tableHabits))
          .thenAnswer((_) async => [habitMap]);

      final result = await repository.getHabits();

      expect(result.length, 1);
      expect(result.first.name, testHabit.name);
      verify(() => mockDatabaseHelper.queryAll(DatabaseConstants.tableHabits)).called(1);
    });

    test('insertHabit calls databaseHelper.insert', () async {
      when(() => mockDatabaseHelper.insert(any(), any()))
          .thenAnswer((_) async => 1);

      final result = await repository.insertHabit(testHabit);

      expect(result, 1);
      verify(() => mockDatabaseHelper.insert(DatabaseConstants.tableHabits, any())).called(1);
    });
  });
}
