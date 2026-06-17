import 'dart:math';

import 'package:beesports/models/match_entity.dart';
import 'package:beesports/models/match_participant_entity.dart';
import 'package:beesports/repos/match_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:beesports/core/result.dart';
import 'package:beesports/core/retry_helper.dart';

class MatchRepositoryImpl implements MatchRepository {
  final SupabaseClient _client;

  MatchRepositoryImpl(this._client);

  @override
  Future<Result<MatchEntity>> submitResult({
    required String lobbyId,
    required int teamAScore,
    required int teamBScore,
  }) async {
    return withRetry(() async {
      final lobby = await _client
          .from('lobbies')
          .select('sport, duration_minutes, scheduled_at')
          .eq('id', lobbyId)
          .single();

      final participants = await _client
          .from('lobby_participants')
          .select('user_id, team')
          .eq('lobby_id', lobbyId)
          .inFilter('status', ['joined', 'confirmed']);

      final sport = lobby['sport'] as String;

      final ratings = await _client
          .from('user_sport_ratings')
          .select()
          .eq('sport', sport)
          .inFilter(
            'user_id',
            participants.map((p) => p['user_id']).toList(),
          );

      final ratingMap = <String, int>{};
      for (final r in ratings) {
        ratingMap[r['user_id']] = r['elo_rating'] as int;
      }

      final teamA = participants.where((p) => p['team'] == 'A').toList();
      final teamB = participants.where((p) => p['team'] == 'B').toList();

      String teamResult(String team) {
        if (teamAScore == teamBScore) return 'draw';
        if (team == 'A') return teamAScore > teamBScore ? 'win' : 'loss';
        return teamBScore > teamAScore ? 'win' : 'loss';
      }

      int avgElo(List<Map<String, dynamic>> team) {
        if (team.isEmpty) return 1000;
        final total = team.fold<int>(
          0,
          (sum, p) => sum + (ratingMap[p['user_id']] ?? 1000),
        );
        return total ~/ team.length;
      }

      final avgA = avgElo(teamA);
      final avgB = avgElo(teamB);

      final eloChanges = <String, dynamic>{};
      final participantRecords = <Map<String, dynamic>>[];

      for (final p in participants) {
        final userId = p['user_id'] as String;
        final team = p['team'] as String?;
        final currentElo = ratingMap[userId] ?? 1000;
        final opponentAvg = team == 'A' ? avgB : avgA;
        final result = teamResult(team ?? 'A');

        final newElo = _calculateElo(currentElo, opponentAvg, result);
        final delta = newElo - currentElo;

        eloChanges[userId] = {
          'before': currentElo,
          'after': newElo,
          'delta': delta,
        };

        participantRecords.add({
          'user_id': userId,
          'team': team,
          'result': result,
          'elo_before': currentElo,
          'elo_after': newElo,
          'elo_delta': delta,
        });
      }

      final List<dynamic> insertedMatches = await _client
          .from('matches')
          .insert({
            'lobby_id': lobbyId,
            'sport': sport,
            'played_at': (lobby['scheduled_at'] as String),
            'duration_minutes': lobby['duration_minutes'],
            'team_a_score': teamAScore,
            'team_b_score': teamBScore,
            'elo_changes': eloChanges,
            'settled': false,
          })
          .select();
      
      final matchData = insertedMatches.first;

      final matchId = matchData['id'] as String;

      for (final record in participantRecords) {
        record['match_id'] = matchId;
      }
      await _client.from('match_participants').insert(participantRecords);

      for (final p in participantRecords) {
        final userId = p['user_id'] as String;
        final newElo = p['elo_after'] as int;
        final result = p['result'] as String;
        final existing = ratingMap.containsKey(userId);

        if (existing) {
          await _client
              .from('user_sport_ratings')
              .update({
                'elo_rating': newElo,
                'matches_played': ratings.firstWhere(
                      (r) => r['user_id'] == userId,
                      orElse: () => <String, dynamic>{'matches_played': 0},
                    )['matches_played'] +
                    1,
                if (result == 'win')
                  'wins': ratings.firstWhere(
                        (r) => r['user_id'] == userId,
                        orElse: () => <String, dynamic>{'wins': 0},
                      )['wins'] +
                      1,
                if (result == 'loss')
                  'losses': ratings.firstWhere(
                        (r) => r['user_id'] == userId,
                        orElse: () => <String, dynamic>{'losses': 0},
                      )['losses'] +
                      1,
              })
              .eq('user_id', userId)
              .eq('sport', sport);
        } else {
          await _client.from('user_sport_ratings').insert({
            'user_id': userId,
            'sport': sport,
            'elo_rating': newElo,
            'matches_played': 1,
            'wins': result == 'win' ? 1 : 0,
            'losses': result == 'loss' ? 1 : 0,
          });
        }
      }

      await _client.from('lobbies').update({
        'status': 'finished',
        'finished_at': DateTime.now().toIso8601String()
      }).eq('id', lobbyId);

      return MatchEntity.fromMap(matchData);
    });
  }

