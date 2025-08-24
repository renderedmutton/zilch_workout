import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zilch_workout/auth/authCredentials.dart';
import 'package:zilch_workout/session/sessionCubit.dart';

enum AuthState { login, eula, signUp, confirmSignUp, forgotPassword }

class AuthCubit extends Cubit<AuthState> {
  final SessionCubit sessionCubit;
  AuthCubit(this.sessionCubit) : super(AuthState.login);

  late AuthCredentials credentials;

  late bool eulaIsGuest;

  void showLogin() => emit(AuthState.login);

  void showEula(bool isGuest) {
    eulaIsGuest = isGuest;
    emit(AuthState.eula);
  }

  void showSignup() => emit(AuthState.signUp);

  void showConfirmSignUp(String username, String password) {
    credentials = AuthCredentials(username: username, password: password);
    emit(AuthState.confirmSignUp);
  }

  void showForgotPassword() => emit(AuthState.forgotPassword);

  void launchSession(AuthCredentials credentials) =>
      sessionCubit.showSession(credentials);

  void launchUnauthSession() => sessionCubit.showSessionUnauth();
}
