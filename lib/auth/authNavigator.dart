import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zilch_workout/auth/authCubit.dart';
import 'package:zilch_workout/auth/confirm/confirmView.dart';
import 'package:zilch_workout/auth/eula/eulaView.dart';
import 'package:zilch_workout/auth/login/loginView.dart';
import 'package:zilch_workout/auth/reset/resetView.dart';
import 'package:zilch_workout/auth/signUp/signUpView.dart';

class AuthNavigator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(builder: (context, state) {
      return Navigator(
        pages: [
          if (state == AuthState.login) MaterialPage(child: LoginView()),

          if (state == AuthState.eula) MaterialPage(child: EulaView()),

          // Allow push animation
          if (state == AuthState.signUp ||
              state == AuthState.confirmSignUp) ...[
            // Show Sign up
            MaterialPage(child: SignUpView()),

            // Show confirm sign up
            if (state == AuthState.confirmSignUp)
              MaterialPage(child: ConfirmationView())
          ],
          //show forgot password
          if (state == AuthState.forgotPassword)
            MaterialPage(child: ResetView()),
        ],
        onPopPage: (route, result) => route.didPop(result),
      );
    });
  }
}
