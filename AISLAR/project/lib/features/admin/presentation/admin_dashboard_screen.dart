import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/admin_controller.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(adminStatsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: () => ref.invalidate(adminStatsProvider)),
        ],
      ),
      body: statsAsync.when(
        data: (stats) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Overview', style: theme.textTheme.titleLarge),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _StatCard(icon: Icons.people, label: 'Members', value: '${stats['totalMembers']}', color: Colors.blue)),
                  const SizedBox(width: 12),
                  Expanded(child: _StatCard(icon: Icons.article, label: 'Posts', value: '${stats['totalPosts']}', color: Colors.green)),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _StatCard(icon: Icons.event, label: 'Events', value: '${stats['totalEvents']}', color: Colors.purple)),
                  const SizedBox(width: 12),
                  Expanded(child: _StatCard(icon: Icons.pending_actions, label: 'Pending', value: '${stats['pendingApprovals']}', color: Colors.orange)),
                ],
              ),
              const SizedBox(height: 24),
              Text('Pending Approvals', style: theme.textTheme.titleLarge),
              const SizedBox(height: 12),
              _PendingApprovalsList(),
              const SizedBox(height: 24),
              Text('Quick Actions', style: theme.textTheme.titleLarge),
              const SizedBox(height: 12),
              _QuickAction(icon: Icons.send, label: 'Send Announcement', onTap: () {}),
              _QuickAction(icon: Icons.people, label: 'Manage Members', onTap: () {}),
              _QuickAction(icon: Icons.settings, label: 'Platform Settings', onTap: () {}),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color)),
            Text(label, style: TextStyle(color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }
}

class _PendingApprovalsList extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingAsync = ref.watch(pendingMembersProvider);
    final theme = Theme.of(context);

    return pendingAsync.when(
      data: (snap) {
        final docs = snap.docs;
        if (docs.isEmpty) return Card(child: const ListTile(title: Text('No pending approvals')));
        return Column(
          children: docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return Card(
              child: ListTile(
                leading: CircleAvatar(child: Text((data['displayName']?[0] ?? '?').toString().toUpperCase())),
                title: Text(data['displayName'] ?? 'Unknown'),
                subtitle: Text(data['email'] ?? ''),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.check_circle, color: Colors.green),
                      onPressed: () => ref.read(adminControllerProvider).approveMember(doc.id),
                    ),
                    IconButton(
                      icon: const Icon(Icons.cancel, color: Colors.red),
                      onPressed: () => ref.read(adminControllerProvider).rejectMember(doc.id),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Text('Error: $e'),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickAction({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(label),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
