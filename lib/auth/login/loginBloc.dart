import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zilch_workout/auth/authCredentials.dart';
import 'package:zilch_workout/auth/authCubit.dart';
import 'package:zilch_workout/auth/authRepository.dart';
import 'package:zilch_workout/auth/formSubmissionStatus.dart';
import 'package:zilch_workout/auth/login/loginEvent.dart';
import 'package:zilch_workout/auth/login/loginState.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final AuthRepository authRepo;
  final AuthCubit authCubit;
  LoginBloc(this.authRepo, this.authCubit) : super(LoginState());

  @override
  Stream<LoginState> mapEventToState(LoginEvent event) async* {
    //Username changed
    if (event is LoginUsernameChanged) {
      yield state.copyWith(event.username, null, null);

      //Password changed
    } else if (event is LoginPasswordChanged) {
      yield state.copyWith(null, event.password, null);

      //Form submitted
    } else if (event is LoginSubmitted) {
      yield state.copyWith(null, null, FormSubmitting());

      await authRepo.signOut();

      try {
        final userId = await authRepo.signIn(
            username: state.username, password: state.password);
        yield state.copyWith(null, null, SubmissionSuccess());
        print('login success $userId');
        authCubit.launchSession(
            AuthCredentials(username: state.username, userId: userId));
      } on AuthException catch (e) {
        print(e.message);
        //check if user is confirmed
        if (e.message == 'User is not confirmed.') {
          //user registered but not confirmed, send to confirm sign up
          await authRepo.resendSignUpCode(state.username);
          authCubit.showConfirmSignUp(state.username, state.password);
        } else {
          yield state.copyWith(null, null,
              SubmissionFailure(Exception('Invalid username/password')));
          yield state.copyWith(null, null, InitialFormStatus());
        }
      }

      //sign in as guest
    } else if (event is LoginAsGuest) {
      print('sign in as guest');
      authCubit.showEula(true);
    }
  }
}
