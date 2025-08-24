import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zilch_workout/auth/authCubit.dart';
import 'package:zilch_workout/auth/authRepository.dart';
import 'package:zilch_workout/auth/formSubmissionStatus.dart';
import 'package:zilch_workout/auth/reset/resetBloc.dart';
import 'package:zilch_workout/auth/reset/resetEvent.dart';
import 'package:zilch_workout/auth/reset/resetState.dart';

class ResetView extends StatefulWidget {
  @override
  _ResetViewState createState() => _ResetViewState();
}

class _ResetViewState extends State<ResetView> {
  final _formKey = GlobalKey<FormState>();
  final _emailKey = GlobalKey<FormState>();
  bool sentCode = false;

  Widget _usernameField() {
    return BlocBuilder<ResetBloc, ResetState>(builder: (context, state) {
      return TextFormField(
        autocorrect: false,
        decoration:
            InputDecoration(icon: Icon(Icons.person), labelText: 'Email'),
        validator: (value) => state.isValidUsername ? null : 'Invalid email',
        onChanged: (value) =>
            context.read<ResetBloc>().add(ResetUsernameChanged(value)),
      );
    });
  }

  Widget _passwordField() {
    return BlocBuilder<ResetBloc, ResetState>(builder: (context, state) {
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
            context.read<ResetBloc>().add(ResetPasswordChanged(value)),
      );
    });
  }

  Widget _confirmPasswordField() {
    return BlocBuilder<ResetBloc, ResetState>(builder: (context, state) {
      return TextFormField(
        obscureText: true,
        decoration: InputDecoration(
            icon: Icon(Icons.verified_user),
            labelText: 'Confirm Password',
            errorMaxLines: 3),
        validator: (value) =>
            state.isValidConfirmPassword ? null : 'Password should match',
        onChanged: (value) =>
            context.read<ResetBloc>().add(ResetConfirmPasswordChanged(value)),
      );
    });
  }

  Widget _codeField() {
    return BlocBuilder<ResetBloc, ResetState>(builder: (context, state) {
      return TextFormField(
        autocorrect: false,
        decoration: InputDecoration(
          icon: Icon(Icons.lock),
          hintText: 'Confirmation Code',
        ),
        validator: (value) =>
            state.isValidCode ? null : 'Invalid confirmation code',
        onChanged: (value) => context.read<ResetBloc>().add(
              ResetCodeChanged(value),
            ),
      );
    });
  }

  Widget _confirmButton() {
    return BlocBuilder<ResetBloc, ResetState>(builder: (context, state) {
      return state.formStatus is FormSubmitting
          ? CupertinoActivityIndicator()
          : ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  context.read<ResetBloc>().add(ResetSubmitted());
                }
              },
              child: Text('CONFIRM'),
            );
    });
  }

  Widget _resetForm(BuildContext ctx) {
    return BlocListener<ResetBloc, ResetState>(
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
            Text('Input New Password',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
            SizedBox(height: 16.0),
            _passwordField(),
            SizedBox(height: 10.0),
            _confirmPasswordField(),
            SizedBox(height: 10.0),
            _codeField(),
            SizedBox(height: 16.0),
            _confirmButton(),
          ]),
        ),
      ),
    );
  }

  Widget _codeButton() {
    return BlocBuilder<ResetBloc, ResetState>(builder: (context, state) {
      return state.emailStatus is FormSubmitting
          ? CupertinoActivityIndicator()
          : ElevatedButton(
              onPressed: () {
                if (_emailKey.currentState!.validate()) {
                  context.read<ResetBloc>().add(ResetCodeSent());
                }
              },
              child: Text('RECOVER'),
            );
    });
  }

  Widget _sendForm() {
    return BlocListener<ResetBloc, ResetState>(
      listener: (context, state) {
        final emailStatus = state.emailStatus;
        if (emailStatus is SubmissionFailure) {
          _showSnackBar(context, emailStatus.exception.toString());
        }
      },
      child: Form(
        key: _emailKey,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(children: [
            SizedBox(height: kToolbarHeight),
            Text('Enter Email',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
            SizedBox(height: 16.0),
            _usernameField(),
            SizedBox(height: 16.0),
            _codeButton(),
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
        create: (context) => ResetBloc(
            context.read<AuthRepository>(), context.read<AuthCubit>()),
        child: BlocListener<ResetBloc, ResetState>(
          listener: (context, state) {
            var emailStatus = state.emailStatus;
            if (emailStatus is SubmissionSuccess) {
              setState(() {
                sentCode = true;
              });
            }
          },
          child: sentCode ? _resetForm(context) : _sendForm(),
        ),
      ),
    );
  }
}
