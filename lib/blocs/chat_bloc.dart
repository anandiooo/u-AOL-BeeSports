import 'dart:async';

import 'package:beesports/models/chat_message_entity.dart';
import 'package:beesports/repos/chat_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class ChatEvent {}

class LoadMessages extends ChatEvent {
  final String lobbyId;
  LoadMessages(this.lobbyId);
}

class SendMessage extends ChatEvent {
  final String lobbyId;
  final String senderId;
  final String content;
  SendMessage(this.lobbyId, this.senderId, this.content);
}

class NewMessageReceived extends ChatEvent {
  final ChatMessageEntity message;
  NewMessageReceived(this.message);
}

abstract class ChatState {}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class ChatLoaded extends ChatState {
  final List<ChatMessageEntity> messages;
  ChatLoaded(this.messages);
}

class ChatError extends ChatState {
  final String message;
  ChatError(this.message);
}

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatRepository _repository;
  StreamSubscription<ChatMessageEntity>? _subscription;
  String? _currentLobbyId;

  ChatBloc(this._repository) : super(ChatInitial()) {
    on<LoadMessages>(_onLoad);
    on<SendMessage>(_onSend);
    on<NewMessageReceived>(_onNewMessage);
  }

  Future<void> _onLoad(LoadMessages event, Emitter<ChatState> emit) async {
    emit(ChatLoading());
    final result = await _repository.getMessages(event.lobbyId);

    result.when(
      success: (messages) {
        if (_currentLobbyId != null && _currentLobbyId != event.lobbyId) {
          _subscription?.cancel();
          _repository.unsubscribe(_currentLobbyId!);
        }

        _currentLobbyId = event.lobbyId;
        _subscription?.cancel();
        _subscription = _repository
            .subscribeToMessages(event.lobbyId)
            .listen((msg) => add(NewMessageReceived(msg)));

        emit(ChatLoaded(messages));
      },
      failure: (f) {
        emit(ChatError(f.message));
      },
    );
  }

  Future<void> _onSend(SendMessage event, Emitter<ChatState> emit) async {
    final result = await _repository.sendMessage(
      lobbyId: event.lobbyId,
      senderId: event.senderId,
      content: event.content,
    );

    result.when(
      success: (_) {},
      failure: (f) {
        emit(ChatError(f.message));
      },
    );
  }

  void _onNewMessage(NewMessageReceived event, Emitter<ChatState> emit) {
    if (state is ChatLoaded) {
      final current = (state as ChatLoaded).messages;
      emit(ChatLoaded([...current, event.message]));
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    if (_currentLobbyId != null) {
      _repository.unsubscribe(_currentLobbyId!);
    }
    return super.close();
  }
}
