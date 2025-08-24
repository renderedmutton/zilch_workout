import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zilch_workout/auth/authCubit.dart';
import 'package:zilch_workout/auth/eula/eulaEvent.dart';
import 'package:zilch_workout/auth/eula/eulaState.dart';

class EulaBloc extends Bloc<EulaEvent, EulaState> {
  final AuthCubit authCubit;
  EulaBloc(this.authCubit) : super(EulaState());

  @override
  Stream<EulaState> mapEventToState(EulaEvent event) async* {
    if (event is EulaAcceptChanged) {
      yield state.copyWith(event.accept);
    } else if (event is EulaSubmitted) {
      if (state.accept) if (authCubit.eulaIsGuest)
        authCubit.launchUnauthSession();
      else
        authCubit.showSignup();
      else
        authCubit.showLogin();
    }
  }
}
