import 'dart:async';

import 'package:amplify_flutter/amplify.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zilch_workout/presession/presessionBloc.dart';
import 'package:zilch_workout/presession/presessionEvent.dart';

class PresessionView extends StatefulWidget {
  @override
  _PresessionViewState createState() => _PresessionViewState();
}

class _PresessionViewState extends State<PresessionView> {
  StreamSubscription? hubSub;
  bool _ran = false;

  @override
  void initState() {
    super.initState();
    _getAmplifyReady();
    _fixTimer();
  }

  @override
  void dispose() {
    if (hubSub != null) hubSub?.cancel();
    super.dispose();
  }

  void _getAmplifyReady() {
    hubSub = Amplify.Hub.listen([HubChannel.DataStore], (event) {
      if (event.eventName == 'ready') {
        _ran = true;
        BlocProvider.of<PresessionBloc>(context).add(GetUserPresession());
      }
    });
  }

  void _fixTimer() async {
    await Future.delayed(Duration(seconds: 30));
    if (!_ran) {
      print('presession timeout');
      BlocProvider.of<PresessionBloc>(context).add(GetUserPresession());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Zilch Workout',
            style: TextStyle(
                color: Colors.white,
                fontSize: 24.0,
                fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.blue.shade700,
      ),
      body: SizedBox(
        height: MediaQuery.of(context).size.height - kToolbarHeight,
        child: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Loading...'),
            CupertinoActivityIndicator(radius: 15.0),
          ],
        )),
      ),
    );
  }
}
