import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/events_controller.dart';

class CreateEventScreen extends ConsumerStatefulWidget {
  const CreateEventScreen({super.key});

  @override
  ConsumerState<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends ConsumerState<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _locationController = TextEditingController();
  final _addressController = TextEditingController();
  final _linkController = TextEditingController();

  String _type = 'reunion';
  DateTime _startDate = DateTime.now().add(const Duration(days: 30));
  DateTime _endDate = DateTime.now().add(const Duration(days: 30, hours: 3));
  bool _isVirtual = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _locationController.dispose();
    _addressController.dispose();
    _linkController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(bool isStart) async {
    final date = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _endDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(isStart ? _startDate : _endDate),
    );
    if (time == null) return;

    final dt = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    setState(() {
      if (isStart) {
        _startDate = dt;
      } else {
        _endDate = dt;
      }
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    await ref.read(eventsControllerProvider).createEvent(
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      type: _type,
      startDate: _startDate,
      endDate: _endDate,
      organizerId: 'current-user',
      locationName: _locationController.text.trim(),
      address: _addressController.text.trim(),
      isVirtual: _isVirtual,
      meetingLink: _linkController.text.trim(),
    );

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final loading = ref.watch(eventsLoadingProvider);
    final dateFormat = (DateTime d) => '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Event'),
        actions: [TextButton(onPressed: loading ? null : _submit, child: const Text('Create'))],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(controller: _titleController, decoration: const InputDecoration(labelText: 'Event Title'), validator: (v) => (v?.isEmpty ?? true) ? 'Required' : null),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _type,
                items: ['agm', 'reunion', 'webinar', 'birthday', 'seminar', 'social']
                    .map((t) => DropdownMenuItem(value: t, child: Text(t[0].toUpperCase() + t.substring(1))))
                    .toList(),
                onChanged: (v) => setState(() => _type = v!),
                decoration: const InputDecoration(labelText: 'Type'),
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () => _pickDate(true),
                child: InputDecorator(
                  decoration: const InputDecoration(labelText: 'Start Date & Time'),
                  child: Text(dateFormat(_startDate)),
                ),
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () => _pickDate(false),
                child: InputDecorator(
                  decoration: const InputDecoration(labelText: 'End Date & Time'),
                  child: Text(dateFormat(_endDate)),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(controller: _locationController, decoration: const InputDecoration(labelText: 'Location Name'), validator: (v) => (v?.isEmpty ?? true) ? 'Required' : null),
              const SizedBox(height: 16),
              TextFormField(controller: _addressController, decoration: const InputDecoration(labelText: 'Address (optional)')),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Virtual Event'),
                value: _isVirtual,
                onChanged: (v) => setState(() => _isVirtual = v),
              ),
              if (_isVirtual) ...[
                const SizedBox(height: 16),
                TextFormField(controller: _linkController, decoration: const InputDecoration(labelText: 'Meeting Link')),
              ],
              const SizedBox(height: 16),
              TextFormField(controller: _descController, maxLines: 4, decoration: const InputDecoration(labelText: 'Description', alignLabelWithHint: true)),
            ],
          ),
        ),
      ),
    );
  }
}
