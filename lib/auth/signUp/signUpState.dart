import 'package:zilch_workout/auth/formSubmissionStatus.dart';

class SignUpState {
  final String username;
  bool get isValidUsername => RegExp(r'\S+@\S+\.\S+').hasMatch(username);

  final String nickname;
  bool get isValidNickname => nickname.length > 3;

  final String password;
  bool get isValidPassword =>
      RegExp(r'^(?=.*?[a-z])(?=.*?[0-9]).{8,}$').hasMatch(password);

  final String confirmPassword;
  bool get isValidConfirmPassword => confirmPassword == password;

  final FormSubmissionStatus formStatus;
  SignUpState({
    this.username = '',
    this.nickname = '',
    this.password = '',
    this.confirmPassword = '',
    this.formStatus = const InitialFormStatus(),
  });

  SignUpState copyWith(String? username, String? nickname, String? password,
      String? confirmPassword, FormSubmissionStatus? formStatus) {
    return SignUpState(
      username: username ?? this.username,
      nickname: nickname ?? this.nickname,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      formStatus: formStatus ?? this.formStatus,
    );
  }
}
