import 'package:beesports/app/app_colors.dart';
import 'package:beesports/models/lobby_entity.dart';
import 'package:beesports/blocs/lobby_list_bloc.dart';
import 'package:beesports/models/sport_type.dart';
import 'package:beesports/widgets/empty_states.dart';
import 'package:beesports/widgets/shimmer_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final sportParam = GoRouterState.of(context).uri.queryParameters['sport'];
      if (sportParam != null) {
        try {
          final sport = SportType.values.firstWhere(
            (s) => s.name.toLowerCase() == sportParam.toLowerCase(),
          );
          setState(() => _selectedSport = sport);
          context.read<LobbyListBloc>().add(LoadLobbies(sport: sport, sortBy: _sortBy));
        } catch (_) {
          context.read<LobbyListBloc>().add(LoadLobbies(sortBy: _sortBy));
        }
      } else {
        context.read<LobbyListBloc>().add(LoadLobbies(sortBy: _sortBy));
      }
    });
  }

  void _onSportFilter(SportType? sport) {
    HapticFeedback.selectionClick();
    setState(() => _selectedSport = sport);
    context.read<LobbyListBloc>().add(LoadLobbies(sport: sport, sortBy: _sortBy));
  }

  void _onSortChanged(String? value) {
    if (value == null) return;
    HapticFeedback.selectionClick();
    setState(() => _sortBy = value);
    context.read<LobbyListBloc>().add(LoadLobbies(sport: _selectedSport, sortBy: value));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Explore Lobbies', style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w500, color: AppColors.charcoal)),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(color: AppColors.softCloud, shape: BoxShape.circle),
                    child: PopupMenuButton<String>(
                      icon: const Icon(Icons.sort_rounded, color: AppColors.neonGreen, size: 20),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      onSelected: _onSortChanged,
                      itemBuilder: (_) => [
                        PopupMenuItem(value: 'time', child: Text('Next Upcoming', style: GoogleFonts.inter(fontWeight: FontWeight.w500))),
                        PopupMenuItem(value: 'slots', child: Text('Most Available Slots', style: GoogleFonts.inter(fontWeight: FontWeight.w500))),
                        PopupMenuItem(value: 'newest', child: Text('Newly Created', style: GoogleFonts.inter(fontWeight: FontWeight.w500))),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: 44,
              margin: const EdgeInsets.only(bottom: 12),
              child: ListView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24),
                children: [
                  _FilterChip(label: 'All Sports', selected: _selectedSport == null, onTap: () => _onSportFilter(null)),
                  const SizedBox(width: 8),
                  ...SportType.values.map((sport) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: _FilterChip(label: sport.label, selected: _selectedSport == sport, onTap: () => _onSportFilter(sport)),
                      )),
                ],
              ),
            ),
            Expanded(
              child: BlocBuilder<LobbyListBloc, LobbyListState>(
                builder: (context, state) {
                  if (state is LobbyListLoading) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: ShimmerListView.lobbyCards(count: 4),
                    );
                  }
                  if (state is LobbyListError) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.error_outline_rounded, size: 48, color: AppColors.mute),
                          const SizedBox(height: 18),
                          Text(state.message, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w500)),
                          const SizedBox(height: 24),
                          SizedBox(
                            height: 48,
                            child: ElevatedButton(
                              onPressed: () => context.read<LobbyListBloc>().add(LoadLobbies(sport: _selectedSport, sortBy: _sortBy)),
                              child: const Text('Retry'),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  if (state is LobbyListLoaded) {
                    if (state.lobbies.isEmpty) {
                      return EmptyLobbies(sportLabel: _selectedSport?.label, onCreateTap: () => context.push('/lobbies/create'));
                    }
                    return RefreshIndicator(
                      color: AppColors.neonGreen,
                      onRefresh: () async {
                        context.read<LobbyListBloc>().add(LoadLobbies(sport: _selectedSport, sortBy: _sortBy));
                      },
                      child: ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                        padding: const EdgeInsets.only(left: 24, right: 24, top: 8, bottom: 100),
                        itemCount: state.lobbies.length,
                        itemBuilder: (context, index) => _LobbyCard(lobby: state.lobbies[index])
                            .animate()
                            .fadeIn(delay: (60 * index).ms, duration: 350.ms, curve: Curves.easeOutCubic)
                            .slideX(begin: 0.05, delay: (60 * index).ms, duration: 350.ms, curve: Curves.easeOutCubic),
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
        onPressed: () {
          HapticFeedback.mediumImpact();
          context.push('/lobbies/create');
        },
        icon: const Icon(Icons.add_rounded, size: 20),
        label: Text('New Lobby', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w500)),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(30),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: selected ? AppColors.neonGreen : AppColors.canvas,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: selected ? AppColors.neonGreen : AppColors.hairline),
          ),
          child: Text(
            label,
            style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: selected ? AppColors.onPrimary : AppColors.charcoal),
          ),
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

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          context.push('/lobbies/${lobby.id}');
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.softCloud,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.hairline.withValues(alpha: 0.5)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(sport.icon, color: AppColors.neonGreen, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Hero(
                          tag: 'lobby_title_${lobby.id}',
                          child: Material(
                            color: Colors.transparent,
                            child: Text(
                              lobby.title,
                              style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.charcoal),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Hosted by ${lobby.hostName ?? 'Unknown'}',
                          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.mute),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: AppColors.canvas, borderRadius: BorderRadius.circular(30)),
                    child: Text(lobby.status.label, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.neonGreen)),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              const Divider(height: 1, color: AppColors.hairline),
              const SizedBox(height: 14),
              Row(
                children: [
                  _InfoChip(icon: Icons.calendar_today_rounded, text: '$dateStr · $timeStr'),
                  const Spacer(),
                  _InfoChip(icon: Icons.group_outlined, text: '${lobby.currentPlayers}/${lobby.maxPlayers}', isBold: true),
                  if (lobby.hasDeposit) ...[
                    const SizedBox(width: 12),
                    _InfoChip(icon: Icons.monetization_on_outlined, text: 'Rp${lobby.depositAmount.toStringAsFixed(0)}', color: AppColors.neonGreen, isBold: true),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = dt.difference(now);
    if (diff.inDays == 0 && dt.day == now.day) return 'Today';
    if (diff.inDays == 1 || (diff.inDays == 0 && dt.day == now.day + 1)) return 'Tomorrow';
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

  const _InfoChip({required this.icon, required this.text, this.color, this.isBold = false});

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.mute;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: c),
        const SizedBox(width: 6),
        Text(text, style: GoogleFonts.inter(fontSize: 14, color: c, fontWeight: isBold ? FontWeight.w500 : FontWeight.w400)),
      ],
    );
  }
}
