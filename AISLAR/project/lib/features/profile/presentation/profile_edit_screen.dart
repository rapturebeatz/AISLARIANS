import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../models/profile_model.dart';
import '../../directory/data/directory_repository.dart';

class ProfileEditScreen extends ConsumerStatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  ConsumerState<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends ConsumerState<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _nicknameController = TextEditingController();
  final _matricController = TextEditingController();
  final _departmentController = TextEditingController();
  final _facultyController = TextEditingController();
  final _occupationController = TextEditingController();
  final _employerController = TextEditingController();
  final _bioController = TextEditingController();
  final _cityController = TextEditingController();
  int? _graduationYear;

  @override
  void dispose() {
    _nameController.dispose();
    _nicknameController.dispose();
    _matricController.dispose();
    _departmentController.dispose();
    _facultyController.dispose();
    _occupationController.dispose();
    _employerController.dispose();
    _bioController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    // Simplified - would need auth user's uid
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [TextButton(onPressed: _save, child: const Text('Save'))],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(controller: _nameController, decoration: const InputDecoration(labelText: 'Full Name')),
              const SizedBox(height: 16),
              TextFormField(controller: _nicknameController, decoration: const InputDecoration(labelText: 'Nickname')),
              const SizedBox(height: 16),
              TextFormField(controller: _matricController, decoration: const InputDecoration(labelText: 'Matric Number')),
              const SizedBox(height: 16),
              TextFormField(controller: _departmentController, decoration: const InputDecoration(labelText: 'Department')),
              const SizedBox(height: 16),
              TextFormField(controller: _facultyController, decoration: const InputDecoration(labelText: 'Faculty')),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                value: _graduationYear,
                items: List.generate(20, (i) => 2010 + i)
                    .map((y) => DropdownMenuItem(value: y, child: Text('$y')))
                    .toList(),
                onChanged: (v) => _graduationYear = v,
                decoration: const InputDecoration(labelText: 'Graduation Year'),
              ),
              const SizedBox(height: 16),
              TextFormField(controller: _occupationController, decoration: const InputDecoration(labelText: 'Occupation')),
              const SizedBox(height: 16),
              TextFormField(controller: _employerController, decoration: const InputDecoration(labelText: 'Employer')),
              const SizedBox(height: 16),
              TextFormField(controller: _cityController, decoration: const InputDecoration(labelText: 'City')),
              const SizedBox(height: 16),
              TextFormField(controller: _bioController, maxLines: 4, decoration: const InputDecoration(labelText: 'Bio', alignLabelWithHint: true)),
            ],
          ),
        ),
      ),
    );
  }
}
