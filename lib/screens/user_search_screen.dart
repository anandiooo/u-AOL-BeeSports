import 'package:beesports/core/feedback_service.dart';
import 'package:beesports/app/app_theme.dart';
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
    if (authState is Authenticated) _currentUserId = authState.user.id;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Find Players',
            style: AppTextStyles.sectionTitle),
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: AppColors.neonGreen),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(DesignConfig.spacingXl,
            DesignConfig.spacingXl, DesignConfig.spacingXl, 0),
        child: Column(children: [
          TextField(
            controller: _searchController,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Search by name or NIM...',
              prefixIcon: Icon(Icons.search),
            ),
            style: AppTextStyles.sectionTitle,
            onChanged: (value) {
              if (value.length >= 2) {
                context.read<SocialBloc>().add(SearchUsers(value));
              }
            },
          ),
          const SizedBox(height: DesignConfig.spacingLg),
          Expanded(
            child: BlocConsumer<SocialBloc, SocialState>(
              listener: (context, state) {
                if (state is FriendRequestSent) {
                  FeedbackService.showSuccess(context, 'Friend request sent!');
                }
              },
              builder: (context, state) {
                if (state is SocialLoading) {
                  return const Center(
                      child:
                          CircularProgressIndicator(color: AppColors.neonGreen));
                }
                if (state is UserSearchResults) {
                  if (state.users.isEmpty) {
                    return Center(
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.search_off,
                                size: 64, color: AppColors.divider),
                            const SizedBox(height: DesignConfig.spacingMd),
                            Text('No users found',
                                style: AppTextStyles.bodySecondary),
                          ]),
                    );
                  }
                  return ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: state.users.length,
                    itemBuilder: (context, index) {
                      final user = state.users[index];
                      final isSelf = user.id == _currentUserId;
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
                                color: AppColors.neonGreen,
                                shape: BoxShape.circle),
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
                          if (isSelf)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: DesignConfig.spacingMd, vertical: DesignConfig.spacingSm),
                              decoration: BoxDecoration(
                                color: AppColors.background,
                                borderRadius: BorderRadius.circular(DesignConfig.rounded2xl),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Text('You',
                                  style: AppTextStyles.captionStrong),
                            )
                          else
                            IconButton(
                              icon: const Icon(Icons.person_add,
                                  color: AppColors.neonGreen),
                              onPressed: () {
                                if (_currentUserId != null) {
                                  context.read<SocialBloc>().add(
                                      SendFriendRequest(
                                          _currentUserId!, user.id));
                                }
                              },
                            ),
                        ]),
                      );
                    },
                  );
                }
                return Center(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.person_search,
                            size: 64, color: AppColors.divider),
                        const SizedBox(height: DesignConfig.spacingMd),
                        Text('Search for players to connect with',
                            style: AppTextStyles.bodySecondary),
                      ]),
                );
              },
            ),
          ),
        ]),
      ),
    );
  }
}

