import 'package:equatable/equatable.dart';
import '../../data/models/habit_model.dart';
import '../../data/models/habit_log_model.dart';

abstract class HabitState extends Equatable {
  const HabitState();
  
  @override
  List<Object?> get props => [];
}

class HabitInitial extends HabitState {}

class HabitLoading extends HabitState {}

class HabitLoaded extends HabitState {
  final List<Habit> habits;
  final Map<int, List<HabitLog>> habitLogs; // Map habitId -> logs

  const HabitLoaded({required this.habits, required this.habitLogs});

  @override
  List<Object?> get props => [habits, habitLogs];
}

class HabitOperationSuccess extends HabitState {
  final String message;
  const HabitOperationSuccess(this.message);
  
  @override
  List<Object?> get props => [message];
}

class HabitError extends HabitState {
  final String message;
  const HabitError(this.message);

  @override
  List<Object?> get props => [message];
}
