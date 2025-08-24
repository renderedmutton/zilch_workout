import 'package:zilch_workout/auth/formSubmissionStatus.dart';

class LoginState {
  final String username;
  bool get isValidUsername => RegExp(r'\S+@\S+\.\S+').hasMatch(username);
  //bool get isValidUsername => username.length > 3;

  final String password;
  bool get isValidPassword =>
      RegExp(r'^(?=.*?[a-z])(?=.*?[0-9]).{8,}$').hasMatch(password);

  final FormSubmissionStatus formStatus;

  LoginState({
    this.username = '',
    this.password = '',
    this.formStatus = const InitialFormStatus(),
  });

  LoginState copyWith(
      String? username, String? password, FormSubmissionStatus? formStatus) {
    return LoginState(
      username: username ?? this.username,
      password: password ?? this.password,
      formStatus: formStatus ?? this.formStatus,
    );
  }
}
