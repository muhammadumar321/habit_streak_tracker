import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:habityne/blocs/habit/habit_bloc.dart';
import 'package:habityne/blocs/habit/habit_event.dart';
import 'package:habityne/blocs/habit/habit_state.dart';
import 'package:habityne/data/repositories/habit_repository.dart';
import 'package:habityne/data/models/habit_model.dart';
import 'package:habityne/data/models/habit_log_model.dart';

class MockHabitRepository extends Mock implements HabitRepository {}

class FakeHabit extends Fake implements Habit {}

void main() {
  late HabitBloc habitBloc;
  late MockHabitRepository mockHabitRepository;

  setUpAll(() {
    registerFallbackValue(FakeHabit());
  });

  setUp(() {
    mockHabitRepository = MockHabitRepository();
    habitBloc = HabitBloc(repository: mockHabitRepository);
  });

  tearDown(() {
    habitBloc.close();
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

  final testLog = HabitLog(
    id: 1,
    habitId: 1,
    completedDate: DateTime(2023, 1, 1),
    completedAt: DateTime(2023, 1, 1, 10),
  );

  group('HabitBloc', () {
    test('initial state should be HabitInitial', () {
      expect(habitBloc.state, HabitInitial());
    });

    blocTest<HabitBloc, HabitState>(
      'emits [HabitLoading, HabitLoaded] when LoadHabits is successful',
      build: () {
        when(() => mockHabitRepository.getHabits()).thenAnswer((_) async => [testHabit]);
        when(() => mockHabitRepository.getAllLogs()).thenAnswer((_) async => [testLog]);
        return habitBloc;
      },
      act: (bloc) => bloc.add(LoadHabits()),
      expect: () => [
        HabitLoading(),
        HabitLoaded(
          habits: [testHabit],
          habitLogs: {1: [testLog]},
        ),
      ],
    );

    blocTest<HabitBloc, HabitState>(
      'emits [HabitError] when LoadHabits fails',
      build: () {
        when(() => mockHabitRepository.getHabits()).thenThrow(Exception('Failed to load'));
        return habitBloc;
      },
      act: (bloc) => bloc.add(LoadHabits()),
      expect: () => [
        HabitLoading(),
        const HabitError('Exception: Failed to load'),
      ],
    );

    blocTest<HabitBloc, HabitState>(
      'triggers LoadHabits after successful AddHabit',
      build: () {
        when(() => mockHabitRepository.insertHabit(any())).thenAnswer((_) async => 1);
        when(() => mockHabitRepository.getHabits()).thenAnswer((_) async => [testHabit]);
        when(() => mockHabitRepository.getAllLogs()).thenAnswer((_) async => []);
        return habitBloc;
      },
      act: (bloc) => bloc.add(AddHabit(habit: testHabit)),
      verify: (_) {
        verify(() => mockHabitRepository.insertHabit(testHabit)).called(1);
      },
    );

    blocTest<HabitBloc, HabitState>(
      'emits [HabitError] when AddHabit fails',
      build: () {
        when(() => mockHabitRepository.insertHabit(any())).thenThrow(Exception('Add failed'));
        return habitBloc;
      },
      act: (bloc) => bloc.add(AddHabit(habit: testHabit)),
      expect: () => [
        const HabitError('Failed to add habit: Exception: Add failed'),
      ],
    );
  });
}
