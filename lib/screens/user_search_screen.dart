import 'package:beesports/app/app_colors.dart';
import 'package:beesports/blocs/auth_bloc.dart';
import 'package:beesports/blocs/social_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UserSearchScreen extends StatefulWidget {
  const UserSearchScreen({super.key});

  @override
  State<UserSearchScreen> createState() => _UserSearchScreenState();
}

class _UserSearchScreenState extends State<UserSearchScreen> {
  final _searchController = TextEditingController();
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      _currentUserId = authState.user.id;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Find Players')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              autofocus: true,
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
            child: BlocConsumer<SocialBloc, SocialState>(
              listener: (context, state) {
                if (state is FriendRequestSent) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Friend request sent!'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              },
              builder: (context, state) {
                if (state is SocialLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is UserSearchResults) {
                  if (state.users.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off,
                              size: 64,
                              color: Colors.white.withValues(alpha: 0.1)),
                          const SizedBox(height: 12),
                          Text(
                            'No users found',
                            style: TextStyle(
                              color: AppColors.textSecondaryDark
                                  .withValues(alpha: 0.5),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: state.users.length,
                    itemBuilder: (context, index) {
                      final user = state.users[index];
                      final isSelf = user.id == _currentUserId;
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
                          trailing: isSelf
                              ? const Chip(label: Text('You'))
                              : IconButton(
                                  icon: const Icon(Icons.person_add,
                                      color: AppColors.primary),
                                  onPressed: () {
                                    if (_currentUserId != null) {
                                      context.read<SocialBloc>().add(
                                            SendFriendRequest(
                                                _currentUserId!, user.id),
                                          );
                                    }
                                  },
                                ),
                        ),
                      );
                    },
                  );
                }

                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.person_search,
                          size: 64, color: Colors.white.withValues(alpha: 0.1)),
                      const SizedBox(height: 12),
                      Text(
                        'Search for players to connect with',
                        style: TextStyle(
                          color: AppColors.textSecondaryDark
                              .withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
