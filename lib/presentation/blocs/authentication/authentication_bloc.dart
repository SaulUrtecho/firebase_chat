import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_firestore/data/firebase/firebase_auth_repository.dart';
import 'package:todo_firestore/data/firebase/models/user_model.dart';

part 'authentication_event.dart';
part 'authentication_state.dart';

class AuthenticationBloc extends Bloc<AuthenticationEvent, AuthenticationState> {
  final FirebaseAuthRepository _firebaseAuthRepository;

  AuthenticationBloc(this._firebaseAuthRepository) : super(AuthenticationState.initial()) {
    on<OnAppStartUp>(onAppStartUp);
    on<OnLogin>(
        (_, emit) => emit(state.copyWith(authStatus: AuthStatus.logged, user: _firebaseAuthRepository.currentUser)));
    on<OnLogOut>((event, emit) => emit(AuthenticationState.logOut()));
  }

  void onAppStartUp(OnAppStartUp event, Emitter emit) {
    final currentUser = _firebaseAuthRepository.currentUser;
    if (currentUser != null) {
      emit(state.copyWith(authStatus: AuthStatus.logged, user: currentUser));
    } else {
      emit(AuthenticationState.logOut());
    }
  }
}