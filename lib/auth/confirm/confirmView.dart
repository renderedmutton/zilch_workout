import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zilch_workout/auth/authCubit.dart';
import 'package:zilch_workout/auth/authRepository.dart';
import 'package:zilch_workout/auth/confirm/confirmBloc.dart';
import 'package:zilch_workout/auth/confirm/confirmEvent.dart';
import 'package:zilch_workout/auth/confirm/confirmState.dart';
import 'package:zilch_workout/auth/formSubmissionStatus.dart';

class ConfirmationView extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();

  Widget _codeField() {
    return BlocBuilder<ConfirmationBloc, ConfirmationState>(
        builder: (context, state) {
      return TextFormField(
        autocorrect: false,
        decoration: InputDecoration(
          icon: Icon(Icons.lock),
          hintText: 'Confirmation Code',
        ),
        validator: (value) =>
            state.isValidCode ? null : 'Invalid confirmation code',
        onChanged: (value) => context.read<ConfirmationBloc>().add(
              ConfirmationCodeChanged(value),
            ),
      );
    });
  }

  Widget _confirmButton() {
    return BlocBuilder<ConfirmationBloc, ConfirmationState>(
        builder: (context, state) {
      return state.formStatus is FormSubmitting
          ? CupertinoActivityIndicator()
          : ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  context.read<ConfirmationBloc>().add(ConfirmationSubmitted());
                }
              },
              child: Text('VERIFY'),
            );
    });
  }

  Widget _confirmationForm() {
    return BlocListener<ConfirmationBloc, ConfirmationState>(
      listener: (context, state) {
        final formStatus = state.formStatus;
        if (formStatus is SubmissionFailure) {
          _showSnackBar(context, formStatus.exception.toString());
        }
      },
      child: Form(
        key: _formKey,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            children: [
              SizedBox(height: kToolbarHeight),
              Text('Confirm Sign Up',
                  style:
                      TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
              SizedBox(height: 16.0),
              _codeField(),
              SizedBox(height: 10.0),
              _confirmButton(),
            ],
          ),
        ),
      ),
    );
  }

  void _showSnackBar(BuildContext context, String message) {
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
      ),
      body: BlocProvider(
        create: (context) => ConfirmationBloc(
            context.read<AuthRepository>(), context.read<AuthCubit>()),
        child: _confirmationForm(),
      ),
    );
  }
}
