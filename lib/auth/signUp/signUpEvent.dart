abstract class SignUpEvent {}

class SignUpUsernameChanged extends SignUpEvent {
  final String username;
  SignUpUsernameChanged(this.username);
}

class SignUpNicknameChanged extends SignUpEvent {
  final String nickname;
  SignUpNicknameChanged(this.nickname);
}

class SignUpPasswordChanged extends SignUpEvent {
  final String password;
  SignUpPasswordChanged(this.password);
}

class SignUpConfirmPasswordChanged extends SignUpEvent {
  final String confirmPassword;
  SignUpConfirmPasswordChanged(this.confirmPassword);
}

class SignUpSubmitted extends SignUpEvent {}
