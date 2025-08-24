import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zilch_workout/auth/authCubit.dart';
import 'package:zilch_workout/auth/eula/eulaBloc.dart';
import 'package:zilch_workout/auth/eula/eulaEvent.dart';
import 'package:zilch_workout/auth/eula/eulaState.dart';
import 'package:zilch_workout/auth/eulaPage.dart';

class EulaView extends StatelessWidget {
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
        create: (context) => EulaBloc(context.read<AuthCubit>()),
        child: BlocBuilder<EulaBloc, EulaState>(builder: (context, state) {
          return SafeArea(
            child: Stack(alignment: Alignment.bottomCenter, children: [
              Column(children: [
                Divider(),
                TextButton(
                    onPressed: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => EulaPage()));
                    },
                    child: Text('End User License Agreement')),
                Divider(),
                CheckboxListTile(
                    title: Text('I have read and agree to the EULA'),
                    value: state.accept,
                    onChanged: (value) => context
                        .read<EulaBloc>()
                        .add(EulaAcceptChanged(value!))),
              ]),
              ElevatedButton(
                  onPressed: () =>
                      context.read<EulaBloc>().add(EulaSubmitted()),
                  child: Text('Continue')),
            ]),
          );
        }),
      ),
    );
  }
}
