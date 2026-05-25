import 'package:equatable/equatable.dart';

abstract class StatisticsState extends Equatable {
  const StatisticsState();

  @override
  List<Object?> get props => [];
}

class StatisticsInitial extends StatisticsState {}

class StatisticsLoading extends StatisticsState {}

class StatisticsLoaded extends StatisticsState {
  final int totalHabits;
  final int totalCompletions;
  final int bestStreak;
  final double completionRate; // 0.0 to 1.0 (overall)
  final Map<DateTime, int> heatmapData; // Date -> Count/Intensity
  final List<double> weeklyCompletion; // Last 7 days or weeks data for chart

  const StatisticsLoaded({
    required this.totalHabits,
    required this.totalCompletions,
    required this.bestStreak,
    required this.completionRate,
    required this.heatmapData,
    required this.weeklyCompletion,
  });

  @override
  List<Object?> get props => [
        totalHabits,
        totalCompletions,
        bestStreak,
        completionRate,
        heatmapData,
        weeklyCompletion,
      ];
}

class StatisticsError extends StatisticsState {
  final String message;

  const StatisticsError(this.message);

  @override
  List<Object?> get props => [message];
}
