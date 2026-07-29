import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/services/firestore_service.dart';
import '../data/library_repository.dart';

final libraryProvider = StreamProvider<List<DocumentModel>>((ref) {
  return ref.read(libraryRepositoryProvider).streamDocuments();
});

class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final docsAsync = ref.watch(libraryProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Digital Library')),
      body: docsAsync.when(
        data: (docs) => docs.isEmpty
            ? const Center(child: Text('No documents in the library'))
            : ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: docs.length,
                itemBuilder: (_, i) {
                  final doc = docs[i];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: theme.colorScheme.primaryContainer,
                        child: Icon(_iconForType(doc.type), color: theme.colorScheme.onPrimaryContainer),
                      ),
                      title: Text(doc.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text('${doc.type.replaceAll('_', ' ')} • ${DateFormat('MMM yyyy').format(doc.createdAt)}'),
                      trailing: const Icon(Icons.download),
                      onTap: () {},
                    ),
                  );
                },
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  IconData _iconForType(String type) {
    switch (type) {
      case 'constitution': return Icons.gavel;
      case 'minutes': return Icons.meeting_room;
      case 'report': return Icons.assessment;
      case 'financial_statement': return Icons.account_balance;
      case 'yearbook': return Icons.auto_stories;
      case 'newsletter': return Icons.newspaper;
      default: return Icons.description;
    }
  }
}
