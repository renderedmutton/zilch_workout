abstract class ResetEvent {}

class ResetUsernameChanged extends ResetEvent {
  final String username;
  ResetUsernameChanged(this.username);
}

class ResetPasswordChanged extends ResetEvent {
  final String password;
  ResetPasswordChanged(this.password);
}

class ResetConfirmPasswordChanged extends ResetEvent {
  final String confirmPassword;
  ResetConfirmPasswordChanged(this.confirmPassword);
}

class ResetCodeChanged extends ResetEvent {
  final String code;
  ResetCodeChanged(this.code);
}

class ResetCodeSent extends ResetEvent {}

class ResetSubmitted extends ResetEvent {}
