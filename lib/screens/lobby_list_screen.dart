import 'package:beesports/app/app_colors.dart';
import 'package:beesports/models/lobby_entity.dart';
import 'package:beesports/blocs/lobby_list_bloc.dart';
import 'package:beesports/models/sport_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

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
      backgroundColor: AppColors.foursier,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Explore Lobbies',
                    style: GoogleFonts.inter(
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primary,
                    ),
                  ),
                  // Sort button — icon-circular style
                  GestureDetector(
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: AppColors.secondaryLight,
                        shape: BoxShape.circle,
                      ),
                      child: PopupMenuButton<String>(
                        icon: const Icon(Icons.sort_rounded,
                            color: AppColors.primary, size: 20),
                        color: AppColors.foursier,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24)),
                        onSelected: _onSortChanged,
                        itemBuilder: (_) => [
                          PopupMenuItem(
                            value: 'time',
                            child: Text('Next Upcoming',
                                style: GoogleFonts.inter(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w500)),
                          ),
                          PopupMenuItem(
                            value: 'slots',
                            child: Text('Most Available Slots',
                                style: GoogleFonts.inter(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w500)),
                          ),
                          PopupMenuItem(
                            value: 'newest',
                            child: Text('Newly Created',
                                style: GoogleFonts.inter(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w500)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Search pill
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 18),
              child: Container(
                height: 40,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.secondaryLight,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    Icon(Icons.search_rounded,
                        color: AppColors.primary.withValues(alpha: 0.4), size: 20),
                    const SizedBox(width: 12),
                    Text(
                      'Search by name or place...',
                      style: GoogleFonts.inter(
                        color: AppColors.primary.withValues(alpha: 0.35),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Filter chips — pill shape, ink/canvas toggle
            Container(
              height: 44,
              margin: const EdgeInsets.only(bottom: 12),
              child: ListView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24),
                children: [
                  _FilterChip(
                    label: 'All Sports',
                    selected: _selectedSport == null,
                    onTap: () => _onSportFilter(null),
                  ),
                  const SizedBox(width: 8),
                  ...SportType.values.map((sport) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: _FilterChip(
                          label: sport.label,
                          selected: _selectedSport == sport,
                          onTap: () => _onSportFilter(sport),
                        ),
                      )),
                ],
              ),
            ),

            // Lobby list
            Expanded(
              child: BlocBuilder<LobbyListBloc, LobbyListState>(
                builder: (context, state) {
                  if (state is LobbyListLoading) {
                    return const Center(
                      child: CircularProgressIndicator(color: AppColors.primary),
                    );
                  }
                  if (state is LobbyListError) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.error_outline_rounded,
                              size: 48, color: AppColors.primaryLight),
                          const SizedBox(height: 18),
                          Text(
                            state.message,
                            style: GoogleFonts.inter(
                              color: AppColors.primary,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            height: 48,
                            child: ElevatedButton(
                              onPressed: () => context.read<LobbyListBloc>().add(
                                  LoadLobbies(
                                      sport: _selectedSport, sortBy: _sortBy)),
                              child: const Text('Retry'),
                            ),
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
                      backgroundColor: AppColors.foursier,
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
      floatingActionButton: Container(
        height: 48,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
        ),
        child: FloatingActionButton.extended(
          onPressed: () => context.push('/lobbies/create'),
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.foursierLight,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          icon: const Icon(Icons.add_rounded, size: 20),
          label: Text('New Lobby',
              style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w500)),
        ),
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
              decoration: const BoxDecoration(
                color: AppColors.secondaryLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.search_off_rounded,
                  size: 48, color: AppColors.primaryLight),
            ),
            const SizedBox(height: 24),
            Text(
              'No lobbies found',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Be the first to create one and invite others!',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.primaryLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Nike-style filter chip — ink bg when active, canvas with hairline when inactive
class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
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
          color: selected ? AppColors.primary : AppColors.foursier,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.foursierDark,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: selected ? AppColors.foursierLight : AppColors.primary,
          ),
        ),
      ),
    );
  }
}

/// Lobby card — flat, no shadow, hairline border, zero radius
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
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: AppColors.secondaryLight,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(sport.icon, color: AppColors.primary, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lobby.title,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppColors.primary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Hosted by ${lobby.hostName ?? 'Unknown'}',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.primaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.foursier,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    lobby.status.label,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            // Hairline divider
            const Divider(height: 1, color: AppColors.tersierLight),
            const SizedBox(height: 14),
            Row(
              children: [
                _InfoChip(
                  icon: Icons.calendar_today_rounded,
                  text: '$dateStr · $timeStr',
                ),
                const Spacer(),
                _InfoChip(
                  icon: Icons.group_outlined,
                  text: '${lobby.currentPlayers}/${lobby.maxPlayers}',
                  isBold: true,
                ),
                if (lobby.hasDeposit) ...[
                  const SizedBox(width: 12),
                  _InfoChip(
                    icon: Icons.monetization_on_outlined,
                    text: 'Rp${lobby.depositAmount.toStringAsFixed(0)}',
                    color: AppColors.secondary,
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
    final c = color ?? AppColors.primaryLight;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: c),
        const SizedBox(width: 6),
        Text(
          text,
          style: GoogleFonts.inter(
            fontSize: 14,
            color: c,
            fontWeight: isBold ? FontWeight.w500 : FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
