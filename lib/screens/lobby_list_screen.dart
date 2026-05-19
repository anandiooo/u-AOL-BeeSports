import 'package:beesports/app/app_colors.dart';
import 'package:beesports/models/lobby_entity.dart';
import 'package:beesports/blocs/lobby_list_bloc.dart';
import 'package:beesports/models/sport_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class LobbyListScreen extends StatefulWidget {
  const LobbyListScreen({super.key});

  @override
  State<LobbyListScreen> createState() => _LobbyListScreenState();
}

class _LobbyListScreenState extends State<LobbyListScreen> {
  SportType? _selectedSport;
  String _sortBy = 'time';

  @override
  void initState() {
    super.initState();
    context.read<LobbyListBloc>().add(LoadLobbies(sortBy: _sortBy));
  }

  void _onSportFilter(SportType? sport) {
    setState(() => _selectedSport = sport);
    context
        .read<LobbyListBloc>()
        .add(LoadLobbies(sport: sport, sortBy: _sortBy));
  }

  void _onSortChanged(String? value) {
    if (value == null) return;
    setState(() => _sortBy = value);
    context
        .read<LobbyListBloc>()
        .add(LoadLobbies(sport: _selectedSport, sortBy: value));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Explore Lobbies',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimaryDark,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.cardDark,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color:
                              AppColors.textPrimaryDark.withValues(alpha: 0.1)),
                    ),
                    child: PopupMenuButton<String>(
                      icon: const Icon(Icons.sort_rounded,
                          color: AppColors.textPrimaryDark, size: 24),
                      color: AppColors.surfaceDark,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      onSelected: _onSortChanged,
                      itemBuilder: (_) => [
                        const PopupMenuItem(
                          value: 'time',
                          child: Text('Next Upcoming',
                              style: TextStyle(
                                  color: AppColors.textPrimaryDark,
                                  fontWeight: FontWeight.w500)),
                        ),
                        const PopupMenuItem(
                          value: 'slots',
                          child: Text('Most Available Slots',
                              style: TextStyle(
                                  color: AppColors.textPrimaryDark,
                                  fontWeight: FontWeight.w500)),
                        ),
                        const PopupMenuItem(
                          value: 'newest',
                          child: Text('Newly Created',
                              style: TextStyle(
                                  color: AppColors.textPrimaryDark,
                                  fontWeight: FontWeight.w500)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
              child: Container(
                height: 52,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceDark,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: AppColors.textPrimaryDark.withValues(alpha: 0.05)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.search_rounded,
                        color:
                            AppColors.textPrimaryDark.withValues(alpha: 0.4)),
                    const SizedBox(width: 12),
                    Text(
                      'Search by name or place...',
                      style: TextStyle(
                        color: AppColors.textPrimaryDark.withValues(alpha: 0.3),
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              height: 48,
              margin: const EdgeInsets.only(bottom: 12),
              child: ListView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24),
                children: [
                  _SportChip(
                    label: 'All Sports',
                    icon: Icons.apps_rounded,
                    selected: _selectedSport == null,
                    onTap: () => _onSportFilter(null),
                  ),
                  const SizedBox(width: 8),
                  ...SportType.values.map((sport) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: _SportChip(
                          label: sport.label,
                          icon: sport.icon,
                          selected: _selectedSport == sport,
                          onTap: () => _onSportFilter(sport),
                        ),
                      )),
                ],
              ),
            ),
            Expanded(
              child: BlocBuilder<LobbyListBloc, LobbyListState>(
                builder: (context, state) {
                  if (state is LobbyListLoading) {
                    return const Center(
                      child:
                          CircularProgressIndicator(color: AppColors.primary),
                    );
                  }
                  if (state is LobbyListError) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: AppColors.error.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.error_outline_rounded,
                                size: 48, color: AppColors.error),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            state.message,
                            style: const TextStyle(
                              color: AppColors.textPrimaryDark,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16)),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 12),
                            ),
                            onPressed: () => context.read<LobbyListBloc>().add(
                                LoadLobbies(
                                    sport: _selectedSport, sortBy: _sortBy)),
                            child: const Text('Retry',
                                style: TextStyle(
                                    color: AppColors.backgroundDark,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16)),
                          ),
                        ],
                      ),
                    );
                  }
                  if (state is LobbyListLoaded) {
                    if (state.lobbies.isEmpty) {
                      return _buildEmptyState();
                    }
                    return RefreshIndicator(
                      color: AppColors.primary,
                      backgroundColor: AppColors.surfaceDark,
                      onRefresh: () async {
                        context.read<LobbyListBloc>().add(LoadLobbies(
                            sport: _selectedSport, sortBy: _sortBy));
                      },
                      child: ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(
                            parent: BouncingScrollPhysics()),
                        padding: const EdgeInsets.only(
                            left: 24, right: 24, top: 8, bottom: 100),
                        itemCount: state.lobbies.length,
                        itemBuilder: (context, index) =>
                            _LobbyCard(lobby: state.lobbies[index]),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/lobbies/create'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.backgroundDark,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        icon: const Icon(Icons.add_rounded, size: 24),
        label: const Text('New Lobby',
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5)),
      ),
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      physics:
          const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: AppColors.cardDark,
                shape: BoxShape.circle,
                border: Border.all(
                    color: AppColors.textPrimaryDark.withValues(alpha: 0.05)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(Icons.search_off_rounded,
                  size: 56,
                  color: AppColors.textPrimaryDark.withValues(alpha: 0.2)),
            ),
            const SizedBox(height: 24),
            Text(
              'No lobbies found',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimaryDark.withValues(alpha: 0.9),
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Be the first to create one and invite others!',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimaryDark.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SportChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _SportChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.textPrimaryDark : AppColors.cardDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected
                ? AppColors.textPrimaryDark
                : AppColors.textPrimaryDark.withValues(alpha: 0.05),
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppColors.textPrimaryDark.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: selected
                  ? AppColors.backgroundDark
                  : AppColors.textPrimaryDark.withValues(alpha: 0.7),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                color: selected
                    ? AppColors.backgroundDark
                    : AppColors.textPrimaryDark.withValues(alpha: 0.6),
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LobbyCard extends StatelessWidget {
  final LobbyEntity lobby;

  const _LobbyCard({required this.lobby});

  @override
  Widget build(BuildContext context) {
    final sport = lobby.sport;
    final timeStr = _formatTime(lobby.scheduledAt);
    final dateStr = _formatDate(lobby.scheduledAt);

    return GestureDetector(
      onTap: () => context.push('/lobbies/${lobby.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
              color: AppColors.textPrimaryDark.withValues(alpha: 0.05)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: AppColors.surfaceDark,
                    shape: BoxShape.circle,
                  ),
                  child:
                      Icon(sport.icon, color: AppColors.primaryLight, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lobby.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimaryDark,
                          letterSpacing: -0.5,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Hosted by ${lobby.hostName ?? 'Unknown'}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondaryDark,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: lobby.status.color == AppColors.success
                        ? AppColors.primaryLight.withValues(alpha: 0.15)
                        : lobby.status.color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    lobby.status.label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: lobby.status.color == AppColors.success
                          ? AppColors.primaryLight
                          : lobby.status.color,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                _InfoChip(
                  icon: Icons.calendar_today_rounded,
                  text: '$dateStr • $timeStr',
                ),
                const Spacer(),
                _InfoChip(
                  icon: Icons.group_rounded,
                  text: '${lobby.currentPlayers}/${lobby.maxPlayers}',
                  color: lobby.isFull
                      ? AppColors.textPrimaryDark
                      : AppColors.primary,
                  isBold: true,
                ),
                if (lobby.hasDeposit) ...[
                  const SizedBox(width: 12),
                  _InfoChip(
                    icon: Icons.monetization_on_rounded,
                    text: 'Rp${lobby.depositAmount.toStringAsFixed(0)}',
                    color: AppColors.success,
                    isBold: true,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = dt.difference(now);
    if (diff.inDays == 0 && dt.day == now.day) return 'Today';
    if (diff.inDays == 1 || (diff.inDays == 0 && dt.day == now.day + 1)) {
      return 'Tomorrow';
    }
    return '${dt.day}/${dt.month}';
  }

  String _formatTime(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color? color;
  final bool isBold;

  const _InfoChip({
    required this.icon,
    required this.text,
    this.color,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.textSecondaryDark;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: c.withValues(alpha: 0.8)),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            fontSize: 13,
            color: c,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
