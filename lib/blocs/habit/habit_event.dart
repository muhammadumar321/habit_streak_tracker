import 'package:equatable/equatable.dart';
import '../../data/models/habit_model.dart';
import '../../data/models/habit_log_model.dart';

abstract class HabitEvent extends Equatable {
  const HabitEvent();

  @override
  List<Object?> get props => [];
}

class LoadHabits extends HabitEvent {}

class AddHabit extends HabitEvent {
  final Habit habit;
  const AddHabit({required this.habit});

  @override
  List<Object?> get props => [habit];
}

class UpdateHabit extends HabitEvent {
  final Habit habit;
  const UpdateHabit({required this.habit});

  @override
  List<Object?> get props => [habit];
}

class DeleteHabit extends HabitEvent {
  final int id;
  const DeleteHabit({required this.id});

  @override
  List<Object?> get props => [id];
}

class ArchiveHabit extends HabitEvent {
  final int id;
  final bool archive;
  const ArchiveHabit({required this.id, required this.archive});

  @override
  List<Object?> get props => [id, archive];
}

class LogHabitCompletion extends HabitEvent {
  final HabitLog log;
  const LogHabitCompletion({required this.log});

  @override
  List<Object?> get props => [log];
}

class UndoHabitCompletion extends HabitEvent {
  final int habitId;
  final DateTime date;
  const UndoHabitCompletion({required this.habitId, required this.date});

  @override
  List<Object?> get props => [habitId, date];
}
