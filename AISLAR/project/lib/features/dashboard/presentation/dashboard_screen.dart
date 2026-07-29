import 'package:flutter/material.dart';

import '../../feed/presentation/feed_screen.dart';
import '../../directory/presentation/directory_screen.dart';
import '../../profile/presentation/profile_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('AISLAR Connect'),
        actions: [
          IconButton(icon: const Icon(Icons.person), onPressed: () {}),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          children: [
            _DashboardCard(icon: Icons.people, label: 'Directory', color: Colors.blue, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DirectoryScreen()))),
            _DashboardCard(icon: Icons.article, label: 'Feed', color: Colors.green, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FeedScreen()))),
            _DashboardCard(icon: Icons.chat, label: 'Chat', color: Colors.orange, onTap: () {}),
            _DashboardCard(icon: Icons.event, label: 'Events', color: Colors.purple, onTap: () {}),
            _DashboardCard(icon: Icons.photo_library, label: 'Gallery', color: Colors.pink, onTap: () {}),
            _DashboardCard(icon: Icons.business, label: 'Business', color: Colors.teal, onTap: () {}),
            _DashboardCard(icon: Icons.work, label: 'Jobs', color: Colors.indigo, onTap: () {}),
            _DashboardCard(icon: Icons.poll, label: 'Polls', color: Colors.amber, onTap: () {}),
            _DashboardCard(icon: Icons.monetization_on, label: 'Donations', color: Colors.green, onTap: () {}),
            _DashboardCard(icon: Icons.library_books, label: 'Library', color: Colors.brown, onTap: () {}),
          ],
        ),
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _DashboardCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: color),
              const SizedBox(height: 8),
              Text(label, style: TextStyle(fontWeight: FontWeight.w600, color: color)),
            ],
          ),
        ),
      ),
    );
  }
}
