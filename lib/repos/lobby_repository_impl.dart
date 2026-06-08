import 'package:beesports/models/lobby_entity.dart';
import 'package:beesports/models/lobby_participant_entity.dart';
import 'package:beesports/repos/lobby_repository.dart';
import 'package:beesports/models/lobby_status.dart';
import 'package:beesports/models/sport_type.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:beesports/core/result.dart';
import 'package:beesports/core/retry_helper.dart';

class LobbyRepositoryImpl implements LobbyRepository {
  final SupabaseClient _client;

  LobbyRepositoryImpl(this._client);

  @override
  Future<Result<List<LobbyEntity>>> getLobbies({
    SportType? sport,
    LobbyStatus? status,
    String? sortBy,
    String? searchQuery,
  }) async {
    return withRetry(() async {
      var query = _client.from('lobbies').select(
            '*, host:profiles!lobbies_host_id_fkey(full_name, avatar_url)',
          );

      if (sport != null) {
        query = query.eq('sport', sport.name);
      }

      if (searchQuery != null && searchQuery.trim().isNotEmpty) {
        final queryStr = '%${searchQuery.trim()}%';
        query = query.or('title.ilike.$queryStr,description.ilike.$queryStr');
      }

      if (status != null) {
        query = query.eq('status', status.value);
      }

      final String orderColumn;
      final bool ascending;
      switch (sortBy) {
        case 'time':
          orderColumn = 'scheduled_at';
          ascending = true;
          break;
        case 'slots':
          orderColumn = 'current_players';
          ascending = false;
          break;
        default:
          orderColumn = 'created_at';
          ascending = false;
      }

      final data = await query.order(orderColumn, ascending: ascending);
      return (data as List).map((e) => LobbyEntity.fromMap(e)).toList();
    });
  }

  @override
  Future<Result<LobbyEntity?>> getLobbyById(String lobbyId) async {
    return withRetry(() async {
      final data = await _client
          .from('lobbies')
          .select(
              '*, host:profiles!lobbies_host_id_fkey(full_name, avatar_url)')
          .eq('id', lobbyId)
          .maybeSingle();

      if (data == null) return null;
      return LobbyEntity.fromMap(data);
    });
  }

  @override
  Future<Result<List<LobbyParticipantEntity>>> getParticipants(
      String lobbyId) async {
    return withRetry(() async {
      final data = await _client
          .from('lobby_participants')
          .select('*, profiles(full_name, avatar_url)')
          .eq('lobby_id', lobbyId)
          .inFilter('status', ['joined', 'confirmed', 'waitlisted']).order(
              'joined_at',
              ascending: true);

      return (data as List)
          .map((e) => LobbyParticipantEntity.fromMap(e))
          .toList();
    });
  }

  @override
  Future<Result<LobbyEntity>> createLobby(LobbyEntity lobby) async {
    return withRetry(() async {
      final List<dynamic> insertedLobbies = await _client
          .from('lobbies')
          .insert(lobby.toMap())
          .select(
              '*, host:profiles!lobbies_host_id_fkey(full_name, avatar_url)');

      final data = insertedLobbies.first;
      final created = LobbyEntity.fromMap(data);

      await _client.from('lobby_participants').insert({
        'lobby_id': created.id,
        'user_id': lobby.hostId,
        'status': 'joined',
      });

      await _client
          .from('lobbies')
          .update({'current_players': 1}).eq('id', created.id);

      return created.copyWith(currentPlayers: 1);
    });
  }

  @override
  Future<Result<void>> joinLobby({
    required String lobbyId,
    required String userId,
  }) async {
    return withRetry(() async {
      await _client.rpc('join_lobby_atomic', params: {
        'p_lobby_id': lobbyId,
        'p_user_id': userId,
      });
    });
  }

  @override
  Future<Result<void>> leaveLobby({
    required String lobbyId,
    required String userId,
  }) async {
    return withRetry(() async {
      await _client.rpc('leave_lobby_atomic', params: {
        'p_lobby_id': lobbyId,
        'p_user_id': userId,
      });
    });
  }

  @override
  Future<Result<void>> updateLobbyStatus({
    required String lobbyId,
    required LobbyStatus status,
  }) async {
    return withRetry(() async {
      final updates = <String, dynamic>{
        'status': status.value,
      };

      switch (status) {
        case LobbyStatus.confirmed:
          updates['confirmed_at'] = DateTime.now().toIso8601String();
          break;
        case LobbyStatus.finished:
          updates['finished_at'] = DateTime.now().toIso8601String();
          break;
        case LobbyStatus.settled:
          updates['settled_at'] = DateTime.now().toIso8601String();
          break;
        case LobbyStatus.cancelled:
          updates['cancelled_at'] = DateTime.now().toIso8601String();
          break;
        default:
          break;
      }

      await _client.from('lobbies').update(updates).eq('id', lobbyId);
    });
  }

  @override
  Future<Result<List<LobbyEntity>>> getMyLobbies(String userId) async {
    return withRetry(() async {
      final participantData = await _client
          .from('lobby_participants')
          .select('lobby_id')
          .eq('user_id', userId)
          .inFilter('status', ['joined', 'confirmed']);

      final lobbyIds = (participantData as List)
          .map((e) => e['lobby_id'] as String)
          .toList();

      if (lobbyIds.isEmpty) return [];

      final data = await _client
          .from('lobbies')
          .select(
              '*, host:profiles!lobbies_host_id_fkey(full_name, avatar_url)')
          .inFilter('id', lobbyIds)
          .order('created_at', ascending: false);

      return (data as List).map((e) => LobbyEntity.fromMap(e)).toList();
    });
  }

  // _promoteFromWaitlist is now handled by the leave_lobby_atomic RPC.
  // Method removed.

  @override
  Stream<LobbyEntity?> watchLobby(String lobbyId) async* {
    await for (final _ in _client
        .from('lobbies')
        .stream(primaryKey: ['id']).eq('id', lobbyId)) {
      final result = await getLobbyById(lobbyId);
      yield result.when(success: (data) => data, failure: (_) => null);
    }
  }

  @override
  Stream<List<LobbyParticipantEntity>> watchParticipants(
      String lobbyId) async* {
    await for (final _ in _client
        .from('lobby_participants')
        .stream(primaryKey: ['id']).eq('lobby_id', lobbyId)) {
      final result = await getParticipants(lobbyId);
      yield result.when(
          success: (data) => data, failure: (_) => <LobbyParticipantEntity>[]);
    }
  }
}
