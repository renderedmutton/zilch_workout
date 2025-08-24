import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zilch_workout/auth/authCubit.dart';
import 'package:zilch_workout/auth/authRepository.dart';
import 'package:zilch_workout/auth/formSubmissionStatus.dart';
import 'package:zilch_workout/auth/login/loginBloc.dart';
import 'package:zilch_workout/auth/login/loginEvent.dart';
import 'package:zilch_workout/auth/login/loginState.dart';

class LoginView extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();

  Widget _usernameField() {
    return BlocBuilder<LoginBloc, LoginState>(builder: (context, state) {
      return TextFormField(
        autocorrect: false,
        decoration:
            InputDecoration(icon: Icon(Icons.person), labelText: 'Email'),
        validator: (value) => state.isValidUsername ? null : 'Invalid email',
        onChanged: (value) =>
            context.read<LoginBloc>().add(LoginUsernameChanged(value)),
      );
    });
  }

  Widget _passwordField() {
    return BlocBuilder<LoginBloc, LoginState>(builder: (context, state) {
      return TextFormField(
        obscureText: true,
        decoration: InputDecoration(
            icon: Icon(Icons.security),
            labelText: 'Password',
            errorMaxLines: 3),
        validator: (value) => state.isValidPassword
            ? null
            : 'Password should be alphanumeric and atleast 8 characters long',
        onChanged: (value) =>
            context.read<LoginBloc>().add(LoginPasswordChanged(value)),
      );
    });
  }

  Widget _forgotPasswordButton(BuildContext context) {
    return TextButton(
      onPressed: () => context.read<AuthCubit>().showForgotPassword(),
      child: Text('Forgot Password?', style: TextStyle(color: Colors.grey)),
    );
  }

  Widget _signInButton() {
    return BlocBuilder<LoginBloc, LoginState>(builder: (context, state) {
      return state.formStatus is FormSubmitting
          ? CupertinoActivityIndicator(radius: 15.0)
          : ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  context.read<LoginBloc>().add(LoginSubmitted());
                }
              },
              child: Text('LOGIN'));
    });
  }

  Widget _signUpButton(BuildContext context) {
    return TextButton(
      onPressed: () => context.read<AuthCubit>().showEula(false),
      child: Text('SIGN UP', style: TextStyle(fontSize: 14.0)),
    );
  }

  Widget _loginForm(BuildContext ctx) {
    return BlocListener<LoginBloc, LoginState>(
      listener: (context, state) {
        final formStatus = state.formStatus;
        if (formStatus is SubmissionFailure) {
          _showSnackBar(context, formStatus.exception.toString());
        }
      },
      child: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(children: [
            SizedBox(height: kToolbarHeight),
            Container(
              width: MediaQuery.of(ctx).size.width * 0.5,
              child: Image(
                  image: AssetImage('assets/images/mainpageIcon.png'),
                  fit: BoxFit.fill),
            ),
            SizedBox(height: 16.0),
            _usernameField(),
            SizedBox(height: 10.0),
            _passwordField(),
            SizedBox(height: 16.0),
            _forgotPasswordButton(ctx),
            _signInButton(),
            _signUpButton(ctx),
          ]),
        ),
      ),
    );
  }

  Widget _signInAsGuest(BuildContext context) {
    return BlocBuilder<LoginBloc, LoginState>(builder: (context, state) {
      return TextButton(
          onPressed: () => context.read<LoginBloc>().add(LoginAsGuest()),
          child: Text('Continue as guest'));
    });
  }

  void _showSnackBar(BuildContext context, String message) {
    int index = message.lastIndexOf('Exception: ');
    message = index == -1 ? message : message.substring(index + 11);
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('Zilch Workout'),
        centerTitle: true,
        backgroundColor: Colors.blue.shade700,
      ),
      body: BlocProvider(
        create: (context) => LoginBloc(
            context.read<AuthRepository>(), context.read<AuthCubit>()),
        child: SafeArea(
          child: Stack(alignment: Alignment.bottomCenter, children: [
            _loginForm(context),
            _signInAsGuest(context),
          ]),
        ),
      ),
    );
  }
}
