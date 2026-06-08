import 'package:beesports/app/app_theme.dart';
import 'package:beesports/blocs/lobby_list_bloc.dart';
import 'package:beesports/models/lobby_entity.dart';
import 'package:beesports/models/lobby_status.dart';
import 'package:beesports/models/sport_type.dart';
import 'package:beesports/widgets/empty_states.dart';
import 'package:beesports/widgets/shimmer_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class LobbyListScreen extends StatefulWidget {
  const LobbyListScreen({super.key});

  @override
  State<LobbyListScreen> createState() => _LobbyListScreenState();
}

class _LobbyListScreenState extends State<LobbyListScreen> {
  SportType? _selectedSport;
  final String _sortBy = 'newest';
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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
          context
              .read<LobbyListBloc>()
              .add(LoadLobbies(sport: sport, sortBy: _sortBy));
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
    context
        .read<LobbyListBloc>()
        .add(LoadLobbies(sport: sport, sortBy: _sortBy));
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(DesignConfig.spacingXl,
              DesignConfig.spacingXl, DesignConfig.spacingXl, 0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: DesignConfig.spacingLg),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Explore Lobbies', style: AppTextStyles.sectionTitle),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: DesignConfig.spacingMd),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    context.read<LobbyListBloc>().add(SearchLobbies(
                          value,
                          sport: _selectedSport,
                          sortBy: _sortBy,
                        ));
                  },
                  style: AppTextStyles.bodySecondary
                      .copyWith(color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Search by title or description...',
                    hintStyle: AppTextStyles.bodySecondary,
                    prefixIcon: const Icon(Icons.search_rounded,
                        color: AppColors.textSecondary, size: 20),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 0, horizontal: DesignConfig.spacingLg),
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(DesignConfig.rounded2xl),
                      borderSide: const BorderSide(color: AppColors.hairline),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(DesignConfig.rounded2xl),
                      borderSide: const BorderSide(color: AppColors.hairline),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(DesignConfig.rounded2xl),
                      borderSide: const BorderSide(color: AppColors.neonGreen),
                    ),
                    fillColor: AppColors.softCloud,
                    filled: true,
                  ),
                ),
              ),
              Container(
                height: 44,
                margin: const EdgeInsets.only(bottom: DesignConfig.spacingMd),
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.zero,
                  children: [
                    _FilterChip(
                        label: 'All Sports',
                        selected: _selectedSport == null,
                        onTap: () => _onSportFilter(null)),
                    const SizedBox(width: DesignConfig.spacingSm),
                    ...SportType.values.map((sport) => Padding(
                          padding: const EdgeInsets.only(
                              right: DesignConfig.spacingSm),
                          child: _FilterChip(
                              label: sport.label,
                              selected: _selectedSport == sport,
                              onTap: () => _onSportFilter(sport)),
                        )),
                  ],
                ),
              ),
              Expanded(
                child: BlocBuilder<LobbyListBloc, LobbyListState>(
                  builder: (context, state) {
                    if (state is LobbyListLoading) {
                      return ShimmerListView.lobbyCards(count: 4);
                    }
                    if (state is LobbyListError) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.error_outline_rounded,
                                size: 48, color: AppColors.textSecondary),
                            const SizedBox(height: DesignConfig.spacingLg),
                            Text(state.message, style: AppTextStyles.cardTitle),
                            const SizedBox(height: DesignConfig.spacingXl),
                            SizedBox(
                              height: 48,
                              child: ElevatedButton(
                                onPressed: () => context
                                    .read<LobbyListBloc>()
                                    .add(LoadLobbies(
                                        sport: _selectedSport,
                                        sortBy: _sortBy)),
                                child: const Text('Retry'),
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    if (state is LobbyListLoaded) {
                      if (state.lobbies.isEmpty) {
                        return EmptyLobbies(
                            sportLabel: _selectedSport?.label,
                            onCreateTap: () => context.push('/lobbies/create'));
                      }
                      return RefreshIndicator(
                        color: AppColors.neonGreen,
                        onRefresh: () async {
                          context.read<LobbyListBloc>().add(LoadLobbies(
                              sport: _selectedSport, sortBy: _sortBy));
                        },
                        child: ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(
                              parent: BouncingScrollPhysics()),
                          padding: const EdgeInsets.only(
                              top: DesignConfig.spacingSm,
                              bottom: DesignConfig.spacing3xl),
                          itemCount: state.lobbies.length,
                          itemBuilder: (context, index) =>
                              LobbyCard(lobby: state.lobbies[index])
                                  .animate()
                                  .fadeIn(
                                      delay: (60 * index).ms,
                                      duration: 350.ms,
                                      curve: Curves.easeOutCubic)
                                  .slideX(
                                      begin: 0.05,
                                      delay: (60 * index).ms,
                                      duration: 350.ms,
                                      curve: Curves.easeOutCubic),
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
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          HapticFeedback.mediumImpact();
          context.push('/lobbies/create');
        },
        icon: const Icon(Icons.add_rounded, size: 20),
        label: Text('New Lobby',
            style:
                AppTextStyles.cardTitle.copyWith(color: AppColors.background)),
      ),
    );
  }
}
class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(DesignConfig.rounded2xl),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(
              horizontal: DesignConfig.spacingLg,
              vertical: DesignConfig.spacingMd),
          decoration: BoxDecoration(
            color: selected ? AppColors.neonGreen : AppColors.canvas,
            borderRadius: BorderRadius.circular(DesignConfig.rounded2xl),
            border: Border.all(
                color: selected ? AppColors.neonGreen : AppColors.hairline),
          ),
          child: Text(
            label,
            style: AppTextStyles.bodySecondaryStrong.copyWith(
                color: selected ? AppColors.onAccent : AppColors.textPrimary),
          ),
        ),
      ),
    );
  }
}

