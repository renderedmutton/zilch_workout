import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zilch_workout/auth/authCubit.dart';
import 'package:zilch_workout/auth/authRepository.dart';
import 'package:zilch_workout/auth/confirm/confirmEvent.dart';
import 'package:zilch_workout/auth/confirm/confirmState.dart';
import 'package:zilch_workout/auth/formSubmissionStatus.dart';

class ConfirmationBloc extends Bloc<ConfirmationEvent, ConfirmationState> {
  final AuthRepository authRepo;
  final AuthCubit authCubit;
  ConfirmationBloc(this.authRepo, this.authCubit) : super(ConfirmationState());

  @override
  Stream<ConfirmationState> mapEventToState(ConfirmationEvent event) async* {
    //Confirmation code updated
    if (event is ConfirmationCodeChanged) {
      yield state.copyWith(code: event.code);
      //form submitted
    } else if (event is ConfirmationSubmitted) {
      yield state.copyWith(formStatus: FormSubmitting());

      try {
        await authRepo.confirmSignUp(
            username: authCubit.credentials.username,
            confirmationCode: state.code);
        yield state.copyWith(formStatus: SubmissionSuccess());

        print('confirm sign up complete');
        final credentials = authCubit.credentials;
        final userId = await authRepo.signIn(
            username: credentials.username, password: credentials.password!);
        credentials.userId = userId;
        authCubit.launchSession(credentials);
      } on AuthException catch (e) {
        print(e.message);
        yield state.copyWith(
            formStatus: SubmissionFailure(Exception(e.message)));
        yield state.copyWith(formStatus: InitialFormStatus());
      }
    }
  }
}
