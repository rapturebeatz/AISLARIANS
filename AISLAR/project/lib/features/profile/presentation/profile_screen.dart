import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../models/profile_model.dart';
import '../../directory/data/directory_repository.dart';

final profileProvider = StreamProvider.family<ProfileModel?, String>((ref, uid) {
  return ref.read(directoryRepositoryProvider).streamProfile(uid).map((p) => p);
});

class ProfileScreen extends ConsumerWidget {
  final String uid;

  const ProfileScreen({super.key, required this.uid});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider(uid));
    final theme = Theme.of(context);

    return profileAsync.when(
      data: (profile) {
        if (profile == null) return const Scaffold(body: Center(child: Text('Profile not found')));
        return Scaffold(
          appBar: AppBar(title: Text(profile.fullName)),
          body: SingleChildScrollView(
            child: Column(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      height: 150,
                      width: double.infinity,
                      color: theme.colorScheme.primaryContainer,
                      child: profile.coverUrl != null
                          ? Image.network(profile.coverUrl!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const SizedBox())
                          : null,
                    ),
                    Positioned(
                      left: 24,
                      bottom: -40,
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: theme.colorScheme.primary,
                        backgroundImage: profile.photoUrl != null ? NetworkImage(profile.photoUrl!) : null,
                        child: profile.photoUrl == null
                            ? Text(profile.fullName[0].toUpperCase(), style: const TextStyle(fontSize: 32, color: Colors.white))
                            : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 48),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(profile.fullName, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                      if (profile.nickname != null) Text('"${profile.nickname}"', style: TextStyle(color: Colors.grey[600])),
                      const SizedBox(height: 12),
                      if (profile.occupation != null) _InfoRow(icon: Icons.work, label: profile.occupation!),
                      if (profile.employer != null) _InfoRow(icon: Icons.business, label: profile.employer!),
                      _InfoRow(icon: Icons.school, label: '${profile.department} (${profile.graduationYear})'),
                      _InfoRow(icon: Icons.location_on, label: '${profile.city ?? ""}, ${profile.country}'),
                      if (profile.bio != null) ...[
                        const SizedBox(height: 12),
                        Text(profile.bio!, style: const TextStyle(fontSize: 14)),
                      ],
                      if (profile.skills.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Text('Skills', style: theme.textTheme.titleSmall),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: profile.skills.map((s) => Chip(label: Text(s, style: const TextStyle(fontSize: 12)))).toList(),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Error: $e'))),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}
