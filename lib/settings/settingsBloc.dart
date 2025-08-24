import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zilch_workout/auth/authCredentials.dart';
import 'package:zilch_workout/auth/formSubmissionStatus.dart';
import 'package:zilch_workout/dataRepository.dart';
import 'package:zilch_workout/session/sessionCubit.dart';
import 'package:zilch_workout/settings/settingsEvent.dart';
import 'package:zilch_workout/settings/settingsState.dart';
import 'package:zilch_workout/strava/stravaAPI.dart' as stravaf;

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final DataRepository dataRepo;
  final SessionCubit sessionCubit;
  final stravaf.StravaAPI stravaAPI;
  SettingsBloc(
      {required user,
      required this.dataRepo,
      required this.sessionCubit,
      required this.stravaAPI})
      : super(SettingsState(user: user));

  @override
  Stream<SettingsState> mapEventToState(SettingsEvent event) async* {
    if (event is NicknameChanged)
      yield state.copyWith(nickname: event.nickname);
    else if (event is AgeChanged)
      yield state.copyWith(age: event.age);
    else if (event is SexChanged)
      yield state.copyWith(sex: event.sex);
    else if (event is MetricChanged)
      yield state.copyWith(metric: event.metric);
    else if (event is WeightChanged)
      yield state.copyWith(weight: event.weight);
    else if (event is BikeWeightChanged)
      yield state.copyWith(bikeWeight: event.bikeWeight);
    else if (event is WheelCircumferenceChanged)
      yield state.copyWith(wheelCircumference: event.wheelCircumference);
    else if (event is FtpChanged)
      yield state.copyWith(ftp: event.ftp);
    else if (event is Zone1Changed)
      yield state.copyWith(zone1: event.zone1);
    else if (event is Zone2Changed)
      yield state.copyWith(zone2: event.zone2);
    else if (event is Zone3Changed)
      yield state.copyWith(zone3: event.zone3);
    else if (event is Zone4Changed)
      yield state.copyWith(zone4: event.zone4);
    else if (event is Zone5Changed)
      yield state.copyWith(zone5: event.zone5);
    else if (event is RRHrChanged)
      yield state.copyWith(rrHr: event.rrHr);
    else if (event is LTHrChanged)
      yield state.copyWith(ltHr: event.ltHr);
    else if (event is MaxHrChanged)
      yield state.copyWith(maxHr: event.maxHr);

    //submit settings
    else if (event is SettingsSubmitted) {
      yield state.copyWith(formStatus: FormSubmitting());

      try {
        print('Updating User');
        final updatedUser = await dataRepo.updateUser(
            userId: state.user.id,
            nickname: state.nickname,
            age: state.age == 0 ? 0 : state.age,
            sex: state.sex == -1 ? -1 : state.sex,
            metric: state.metric,
            weight: state.weight,
            bikeWeight: state.bikeWeight,
            wheelCircumference: state.wheelCircumference,
            ftp: state.ftp,
            zone1: state.zone1,
            zone2: state.zone2,
            zone3: state.zone3,
            zone4: state.zone4,
            zone5: state.zone5,
            rrHr: state.rrHr,
            ltHr: state.ltHr == 0 ? 0 : state.ltHr,
            maxHr: state.maxHr == 0 ? 0 : state.maxHr);
        print(updatedUser);
        sessionCubit.showSession(AuthCredentials(
            username: state.user.username, userId: state.user.id));
        yield state.copyWith(formStatus: SubmissionSuccess());
      } catch (e) {
        print(e);
        yield state.copyWith(formStatus: SubmissionFailure(Exception(e)));
        yield state.copyWith(formStatus: InitialFormStatus());
      }

      //authorize strava
    } else if (event is AuthorizeStrava) {
      yield state.copyWith(stravaStatus: FormSubmitting());
      try {
        final strava = await dataRepo.getStrava();
        final loggedin =
            await stravaAPI.initialize(strava.clientId!, strava.secret!);
        if (loggedin)
          yield state.copyWith(stravaStatus: SubmissionSuccess());
        else {
          yield state.copyWith(
              formStatus: SubmissionFailure(Exception('strava not logged in')));
          yield state.copyWith(formStatus: InitialFormStatus());
        }
      } catch (e) {
        print(e);
        yield state.copyWith(formStatus: SubmissionFailure(Exception(e)));
        yield state.copyWith(formStatus: InitialFormStatus());
      }

      //deauthorize strava
    } else if (event is DeauthorizedStrava) {
      yield state.copyWith(stravaStatus: FormSubmitting());
      try {
        final strava = await dataRepo.getStrava();
        stravaAPI.deAuthorize(strava.secret!);
        yield state.copyWith(stravaStatus: SubmissionSuccess());
      } catch (e) {
        print(e);
        yield state.copyWith(formStatus: SubmissionFailure(Exception(e)));
        yield state.copyWith(formStatus: InitialFormStatus());
      }

      //
    }
  }
}
