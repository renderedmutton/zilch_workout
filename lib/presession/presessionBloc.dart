import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zilch_workout/appConstants.dart';
import 'package:zilch_workout/dataRepository.dart';
import 'package:zilch_workout/models/User.dart';
import 'package:zilch_workout/presession/presessionEvent.dart';
import 'package:zilch_workout/presession/presessionState.dart';
import 'package:zilch_workout/session/sessionCubit.dart';
import 'package:zilch_workout/session/sessionState.dart';

class PresessionBloc extends Bloc<PresessionEvent, PresessionState> {
  final String userId;
  final String username;
  final String nickname;
  final DataRepository dataRepo;
  final SessionCubit sessionCubit;
  PresessionBloc(
      {required this.userId,
      required this.username,
      required this.nickname,
      required this.dataRepo,
      required this.sessionCubit})
      : super(PresessionState(
            userId: userId,
            dataRepo: dataRepo,
            sessionCubit: sessionCubit,
            ready: false));

  @override
  Stream<PresessionState> mapEventToState(PresessionEvent event) async* {
    if (event is ReadyPresession) {
      await state.dataRepo.getUserById(userId);
      yield state.copyWith(ready: true);

      //
    } else if (event is GetUserPresession) {
      User? user = await state.dataRepo.getUserById(userId);
      if (user == null) {
        print('preSession user==null');
        User? guestUser =
            await state.dataRepo.getUserById(AppConstants().guestUUID);

        //
        if (guestUser != null) {
          print('presession found guest user');
          final newUser = await dataRepo.updateUser(
              userId: AppConstants().guestUUID,
              newId: userId,
              username: username,
              nickname: nickname);
          await dataRepo.updateWorkoutsActivitiesSchedules(
              userId: newUser.id, guestId: AppConstants().guestUUID);
          print('$newUser');
          //delete guest user data
          dataRepo.deleteGuestUser(userId: AppConstants().guestUUID);
          state.sessionCubit
              .emit(Authenticated(user: newUser, isAuthenticated: true));

          //
        } else {
          print('preSession new user');
          final user = await dataRepo.createUser(
              userId: userId, username: username, nickname: nickname);
          state.sessionCubit
              .emit(Authenticated(user: user, isAuthenticated: true));
        }

        //
      } else {
        print('presession authenticated user');
        state.sessionCubit
            .emit(Authenticated(user: user, isAuthenticated: true));
      }
    }
  }
}
