import 'package:amplify_flutter/amplify.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zilch_workout/auth/authCubit.dart';
import 'package:zilch_workout/auth/authRepository.dart';
import 'package:zilch_workout/auth/formSubmissionStatus.dart';
import 'package:zilch_workout/auth/reset/resetEvent.dart';
import 'package:zilch_workout/auth/reset/resetState.dart';

class ResetBloc extends Bloc<ResetEvent, ResetState> {
  final AuthRepository authRepo;
  final AuthCubit authCubit;
  ResetBloc(this.authRepo, this.authCubit) : super(ResetState());

  @override
  Stream<ResetState> mapEventToState(ResetEvent event) async* {
    //Username changed
    if (event is ResetUsernameChanged) {
      yield state.copyWith(event.username, null, null, null, null, null);
      //Password changed
    } else if (event is ResetPasswordChanged) {
      yield state.copyWith(null, event.password, null, null, null, null);
      //Confirm password changed
    } else if (event is ResetConfirmPasswordChanged) {
      yield state.copyWith(null, null, event.confirmPassword, null, null, null);
      //Code changed
    } else if (event is ResetCodeChanged) {
      yield state.copyWith(null, null, null, event.code, null, null);
      //Form submitted
    } else if (event is ResetSubmitted) {
      yield state.copyWith(null, null, null, null, null, FormSubmitting());

      try {
        await authRepo.confirmPassword(
            state.username, state.password, state.code);
        yield state.copyWith(null, null, null, null, null, SubmissionSuccess());
        print('reset success');

        authCubit.showLogin();
      } on AmplifyException catch (e) {
        print(e.message);
        yield state.copyWith(null, null, null, null, null,
            SubmissionFailure(Exception(e.message)));
        yield state.copyWith(null, null, null, null, null, InitialFormStatus());
      }
      //reset code sent
    } else if (event is ResetCodeSent) {
      yield state.copyWith(null, null, null, null, FormSubmitting(), null);

      try {
        await authRepo.forgotPassword(state.username);
        yield state.copyWith(null, null, null, null, SubmissionSuccess(), null);
        print('code sent success');
      } on AmplifyException catch (e) {
        print(e.message);
        yield state.copyWith(null, null, null, null,
            SubmissionFailure(Exception(e.message)), null);
        yield state.copyWith(null, null, null, null, InitialFormStatus(), null);
      }
    }
  }
}
