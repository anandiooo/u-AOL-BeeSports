import 'package:beesports/core/feedback_service.dart';
import 'package:beesports/app/app_theme.dart';
import 'package:beesports/blocs/auth_bloc.dart';
import 'package:beesports/models/friendship_entity.dart';
import 'package:beesports/blocs/social_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});
  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      _currentUserId = authState.user.id;
      context.read<SocialBloc>().add(LoadFriends(_currentUserId!));
    }
    _tabController.addListener(() {
      if (_currentUserId == null) return;
      if (_tabController.index == 0) {
        context.read<SocialBloc>().add(LoadFriends(_currentUserId!));
      } else if (_tabController.index == 1) {
        context.read<SocialBloc>().add(LoadPendingRequests(_currentUserId!));
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Friends',
            style: AppTextStyles.sectionTitle),
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Friends'),
            Tab(text: 'Requests'),
            Tab(text: 'Search'),
          ],
          indicatorColor: AppColors.neonGreen,
          labelColor: AppColors.neonGreen,
          unselectedLabelColor: AppColors.textSecondary,
          labelStyle: AppTextStyles.sectionTitle,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_search, color: AppColors.neonGreen),
            onPressed: () => context.push('/users/search'),
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _FriendsTab(currentUserId: _currentUserId),
          _RequestsTab(currentUserId: _currentUserId),
          _SearchTab(currentUserId: _currentUserId),
        ],
      ),
    );
  }
}

class _FriendsTab extends StatelessWidget {
  final String? currentUserId;
  const _FriendsTab({this.currentUserId});
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SocialBloc, SocialState>(builder: (context, state) {
      if (state is SocialLoading) {
        return const Center(
            child: CircularProgressIndicator(color: AppColors.neonGreen));
      }
      if (state is FriendsLoaded) {
        if (state.friends.isEmpty) {
          return _emptyState(
              icon: Icons.people_outline,
              label: 'No friends yet. Search and add people!');
        }
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(DesignConfig.spacingXl,
              DesignConfig.spacingXl, DesignConfig.spacingXl, 0),
          itemCount: state.friends.length,
          itemBuilder: (context, index) => _FriendTile(
              friendship: state.friends[index], currentUserId: currentUserId),
        );
      }
      return const SizedBox.shrink();
    });
  }
}

class _RequestsTab extends StatelessWidget {
  final String? currentUserId;
  const _RequestsTab({this.currentUserId});
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SocialBloc, SocialState>(builder: (context, state) {
      if (state is SocialLoading) {
        return const Center(
            child: CircularProgressIndicator(color: AppColors.neonGreen));
      }
      if (state is PendingRequestsLoaded) {
        if (state.requests.isEmpty) {
          return _emptyState(
              icon: Icons.mail_outline, label: 'No pending requests');
        }
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(DesignConfig.spacingXl,
              DesignConfig.spacingXl, DesignConfig.spacingXl, 0),
          itemCount: state.requests.length,
          itemBuilder: (context, index) {
            final request = state.requests[index];
            return Container(
              margin: const EdgeInsets.only(bottom: DesignConfig.spacingSm),
              padding: const EdgeInsets.all(DesignConfig.spacingLg),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(DesignConfig.roundedXl),
              ),
              child: Row(children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                      color: AppColors.neonGreen, shape: BoxShape.circle),
                  child: Center(
                    child: Text((request.requesterName ?? '?')[0].toUpperCase(),
                        style: AppTextStyles.onAccentBody),
                  ),
                ),
                const SizedBox(width: DesignConfig.spacingMd),
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(request.requesterName ?? '[N/A]',
                            style: AppTextStyles.sectionTitle),
                        Text('Wants to be your friend',
                            style: AppTextStyles.caption),
                      ]),
                ),
                IconButton(
                  icon: const Icon(Icons.check_circle,
                      color: AppColors.neonGreen),
                  onPressed: () => context.read<SocialBloc>().add(
                      RespondToRequest(request.id, true, currentUserId ?? '')),
                ),
                IconButton(
                  icon: const Icon(Icons.cancel, color: AppColors.accentOrange),
                  onPressed: () => context.read<SocialBloc>().add(
                      RespondToRequest(request.id, false, currentUserId ?? '')),
                ),
              ]),
            );
          },
        );
      }
      return const SizedBox.shrink();
    });
  }
}

