import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zilch_workout/calendar/activityPages/activityCubit.dart';
import 'package:zilch_workout/calendar/activityPages/activityState.dart';
import 'package:zilch_workout/calendar/activityPages/graphTab.dart';
import 'package:zilch_workout/calendar/activityPages/lapTab.dart';
import 'package:zilch_workout/calendar/activityPages/summaryTab.dart';
import 'package:zilch_workout/models/User.dart';

class ActivityPage extends StatefulWidget {
  @override
  _ActivityPageState createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  TextStyle largeText = TextStyle(fontSize: 20.0);
  TextStyle mediumText = TextStyle(fontSize: 18.0);
  TextStyle smallText = TextStyle(fontSize: 12.0);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ActivityCubit, ActivityState>(builder: (context, state) {
      User _user = context.read<ActivityCubit>().user;
      List<int> zones = [
        (_user.zone1 * _user.ftp * 0.01).round(),
        (_user.zone2 * _user.ftp * 0.01).round(),
        (_user.zone3 * _user.ftp * 0.01).round(),
        (_user.zone4 * _user.ftp * 0.01).round(),
        (_user.zone5 * _user.ftp * 0.01).round(),
      ];

      if (state is UninitializedActivity)
        return Scaffold(
            appBar: AppBar(
                backgroundColor: Colors.grey[50],
                title:
                    Text(context.read<ActivityCubit>().activity.workoutName!)),
            body: SizedBox(
                height: MediaQuery.of(context).size.height - kToolbarHeight,
                child: Center(child: CupertinoActivityIndicator())));
      else if (state is InitializedActivity)
        return Scaffold(
            body: DefaultTabController(
          length: 3,
          child: NestedScrollView(
            headerSliverBuilder:
                (BuildContext context, bool innerBoxIsScrolled) {
              return [
                SliverOverlapAbsorber(
                  handle:
                      NestedScrollView.sliverOverlapAbsorberHandleFor(context),
                  sliver: SliverSafeArea(
                    top: false,
                    sliver: SliverAppBar(
                      leading: IconButton(
                          onPressed: () => Navigator.of(context).maybePop(),
                          icon: Icon(Icons.arrow_back_ios),
                          color: Colors.black),
                      title: Text(
                        context.read<ActivityCubit>().activity.workoutName!,
                        style: TextStyle(color: Colors.black),
                      ),
                      pinned: true,
                      floating: true,
                      backgroundColor: Colors.grey[50],
                      forceElevated: innerBoxIsScrolled,
                      bottom: TabBar(labelColor: Colors.black, tabs: [
                        Tab(icon: Icon(Icons.summarize_outlined)),
                        Tab(icon: Icon(Icons.timer)),
                        Tab(icon: Icon(Icons.insert_chart)),
                      ]),
                    ),
                  ),
                )
              ];
            },
            body: TabBarView(children: [
              SummaryTab(_user.metric, state.activityData,
                  context.read<ActivityCubit>().activity),
              LabTab(
                  context.read<ActivityCubit>().activity, state.activityData),
              GraphTab(_user.metric, state.activityData, zones),
            ]),
          ),
        ));
      else
        return Scaffold(
            appBar: AppBar(
                backgroundColor: Colors.grey[50],
                title:
                    Text(context.read<ActivityCubit>().activity.workoutName!)),
            body: SizedBox(
                height: MediaQuery.of(context).size.height - kToolbarHeight,
                child: Center(child: Text('Unable to load activity data'))));
    });
  }
}
