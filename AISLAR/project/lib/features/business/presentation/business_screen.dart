import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../models/business_job_model.dart';
import '../data/business_repository.dart';

final businessesProvider = StreamProvider<List<BusinessModel>>((ref) {
  return ref.read(businessRepositoryProvider).streamBusinesses();
});

final jobsProvider = StreamProvider<List<JobModel>>((ref) {
  return ref.read(businessRepositoryProvider).streamJobs();
});

final selectedBizTabProvider = StateProvider<int>((ref) => 0);

class BusinessScreen extends ConsumerWidget {
  const BusinessScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tab = ref.watch(selectedBizTabProvider);
    final businessesAsync = ref.watch(businessesProvider);
    final jobsAsync = ref.watch(jobsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Business & Jobs'),
        bottom: TabBar(
          tabs: const [Tab(text: 'Businesses'), Tab(text: 'Jobs')],
          onTap: (i) => ref.read(selectedBizTabProvider.notifier).state = i,
        ),
      ),
      body: tab == 0
          ? businessesAsync.when(
              data: (list) => list.isEmpty
                  ? const Center(child: Text('No businesses listed'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: list.length,
                      itemBuilder: (_, i) => Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(backgroundColor: theme.colorScheme.primary, child: Text(list[i].name[0].toUpperCase(), style: const TextStyle(color: Colors.white))),
                          title: Text(list[i].name, style: const TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: Text('${list[i].category} • ${list[i].city ?? list[i].country}'),
                          trailing: const Icon(Icons.chevron_right),
                        ),
                      ),
                    ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            )
          : jobsAsync.when(
              data: (list) => list.isEmpty
                  ? const Center(child: Text('No jobs posted'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: list.length,
                      itemBuilder: (_, i) {
                        final job = list[i];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            title: Text(job.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                            subtitle: Text('${job.category} • ${job.type.replaceAll('_', ' ')}'),
                            trailing: Chip(label: Text(job.status, style: const TextStyle(fontSize: 11))),
                          ),
                        );
                      },
                    ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
    );
  }
}
