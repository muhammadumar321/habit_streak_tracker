import 'package:flutter/material.dart';

class Tip {
  final String title;
  final String description;
  final IconData icon;

  const Tip({
    required this.title,
    required this.description,
    required this.icon,
  });
}

const List<Tip> dailyTips = [
  Tip(
    title: 'Track Daily',
    description: 'Consistency is key! Mark your habits every day to build a streak.',
    icon: Icons.calendar_today,
  ),
  Tip(
    title: 'Swipe Actions',
    description: 'Swipe right on a habit to quickly mark it as complete.',
    icon: Icons.swipe_right,
  ),
  Tip(
    title: 'Edit Habits',
    description: 'Topic specific settings? Long press a habit card to edit or archive it.',
    icon: Icons.edit,
  ),
  Tip(
    title: 'Monitor Progress',
    description: 'Check the Progress tab to visualize your streaks and consistency.',
    icon: Icons.bar_chart,
  ),
  Tip(
    title: 'Stay Motivated',
    description: 'Try to beat your longest streak! You can do it!',
    icon: Icons.local_fire_department,
  ),
];
