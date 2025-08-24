import 'package:zilch_workout/models/User.dart';

abstract class SessionState {}

class UnknownSessionState extends SessionState {}

class Unauthenticated extends SessionState {}

class AuthenticatedWithoutUser extends SessionState {
  final String userId;
  final String username;
  final String nickname;
  AuthenticatedWithoutUser(
      {required this.userId, required this.username, required this.nickname});
}

class Authenticated extends SessionState {
  final User user;
  final bool isAuthenticated;
  Authenticated({required this.user, required this.isAuthenticated});
}
