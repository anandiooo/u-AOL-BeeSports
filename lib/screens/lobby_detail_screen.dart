import 'package:beesports/core/feedback_service.dart';
import 'package:beesports/app/app_theme.dart';
import 'package:beesports/blocs/auth_bloc.dart';
import 'package:beesports/models/lobby_participant_entity.dart';
import 'package:beesports/blocs/lobby_detail_bloc.dart';
import 'package:beesports/models/lobby_status.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
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
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  if (Navigator.of(context).canPop()) {
                    context.pop();
                    return;
                  }
                  context.go('/home');
                },
              ),
              backgroundColor: AppColors.background,
              elevation: 0,
            ),
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
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  if (Navigator.of(context).canPop()) {
                    context.pop();
                    return;
                  }
                  context.go('/home');
                },
              ),
              title: Text(lobby.title,
                  style: AppTextStyles.sectionTitle),
              backgroundColor: AppColors.background,
              elevation: 0,
              scrolledUnderElevation: 0,
              iconTheme: const IconThemeData(color: AppColors.neonGreen),
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(DesignConfig.spacingXl,
                  DesignConfig.spacingXl, DesignConfig.spacingXl, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(lobby),
                  const SizedBox(height: DesignConfig.spacingXl),
                  if (lobby.latitude != null && lobby.longitude != null) ...[
                    _buildMapSection(lobby),
                    const SizedBox(height: DesignConfig.spacingXl),
                  ],
                  _buildInfoSection(lobby),
                  const SizedBox(height: DesignConfig.spacingXl),
                  _buildParticipantsSection(participants, lobby),
                  const SizedBox(height: DesignConfig.spacingXl),
                  if (lobby.description.isNotEmpty) ...[
                    Text('Description',
                        style: AppTextStyles.accentBody),
                    const SizedBox(height: DesignConfig.spacingSm),
                    Text(lobby.description,
                        style: AppTextStyles.bodySecondary.copyWith(height: 1.5)),
                    const SizedBox(height: DesignConfig.spacingXl),
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
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                if (Navigator.of(context).canPop()) {
                  context.pop();
                  return;
                }
                context.go('/home');
              },
            ),
            backgroundColor: AppColors.background,
            elevation: 0,
          ),
          body: Center(
              child: Text('Failed to load lobby.',
                  style: AppTextStyles.sectionTitle)),
        );
      },
    );
  }

  Widget _buildHeader(lobby) {
    final sport = lobby.sport;
    return Row(children: [
      Icon(sport.icon, color: AppColors.neonGreen, size: 32),
      const SizedBox(width: DesignConfig.spacingLg),
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(sport.label,
              style: AppTextStyles.accentLabel),
          const SizedBox(height: DesignConfig.spacingXxs),
          Text('Hosted by ${lobby.hostName ?? '[N/A]'}',
              style: AppTextStyles.bodySecondary),
        ]),
      ),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: DesignConfig.spacingMd, vertical: DesignConfig.spacingSm),
        decoration: BoxDecoration(
          color: AppColors.neonGreen,
          borderRadius: BorderRadius.circular(DesignConfig.rounded2xl),
        ),
        child: Text(lobby.status.label,
            style: AppTextStyles.onAccent),
      ),
    ]);
  }

  Widget _buildInfoSection(lobby) {
    return Container(
      padding: const EdgeInsets.all(DesignConfig.spacingXl),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(DesignConfig.roundedXl),
      ),
      child: Column(children: [
        _InfoRow(
            icon: Icons.calendar_today,
            label: 'Date & Time',
            value:
                '${_formatDate(lobby.scheduledAt)} at ${_formatTime(lobby.scheduledAt)}'),
        const Padding(
            padding: EdgeInsets.symmetric(vertical: DesignConfig.spacingMd),
            child: Divider(height: 1, color: AppColors.divider)),
        _InfoRow(
            icon: Icons.timer,
            label: 'Duration',
            value: '${lobby.durationMinutes} minutes'),
        const Padding(
            padding: EdgeInsets.symmetric(vertical: DesignConfig.spacingMd),
            child: Divider(height: 1, color: AppColors.divider)),
        _InfoRow(
            icon: Icons.people,
            label: 'Players',
            value:
                '${lobby.currentPlayers}/${lobby.maxPlayers} (min: ${lobby.minPlayers})'),
        if (lobby.hasDeposit) ...[
          const Padding(
              padding: EdgeInsets.symmetric(vertical: DesignConfig.spacingMd),
              child: Divider(height: 1, color: AppColors.divider)),
          _InfoRow(
              icon: Icons.monetization_on,
              label: 'Deposit',
              value: 'Rp${lobby.depositAmount.toStringAsFixed(0)}',
              valueColor: AppColors.neonGreen),
        ],
        if (lobby.minElo != null || lobby.maxElo != null) ...[
          const Padding(
              padding: EdgeInsets.symmetric(vertical: DesignConfig.spacingMd),
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
            style: AppTextStyles.accentBody),
        const Spacer(),
        Text(
            '${participants.where((p) => p.isActive).length}/${lobby.maxPlayers}',
            style: AppTextStyles.bodySecondary),
      ]),
      const SizedBox(height: DesignConfig.spacingMd),
      if (teamA.isNotEmpty || teamB.isNotEmpty) ...[
        if (teamA.isNotEmpty) ...[
          const _TeamHeader('Team A'),
          ...teamA.map((p) => _ParticipantTile(participant: p)),
          const SizedBox(height: DesignConfig.spacingSm),
        ],
        if (teamB.isNotEmpty) ...[
          const _TeamHeader('Team B'),
          ...teamB.map((p) => _ParticipantTile(participant: p)),
          const SizedBox(height: DesignConfig.spacingSm),
        ],
      ],
      if (unassigned.isNotEmpty)
        ...unassigned.map((p) => _ParticipantTile(participant: p)),
      if (participants.where((p) => p.isActive).isEmpty)
        Container(
          padding: const EdgeInsets.all(DesignConfig.spacingXl),
          alignment: Alignment.center,
          child: Text('No participants yet',
              style: AppTextStyles.bodySecondary),
        ),
    ]);
  }

  Widget _buildActions(BuildContext context, lobby, bool isHost,
      bool isParticipant, String currentUserId) {
    if (lobby.status == LobbyStatus.cancelled ||
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
        const SizedBox(height: DesignConfig.spacingSm),
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
        const SizedBox(height: DesignConfig.spacingSm),
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
        const SizedBox(height: DesignConfig.spacing2xl),
      ],
      if (isHost && lobby.status == LobbyStatus.confirmed) ...[
        const SizedBox(height: DesignConfig.spacingSm),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.neonGreen,
                foregroundColor: AppColors.onAccent),
            onPressed: () => context.read<LobbyDetailBloc>().add(
                SettleLobbyRequested(lobby.id)),
            child: const Text('Finish & Split Bill'),
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
          style: AppTextStyles.accentBody,
        ),
        const SizedBox(height: DesignConfig.spacingSm),
        Container(
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(DesignConfig.roundedXl),
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
      const SizedBox(width: DesignConfig.spacingMd),
      Text(label,
          style:
              AppTextStyles.bodySecondary),
      const Spacer(),
      Text(value,
          style: AppTextStyles.accentLabel.copyWith(
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
      padding: const EdgeInsets.only(bottom: DesignConfig.spacingSm, top: DesignConfig.spacingXs),
      child: Text(label,
          style: AppTextStyles.accentLabel),
    );
  }
}

class _ParticipantTile extends StatelessWidget {
  final LobbyParticipantEntity participant;
  const _ParticipantTile({required this.participant});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: DesignConfig.spacingXs),
      padding: const EdgeInsets.symmetric(horizontal: DesignConfig.spacingMd, vertical: DesignConfig.spacingMd),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(DesignConfig.roundedXl),
      ),
      child: Row(children: [
        Container(
          width: 32,
          height: 32,
          decoration: const BoxDecoration(
              color: AppColors.neonGreen, shape: BoxShape.circle),
          child: Center(
            child: Text((participant.userName ?? '?')[0].toUpperCase(),
                style: AppTextStyles.onAccentBody),
          ),
        ),
        const SizedBox(width: DesignConfig.spacingMd),
        Expanded(
          child: Text(participant.userName ?? '[N/A]',
              style: AppTextStyles.accentLabel),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: DesignConfig.spacingMd, vertical: DesignConfig.spacingXs),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(DesignConfig.rounded2xl),
          ),
          child: Text(participant.status.label,
              style: AppTextStyles.accentCaption),
        ),
      ]),
    );
  }
}


