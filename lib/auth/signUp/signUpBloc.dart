import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zilch_workout/auth/authCubit.dart';
import 'package:zilch_workout/auth/authRepository.dart';
import 'package:zilch_workout/auth/formSubmissionStatus.dart';
import 'package:zilch_workout/auth/signUp/signUpEvent.dart';
import 'package:zilch_workout/auth/signUp/signUpState.dart';

class SignUpBloc extends Bloc<SignUpEvent, SignUpState> {
  final AuthRepository authRepo;
  final AuthCubit authCubit;
  SignUpBloc(this.authRepo, this.authCubit) : super(SignUpState());

  @override
  Stream<SignUpState> mapEventToState(SignUpEvent event) async* {
    //Username changed
    if (event is SignUpUsernameChanged) {
      yield state.copyWith(event.username, null, null, null, null);
      //Email changed
    } else if (event is SignUpNicknameChanged) {
      yield state.copyWith(null, event.nickname, null, null, null);
      //Password changed
    } else if (event is SignUpPasswordChanged) {
      yield state.copyWith(null, null, event.password, null, null);
      //ConfirmPassword changed
    } else if (event is SignUpConfirmPasswordChanged) {
      yield state.copyWith(null, null, null, event.confirmPassword, null);
      //Form submitted
    } else if (event is SignUpSubmitted) {
      yield state.copyWith(null, null, null, null, FormSubmitting());

      //sign up
      try {
        await authRepo.signUp(
            username: state.username,
            nickname: state.nickname,
            password: state.password);
        yield state.copyWith(null, null, null, null, SubmissionSuccess());

        authCubit.showConfirmSignUp(state.username, state.password);
      } on AuthException catch (e) {
        print(e.message);
        yield state.copyWith(
            null, null, null, null, SubmissionFailure(Exception(e.message)));
        yield state.copyWith(null, null, null, null, InitialFormStatus());
      }
    }
  }
}
