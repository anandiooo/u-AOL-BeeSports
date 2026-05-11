import 'package:beesports/app/app_colors.dart';
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
      appBar: AppBar(
        title: const Text('Friends'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Friends'),
            Tab(text: 'Requests'),
            Tab(text: 'Search'),
          ],
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_search),
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
    return BlocBuilder<SocialBloc, SocialState>(
      builder: (context, state) {
        if (state is SocialLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is FriendsLoaded) {
          if (state.friends.isEmpty) {
            return _emptyState(
              icon: Icons.people_outline,
              label: 'No friends yet. Search and add people!',
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.friends.length,
            itemBuilder: (context, index) => _FriendTile(
              friendship: state.friends[index],
              currentUserId: currentUserId,
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class _RequestsTab extends StatelessWidget {
  final String? currentUserId;
  const _RequestsTab({this.currentUserId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SocialBloc, SocialState>(
      builder: (context, state) {
        if (state is SocialLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is PendingRequestsLoaded) {
          if (state.requests.isEmpty) {
            return _emptyState(
              icon: Icons.mail_outline,
              label: 'No pending requests',
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.requests.length,
            itemBuilder: (context, index) {
              final request = state.requests[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                    child: Text(
                      (request.requesterName ?? '?')[0].toUpperCase(),
                      style: const TextStyle(color: AppColors.primary),
                    ),
                  ),
                  title: Text(request.requesterName ?? 'Unknown'),
                  subtitle: const Text('Wants to be your friend'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.check_circle,
                            color: AppColors.success),
                        onPressed: () {
                          context.read<SocialBloc>().add(
                                RespondToRequest(
                                    request.id, true, currentUserId ?? ''),
                              );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.cancel, color: AppColors.error),
                        onPressed: () {
                          context.read<SocialBloc>().add(
                                RespondToRequest(
                                    request.id, false, currentUserId ?? ''),
                              );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class _SearchTab extends StatelessWidget {
  final String? currentUserId;
  const _SearchTab({this.currentUserId});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search by name or NIM...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onChanged: (value) {
              if (value.length >= 2) {
                context.read<SocialBloc>().add(SearchUsers(value));
              }
            },
          ),
        ),
        Expanded(
          child: BlocBuilder<SocialBloc, SocialState>(
            builder: (context, state) {
              if (state is SocialLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is UserSearchResults) {
                if (state.users.isEmpty) {
                  return _emptyState(
                    icon: Icons.search_off,
                    label: 'No users found',
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: state.users.length,
                  itemBuilder: (context, index) {
                    final user = state.users[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor:
                              AppColors.accent.withValues(alpha: 0.15),
                          child: Text(
                            (user.fullName ?? '?')[0].toUpperCase(),
                            style: const TextStyle(color: AppColors.accent),
                          ),
                        ),
                        title: Text(user.fullName ?? 'Unknown'),
                        subtitle: Text(user.campus ?? ''),
                        trailing: IconButton(
                          icon: const Icon(Icons.person_add,
                              color: AppColors.primary),
                          onPressed: () {
                            if (currentUserId != null) {
                              context.read<SocialBloc>().add(
                                    SendFriendRequest(currentUserId!, user.id),
                                  );
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Friend request sent!'),
                                  backgroundColor: AppColors.success,
                                ),
                              );
                            }
                          },
                        ),
                      ),
                    );
                  },
                );
              }
              return _emptyState(
                icon: Icons.person_search,
                label: 'Search for users to add as friends',
              );
            },
          ),
        ),
      ],
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

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withValues(alpha: 0.15),
          child: Text(
            (friendName ?? '?')[0].toUpperCase(),
            style: const TextStyle(color: AppColors.primary),
          ),
        ),
        title: Text(friendName ?? 'Unknown'),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'remove') {
              context.read<SocialBloc>().add(
                    RemoveFriend(friendship.id, currentUserId ?? ''),
                  );
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'remove',
              child: Row(
                children: [
                  Icon(Icons.person_remove, color: AppColors.error, size: 18),
                  SizedBox(width: 8),
                  Text('Remove Friend'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _emptyState({required IconData icon, required String label}) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 64, color: Colors.white.withValues(alpha: 0.1)),
        const SizedBox(height: 12),
        Text(
          label,
          style: TextStyle(
            color: AppColors.textSecondaryDark.withValues(alpha: 0.5),
          ),
        ),
      ],
    ),
  );
}
