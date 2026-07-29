import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../models/feature_models.dart';
import '../data/donations_repository.dart';

final donationsProvider = StreamProvider<List<DonationModel>>((ref) {
  return ref.read(donationsRepositoryProvider).streamDonations();
});

class DonationsScreen extends ConsumerStatefulWidget {
  const DonationsScreen({super.key});

  @override
  ConsumerState<DonationsScreen> createState() => _DonationsScreenState();
}

class _DonationsScreenState extends ConsumerState<DonationsScreen> {
  final _amountController = TextEditingController();
  final _messageController = TextEditingController();
  String _fundType = 'general';

  @override
  void dispose() {
    _amountController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _donate() async {
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) return;

    await ref.read(donationsRepositoryProvider).createDonation(DonationModel(
      id: '',
      donorId: 'current-user',
      amount: amount,
      fundType: _fundType,
      paymentReference: 'ref_${DateTime.now().millisecondsSinceEpoch}',
      message: _messageController.text.trim(),
      createdAt: DateTime.now(),
    ));

    _amountController.clear();
    _messageController.clear();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Thank you for your contribution!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final donationsAsync = ref.watch(donationsProvider);
    final theme = Theme.of(context);
    final currencyFormat = NumberFormat.currency(symbol: '₦', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(title: const Text('Donations')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              color: theme.colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Icon(Icons.favorite, size: 48, color: theme.colorScheme.primary),
                    const SizedBox(height: 12),
                    Text('Support AISLAR', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('Contributions help fund reunions, welfare, and class projects.', style: TextStyle(color: Colors.grey[600])),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            DropdownButtonFormField<String>(
              value: _fundType,
              items: const [
                DropdownMenuItem(value: 'reunion', child: Text('Reunion Fund')),
                DropdownMenuItem(value: 'welfare', child: Text('Welfare')),
                DropdownMenuItem(value: 'emergency', child: Text('Emergency Fund')),
                DropdownMenuItem(value: 'scholarship', child: Text('Scholarship')),
                DropdownMenuItem(value: 'general', child: Text('General Fund')),
              ],
              onChanged: (v) => setState(() => _fundType = v!),
              decoration: const InputDecoration(labelText: 'Fund Type'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Amount (NGN)', prefixText: '₦ '),
            ),
            const SizedBox(height: 16),
            TextField(controller: _messageController, maxLines: 3, decoration: const InputDecoration(labelText: 'Message (optional)', alignLabelWithHint: true)),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _donate,
              icon: const Icon(Icons.favorite),
              label: const Text('Contribute Now'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 32),
            Text('Recent Contributions', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            donationsAsync.when(
              data: (list) => list.isEmpty
                  ? const Text('No contributions yet')
                  : Column(
                      children: list.map((d) => ListTile(
                        leading: CircleAvatar(child: Text(d.donorId[0].toUpperCase())),
                        title: Text(currencyFormat.format(d.amount)),
                        subtitle: Text('${d.fundType} • ${DateFormat('MMM d, yyyy').format(d.createdAt)}'),
                        trailing: Chip(label: Text(d.status, style: const TextStyle(fontSize: 11))),
                      )).toList(),
                    ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('Error: $e'),
            ),
          ],
        ),
      ),
    );
  }
}
