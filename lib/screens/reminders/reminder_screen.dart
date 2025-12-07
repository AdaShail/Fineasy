import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/reminder_service.dart';

class ReminderScreen extends StatefulWidget {
  const ReminderScreen({super.key});

  @override
  State<ReminderScreen> createState() => _ReminderScreenState();
}

class _ReminderScreenState extends State<ReminderScreen> {
  List<ReminderModel> _reminders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReminders();
  }

  Future<void> _loadReminders() async {
    try {
      final reminders = await ReminderService.getAllReminders();
      setState(() {
        _reminders = reminders;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reminders'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddReminderDialog(),
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _reminders.isEmpty
              ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.notifications_off, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'No reminders set',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Tap + to add your first reminder',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              )
              : RefreshIndicator(
                onRefresh: _loadReminders,
                child: ListView.builder(
                  itemCount: _reminders.length,
                  itemBuilder: (context, index) {
                    final reminder = _reminders[index];
                    return _buildReminderCard(reminder);
                  },
                ),
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddReminderDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildReminderCard(ReminderModel reminder) {
    final isOverdue = reminder.scheduledTime.isBefore(DateTime.now());
    final timeFormat = DateFormat('MMM dd, yyyy - hh:mm a');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor:
              isOverdue
                  ? Colors.red
                  : reminder.isActive
                  ? Colors.green
                  : Colors.grey,
          child: Icon(_getReminderIcon(reminder.type), color: Colors.white),
        ),
        title: Text(
          reminder.title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            decoration: isOverdue ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(reminder.description),
            const SizedBox(height: 4),
            Text(
              timeFormat.format(reminder.scheduledTime),
              style: TextStyle(
                color: isOverdue ? Colors.red : Colors.blue,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (reminder.frequency != ReminderFrequency.once)
              Text(
                'Repeats: ${reminder.frequency.toString().split('.').last}',
                style: const TextStyle(color: Colors.orange, fontSize: 12),
              ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _handleReminderAction(value, reminder),
          itemBuilder:
              (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit),
                      SizedBox(width: 8),
                      Text('Edit'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'toggle',
                  child: Row(
                    children: [
                      Icon(reminder.isActive ? Icons.pause : Icons.play_arrow),
                      const SizedBox(width: 8),
                      Text(reminder.isActive ? 'Disable' : 'Enable'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Delete', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
        ),
      ),
    );
  }

  IconData _getReminderIcon(ReminderType type) {
    switch (type) {
      case ReminderType.payment:
        return Icons.payment;
      case ReminderType.dueDate:
        return Icons.schedule;
      case ReminderType.custom:
        return Icons.notifications;
    }
  }

  void _handleReminderAction(String action, ReminderModel reminder) async {
    switch (action) {
      case 'edit':
        _showEditReminderDialog(reminder);
        break;
      case 'toggle':
        final updatedReminder = ReminderModel(
          id: reminder.id,
          title: reminder.title,
          description: reminder.description,
          scheduledTime: reminder.scheduledTime,
          type: reminder.type,
          frequency: reminder.frequency,
          isActive: !reminder.isActive,
          data: reminder.data,
          createdAt: reminder.createdAt,
        );
        await ReminderService.updateReminder(updatedReminder);
        _loadReminders();
        break;
      case 'delete':
        _showDeleteConfirmation(reminder);
        break;
    }
  }

  void _showDeleteConfirmation(ReminderModel reminder) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Reminder'),
            content: Text(
              'Are you sure you want to delete "${reminder.title}"?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await ReminderService.cancelReminder(reminder.id);
                  _loadReminders();
                },
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }

  void _showAddReminderDialog() {
    _showReminderDialog();
  }

  void _showEditReminderDialog(ReminderModel reminder) {
    _showReminderDialog(reminder: reminder);
  }

  void _showReminderDialog({ReminderModel? reminder}) {
    showDialog(
      context: context,
      builder:
          (context) => ReminderDialog(
            reminder: reminder,
            onSaved: () => _loadReminders(),
          ),
    );
  }
}

class ReminderDialog extends StatefulWidget {
  final ReminderModel? reminder;
  final VoidCallback onSaved;

  const ReminderDialog({super.key, this.reminder, required this.onSaved});

  @override
  State<ReminderDialog> createState() => _ReminderDialogState();
}

class _ReminderDialogState extends State<ReminderDialog> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime _selectedDateTime = DateTime.now().add(const Duration(hours: 1));
  ReminderFrequency _selectedFrequency = ReminderFrequency.once;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.reminder != null) {
      _titleController.text = widget.reminder!.title;
      _descriptionController.text = widget.reminder!.description;
      _selectedDateTime = widget.reminder!.scheduledTime;
      _selectedFrequency = widget.reminder!.frequency;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.reminder == null ? 'Add Reminder' : 'Edit Reminder'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            _buildDateTimeSelector(),
            const SizedBox(height: 16),
            _buildFrequencySelector(),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _saveReminder,
          child:
              _isLoading
                  ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                  : Text(widget.reminder == null ? 'Add' : 'Update'),
        ),
      ],
    );
  }

  Widget _buildDateTimeSelector() {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final timeFormat = DateFormat('hh:mm a');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Schedule Time',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: _selectDate,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today),
                      const SizedBox(width: 8),
                      Text(dateFormat.format(_selectedDateTime)),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: InkWell(
                onTap: _selectTime,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.access_time),
                      const SizedBox(width: 8),
                      Text(timeFormat.format(_selectedDateTime)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFrequencySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Frequency', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        DropdownButtonFormField<ReminderFrequency>(
          initialValue: _selectedFrequency,
          decoration: const InputDecoration(border: OutlineInputBorder()),
          items:
              ReminderFrequency.values.map((frequency) {
                return DropdownMenuItem(
                  value: frequency,
                  child: Text(
                    frequency.toString().split('.').last.toUpperCase(),
                  ),
                );
              }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedFrequency = value!;
            });
          },
        ),
      ],
    );
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null) {
      setState(() {
        _selectedDateTime = DateTime(
          date.year,
          date.month,
          date.day,
          _selectedDateTime.hour,
          _selectedDateTime.minute,
        );
      });
    }
  }

  Future<void> _selectTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
    );

    if (time != null) {
      setState(() {
        _selectedDateTime = DateTime(
          _selectedDateTime.year,
          _selectedDateTime.month,
          _selectedDateTime.day,
          time.hour,
          time.minute,
        );
      });
    }
  }

  Future<void> _saveReminder() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter a title')));
      return;
    }

    if (_selectedDateTime.isBefore(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a future date and time')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      if (widget.reminder == null) {
        // Add new reminder
        await ReminderService.scheduleCustomReminder(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          scheduledTime: _selectedDateTime,
          frequency: _selectedFrequency,
        );
      } else {
        // Update existing reminder
        final updatedReminder = ReminderModel(
          id: widget.reminder!.id,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          scheduledTime: _selectedDateTime,
          type: widget.reminder!.type,
          frequency: _selectedFrequency,
          isActive: widget.reminder!.isActive,
          data: widget.reminder!.data,
          createdAt: widget.reminder!.createdAt,
        );
        await ReminderService.updateReminder(updatedReminder);
      }

      Navigator.pop(context);
      widget.onSaved();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.reminder == null
                ? 'Reminder added successfully'
                : 'Reminder updated successfully',
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
