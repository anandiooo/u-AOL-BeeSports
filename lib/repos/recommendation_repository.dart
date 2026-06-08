import 'package:beesports/models/lobby_entity.dart';
import 'package:beesports/core/result.dart';

abstract class RecommendationRepository {
  /// Get personalized lobby recommendations based on user's sport preferences,
  /// campus, and match history.
  Future<Result<List<LobbyEntity>>> getRecommendedLobbies(String userId);
}
