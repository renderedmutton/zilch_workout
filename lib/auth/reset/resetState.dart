import 'package:zilch_workout/auth/formSubmissionStatus.dart';

class ResetState {
  final String username;
  bool get isValidUsername => RegExp(r'\S+@\S+\.\S+').hasMatch(username);
  //bool get isValidUsername => username.length > 3;

  final String password;
  bool get isValidPassword =>
      RegExp(r'^(?=.*?[a-z])(?=.*?[0-9]).{8,}$').hasMatch(password);

  final String confirmPassword;
  bool get isValidConfirmPassword => confirmPassword == password;

  final String code;
  bool get isValidCode => code.length == 6;

  final FormSubmissionStatus emailStatus;

  final FormSubmissionStatus formStatus;

  ResetState({
    this.username = '',
    this.password = '',
    this.confirmPassword = '',
    this.code = '',
    this.emailStatus = const InitialFormStatus(),
    this.formStatus = const InitialFormStatus(),
  });

  ResetState copyWith(
      String? username,
      String? password,
      String? confirmPassword,
      String? code,
      FormSubmissionStatus? emailStatus,
      FormSubmissionStatus? formStatus) {
    return ResetState(
      username: username ?? this.username,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      code: code ?? this.code,
      emailStatus: emailStatus ?? this.emailStatus,
      formStatus: formStatus ?? this.formStatus,
    );
  }
}
