import 'package:amplify_flutter/amplify.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zilch_workout/appConstants.dart';
import 'package:zilch_workout/auth/authCredentials.dart';
import 'package:zilch_workout/auth/authRepository.dart';
import 'package:zilch_workout/bluetooth/bluetoothApi.dart';
import 'package:zilch_workout/dataRepository.dart';
import 'package:zilch_workout/models/User.dart';
import 'package:zilch_workout/session/sessionState.dart';
import 'package:zilch_workout/storageRepository.dart';
import 'package:zilch_workout/strava/stravaAPI.dart';

class SessionCubit extends Cubit<SessionState> {
  final AuthRepository authRepo;
  final DataRepository dataRepo;
  final StorageRepository storageRepo;
  final BluetoothAPI bleRepo;
  final StravaAPI stravaRepo;
  SessionCubit(
      {required this.authRepo,
      required this.dataRepo,
      required this.storageRepo,
      required this.bleRepo,
      required this.stravaRepo})
      : super(UnknownSessionState()) {
    attemptAutoSignIn();
  }

  User get currentUser => (state as Authenticated).user;
  bool get userAuthenticated => (state as Authenticated).isAuthenticated;

  void attemptAutoSignIn() async {
    try {
      final userId = await authRepo.attemptAutoLogin();
      if (userId == null) {
        //check if guest user exist
        User? user = await dataRepo.getUserById(AppConstants().guestUUID);
        if (user == null) {
          emit(Unauthenticated());
          return;
        } else {
          showSessionUnauth();
          return;
        }
      }
      //userId exist, check if user exist in dataRepo
      User? user = await dataRepo.getUserById(userId);
      if (user == null) {
        //auth exist but user not in dataRepo, force to sign in again
        print('auto login user==null');
        emit(Unauthenticated());
      } else {
        print('$user');
        emit(AuthenticatedWithoutUser(
            userId: userId, username: user.username, nickname: user.nickname));
      }
    } on Exception {
      emit(Unauthenticated());
    }
  }

  void showAuth() => emit(Unauthenticated());

  void showSession(AuthCredentials credentials) async {
    try {
      User? user = await dataRepo.getUserById(credentials.userId!);
      if (user == null) {
        print('showSession user==null');
        final attributes = await authRepo.getAuthAttributes();
        String username = attributes
            .firstWhere((element) => element.userAttributeKey == 'email')
            .value;
        String nickname = attributes
            .firstWhere(
                (element) => element.userAttributeKey == 'preferred_username')
            .value;
        emit(AuthenticatedWithoutUser(
            userId: credentials.userId!,
            username: username,
            nickname: nickname));
      } else {
        if (user.id == AppConstants().guestUUID)
          emit(Authenticated(user: user, isAuthenticated: false));
        else
          emit(Authenticated(user: user, isAuthenticated: true));
      }
    } catch (e) {
      print(e);
      emit(Unauthenticated());
    }
  }

  void showSessionUnauth() async {
    try {
      User? user = await dataRepo.getUserById(AppConstants().guestUUID);
      if (user == null) {
        print('guest user==null');
        user = await dataRepo.createUser(
            userId: AppConstants().guestUUID, username: 'guest');
        emit(Authenticated(user: user, isAuthenticated: false));
      } else {
        print('guest user found');
        emit(Authenticated(user: user, isAuthenticated: false));
      }
    } catch (e) {
      print(e);
      emit(Unauthenticated());
    }
  }

  void signOut(bool clear) async {
    if (clear) {
      await Amplify.DataStore.clear();
    }
    authRepo.signOut();
    emit(Unauthenticated());
  }
}
