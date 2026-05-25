import 'package:flutter/material.dart';
import '../../core/utils/date_utils.dart';

class DateTimeline extends StatefulWidget {
  final DateTime selectedDate;
  final Function(DateTime) onDateSelected;

  const DateTimeline({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  State<DateTimeline> createState() => _DateTimelineState();
}

class _DateTimelineState extends State<DateTimeline> {
  late ScrollController _scrollController;
  final int _daysBefore = 30;
  final int _daysAfter = 7;

  @override
  void initState() {
    super.initState();
    // Calculate initial scroll position to center "Today" or selected date
    // Item width (60) + margin (8) = 68
    // We want to scroll to the index of today.
    // Index 0 is (Today - 30). Today is at index 30.
    // Wait for build to scroll
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollToDate(widget.selectedDate);
      }
    });
  }
  
  @override
  void didUpdateWidget(DateTimeline oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedDate != widget.selectedDate) {
       _scrollToDate(widget.selectedDate);
    }
  }

  void _scrollToDate(DateTime date) {
      final today = AppDateUtils.startOfDay(DateTime.now());
      final diff = date.difference(today.subtract(Duration(days: _daysBefore))).inDays;
      final index = diff.clamp(0, _daysBefore + _daysAfter);
      
      // Center the item: (Screen Width / 2) - (Item Width / 2)
      // For simplicity, just scroll to index * itemWidth
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          index * 68.0 - (MediaQuery.of(context).size.width / 2) + 34, 
          duration: const Duration(milliseconds: 300), 
          curve: Curves.easeInOut
        );
      }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final today = AppDateUtils.startOfDay(DateTime.now());
    final startDate = today.subtract(Duration(days: _daysBefore));
    final totalDays = _daysBefore + _daysAfter + 1;

    return SizedBox(
      height: 90,
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        itemCount: totalDays,
        itemBuilder: (context, index) {
          final date = startDate.add(Duration(days: index));
          final isSelected = AppDateUtils.isSameDay(date, widget.selectedDate);
          final isToday = AppDateUtils.isSameDay(date, today);

          return GestureDetector(
            onTap: () => widget.onDateSelected(date),
            child: Container(
              width: 60,
              margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: isToday && !isSelected 
                    ? Border.all(color: Theme.of(context).colorScheme.primary, width: 2)
                    : null,
                boxShadow: isSelected 
                    ? [BoxShadow(color: Theme.of(context).colorScheme.primary.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))] 
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _getWeekday(date.weekday),
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    date.day.toString(),
                    style: TextStyle(
                      color: isSelected ? Colors.white : Theme.of(context).textTheme.bodyLarge?.color,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _getWeekday(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }
}
