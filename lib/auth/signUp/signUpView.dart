import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zilch_workout/auth/authCubit.dart';
import 'package:zilch_workout/auth/authRepository.dart';
import 'package:zilch_workout/auth/formSubmissionStatus.dart';
import 'package:zilch_workout/auth/signUp/signUpBloc.dart';
import 'package:zilch_workout/auth/signUp/signUpEvent.dart';
import 'package:zilch_workout/auth/signUp/signUpState.dart';

class SignUpView extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();

  Widget _nicknameField() {
    return BlocBuilder<SignUpBloc, SignUpState>(builder: (context, state) {
      return TextFormField(
        autocorrect: false,
        decoration: InputDecoration(
            icon: Icon(Icons.person), labelText: 'Nickname', errorMaxLines: 2),
        validator: (value) => state.isValidNickname
            ? null
            : 'Nickname has to be atleast 4 characters long',
        onChanged: (value) =>
            context.read<SignUpBloc>().add(SignUpNicknameChanged(value)),
      );
    });
  }

  Widget _usernameField() {
    return BlocBuilder<SignUpBloc, SignUpState>(builder: (context, state) {
      return TextFormField(
        keyboardType: TextInputType.emailAddress,
        autocorrect: false,
        decoration: InputDecoration(
            icon: Icon(Icons.alternate_email), labelText: 'Email'),
        validator: (value) =>
            state.isValidUsername ? null : 'Invalid email address',
        onChanged: (value) =>
            context.read<SignUpBloc>().add(SignUpUsernameChanged(value)),
      );
    });
  }

  Widget _passwordField() {
    return BlocBuilder<SignUpBloc, SignUpState>(builder: (context, state) {
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
            context.read<SignUpBloc>().add(SignUpPasswordChanged(value)),
      );
    });
  }

  Widget _confirmPasswordField() {
    return BlocBuilder<SignUpBloc, SignUpState>(builder: (context, state) {
      return TextFormField(
        obscureText: true,
        decoration: InputDecoration(
            icon: Icon(Icons.verified_user),
            labelText: 'Confirm Password',
            errorMaxLines: 3),
        validator: (value) =>
            state.isValidConfirmPassword ? null : 'Password should match',
        onChanged: (value) =>
            context.read<SignUpBloc>().add(SignUpConfirmPasswordChanged(value)),
      );
    });
  }

  Widget _signUpButton() {
    return BlocBuilder<SignUpBloc, SignUpState>(builder: (context, state) {
      return state.formStatus is FormSubmitting
          ? CupertinoActivityIndicator(radius: 15.0)
          : ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  context.read<SignUpBloc>().add(SignUpSubmitted());
                }
              },
              child: Text('SIGN UP'));
    });
  }

  Widget _signUpForm() {
    return BlocListener<SignUpBloc, SignUpState>(
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
            Text('Sign up',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
            SizedBox(height: 16.0),
            _nicknameField(),
            SizedBox(height: 10.0),
            _usernameField(),
            SizedBox(height: 10.0),
            _passwordField(),
            SizedBox(height: 10.0),
            _confirmPasswordField(),
            SizedBox(height: 16.0),
            _signUpButton(),
          ]),
        ),
      ),
    );
  }

  void _showSnackBar(BuildContext context, String message) {
    int index = message.lastIndexOf('Exception: ');
    message = index == -1 ? message : message.substring(index + 11);
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('Zilch Workout'),
        centerTitle: true,
        backgroundColor: Colors.blue.shade700,
        leading: IconButton(
            onPressed: () => context.read<AuthCubit>().showLogin(),
            icon: Icon(Icons.arrow_back_ios)),
      ),
      body: BlocProvider(
        create: (context) => SignUpBloc(
            context.read<AuthRepository>(), context.read<AuthCubit>()),
        child: _signUpForm(),
      ),
    );
  }
}
