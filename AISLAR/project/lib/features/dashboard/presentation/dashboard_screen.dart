import 'package:flutter/material.dart';

import '../../feed/presentation/feed_screen.dart';
import '../../directory/presentation/directory_screen.dart';
import '../../chat/presentation/chat_list_screen.dart';
import '../../events/presentation/events_screen.dart';
import '../../gallery/presentation/gallery_screen.dart';
import '../../business/presentation/business_screen.dart';
import '../../polls/presentation/polls_screen.dart';
import '../../donations/presentation/donations_screen.dart';
import '../../library/presentation/library_screen.dart';
import '../../admin/presentation/admin_dashboard_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final menuItems = [
      _MenuItem('Directory', Icons.people, Colors.blue, const DirectoryScreen()),
      _MenuItem('Feed', Icons.article, Colors.green, const FeedScreen()),
      _MenuItem('Chat', Icons.chat, Colors.orange, const ChatListScreen(userId: 'current-user')),
      _MenuItem('Events', Icons.event, Colors.purple, const EventsScreen()),
      _MenuItem('Gallery', Icons.photo_library, Colors.pink, const GalleryScreen()),
      _MenuItem('Business', Icons.business, Colors.teal, const BusinessScreen()),
      _MenuItem('Polls', Icons.poll, Colors.amber, const PollsScreen()),
      _MenuItem('Donations', Icons.monetization_on, Colors.green, const DonationsScreen()),
      _MenuItem('Library', Icons.library_books, Colors.brown, const LibraryScreen()),
      _MenuItem('Admin', Icons.admin_panel_settings, Colors.red, const AdminDashboardScreen()),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('AISLAR Connect'),
        actions: [
          IconButton(icon: const Icon(Icons.person), onPressed: () {}),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.1,
          ),
          itemCount: menuItems.length,
          itemBuilder: (_, i) {
            final item = menuItems[i];
            return Card(
              elevation: 2,
              child: InkWell(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => item.screen)),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(item.icon, size: 40, color: item.color),
                      const SizedBox(height: 8),
                      Text(item.label, style: TextStyle(fontWeight: FontWeight.w600, color: item.color)),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _MenuItem {
  final String label;
  final IconData icon;
  final Color color;
  final Widget screen;

  _MenuItem(this.label, this.icon, this.color, this.screen);
}
