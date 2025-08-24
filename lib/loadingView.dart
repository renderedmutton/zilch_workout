import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LoadingView extends StatelessWidget {
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
      body: Center(child: CupertinoActivityIndicator(radius: 15.0)),
    );
  }
}
