import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/firestore_service.dart';
import '../../../../models/feature_models.dart';

final pollsRepositoryProvider = Provider<PollsRepository>((ref) {
  return PollsRepository(ref.read(firestoreServiceProvider));
});

class PollsRepository {
  final FirestoreService _firestore;

  PollsRepository(this._firestore);

  Stream<List<PollModel>> streamActivePolls() {
    final now = DateTime.now();
    return _firestore
        .streamWhere('polls', 'status', 'active')
        .map((snap) => snap.docs
            .map((doc) => PollModel.fromJson(doc.data() as Map<String, dynamic>, doc.id))
            .where((p) => p.endsAt.isAfter(now))
            .toList());
  }

  Stream<List<PollModel>> streamClosedPolls() {
    return _firestore
        .streamCollection('polls', orderByField: 'endsAt', descending: true)
        .map((snap) => snap.docs
            .map((doc) => PollModel.fromJson(doc.data() as Map<String, dynamic>, doc.id))
            .where((p) => p.endsAt.isBefore(DateTime.now()))
            .toList());
  }

  Future<String> createPoll({
    required String title,
    required String type,
    required List<String> options,
    required String createdBy,
    required DateTime endsAt,
    bool isAnonymous = false,
  }) async {
    final pollOptions = options.asMap().entries.map((e) => PollOption(id: 'opt_${e.key}', text: e.value)).toList();
    final docRef = await _firestore.create('polls', {
      'title': title,
      'type': type,
      'options': pollOptions.map((o) => o.toJson()).toList(),
      'createdBy': createdBy,
      'startsAt': Timestamp.now(),
      'endsAt': endsAt,
      'isAnonymous': isAnonymous,
      'totalVotes': 0,
      'status': 'active',
    });
    return docRef.id;
  }

  Future<void> castVote(String pollId, String userId, String optionId) async {
    final voteId = '${pollId}_$userId';
    await _firestore.set('votes', voteId, {
      'pollId': pollId,
      'userId': userId,
      'selectedOptionId': optionId,
      'castAt': Timestamp.now(),
    });
    await _firestore.increment('polls', pollId, 'totalVotes');
  }

  Future<String?> getVote(String pollId, String userId) async {
    final doc = await _firestore.get('votes', '${pollId}_$userId');
    if (!doc.exists) return null;
    return (doc.data() as Map)['selectedOptionId'] as String?;
  }

  Future<Map<String, int>> getResults(String pollId) async {
    final votes = await _firestore.whereIn('votes', 'pollId', [pollId]);
    final tally = <String, int>{};
    for (final doc in votes) {
      final optionId = (doc.data() as Map)['selectedOptionId'] as String;
      tally[optionId] = (tally[optionId] ?? 0) + 1;
    }
    return tally;
  }
}
