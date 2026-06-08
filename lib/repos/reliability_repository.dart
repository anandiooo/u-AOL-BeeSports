import 'package:beesports/core/result.dart';

abstract class ReliabilityRepository {
  /// Record a reliability event for a user (e.g., no_show, attended, late_cancel)
  Future<Result<void>> recordEvent({
    required String userId,
    required String lobbyId,
    required String eventType,
    required int scoreDelta,
    String? description,
  });

  /// Get the user's current reliability score
  Future<Result<int>> getReliabilityScore(String userId);

  /// Check if a user should be suspended (score below threshold)
  Future<Result<bool>> shouldSuspend(String userId);

  /// Suspend a user account
  Future<Result<void>> suspendUser(String userId);

  /// Get reliability events for a user
  Future<Result<List<Map<String, dynamic>>>> getReliabilityHistory(String userId);
}
