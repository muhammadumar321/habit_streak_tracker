import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'dart:math'; // For Random
import '../../../../blocs/habit/habit_bloc.dart';
import '../../../../blocs/habit/habit_event.dart';
import '../../../../blocs/habit/habit_state.dart';
import '../../../../data/models/habit_model.dart';
import '../../../../data/models/habit_log_model.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/utils/streak_calculator.dart';
import '../../widgets/date_timeline.dart';
import '../../widgets/habit_card.dart';
import '../../widgets/animated_habit_card.dart';
import '../../widgets/streak_badge.dart';
import '../../widgets/motivation_banner.dart';
import '../../../../core/constants/motivation_data.dart';
import '../../widgets/heatmap_grid.dart';
import '../../../../core/services/reward_service.dart';
import '../../../../core/services/ad_service.dart';
import '../../dialogs/add_edit_habit_dialog.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime _selectedDate = AppDateUtils.startOfDay(DateTime.now());
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  List<Habit> _displayHabits = [];
  Map<int, List<HabitLog>> _habitLogs = {};
  
  MotivationQuote? _dailyQuote;

  @override
  void initState() {
    super.initState();
    if (motivationQuotes.isNotEmpty) {
      _dailyQuote = motivationQuotes[Random().nextInt(motivationQuotes.length)];
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, // For glassmorphism effect
      appBar: AppBar(
        title: Column(
          children: [
            const Text('StreakMaster'), // Renamed app title
            Text(
              DateFormat('MMMM d, yyyy').format(_selectedDate),
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddHabitDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime(2023),
                lastDate: DateTime.now().add(const Duration(days: 30)),
              );
              if (date != null) {
                setState(() => _selectedDate = AppDateUtils.startOfDay(date));
              }
            },
          )
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
           gradient: RadialGradient(
             center: const Alignment(-0.5, -0.5),
             radius: 1.5,
             colors: [
               Theme.of(context).colorScheme.primary.withOpacity(0.1),
               Theme.of(context).colorScheme.background,
             ]
           )
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Timeline
              DateTimeline(
                selectedDate: _selectedDate,
                onDateSelected: (date) => setState(() => _selectedDate = date),
              ),
              const Divider(color: Colors.white10),
              
              // Motivation Banner
              if (_dailyQuote != null)
                MotivationBanner(quote: _dailyQuote!),
              
              // Heatmap Grid
              if (_habitLogs.isNotEmpty)
                HeatmapGrid(habitLogs: _habitLogs),
              
              // Habits List
              Expanded(
                child: BlocConsumer<HabitBloc, HabitState>(
                  listener: (context, state) {
                    if (state is HabitLoaded) {
                      _updateHabitList(state.habits, state.habitLogs);
                      // Check for reward unlock
                      RewardService().checkStreakUnlock(state.habits, state.habitLogs);
                    }
                  },
                  builder: (context, state) {
                    if (state is HabitLoading && _displayHabits.isEmpty) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is HabitLoaded || (state is HabitLoading && _displayHabits.isNotEmpty)) {
                      return _buildHabitList();
                    } else if (state is HabitError) {
                      return Center(child: Text('Error: ${state.message}'));
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
              // AdMob Banner
              SizedBox(
                width: double.infinity,
                height: 50,
                child: AdService().createBannerAdWidget(),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddHabitDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _updateHabitList(List<Habit> allHabits, Map<int, List<HabitLog>> allLogs) {
    final newActiveHabits = allHabits.where((h) => !h.archived).toList();
    _habitLogs = allLogs;

    // Simple diffing
    final oldHabitIds = _displayHabits.map((h) => h.id).toSet();
    final newHabitIds = newActiveHabits.map((h) => h.id).toSet();

    // Remove old items
    for (int i = _displayHabits.length - 1; i >= 0; i--) {
      final habit = _displayHabits[i];
      if (!newHabitIds.contains(habit.id)) {
        final removedHabit = _displayHabits.removeAt(i);
        _listKey.currentState?.removeItem(
          i,
          (context, animation) => _buildHabitItem(removedHabit, animation, i),
          duration: const Duration(milliseconds: 300),
        );
      }
    }

    // Add new items
    for (int i = 0; i < newActiveHabits.length; i++) {
      final habit = newActiveHabits[i];
      if (!oldHabitIds.contains(habit.id)) {
        _displayHabits.insert(i, habit);
        _listKey.currentState?.insertItem(i, duration: const Duration(milliseconds: 300));
      } else {
        // Update existing (just replace in list, handled by rebuild)
        final oldIndex = _displayHabits.indexWhere((h) => h.id == habit.id);
        if (oldIndex != -1) {
          _displayHabits[oldIndex] = habit;
        }
      }
    }
    
    setState(() {});
  }

  Widget _buildHabitList() {
    if (_displayHabits.isEmpty) {
      return RefreshIndicator(
        onRefresh: () async {
          context.read<HabitBloc>().add(LoadHabits());
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   Icon(Icons.list_alt, size: 64, color: Colors.grey),
                   SizedBox(height: 16),
                   Text('No habits yet', style: TextStyle(fontSize: 18, color: Colors.grey)),
                   SizedBox(height: 8),
                   Text('Tap + to add a new habit'),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<HabitBloc>().add(LoadHabits());
      },
      child: AnimatedList(
        key: _listKey,
        padding: const EdgeInsets.only(bottom: 80),
        initialItemCount: _displayHabits.length,
        itemBuilder: (context, index, animation) {
          if (index >= _displayHabits.length) return const SizedBox.shrink();
          return _buildHabitItem(_displayHabits[index], animation, index);
        },
      ),
    );
  }

  Widget _buildHabitItem(Habit habit, Animation<double> animation, int index) {
    final logs = _habitLogs[habit.id] ?? [];
    
    final isCompleted = logs.any((log) => 
        AppDateUtils.isSameDay(log.completedDate, _selectedDate));
        
    final currentStreak = StreakCalculator.calculateCurrentStreak(logs);

    return FadeTransition(
      opacity: animation,
      child: SizeTransition(
        sizeFactor: animation,
        child: Stack(
          children: [
            AnimatedHabitCard(
              index: index,
              habit: habit,
              isCompleted: isCompleted,
              logs: logs,
              onMobilePressed: () {
                _toggleCompletion(habit, isCompleted);
              },
              onComplete: () => _toggleCompletion(habit, isCompleted),
              onEdit: () => _showEditHabitDialog(context, habit),
              onArchive: () => _archiveHabit(habit),
              onDelete: () => _deleteHabit(habit),
            ),
            if (currentStreak > 0)
              Positioned(
                right: 24,
                top: 12,
                child: StreakBadge(streak: currentStreak),
              ),
          ],
        ),
      ),
    );
  }

  void _toggleCompletion(Habit habit, bool isCompleted) {
    final bloc = context.read<HabitBloc>();
    final habitId = habit.id;
    if (habitId == null) return;

    if (isCompleted) {
      bloc.add(UndoHabitCompletion(habitId: habitId, date: _selectedDate));
    } else {
      final log = HabitLog(
        habitId: habitId,
        completedDate: _selectedDate,
        completedAt: DateTime.now(),
      );
      bloc.add(LogHabitCompletion(log: log));
      AdService().incrementCompletionCount();
    }
  }

  Future<void> _showAddHabitDialog(BuildContext context) async {
    final habitState = context.read<HabitBloc>().state;
    final isUnlimited = RewardService().isUnlimitedUnlocked;

    if (!isUnlimited && habitState is HabitLoaded && habitState.habits.length >= 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reach a 5-day streak to unlock unlimited habits!'))
      );
      return;
    }

    final bloc = context.read<HabitBloc>();
    final habit = await showDialog<Habit>(
      context: context, 
      builder: (_) => const AddEditHabitDialog()
    );
    
    if (habit == null || !mounted) return;

    bloc.add(AddHabit(habit: habit));
  }

  Future<void> _showEditHabitDialog(BuildContext context, Habit habit) async {
    final bloc = context.read<HabitBloc>();
    final updatedHabit = await showDialog<Habit>(
      context: context, 
      builder: (_) => AddEditHabitDialog(habit: habit)
    );
    
    if (updatedHabit == null || !mounted) return;

    final toUpdate = updatedHabit.copyWith(id: habit.id); 
    bloc.add(UpdateHabit(habit: toUpdate));
  }

  void _archiveHabit(Habit habit) {
    final habitId = habit.id;
    if (habitId == null) return;
    context.read<HabitBloc>().add(ArchiveHabit(id: habitId, archive: !habit.archived));
  }

  void _deleteHabit(Habit habit) {
    final habitId = habit.id;
    if (habitId == null) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Habit?'),
        content: const Text('This will delete the habit and all its history permanently.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              context.read<HabitBloc>().add(DeleteHabit(id: habitId));
              Navigator.pop(ctx);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
