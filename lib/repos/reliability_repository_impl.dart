import 'package:beesports/repos/reliability_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:beesports/core/result.dart';
import 'package:beesports/core/retry_helper.dart';

class ReliabilityRepositoryImpl implements ReliabilityRepository {
  final SupabaseClient _client;

  /// Users with reliability score below this are auto-suspended
  static const int suspensionThreshold = 30;

  ReliabilityRepositoryImpl(this._client);

  @override
  Future<Result<void>> recordEvent({
    required String userId,
    required String lobbyId,
    required String eventType,
    required int scoreDelta,
    String? description,
  }) async {
    return withRetry(() async {
      // Insert the reliability event
      await _client.from('reliability_events').insert({
        'user_id': userId,
        'lobby_id': lobbyId,
        'event_type': eventType,
        'score_delta': scoreDelta,
        'description': description ?? _defaultDescription(eventType),
      });

      // Update the profile's reliability score
      final currentScore = await _fetchScore(userId);
      final newScore = (currentScore + scoreDelta).clamp(0, 100);

      await _client
          .from('profiles')
          .update({'reliability_score': newScore}).eq('id', userId);

      // Auto-suspend if score drops too low
      if (newScore <= suspensionThreshold) {
        await _client
            .from('profiles')
            .update({'is_suspended': true}).eq('id', userId);
      }
    });
  }

  @override
  Future<Result<int>> getReliabilityScore(String userId) async {
    return withRetry(() async {
      return await _fetchScore(userId);
    });
  }

  @override
  Future<Result<bool>> shouldSuspend(String userId) async {
    return withRetry(() async {
      final score = await _fetchScore(userId);
      return score <= suspensionThreshold;
    });
  }

  @override
  Future<Result<void>> suspendUser(String userId) async {
    return withRetry(() async {
      await _client
          .from('profiles')
          .update({'is_suspended': true}).eq('id', userId);
    });
  }

  @override
  Future<Result<List<Map<String, dynamic>>>> getReliabilityHistory(
      String userId) async {
    return withRetry(() async {
      final data = await _client
          .from('reliability_events')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(50);
      return List<Map<String, dynamic>>.from(data);
    });
  }

  Future<int> _fetchScore(String userId) async {
    final data = await _client
        .from('profiles')
        .select('reliability_score')
        .eq('id', userId)
        .single();
    return (data['reliability_score'] as int?) ?? 100;
  }

  String _defaultDescription(String eventType) {
    switch (eventType) {
      case 'no_show':
        return 'Failed to attend a confirmed match';
      case 'attended':
        return 'Successfully attended a match';
      case 'late_cancel':
        return 'Cancelled attendance less than 3 hours before match';
      case 'early_cancel':
        return 'Left lobby before confirmation window';
      case 'host_cancel':
        return 'Cancelled a lobby as host';
      default:
        return eventType;
    }
  }
}