  @override
  Future<Result<MatchEntity?>> getMatchByLobby(String lobbyId) async {
    return withRetry(() async {
      final List<dynamic> data = await _client
          .from('matches')
          .select()
          .eq('lobby_id', lobbyId)
          .order('created_at', ascending: false)
          .limit(1);
          
      if (data.isEmpty) return null;
      return MatchEntity.fromMap(data.first);
    });
  }

  @override
  Future<Result<List<MatchParticipantEntity>>> getMatchParticipants(
    String matchId,
  ) async {
    return withRetry(() async {
      final data = await _client
          .from('match_participants')
          .select(
              '*, profile:profiles!match_participants_user_id_fkey(full_name, avatar_url)')
          .eq('match_id', matchId);
      return (data as List)
          .map((e) => MatchParticipantEntity.fromMap(e))
          .toList();
    });
  }

  @override
  Future<Result<List<MatchEntity>>> getMyMatches(String userId) async {
    return withRetry(() async {
      final participations = await _client
          .from('match_participants')
          .select('match_id')
          .eq('user_id', userId);

      if (participations.isEmpty) return [];

      final matchIds =
          participations.map((p) => p['match_id'] as String).toList();

      final data = await _client
          .from('matches')
          .select()
          .inFilter('id', matchIds)
          .order('played_at', ascending: false);

      return (data as List).map((e) => MatchEntity.fromMap(e)).toList();
    });
  }

  @override
  Future<Result<void>> settleLobby(String lobbyId) async {
    return withRetry(() async {
      await _client.from('lobbies').update({
        'status': 'settled',
        'settled_at': DateTime.now().toIso8601String()
      }).eq('id', lobbyId);

      // Fetch lobby deposit details
      final lobby = await _client
          .from('lobbies')
          .select('deposit_amount, host_deposit_amount, host_id')
          .eq('id', lobbyId)
          .single();

      final depositAmount = (lobby['deposit_amount'] as num?)?.toDouble() ?? 0.0;
      final hostDepositAmount = (lobby['host_deposit_amount'] as num?)?.toDouble() ?? 0.0;
      final hostId = lobby['host_id'] as String;
      final hasDeposit = depositAmount > 0 || hostDepositAmount > 0;

      if (hasDeposit) {
        // Fetch all participants
        final participants = await _client
            .from('lobby_participants')
            .select('user_id, status, deposit_held')
            .eq('lobby_id', lobbyId);

        for (final p in participants) {
          final userId = p['user_id'] as String;
          final status = p['status'] as String;
          final depositHeld = p['deposit_held'] as bool? ?? false;

          if (depositHeld) {
            final walletData = await _client
                .from('credit_wallets')
                .select()
                .eq('user_id', userId)
                .maybeSingle();

            if (walletData == null) continue; // Skip if no wallet found

            final balance = (walletData['balance'] as num).toDouble();
            final held = (walletData['held'] as num).toDouble();

            if (status == 'no_show') {
              final relevantAmount = userId == hostId && hostDepositAmount > 0
                  ? hostDepositAmount
                  : depositAmount;
              final newBalance = (balance - relevantAmount).clamp(0.0, double.infinity);
              final newHeld = (held - relevantAmount).clamp(0.0, double.infinity);
              await _client
                  .from('credit_wallets')
                  .update({'balance': newBalance, 'held': newHeld})
                  .eq('user_id', userId);

              await _client.from('credit_transactions').insert({
                'user_id': userId,
                'type': 'deposit_forfeit',
                'amount': relevantAmount,
                'balance_after': newBalance,
                'reference_id': lobbyId,
                'description': 'Deposit forfeited for no-show',
              });
            } else {
              final relevantAmount = userId == hostId && hostDepositAmount > 0
                  ? hostDepositAmount
                  : depositAmount;
              final newHeld = (held - relevantAmount).clamp(0.0, double.infinity);
              await _client
                  .from('credit_wallets')
                  .update({'held': newHeld})
                  .eq('user_id', userId);

              await _client.from('credit_transactions').insert({
                'user_id': userId,
                'type': 'deposit_release',
                'amount': relevantAmount,
                'balance_after': balance,
                'reference_id': lobbyId,
                'description': 'Deposit released after match settlement',
              });
            }

          }
        }
      }

    });
  }

  int _calculateElo(int playerElo, int opponentElo, String result) {
    const kFactor = 32;
    final expected = 1.0 / (1.0 + pow(10.0, (opponentElo - playerElo) / 400.0));
    double actual;
    switch (result) {
      case 'win':
        actual = 1.0;
        break;
      case 'loss':
        actual = 0.0;
        break;
      default:
        actual = 0.5;
    }
    final newElo = playerElo + (kFactor * (actual - expected)).round();
    return newElo < 0 ? 0 : newElo;
  }
}
