import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habityne/presentation/widgets/habit_card.dart';
import 'package:habityne/data/models/habit_model.dart';

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

  testWidgets('HabitCard triggers onComplete when circle icon is tapped', (WidgetTester tester) async {
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

    // Tap the circle_outlined icon to complete the habit
    await tester.tap(find.byIcon(Icons.circle_outlined));
    await tester.pump();

    expect(completed, isTrue);
  });
}
