import 'package:beesports/app/app_colors.dart';
import 'package:beesports/blocs/auth_bloc.dart';
import 'package:beesports/models/lobby_participant_entity.dart';
import 'package:beesports/blocs/lobby_detail_bloc.dart';
import 'package:beesports/models/lobby_status.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class LobbyDetailScreen extends StatelessWidget {
  final String lobbyId;

  const LobbyDetailScreen({super.key, required this.lobbyId});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LobbyDetailBloc, LobbyDetailState>(
      listener: (context, state) {
        if (state is LobbyActionSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.success,
            ),
          );
        }
        if (state is LobbyDetailError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is LobbyDetailLoading) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: CircularProgressIndicator()),
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
            appBar: AppBar(
              title: Text(lobby.title),
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(lobby),
                  const SizedBox(height: 20),
                  _buildInfoSection(lobby),
                  const SizedBox(height: 24),
                  _buildParticipantsSection(participants, lobby),
                  const SizedBox(height: 24),
                  if (lobby.description.isNotEmpty) ...[
                    const Text(
                      'Description',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      lobby.description,
                      style: TextStyle(
                        color:
                            AppColors.textSecondaryDark.withValues(alpha: 0.7),
                      ),
                    ),
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
          appBar: AppBar(),
          body: const Center(child: Text('Failed to load lobby.')),
        );
      },
    );
  }

  Widget _buildHeader(lobby) {
    final sport = lobby.sport;
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                sport.color.withValues(alpha: 0.2),
                sport.color.withValues(alpha: 0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(sport.icon, color: sport.color, size: 32),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                sport.label,
                style: TextStyle(
                  color: sport.color,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Hosted by ${lobby.hostName ?? 'Unknown'}',
                style: TextStyle(
                  color: AppColors.textSecondaryDark.withValues(alpha: 0.7),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: lobby.status.color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            lobby.status.label,
            style: TextStyle(
              color: lobby.status.color,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoSection(lobby) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          _InfoRow(
            icon: Icons.calendar_today,
            label: 'Date & Time',
            value:
                '${_formatDate(lobby.scheduledAt)} at ${_formatTime(lobby.scheduledAt)}',
          ),
          const Divider(height: 20, color: Color(0xFF3C3C3C)),
          _InfoRow(
            icon: Icons.timer,
            label: 'Duration',
            value: '${lobby.durationMinutes} minutes',
          ),
          const Divider(height: 20, color: Color(0xFF3C3C3C)),
          _InfoRow(
            icon: Icons.people,
            label: 'Players',
            value:
                '${lobby.currentPlayers}/${lobby.maxPlayers} (min: ${lobby.minPlayers})',
          ),
          if (lobby.hasDeposit) ...[
            const Divider(height: 20, color: Color(0xFF3C3C3C)),
            _InfoRow(
              icon: Icons.monetization_on,
              label: 'Deposit',
              value: 'Rp${lobby.depositAmount.toStringAsFixed(0)}',
              valueColor: AppColors.warning,
            ),
          ],
          if (lobby.minElo != null || lobby.maxElo != null) ...[
            const Divider(height: 20, color: Color(0xFF3C3C3C)),
            _InfoRow(
              icon: Icons.trending_up,
              label: 'Elo Range',
              value: '${lobby.minElo ?? '—'} – ${lobby.maxElo ?? '—'}',
            ),
          ],
        ],
      ),
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Participants',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const Spacer(),
            Text(
              '${participants.where((p) => p.isActive).length}/${lobby.maxPlayers}',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondaryDark.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (teamA.isNotEmpty || teamB.isNotEmpty) ...[
          if (teamA.isNotEmpty) ...[
            const _TeamHeader('Team A', Color(0xFF42A5F5)),
            ...teamA.map((p) => _ParticipantTile(participant: p)),
            const SizedBox(height: 8),
          ],
          if (teamB.isNotEmpty) ...[
            const _TeamHeader('Team B', Color(0xFFEF5350)),
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
            child: Text(
              'No participants yet',
              style: TextStyle(
                color: AppColors.textSecondaryDark.withValues(alpha: 0.4),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildActions(BuildContext context, lobby, bool isHost,
      bool isParticipant, String currentUserId) {
    if (lobby.status == LobbyStatus.cancelled ||
        lobby.status == LobbyStatus.finished ||
        lobby.status == LobbyStatus.settled) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        if (!isParticipant && lobby.isOpen)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                context.read<LobbyDetailBloc>().add(JoinLobbyRequested(
                      lobbyId: lobby.id,
                      userId: currentUserId,
                    ));
              },
              icon: const Icon(Icons.login),
              label: Text(lobby.isFull ? 'Join Waitlist' : 'Join Lobby'),
            ),
          ),
        if (isParticipant && !isHost) ...[
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                _showConfirmDialog(
                  context,
                  title: 'Leave Lobby',
                  message: 'Are you sure you want to leave?',
                  onConfirm: () {
                    context.read<LobbyDetailBloc>().add(LeaveLobbyRequested(
                          lobbyId: lobby.id,
                          userId: currentUserId,
                        ));
                  },
                );
              },
              icon: const Icon(Icons.logout),
              label: const Text('Leave Lobby'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: const BorderSide(color: AppColors.error),
              ),
            ),
          ),
        ],
        if (isHost && lobby.isOpen) ...[
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: lobby.hasMinPlayers
                  ? () {
                      context
                          .read<LobbyDetailBloc>()
                          .add(ConfirmLobbyRequested(lobby.id));
                    }
                  : null,
              icon: const Icon(Icons.check_circle),
              label: const Text('Confirm Lobby'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                foregroundColor: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                _showConfirmDialog(
                  context,
                  title: 'Cancel Lobby',
                  message: 'Are you sure? All participants will be removed.',
                  onConfirm: () {
                    context
                        .read<LobbyDetailBloc>()
                        .add(CancelLobbyRequested(lobby.id));
                    context.pop();
                  },
                );
              },
              icon: const Icon(Icons.cancel),
              label: const Text('Cancel Lobby'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: const BorderSide(color: AppColors.error),
              ),
            ),
          ),
        ],
      ],
    );
  }

  void _showConfirmDialog(
    BuildContext context, {
    required String title,
    required String message,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              onConfirm();
            },
            child: const Text('Yes'),
          ),
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
      'Dec',
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  String _formatTime(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textSecondaryDark),
        const SizedBox(width: 10),
        Text(
          label,
          style: TextStyle(
            color: AppColors.textSecondaryDark.withValues(alpha: 0.7),
            fontSize: 13,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: valueColor ?? AppColors.textPrimaryDark,
          ),
        ),
      ],
    );
  }
}

class _TeamHeader extends StatelessWidget {
  final String label;
  final Color color;

  const _TeamHeader(this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, top: 4),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

class _ParticipantTile extends StatelessWidget {
  final LobbyParticipantEntity participant;

  const _ParticipantTile({required this.participant});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.primary.withValues(alpha: 0.2),
            child: Text(
              (participant.userName ?? '?')[0].toUpperCase(),
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              participant.userName ?? 'Unknown',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: _statusColor(participant.status.label)
                  .withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              participant.status.label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: _statusColor(participant.status.label),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Confirmed':
        return AppColors.success;
      case 'Waitlisted':
        return AppColors.warning;
      case 'Joined':
        return AppColors.info;
      default:
        return AppColors.textSecondaryDark;
    }
  }
}