class LobbyCard extends StatelessWidget {
  final LobbyEntity lobby;

  const LobbyCard({super.key, required this.lobby});

  @override
  Widget build(BuildContext context) {
    final sport = lobby.sport;
    final timeStr = _formatTime(lobby.scheduledAt);
    final dateStr = _formatDate(lobby.scheduledAt);
    final isCancelled = lobby.status == LobbyStatus.cancelled;

    Widget cardContent = Container(
      margin: const EdgeInsets.only(bottom: DesignConfig.spacingSm),
      padding: const EdgeInsets.all(DesignConfig.spacingXl),
      decoration: BoxDecoration(
        color: AppColors.softCloud,
        borderRadius: BorderRadius.circular(DesignConfig.roundedXl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(sport.icon, color: AppColors.neonGreen, size: 24),
              const SizedBox(width: DesignConfig.spacingMd),
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
                          style: AppTextStyles.cardTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    const SizedBox(height: DesignConfig.spacingXxs),
                    Text(
                      'Hosted by ${lobby.hostName ?? '[N/A]'}',
                      style: AppTextStyles.bodySecondaryStrong,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: DesignConfig.spacingMd,
                    vertical: DesignConfig.spacingSm),
                decoration: BoxDecoration(
                    color: AppColors.canvas,
                    borderRadius:
                        BorderRadius.circular(DesignConfig.rounded2xl)),
                child: Text(lobby.status.label,
                    style: AppTextStyles.accentCaption),
              ),
            ],
          ),
          const SizedBox(height: DesignConfig.spacingLg),
          const Divider(height: 1, color: AppColors.hairline),
          const SizedBox(height: DesignConfig.spacingLg),
          Row(
            children: [
              _InfoChip(
                  icon: Icons.calendar_today_rounded,
                  text: '$dateStr · $timeStr'),
              const Spacer(),
              _InfoChip(
                  icon: Icons.group_outlined,
                  text: '${lobby.currentPlayers}/${lobby.maxPlayers}',
                  isBold: true),
              if (lobby.hasDeposit) ...[
                const SizedBox(width: DesignConfig.spacingMd),
                _InfoChip(
                    icon: Icons.monetization_on_outlined,
                    text: 'Rp${lobby.depositAmount.toStringAsFixed(0)}',
                    color: AppColors.neonGreen,
                    isBold: true),
              ],
            ],
          ),
        ],
      ),
    );

    if (isCancelled) {
      cardContent = Opacity(
        opacity: 0.4,
        child: cardContent,
      );
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          context.push('/lobbies/${lobby.id}');
        },
        borderRadius: BorderRadius.circular(DesignConfig.roundedXl),
        child: cardContent,
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

  const _InfoChip(
      {required this.icon,
      required this.text,
      this.color,
      this.isBold = false});

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.textSecondary;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: c),
        const SizedBox(width: DesignConfig.spacingSm),
        Text(text,
            style: AppTextStyles.bodySecondary.copyWith(
                color: c,
                fontWeight: isBold ? FontWeight.w500 : FontWeight.w400)),
      ],
    );
  }
}
