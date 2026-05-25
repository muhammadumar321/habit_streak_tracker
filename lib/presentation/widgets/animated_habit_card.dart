import 'package:flutter/material.dart';
import 'habit_card.dart';
import '../../data/models/habit_model.dart';
import '../../data/models/habit_log_model.dart';

class AnimatedHabitCard extends StatefulWidget {
  final Habit habit;
  final bool isCompleted;
  final List<HabitLog> logs;
  final VoidCallback onMobilePressed;
  final VoidCallback onComplete;
  final VoidCallback onEdit;
  final VoidCallback onArchive;
  final VoidCallback onDelete;
  final int index;

  const AnimatedHabitCard({
    super.key,
    required this.habit,
    required this.isCompleted,
    required this.logs,
    required this.onMobilePressed,
    required this.onComplete,
    required this.onEdit,
    required this.onArchive,
    required this.onDelete,
    required this.index,
  });

  @override
  State<AnimatedHabitCard> createState() => _AnimatedHabitCardState();
}

class _AnimatedHabitCardState extends State<AnimatedHabitCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 400 + (widget.index * 100)),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.4, 1.0, curve: Curves.easeIn),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.4, 1.0, curve: Curves.easeOutCubic),
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: HabitCard(
          habit: widget.habit,
          isCompleted: widget.isCompleted,
          logs: widget.logs,
          onMobilePressed: widget.onMobilePressed,
          onComplete: widget.onComplete,
          onEdit: widget.onEdit,
          onArchive: widget.onArchive,
          onDelete: widget.onDelete,
        ),
      ),
    );
  }
}
