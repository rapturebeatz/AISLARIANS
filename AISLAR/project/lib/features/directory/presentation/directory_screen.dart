import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../models/profile_model.dart';
import '../domain/directory_controller.dart';
import '../data/directory_repository.dart';
import '../../profile/presentation/profile_screen.dart';

class DirectoryScreen extends ConsumerStatefulWidget {
  const DirectoryScreen({super.key});

  @override
  ConsumerState<DirectoryScreen> createState() => _DirectoryScreenState();
}

class _DirectoryScreenState extends ConsumerState<DirectoryScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profiles = ref.watch(filteredDirectoryProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Alumni Directory'),
        actions: [
          IconButton(icon: const Icon(Icons.filter_list), onPressed: _showFilters),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(icon: const Icon(Icons.clear), onPressed: () {
                        _searchController.clear();
                        ref.read(searchQueryProvider.notifier).state = '';
                      })
                    : null,
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (v) => ref.read(searchQueryProvider.notifier).state = v,
            ),
          ),
          Expanded(
            child: profiles.isEmpty
                ? const Center(child: Text('No alumni found'))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: profiles.length,
                    itemBuilder: (_, i) => _AlumniTile(profile: profiles[i]),
                  ),
          ),
        ],
      ),
    );
  }

  void _showFilters() {
    final departments = ref.watch(directoryListProvider).valueOrNull?.map((p) => p.department).toSet().toList() ?? [];
    final years = ref.watch(directoryListProvider).valueOrNull?.map((p) => p.graduationYear).toSet().toList() ?? [];

    showModalBottomSheet(
      context: context,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Filter', style: Theme.of(ctx).textTheme.titleLarge),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: ref.watch(selectedDepartmentProvider),
              items: [const DropdownMenuItem(value: null, child: Text('All Departments')),
                ...departments.map((d) => DropdownMenuItem(value: d, child: Text(d))),
              ],
              onChanged: (v) => ref.read(selectedDepartmentProvider.notifier).state = v,
              decoration: const InputDecoration(labelText: 'Department'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              value: ref.watch(selectedYearProvider),
              items: [const DropdownMenuItem(value: null, child: Text('All Years')),
                ...years.map((y) => DropdownMenuItem(value: y, child: Text('$y'))),
              ],
              onChanged: (v) => ref.read(selectedYearProvider.notifier).state = v,
              decoration: const InputDecoration(labelText: 'Graduation Year'),
            ),
            const SizedBox(height: 16),
            FilledButton(onPressed: () => Navigator.pop(ctx), child: const Text('Apply')),
          ],
        ),
      ),
    );
  }
}

class _AlumniTile extends StatelessWidget {
  final ProfileModel profile;

  const _AlumniTile({required this.profile});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primary,
          child: Text(profile.fullName[0].toUpperCase(), style: const TextStyle(color: Colors.white)),
        ),
        title: Text(profile.fullName, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text('${profile.department} • ${profile.graduationYear}'),
        trailing: profile.occupation != null ? Chip(label: Text(profile.occupation!, style: const TextStyle(fontSize: 11))) : null,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ProfileScreen(uid: profile.uid)),
        ),
      ),
    );
  }
}
