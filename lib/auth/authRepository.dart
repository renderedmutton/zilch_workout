import 'dart:async';

import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify.dart';

class AuthRepository {
  Future<List<AuthUserAttribute>> getAuthAttributes() async {
    try {
      final attributes = await Amplify.Auth.fetchUserAttributes();
      return attributes;
    } catch (e) {
      throw e;
    }
  }

  Future<String> _getUserIdFromAttributes() async {
    try {
      final attributes = await Amplify.Auth.fetchUserAttributes();
      attributes.forEach((element) =>
          print('key: ${element.userAttributeKey}, value: ${element.value}'));
      final userId = attributes
          .firstWhere((element) => element.userAttributeKey == 'sub')
          .value;
      return userId;
    } catch (e) {
      throw e;
    }
  }

  Future<String?> attemptAutoLogin() async {
    try {
      print('attempt auto login');
      final session = await Amplify.Auth.fetchAuthSession();
      if (!session.isSignedIn)
        return null;
      else {
        return await _getUserIdFromAttributes();
      }
    } catch (e) {
      throw e;
    }
  }

  Future<String?> signIn(
      {required String username, required String password}) async {
    try {
      print('attempt sign in');
      final result = await Amplify.Auth.signIn(
          username: username.trim(), password: password.trim());
      return result.isSignedIn ? (await _getUserIdFromAttributes()) : null;
    } catch (e) {
      throw e;
    }
  }

  Future<bool> signUp(
      {required String username,
      required String nickname,
      required String password}) async {
    print('attempting signup');
    final options = CognitoSignUpOptions(userAttributes: {
      'preferred_username': nickname.trim(),
      'email': username.trim()
    });
    try {
      final result = await Amplify.Auth.signUp(
          username: username.trim(),
          password: password.trim(),
          options: options);
      return result.isSignUpComplete;
    } catch (e) {
      throw e;
    }
  }

  Future<bool> confirmSignUp(
      {required String username, required String confirmationCode}) async {
    try {
      final options = CognitoConfirmSignUpOptions(
          clientMetadata: {'forceAliasCreation': 'false'});
      final result = await Amplify.Auth.confirmSignUp(
          username: username.trim(),
          confirmationCode: confirmationCode.trim(),
          options: options);
      return result.isSignUpComplete;
    } catch (e) {
      throw e;
    }
  }

  Future<void> resendSignUpCode(String username) async {
    try {
      await Amplify.Auth.resendSignUpCode(username: username);
    } catch (e) {
      throw e;
    }
  }

  Future<bool> forgotPassword(String username) async {
    try {
      final result = await Amplify.Auth.resetPassword(username: username);
      return result.isPasswordReset;
    } catch (e) {
      throw e;
    }
  }

  Future<void> confirmPassword(
      String username, String newPassword, String confirmationCode) async {
    try {
      await Amplify.Auth.confirmPassword(
          username: username,
          newPassword: newPassword,
          confirmationCode: confirmationCode);
    } catch (e) {
      throw e;
    }
  }

  Future<void> signOut() async {
    await Amplify.Auth.signOut();
  }
}
