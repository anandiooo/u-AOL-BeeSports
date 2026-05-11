import 'package:beesports/models/user_entity.dart';
import 'package:beesports/models/friendship_entity.dart';
import 'package:beesports/repos/social_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class SocialEvent {}

class LoadFriends extends SocialEvent {
  final String userId;
  LoadFriends(this.userId);
}

class LoadPendingRequests extends SocialEvent {
  final String userId;
  LoadPendingRequests(this.userId);
}

class SendFriendRequest extends SocialEvent {
  final String requesterId;
  final String addresseeId;
  SendFriendRequest(this.requesterId, this.addresseeId);
}

class RespondToRequest extends SocialEvent {
  final String friendshipId;
  final bool accept;
  final String userId;
  RespondToRequest(this.friendshipId, this.accept, this.userId);
}

class SearchUsers extends SocialEvent {
  final String query;
  SearchUsers(this.query);
}

class RemoveFriend extends SocialEvent {
  final String friendshipId;
  final String userId;
  RemoveFriend(this.friendshipId, this.userId);
}

abstract class SocialState {}

class SocialInitial extends SocialState {}

class SocialLoading extends SocialState {}

class FriendsLoaded extends SocialState {
  final List<FriendshipEntity> friends;
  FriendsLoaded(this.friends);
}

class PendingRequestsLoaded extends SocialState {
  final List<FriendshipEntity> requests;
  PendingRequestsLoaded(this.requests);
}

class UserSearchResults extends SocialState {
  final List<UserEntity> users;
  UserSearchResults(this.users);
}

class FriendRequestSent extends SocialState {}

class SocialError extends SocialState {
  final String message;
  SocialError(this.message);
}

class SocialBloc extends Bloc<SocialEvent, SocialState> {
  final SocialRepository _repository;

  SocialBloc(this._repository) : super(SocialInitial()) {
    on<LoadFriends>(_onLoadFriends);
    on<LoadPendingRequests>(_onLoadPending);
    on<SendFriendRequest>(_onSendRequest);
    on<RespondToRequest>(_onRespond);
    on<SearchUsers>(_onSearch);
    on<RemoveFriend>(_onRemove);
  }

  Future<void> _onLoadFriends(
    LoadFriends event,
    Emitter<SocialState> emit,
  ) async {
    emit(SocialLoading());
    try {
      final friends = await _repository.getFriends(event.userId);
      emit(FriendsLoaded(friends));
    } catch (e) {
      emit(SocialError(e.toString()));
    }
  }

  Future<void> _onLoadPending(
    LoadPendingRequests event,
    Emitter<SocialState> emit,
  ) async {
    emit(SocialLoading());
    try {
      final requests = await _repository.getPendingRequests(event.userId);
      emit(PendingRequestsLoaded(requests));
    } catch (e) {
      emit(SocialError(e.toString()));
    }
  }

  Future<void> _onSendRequest(
    SendFriendRequest event,
    Emitter<SocialState> emit,
  ) async {
    try {
      await _repository.sendFriendRequest(
        event.requesterId,
        event.addresseeId,
      );
      emit(FriendRequestSent());
    } catch (e) {
      emit(SocialError(e.toString()));
    }
  }

  Future<void> _onRespond(
    RespondToRequest event,
    Emitter<SocialState> emit,
  ) async {
    try {
      await _repository.respondToRequest(event.friendshipId, event.accept);
      add(LoadPendingRequests(event.userId));
    } catch (e) {
      emit(SocialError(e.toString()));
    }
  }

  Future<void> _onSearch(
    SearchUsers event,
    Emitter<SocialState> emit,
  ) async {
    emit(SocialLoading());
    try {
      final users = await _repository.searchUsers(event.query);
      emit(UserSearchResults(users));
    } catch (e) {
      emit(SocialError(e.toString()));
    }
  }

  Future<void> _onRemove(
    RemoveFriend event,
    Emitter<SocialState> emit,
  ) async {
    try {
      await _repository.removeFriend(event.friendshipId);
      add(LoadFriends(event.userId));
    } catch (e) {
      emit(SocialError(e.toString()));
    }
  }
}
