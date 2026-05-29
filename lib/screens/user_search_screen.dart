import 'package:beesports/core/feedback_service.dart';
import 'package:beesports/app/app_colors.dart';
import 'package:beesports/blocs/auth_bloc.dart';
import 'package:beesports/blocs/social_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

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
            style: GoogleFonts.inter(
                fontWeight: FontWeight.w500, color: AppColors.neonGreen)),
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: AppColors.neonGreen),
      ),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.all(24),
          child: TextField(
            controller: _searchController,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Search by name or NIM...',
              prefixIcon: Icon(Icons.search),
            ),
            style: GoogleFonts.inter(color: AppColors.neonGreen),
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
                          const SizedBox(height: 12),
                          Text('No users found',
                              style: GoogleFonts.inter(
                                  color: AppColors.textSecondary)),
                        ]),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: state.users.length,
                  itemBuilder: (context, index) {
                    final user = state.users[index];
                    final isSelf = user.id == _currentUserId;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(14),
                      color: AppColors.surfaceVariant,
                      child: Row(children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: const BoxDecoration(
                              color: AppColors.neonGreen,
                              shape: BoxShape.circle),
                          child: Center(
                            child: Text((user.fullName ?? '?')[0].toUpperCase(),
                                style: GoogleFonts.inter(
                                    color: AppColors.onAccent,
                                    fontWeight: FontWeight.w500)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(user.fullName ?? 'Unknown',
                                    style: GoogleFonts.inter(
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.neonGreen)),
                                Text(user.campus ?? '',
                                    style: GoogleFonts.inter(
                                        fontSize: 12,
                                        color: AppColors.textSecondary)),
                              ]),
                        ),
                        if (isSelf)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Text('You',
                                style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textSecondary)),
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
                      const SizedBox(height: 12),
                      Text('Search for players to connect with',
                          style: GoogleFonts.inter(
                              color: AppColors.textSecondary)),
                    ]),
              );
            },
          ),
        ),
      ]),
    );
  }
}