class _SearchTab extends StatelessWidget {
  final String? currentUserId;
  const _SearchTab({this.currentUserId});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(DesignConfig.spacingXl,
          DesignConfig.spacingXl, DesignConfig.spacingXl, 0),
      child: Column(children: [
        TextField(
          decoration: const InputDecoration(
            hintText: 'Search by name or NIM...',
            prefixIcon: Icon(Icons.search),
          ),
          onChanged: (value) {
            if (value.length >= 2) {
              context.read<SocialBloc>().add(SearchUsers(value));
            }
          },
        ),
        const SizedBox(height: DesignConfig.spacingLg),
        Expanded(
          child: BlocBuilder<SocialBloc, SocialState>(builder: (context, state) {
            if (state is SocialLoading) {
              return const Center(
                  child: CircularProgressIndicator(color: AppColors.neonGreen));
            }
            if (state is UserSearchResults) {
              if (state.users.isEmpty) {
                return _emptyState(
                    icon: Icons.search_off, label: 'No users found');
              }
              return ListView.builder(
                padding: EdgeInsets.zero,
              itemCount: state.users.length,
              itemBuilder: (context, index) {
                final user = state.users[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: DesignConfig.spacingSm),
                  padding: const EdgeInsets.all(DesignConfig.spacingLg),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(DesignConfig.roundedXl),
                  ),
                  child: Row(children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                          color: AppColors.neonGreen, shape: BoxShape.circle),
                      child: Center(
                        child: Text((user.fullName ?? '?')[0].toUpperCase(),
                            style: AppTextStyles.onAccentBody),
                      ),
                    ),
                    const SizedBox(width: DesignConfig.spacingMd),
                    Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(user.fullName ?? '[N/A]',
                                style: AppTextStyles.sectionTitle),
                            Text(user.campus ?? '',
                                style: AppTextStyles.caption),
                          ]),
                    ),
                    IconButton(
                      icon: const Icon(Icons.person_add,
                          color: AppColors.neonGreen),
                      onPressed: () {
                        if (currentUserId != null) {
                          context
                              .read<SocialBloc>()
                              .add(SendFriendRequest(currentUserId!, user.id));
                          FeedbackService.showSuccess(
                              context, 'Friend request sent!');
                        }
                      },
                    ),
                  ]),
                );
              },
            );
          }
          return _emptyState(
              icon: Icons.person_search,
              label: 'Search for users to add as friends');
        }),
      ),
    ]),
  );
}
}

class _FriendTile extends StatelessWidget {
  final FriendshipEntity friendship;
  final String? currentUserId;
  const _FriendTile({required this.friendship, this.currentUserId});

  @override
  Widget build(BuildContext context) {
    final isRequester = friendship.requesterId == currentUserId;
    final friendName =
        isRequester ? friendship.addresseeName : friendship.requesterName;
    return Container(
      margin: const EdgeInsets.only(bottom: DesignConfig.spacingSm),
      padding: const EdgeInsets.all(DesignConfig.spacingLg),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(DesignConfig.roundedXl),
      ),
      child: Row(children: [
        Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(
              color: AppColors.neonGreen, shape: BoxShape.circle),
          child: Center(
            child: Text((friendName ?? '?')[0].toUpperCase(),
                style: AppTextStyles.onAccentBody),
          ),
        ),
        const SizedBox(width: DesignConfig.spacingMd),
        Expanded(
          child: Text(friendName ?? '[N/A]',
              style: AppTextStyles.sectionTitle),
        ),
        PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'remove') {
              context
                  .read<SocialBloc>()
                  .add(RemoveFriend(friendship.id, currentUserId ?? ''));
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'remove',
              child: Row(children: [
                const Icon(Icons.person_remove,
                    color: AppColors.accentOrange, size: 18),
                const SizedBox(width: DesignConfig.spacingSm),
                Text('Remove Friend',
                    style: AppTextStyles.sectionTitle),
              ]),
            ),
          ],
        ),
      ]),
    );
  }
}

Widget _emptyState({required IconData icon, required String label}) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 64, color: AppColors.divider),
        const SizedBox(height: DesignConfig.spacingMd),
        Text(label, style: AppTextStyles.bodySecondary),
      ],
    ),
  );
}

