import 'package:beesports/models/lobby_entity.dart';
import 'package:beesports/models/lobby_participant_entity.dart';
import 'package:beesports/repos/lobby_repository.dart';
import 'package:beesports/models/lobby_status.dart';
import 'package:beesports/models/sport_type.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LobbyRepositoryImpl implements LobbyRepository {
  final SupabaseClient _client;

  LobbyRepositoryImpl(this._client);

  @override
  Future<List<LobbyEntity>> getLobbies({
    SportType? sport,
    LobbyStatus? status,
    String? sortBy,
  }) async {
    var query = _client.from('lobbies').select(
          '*, host:profiles!lobbies_host_id_fkey(full_name, avatar_url)',
        );

    if (sport != null) {
      query = query.eq('sport', sport.name);
    }

    if (status != null) {
      query = query.eq('status', status.value);
    } else {
      query = query.inFilter('status', ['open', 'confirmed']);
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
  }

  @override
  Future<LobbyEntity?> getLobbyById(String lobbyId) async {
    final data = await _client
        .from('lobbies')
        .select('*, host:profiles!lobbies_host_id_fkey(full_name, avatar_url)')
        .eq('id', lobbyId)
        .maybeSingle();

    if (data == null) return null;
    return LobbyEntity.fromMap(data);
  }

  @override
  Future<List<LobbyParticipantEntity>> getParticipants(String lobbyId) async {
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
  }

  @override
  Future<LobbyEntity> createLobby(LobbyEntity lobby) async {
    final data = await _client
        .from('lobbies')
        .insert(lobby.toMap())
        .select('*, host:profiles!lobbies_host_id_fkey(full_name, avatar_url)')
        .single();

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
  }

  @override
  Future<void> joinLobby({
    required String lobbyId,
    required String userId,
  }) async {
    final lobby = await getLobbyById(lobbyId);
    if (lobby == null) throw Exception('Lobby not found');

    final status = lobby.isFull ? 'waitlisted' : 'joined';

    await _client.from('lobby_participants').insert({
      'lobby_id': lobbyId,
      'user_id': userId,
      'status': status,
    });

    if (!lobby.isFull) {
      await _client.from('lobbies').update({
        'current_players': lobby.currentPlayers + 1,
      }).eq('id', lobbyId);
    }
  }

  @override
  Future<void> leaveLobby({
    required String lobbyId,
    required String userId,
  }) async {
    await _client
        .from('lobby_participants')
        .update({
          'status': 'left',
          'left_at': DateTime.now().toIso8601String(),
        })
        .eq('lobby_id', lobbyId)
        .eq('user_id', userId);

    final lobby = await getLobbyById(lobbyId);
    if (lobby != null && lobby.currentPlayers > 0) {
      await _client.from('lobbies').update({
        'current_players': lobby.currentPlayers - 1,
      }).eq('id', lobbyId);
    }

    await _promoteFromWaitlist(lobbyId);
  }

  @override
  Future<void> updateLobbyStatus({
    required String lobbyId,
    required LobbyStatus status,
  }) async {
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
  }

  @override
  Future<List<LobbyEntity>> getMyLobbies(String userId) async {
    final participantData = await _client
        .from('lobby_participants')
        .select('lobby_id')
        .eq('user_id', userId)
        .inFilter('status', ['joined', 'confirmed']);

    final lobbyIds =
        (participantData as List).map((e) => e['lobby_id'] as String).toList();

    if (lobbyIds.isEmpty) return [];

    final data = await _client
        .from('lobbies')
        .select('*, host:profiles!lobbies_host_id_fkey(full_name, avatar_url)')
        .inFilter('id', lobbyIds)
        .order('scheduled_at', ascending: true);

    return (data as List).map((e) => LobbyEntity.fromMap(e)).toList();
  }

  Future<void> _promoteFromWaitlist(String lobbyId) async {
    final lobby = await getLobbyById(lobbyId);
    if (lobby == null || lobby.isFull) return;

    final waitlisted = await _client
        .from('lobby_participants')
        .select()
        .eq('lobby_id', lobbyId)
        .eq('status', 'waitlisted')
        .order('joined_at', ascending: true)
        .limit(1);

    if ((waitlisted as List).isNotEmpty) {
      final participant = waitlisted.first;
      await _client
          .from('lobby_participants')
          .update({'status': 'joined'}).eq('id', participant['id']);

      await _client.from('lobbies').update({
        'current_players': lobby.currentPlayers + 1,
      }).eq('id', lobbyId);
    }
  }
}
