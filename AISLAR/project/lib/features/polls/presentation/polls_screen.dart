import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../models/feature_models.dart';
import '../data/polls_repository.dart';

final activePollsProvider = StreamProvider<List<PollModel>>((ref) {
  return ref.read(pollsRepositoryProvider).streamActivePolls();
});

class PollsScreen extends ConsumerStatefulWidget {
  const PollsScreen({super.key});

  @override
  ConsumerState<PollsScreen> createState() => _PollsScreenState();
}

class _PollsScreenState extends ConsumerState<PollsScreen> {
  final _titleController = TextEditingController();
  final _optionsController = TextEditingController();
  final _options = <String>[];
  String _type = 'opinion';
  DateTime _endsAt = DateTime.now().add(const Duration(days: 7));

  @override
  void dispose() {
    _titleController.dispose();
    _optionsController.dispose();
    super.dispose();
  }

  Future<void> _createPoll() async {
    final title = _titleController.text.trim();
    if (title.isEmpty || _options.length < 2) return;

    await ref.read(pollsRepositoryProvider).createPoll(
      title: title,
      type: _type,
      options: _options,
      createdBy: 'current-user',
      endsAt: _endsAt,
    );

    _titleController.clear();
    _options.clear();
    _optionsController.clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final pollsAsync = ref.watch(activePollsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Polls')),
      body: Column(
        children: [
          Expanded(
            child: pollsAsync.when(
              data: (polls) => polls.isEmpty
                  ? const Center(child: Text('No active polls'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: polls.length,
                      itemBuilder: (_, i) => _PollCard(poll: polls[i]),
                    ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              border: Border(top: BorderSide(color: Colors.grey[300]!)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(controller: _titleController, decoration: const InputDecoration(labelText: 'Poll Question', filled: true, fillColor: Colors.white)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _optionsController,
                        decoration: const InputDecoration(labelText: 'Add option', filled: true, fillColor: Colors.white),
                        onSubmitted: (v) {
                          if (v.trim().isNotEmpty) {
                            setState(() => _options.add(v.trim()));
                            _optionsController.clear();
                          }
                        },
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle),
                      onPressed: () {
                        final v = _optionsController.text.trim();
                        if (v.isNotEmpty) {
                          setState(() => _options.add(v));
                          _optionsController.clear();
                        }
                      },
                    ),
                  ],
                ),
                if (_options.isNotEmpty)
                  Wrap(
                    spacing: 8,
                    children: _options.map((o) => Chip(
                      label: Text(o),
                      onDeleted: () => setState(() => _options.remove(o)),
                    )).toList(),
                  ),
                const SizedBox(height: 8),
                FilledButton(onPressed: _createPoll, child: const Text('Create Poll')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PollCard extends ConsumerStatefulWidget {
  final PollModel poll;
  const _PollCard({required this.poll});

  @override
  ConsumerState<_PollCard> createState() => _PollCardState();
}

class _PollCardState extends ConsumerState<_PollCard> {
  String? _selectedOption;
  Map<String, int>? _results;

  @override
  void initState() {
    super.initState();
    _loadVote();
  }

  Future<void> _loadVote() async {
    final vote = await ref.read(pollsRepositoryProvider).getVote(widget.poll.id, 'current-user');
    if (vote != null) {
      setState(() => _selectedOption = vote);
      _loadResults();
    }
  }

  Future<void> _loadResults() async {
    final r = await ref.read(pollsRepositoryProvider).getResults(widget.poll.id);
    setState(() => _results = r);
  }

  Future<void> _vote(String optionId) async {
    await ref.read(pollsRepositoryProvider).castVote(widget.poll.id, 'current-user', optionId);
    setState(() => _selectedOption = optionId);
    _loadResults();
  }

  @override
  Widget build(BuildContext context) {
    final total = _results?.values.fold(0, (a, b) => a + b) ?? 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(widget.poll.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
                Chip(label: Text(widget.poll.type, style: const TextStyle(fontSize: 11))),
              ],
            ),
            const SizedBox(height: 4),
            Text('Ends ${DateFormat('MMM d').format(widget.poll.endsAt)}', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
            const SizedBox(height: 12),
            ...widget.poll.options.map((opt) {
              final isSelected = _selectedOption == opt.id;
              final count = _results?[opt.id] ?? 0;
              final pct = total > 0 ? (count / total * 100).round() : 0;

              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: InkWell(
                  onTap: _selectedOption == null ? () => _vote(opt.id) : null,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      border: Border.all(color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Expanded(child: Text(opt.text)),
                        if (_selectedOption != null)
                          Text('$count ($pct%)', style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                        if (isSelected) const Icon(Icons.check, size: 18, color: Colors.green),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
