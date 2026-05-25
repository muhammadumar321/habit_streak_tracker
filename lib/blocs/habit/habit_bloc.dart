import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/habit_repository.dart';
import '../../data/models/habit_log_model.dart';
import 'habit_event.dart';
import 'habit_state.dart';

class HabitBloc extends Bloc<HabitEvent, HabitState> {
  final HabitRepository repository;

  HabitBloc({required this.repository}) : super(HabitInitial()) {
    on<LoadHabits>(_onLoadHabits);
    on<AddHabit>(_onAddHabit);
    on<UpdateHabit>(_onUpdateHabit);
    on<DeleteHabit>(_onDeleteHabit);
    on<ArchiveHabit>(_onArchiveHabit);
    on<LogHabitCompletion>(_onLogHabitCompletion);
    on<UndoHabitCompletion>(_onUndoHabitCompletion);
  }

  Future<void> _onLoadHabits(LoadHabits event, Emitter<HabitState> emit) async {
    emit(HabitLoading());
    try {
      final habits = await repository.getHabits();
      final logs = await repository.getAllLogs();
      
      final Map<int, List<HabitLog>> habitLogs = {};
      
      for (var log in logs) {
        if (!habitLogs.containsKey(log.habitId)) {
          habitLogs[log.habitId] = [];
        }
        habitLogs[log.habitId]!.add(log);
      }

      emit(HabitLoaded(habits: habits, habitLogs: habitLogs));
    } catch (e) {
      emit(HabitError(e.toString()));
    }
  }

  Future<void> _onAddHabit(AddHabit event, Emitter<HabitState> emit) async {
    try {
      await repository.insertHabit(event.habit);
      add(LoadHabits()); // Reload
    } catch (e) {
      emit(HabitError("Failed to add habit: ${e.toString()}"));
    }
  }

  Future<void> _onUpdateHabit(UpdateHabit event, Emitter<HabitState> emit) async {
    try {
      await repository.updateHabit(event.habit);
      add(LoadHabits());
    } catch (e) {
      emit(HabitError("Failed to update habit: ${e.toString()}"));
    }
  }

  Future<void> _onDeleteHabit(DeleteHabit event, Emitter<HabitState> emit) async {
    try {
      await repository.deleteHabit(event.id);
      add(LoadHabits());
    } catch (e) {
      emit(HabitError("Failed to delete habit: ${e.toString()}"));
    }
  }

  Future<void> _onArchiveHabit(ArchiveHabit event, Emitter<HabitState> emit) async {
    try {
      await repository.archiveHabit(event.id, event.archive);
      add(LoadHabits());
    } catch (e) {
      emit(HabitError("Failed to archive habit: ${e.toString()}"));
    }
  }

  Future<void> _onLogHabitCompletion(LogHabitCompletion event, Emitter<HabitState> emit) async {
    try {
      await repository.logCompletion(event.log);
      add(LoadHabits());
    } catch (e) {
      emit(HabitError("Failed to log completion: ${e.toString()}"));
    }
  }
  
  Future<void> _onUndoHabitCompletion(UndoHabitCompletion event, Emitter<HabitState> emit) async {
    try {
      await repository.deleteLogByDate(event.habitId, event.date);
      add(LoadHabits());
    } catch (e) {
      emit(HabitError("Failed to undo completion: ${e.toString()}"));
    }
  }
}
