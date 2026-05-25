import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_streak_tracker/presentation/widgets/habit_card.dart';
import 'package:habit_streak_tracker/data/models/habit_model.dart';

void main() {
  final testHabit = Habit(
    id: 1,
    name: 'Test Habit',
    description: 'Description',
    iconName: 'star',
    colorHex: '#000000',
    frequency: 'daily',
    createdAt: DateTime(2023, 1, 1),
  );

  testWidgets('HabitCard displays habit name and description', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: HabitCard(
            habit: testHabit,
            isCompleted: false,
            onMobilePressed: () {},
            onComplete: () {},
            onEdit: () {},
            onArchive: () {},
            onDelete: () {},
          ),
        ),
      ),
    );

    expect(find.text('Test Habit'), findsOneWidget);
    expect(find.text('Description'), findsOneWidget);
  });

  testWidgets('HabitCard triggers onComplete when checkbox is tapped', (WidgetTester tester) async {
    bool completed = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: HabitCard(
            habit: testHabit,
            isCompleted: false,
            onMobilePressed: () {},
            onComplete: () => completed = true,
            onEdit: () {},
            onArchive: () {},
            onDelete: () {},
          ),
        ),
      ),
    );

    // Find the checkbox and tap it
    await tester.tap(find.byType(Checkbox));
    await tester.pump();

    expect(completed, isTrue);
  });
}
