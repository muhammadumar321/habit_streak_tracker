import 'package:flutter/material.dart';
import '../../data/models/habit_model.dart';

class AddEditHabitDialog extends StatefulWidget {
  final Habit? habit;

  const AddEditHabitDialog({super.key, this.habit});

  @override
  State<AddEditHabitDialog> createState() => _AddEditHabitDialogState();
}

class _AddEditHabitDialogState extends State<AddEditHabitDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;

  Color _selectedColor = Colors.blue;
  String _frequency = 'daily';
  TimeOfDay? _reminderTime;
  bool _reminderEnabled = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.habit?.name);
    _descriptionController =
        TextEditingController(text: widget.habit?.description);

    if (widget.habit != null) {
      if (widget.habit!.colorHex != null) {
        _selectedColor =
            Color(int.parse(widget.habit!.colorHex!.replaceFirst('#', '0xff')));
      }
      _frequency = widget.habit!.frequency;
      _reminderEnabled = widget.habit!.reminderEnabled;
      if (widget.habit!.reminderTime != null) {
        final parts = widget.habit!.reminderTime!.split(':');
        _reminderTime =
            TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(20),
        constraints: const BoxConstraints(maxWidth: 400),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.habit == null ? 'New Habit' : 'Edit Habit',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 20),

                // Name
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Habit Name',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.edit),
                  ),
                  maxLength: 100,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a name';
                    }
                    if (value.trim().length > 100) {
                      return 'Name too long (max 100 characters)';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Description
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description (Optional)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.description),
                  ),
                ),
                const SizedBox(height: 20),

                // Color Picker (Simple row for now)
                const Text('Color'),
                const SizedBox(height: 8),
                _buildColorPicker(),
                const SizedBox(height: 20),

                // Frequency
                DropdownButtonFormField<String>(
                  initialValue: _frequency,
                  decoration: const InputDecoration(
                    labelText: 'Frequency',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.repeat),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'daily', child: Text('Daily')),
                    DropdownMenuItem(value: 'weekly', child: Text('Weekly')),
                  ],
                  onChanged: (value) {
                    if (value != null) setState(() => _frequency = value);
                  },
                ),
                const SizedBox(height: 16),

                // Reminder
                SwitchListTile(
                  title: const Text('Daily Reminder'),
                  value: _reminderEnabled,
                  onChanged: (val) => setState(() => _reminderEnabled = val),
                  secondary: const Icon(Icons.alarm),
                  contentPadding: EdgeInsets.zero,
                ),

                if (_reminderEnabled)
                  ListTile(
                    title:
                        Text(_reminderTime?.format(context) ?? 'Select Time'),
                    leading: const Icon(Icons.access_time),
                    onTap: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: _reminderTime ?? TimeOfDay.now(),
                      );
                      if (time != null) {
                        setState(() => _reminderTime = time);
                      }
                    },
                  ),

                const SizedBox(height: 24),

                // Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _saveHabit,
                      child: const Text('Save'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildColorPicker() {
    final colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.indigo
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: colors.map((color) {
        final isSelected = _selectedColor.toARGB32() == color.toARGB32();
        return GestureDetector(
          onTap: () => setState(() => _selectedColor = color),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: isSelected
                    ? Border.all(color: Colors.black, width: 2)
                    : null,
                boxShadow: [
                  if (isSelected)
                    BoxShadow(
                        color: color.withValues(alpha: 0.4),
                        blurRadius: 6,
                        spreadRadius: 2)
                ]),
            child: isSelected
                ? const Icon(Icons.check, color: Colors.white, size: 20)
                : null,
          ),
        );
      }).toList(),
    );
  }

  void _saveHabit() {
    if (_formKey.currentState!.validate()) {
      if (_reminderEnabled && _reminderTime == null) {
        // Default to 9:00 AM if not set
        _reminderTime = const TimeOfDay(hour: 9, minute: 0);
      }

      final String colorHex =
          '#${_selectedColor.toARGB32().toRadixString(16).substring(2)}';
      final String? timeString = _reminderTime != null
          ? '${_reminderTime!.hour.toString().padLeft(2, '0')}:${_reminderTime!.minute.toString().padLeft(2, '0')}'
          : null;

      final newHabit = Habit(
        id: widget.habit?.id,
        name: _nameController.text,
        description: _descriptionController.text.isNotEmpty
            ? _descriptionController.text
            : null,
        colorHex: colorHex,
        frequency: _frequency,
        reminderEnabled: _reminderEnabled,
        reminderTime: _reminderEnabled ? timeString : null,
        createdAt: widget.habit?.createdAt ?? DateTime.now(),
        archived: widget.habit?.archived ?? false,
      );

      Navigator.pop(context, newHabit);
    }
  }
}
