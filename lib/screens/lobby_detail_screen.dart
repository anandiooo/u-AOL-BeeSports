import 'package:beesports/core/feedback_service.dart';
import 'package:beesports/app/app_colors.dart';
import 'package:beesports/blocs/auth_bloc.dart';
import 'package:beesports/models/lobby_participant_entity.dart';
import 'package:beesports/blocs/lobby_detail_bloc.dart';
import 'package:beesports/models/lobby_status.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:beesports/models/lobby_entity.dart';

class LobbyDetailScreen extends StatelessWidget {
  final String lobbyId;
  const LobbyDetailScreen({super.key, required this.lobbyId});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LobbyDetailBloc, LobbyDetailState>(
      listener: (context, state) {
        if (state is LobbyActionSuccess) {
          FeedbackService.showError(context, state.message);
        }
        if (state is LobbyDetailError) {
          FeedbackService.showError(context, state.message);
        }
      },
      builder: (context, state) {
        if (state is LobbyDetailLoading) {
          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(backgroundColor: AppColors.background, elevation: 0),
            body: const Center(
                child: CircularProgressIndicator(color: AppColors.neonGreen)),
          );
        }
        if (state is LobbyDetailLoaded) {
          final lobby = state.lobby;
          final participants = state.participants;
          final authState = context.read<AuthBloc>().state;
          final currentUserId =
              authState is Authenticated ? authState.user.id : '';
          final isHost = lobby.hostId == currentUserId;
          final isParticipant =
              participants.any((p) => p.userId == currentUserId && p.isActive);

          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              title: Text(lobby.title,
                  style: GoogleFonts.inter(
                      fontWeight: FontWeight.w500, color: AppColors.neonGreen)),
              backgroundColor: AppColors.background,
              elevation: 0,
              scrolledUnderElevation: 0,
              iconTheme: const IconThemeData(color: AppColors.neonGreen),
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(lobby),
                  const SizedBox(height: 24),
                  if (lobby.latitude != null && lobby.longitude != null) ...[
                    _buildMapSection(lobby),
                    const SizedBox(height: 24),
                  ],
                  _buildInfoSection(lobby),
                  const SizedBox(height: 24),
                  _buildParticipantsSection(participants, lobby),
                  const SizedBox(height: 24),
                  if (lobby.description.isNotEmpty) ...[
                    Text('Description',
                        style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: AppColors.neonGreen)),
                    const SizedBox(height: 8),
                    Text(lobby.description,
                        style: GoogleFonts.inter(
                            color: AppColors.textSecondary, height: 1.5)),
                    const SizedBox(height: 24),
                  ],
                  _buildActions(
                      context, lobby, isHost, isParticipant, currentUserId),
                ],
              ),
            ),
          );
        }
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(backgroundColor: AppColors.background, elevation: 0),
          body: Center(
              child: Text('Failed to load lobby.',
                  style: GoogleFonts.inter(color: AppColors.neonGreen))),
        );
      },
    );
  }

  Widget _buildHeader(lobby) {
    final sport = lobby.sport;
    return Row(children: [
      Icon(sport.icon, color: AppColors.neonGreen, size: 32),
      const SizedBox(width: 16),
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(sport.label,
              style: GoogleFonts.inter(
                  color: AppColors.neonGreen,
                  fontWeight: FontWeight.w500,
                  fontSize: 14)),
          const SizedBox(height: 2),
          Text('Hosted by ${lobby.hostName ?? 'Unknown'}',
              style: GoogleFonts.inter(
                  color: AppColors.textSecondary, fontSize: 14)),
        ]),
      ),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.neonGreen,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(lobby.status.label,
            style: GoogleFonts.inter(
                color: AppColors.onAccent,
                fontWeight: FontWeight.w500,
                fontSize: 12)),
      ),
    ]);
  }

  Widget _buildInfoSection(lobby) {
    return Container(
      padding: const EdgeInsets.all(20),
      color: AppColors.surfaceVariant,
      child: Column(children: [
        _InfoRow(
            icon: Icons.calendar_today,
            label: 'Date & Time',
            value:
                '${_formatDate(lobby.scheduledAt)} at ${_formatTime(lobby.scheduledAt)}'),
        const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, color: AppColors.divider)),
        _InfoRow(
            icon: Icons.timer,
            label: 'Duration',
            value: '${lobby.durationMinutes} minutes'),
        const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, color: AppColors.divider)),
        _InfoRow(
            icon: Icons.people,
            label: 'Players',
            value:
                '${lobby.currentPlayers}/${lobby.maxPlayers} (min: ${lobby.minPlayers})'),
        if (lobby.hasDeposit) ...[
          const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(height: 1, color: AppColors.divider)),
          _InfoRow(
              icon: Icons.monetization_on,
              label: 'Deposit',
              value: 'Rp${lobby.depositAmount.toStringAsFixed(0)}',
              valueColor: AppColors.neonGreen),
        ],
        if (lobby.minElo != null || lobby.maxElo != null) ...[
          const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(height: 1, color: AppColors.divider)),
          _InfoRow(
              icon: Icons.trending_up,
              label: 'Elo Range',
              value: '${lobby.minElo ?? '—'} – ${lobby.maxElo ?? '—'}'),
        ],
      ]),
    );
  }

  Widget _buildParticipantsSection(
      List<LobbyParticipantEntity> participants, lobby) {
    final teamA =
        participants.where((p) => p.team == 'A' && p.isActive).toList();
    final teamB =
        participants.where((p) => p.team == 'B' && p.isActive).toList();
    final unassigned =
        participants.where((p) => p.team == null && p.isActive).toList();

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Text('Participants',
            style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.neonGreen)),
        const Spacer(),
        Text(
            '${participants.where((p) => p.isActive).length}/${lobby.maxPlayers}',
            style: GoogleFonts.inter(
                fontSize: 14, color: AppColors.textSecondary)),
      ]),
      const SizedBox(height: 12),
      if (teamA.isNotEmpty || teamB.isNotEmpty) ...[
        if (teamA.isNotEmpty) ...[
          const _TeamHeader('Team A'),
          ...teamA.map((p) => _ParticipantTile(participant: p)),
          const SizedBox(height: 8),
        ],
        if (teamB.isNotEmpty) ...[
          const _TeamHeader('Team B'),
          ...teamB.map((p) => _ParticipantTile(participant: p)),
          const SizedBox(height: 8),
        ],
      ],
      if (unassigned.isNotEmpty)
        ...unassigned.map((p) => _ParticipantTile(participant: p)),
      if (participants.where((p) => p.isActive).isEmpty)
        Container(
          padding: const EdgeInsets.all(24),
          alignment: Alignment.center,
          child: Text('No participants yet',
              style: GoogleFonts.inter(color: AppColors.textSecondary)),
        ),
    ]);
  }

  Widget _buildActions(BuildContext context, lobby, bool isHost,
      bool isParticipant, String currentUserId) {
    if (lobby.status == LobbyStatus.cancelled ||
        lobby.status == LobbyStatus.finished ||
        lobby.status == LobbyStatus.settled) {
      return const SizedBox.shrink();
    }
    return Column(children: [
      if (!isParticipant && lobby.isOpen)
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: () => context.read<LobbyDetailBloc>().add(
                JoinLobbyRequested(lobbyId: lobby.id, userId: currentUserId)),
            child: Text(lobby.isFull ? 'Join Waitlist' : 'Join Lobby'),
          ),
        ),
      if (isParticipant && !isHost) ...[
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.surfaceVariant,
                foregroundColor: AppColors.border),
            onPressed: () => _showConfirmDialog(context,
                title: 'Leave Lobby',
                message: 'Are you sure you want to leave?',
                onConfirm: () => context.read<LobbyDetailBloc>().add(
                    LeaveLobbyRequested(
                        lobbyId: lobby.id, userId: currentUserId))),
            child: const Text('Leave Lobby'),
          ),
        ),
      ],
      if (isHost && lobby.isOpen) ...[
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.neonGreen,
                foregroundColor: AppColors.onAccent),
            onPressed: lobby.hasMinPlayers
                ? () => context
                    .read<LobbyDetailBloc>()
                    .add(ConfirmLobbyRequested(lobby.id))
                : null,
            child: const Text('Confirm Lobby'),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.surfaceVariant,
                foregroundColor: AppColors.border),
            onPressed: () => _showConfirmDialog(context,
                title: 'Cancel Lobby',
                message: 'Are you sure? All participants will be removed.',
                onConfirm: () {
              context
                  .read<LobbyDetailBloc>()
                  .add(CancelLobbyRequested(lobby.id));
              context.pop();
            }),
            child: const Text('Cancel Lobby'),
          ),
        ),
      ],
    ]);
  }

  void _showConfirmDialog(BuildContext context,
      {required String title,
      required String message,
      required VoidCallback onConfirm}) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('No')),
          ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                onConfirm();
              },
              child: const Text('Yes')),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  String _formatTime(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

  Widget _buildMapSection(LobbyEntity lobby) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Location',
          style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.neonGreen),
        ),
        const SizedBox(height: 8),
        Container(
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.divider),
          ),
          clipBehavior: Clip.antiAlias,
          child: FlutterMap(
            options: MapOptions(
              initialCenter: LatLng(lobby.latitude!, lobby.longitude!),
              initialZoom: 15.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.beesports',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: LatLng(lobby.latitude!, lobby.longitude!),
                    width: 40,
                    height: 40,
                    child: const Icon(
                      Icons.location_on,
                      color: AppColors.neonGreen,
                      size: 40,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;
  const _InfoRow(
      {required this.icon,
      required this.label,
      required this.value,
      this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Icon(icon, size: 18, color: AppColors.textSecondary),
      const SizedBox(width: 10),
      Text(label,
          style:
              GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 14)),
      const Spacer(),
      Text(value,
          style: GoogleFonts.inter(
              fontWeight: FontWeight.w500,
              fontSize: 14,
              color: valueColor ?? AppColors.neonGreen)),
    ]);
  }
}

class _TeamHeader extends StatelessWidget {
  final String label;
  const _TeamHeader(this.label);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, top: 4),
      child: Text(label,
          style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.neonGreen)),
    );
  }
}

class _ParticipantTile extends StatelessWidget {
  final LobbyParticipantEntity participant;
  const _ParticipantTile({required this.participant});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      color: AppColors.surfaceVariant,
      child: Row(children: [
        Container(
          width: 32,
          height: 32,
          decoration: const BoxDecoration(
              color: AppColors.neonGreen, shape: BoxShape.circle),
          child: Center(
            child: Text((participant.userName ?? '?')[0].toUpperCase(),
                style: GoogleFonts.inter(
                    fontWeight: FontWeight.w500,
                    color: AppColors.onAccent,
                    fontSize: 14)),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(participant.userName ?? 'Unknown',
              style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.neonGreen)),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Text(participant.status.label,
              style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.neonGreen)),
        ),
      ]),
    );
  }
}
