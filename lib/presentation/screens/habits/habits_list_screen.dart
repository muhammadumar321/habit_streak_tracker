import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../blocs/habit/habit_bloc.dart';
import '../../../../blocs/habit/habit_event.dart';
import '../../../../blocs/habit/habit_state.dart';
import '../../../../data/models/habit_model.dart';
import '../../widgets/habit_card.dart';
import '../../dialogs/add_edit_habit_dialog.dart';

class HabitsListScreen extends StatelessWidget {
  const HabitsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('All Habits'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Active'),
              Tab(text: 'Archived'),
            ],
          ),
        ),
        body: BlocBuilder<HabitBloc, HabitState>(
          builder: (context, state) {
            if (state is HabitLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is HabitLoaded) {
              return TabBarView(
                children: [
                  _buildHabitList(context, state.habits, archived: false),
                  _buildHabitList(context, state.habits, archived: true),
                ],
              );
            } else if (state is HabitError) {
              return Center(child: Text('Error: ${state.message}'));
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildHabitList(BuildContext context, List<Habit> habits, {required bool archived}) {
    final filteredHabits = habits.where((h) => h.archived == archived).toList();

    if (filteredHabits.isEmpty) {
      return Center(
        child: Text(
          archived ? 'No archived habits' : 'No active habits',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredHabits.length,
      itemBuilder: (context, index) {
        final habit = filteredHabits[index];
        // We need logs for sparkline, but we are inside _buildHabitList which doesn't have logs passed to it in the widget signature currently.
        // We need to update _buildHabitList signature too.
        return HabitCard(
          habit: habit,
          isCompleted: false,
          logs: const [], // Placeholder or pass from state
          onMobilePressed: () => _showEditHabitDialog(context, habit),
          onComplete: () {}, 
          onEdit: () => _showEditHabitDialog(context, habit),
          onArchive: () => _archiveHabit(context, habit),
          onDelete: () => _deleteHabit(context, habit),
        );
      },
    );
  }

  Future<void> _showEditHabitDialog(BuildContext context, Habit habit) async {
    final updatedHabit = await showDialog<Habit>(
      context: context, 
      builder: (_) => AddEditHabitDialog(habit: habit)
    );
    
    if (updatedHabit != null && context.mounted) {
      final toUpdate = updatedHabit.copyWith(id: habit.id); 
      context.read<HabitBloc>().add(UpdateHabit(habit: toUpdate));
    }
  }

  void _archiveHabit(BuildContext context, Habit habit) {
    context.read<HabitBloc>().add(ArchiveHabit(id: habit.id!, archive: !habit.archived));
  }

  void _deleteHabit(BuildContext context, Habit habit) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Habit?'),
        content: const Text('This will delete the habit and all its history permanently.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              context.read<HabitBloc>().add(DeleteHabit(id: habit.id!));
              Navigator.pop(ctx);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
