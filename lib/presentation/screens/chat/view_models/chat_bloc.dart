import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_firestore/data/firebase/firebase_auth_repository.dart';
import 'package:todo_firestore/data/firebase/firestore/firebase_storage_repository.dart';
import 'package:todo_firestore/data/firebase/models/message_model.dart';
import 'package:todo_firestore/presentation/architecture/page_command.dart';
import 'package:todo_firestore/presentation/architecture/page_state.dart';
import 'package:todo_firestore/presentation/screens/chat/use_cases/delete_message_use_case.dart';
import 'package:todo_firestore/presentation/screens/chat/use_cases/edit_message_use_case.dart';
import 'package:todo_firestore/presentation/screens/chat/use_cases/send_message_use_case.dart';
import 'package:todo_firestore/presentation/screens/chat/use_cases/sign_out_use_case.dart';
import 'package:todo_firestore/presentation/screens/chat/view_models/page_commands.dart';

part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final FirebaseAuthRepository _firebaseAuthRepository;
  final FirebaseStorageRepository _firebaseStorageRepository;
  final SendMessageUseCase _sendMessageUseCase;
  final SignOutUseCase _signOutUseCase;
  final DeleteMessageUseCase _deleteMessageUseCase;
  final EditMessageUseCase _editMessageUseCase;
  late final StreamSubscription _messagesListener;

  ChatBloc(
    this._firebaseAuthRepository,
    this._sendMessageUseCase,
    this._signOutUseCase,
    this._firebaseStorageRepository,
    this._deleteMessageUseCase,
    this._editMessageUseCase,
  ) : super(ChatState.initial()) {
    _messagesListener =
        _firebaseStorageRepository.watchMessages().listen((messages) => add(OnMessagesUpdated(messages)));
    on<OnMessagesUpdated>((event, emit) => emit(state.copyWith(messages: event.messages)));
    on<OnSignOut>(_onSignOut);
    on<OnSendMessagePressed>(_onSendMessagePressed);
    on<OnDeleteMessagePressed>(_onDeleteMessagePressed);
    on<OnEditMessagePressed>(_onEditMessagePressed);
    on<ClearChatCommand>((_, emit) => emit(state.copyWith(pageCommand: null)));
  }

  @override
  Future<void> close() async {
    await _messagesListener.cancel();
    return super.close();
  }

  void _onEditMessagePressed(OnEditMessagePressed event, Emitter<ChatState> emit) {
    emit(state.copyWith(pageCommand: UpdateTextController(event.text), isEditing: true));
  }

  Future<void> _onDeleteMessagePressed(OnDeleteMessagePressed event, Emitter<ChatState> emit) async {
    final result = await _deleteMessageUseCase.run(event.messageId);
    if (result.isLeft) {
      emit(state.copyWith(pageState: PageState.failure));
    }
  }

  Future<void> _onSignOut(OnSignOut event, Emitter<ChatState> emit) async {
    final result = await _signOutUseCase.run();
    if (result.isRight) {
      emit(state.copyWith(pageCommand: UserLogOut()));
    } else {
      emit(state.copyWith(pageState: PageState.failure));
    }
  }

  Future<void> _onSendMessagePressed(OnSendMessagePressed event, Emitter<ChatState> emit) async {
    emit(state.copyWith(isSending: true));
    await Future.delayed(const Duration(seconds: 2));
    final result = await _sendMessageUseCase.run(MessageModel.toSend(
      message: event.text,
      sender: _firebaseAuthRepository.currentUser?.email ?? '',
    ));
    if (result.isRight) {
      emit(state.copyWith(isSending: false));
    } else {
      emit(state.copyWith(pageState: PageState.failure, isSending: false));
    }
  }
}