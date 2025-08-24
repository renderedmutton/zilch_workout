import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:zilch_workout/appConstants.dart';
import 'package:zilch_workout/auth/formSubmissionStatus.dart';
import 'package:zilch_workout/auth/privacyPage.dart';
import 'package:zilch_workout/dataRepository.dart';
import 'package:zilch_workout/session/sessionCubit.dart';
import 'package:zilch_workout/settings/settingsBloc.dart';
import 'package:zilch_workout/settings/settingsEvent.dart';
import 'package:zilch_workout/settings/settingsState.dart';
import 'package:zilch_workout/auth/eulaPage.dart';
import 'package:zilch_workout/strava/stravaAPI.dart' as stravaf;

class SettingsView extends StatefulWidget {
  final ValueChanged<bool> settingsChanged;
  SettingsView(this.settingsChanged);

  @override
  _SettingsViewState createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  final _formKey = GlobalKey<FormState>();
  final _prefs = SharedPreferences.getInstance();
  TextEditingController _weightController = TextEditingController();
  TextEditingController _bikeWeightController = TextEditingController();

  late bool instantenousP;
  late bool displayCadence;
  late bool displayHr;
  late int displayLength; //0-fullworkout,1-30minutes,2-15minutes,3-5minutes
  late bool simulatedSpeed; //false uses actual spinning speed
  late int countdown; //0=both on, 1=sound, 2=vibrate, 3=off
  bool? _isAuthOk;
  late Future<SharedPreferences> prefsFuture;

  @override
  void initState() {
    super.initState();
    prefsFuture = _getPreferences();
  }

  Future<SharedPreferences> _getPreferences() async {
    SharedPreferences prefs = await _prefs;
    instantenousP = prefs.getBool('instantenousP') ?? false;
    displayCadence = prefs.getBool('displayCadence') ?? true;
    displayHr = prefs.getBool('displayHr') ?? true;
    displayLength = prefs.getInt('displayLength') ?? 0;
    simulatedSpeed = prefs.getBool('simulatedSpeed') ?? true;
    countdown = prefs.getInt('countdown') ?? 0;
    _isAuthOk = prefs.getBool('strava') ?? false;
    setState(() {});
    return prefs;
  }

  Widget _unauthenticatedWarningWidget(BuildContext context) {
    return Container(
      color: Colors.red,
      padding: EdgeInsets.all(8.0),
      child: Row(children: [
        Expanded(
          child: Text(
              'You are signed in as guest, signing out or deleting the app would delete all data!\nSigning up would back up data to cloud.',
              style: TextStyle(color: Colors.white)),
        ),
        SizedBox(width: 8.0),
        ElevatedButton(
            onPressed: () => context.read<SessionCubit>().signOut(false),
            child: Text('Sign Up')),
      ]),
    );
  }

  Widget _stravaWidget(BuildContext context, SettingsState state) {
    if (_isAuthOk == null) return Container();

    if (state.user.id == AppConstants().guestUUID) {
      return Text(
          'Strava authorization not allowed for guest. Manually export tcx from activites.',
          style: TextStyle(fontSize: 18));
    }
    return Row(children: [
      Expanded(
        child: Text('Strava',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ),
      if (!_isAuthOk!)
        ElevatedButton(
            style: ElevatedButton.styleFrom(primary: Colors.orange),
            onPressed: () {
              context.read<SettingsBloc>().add(AuthorizeStrava());
              _loginStravaDialog(context.read<SettingsBloc>(), true);
            },
            child: Text('log in')),
      if (_isAuthOk!)
        ElevatedButton(
            style: ElevatedButton.styleFrom(primary: Colors.orange),
            onPressed: () {
              context.read<SettingsBloc>().add(DeauthorizedStrava());
              _loginStravaDialog(context.read<SettingsBloc>(), false);
            },
            child: Text('log out')),
    ]);
  }

  void _loginStravaDialog(SettingsBloc settingsBloc, bool login) {
    showDialog(
      context: context,
      builder: (context) {
        return BlocProvider.value(
          value: settingsBloc,
          child: BlocConsumer<SettingsBloc, SettingsState>(
              builder: (context, state) {
            return SimpleDialog(
                title: Text(login ? 'Logging in' : 'Loggin out',
                    textAlign: TextAlign.center),
                children: [CupertinoActivityIndicator()]);
          }, listener: (context, state) async {
            if (state.stravaStatus is SubmissionSuccess) {
              final prefs = await _prefs;
              prefs.setBool('strava', login);
              Navigator.of(context).maybePop();
            }
            if (state.stravaStatus is SubmissionFailure) {
              _showSnackBar(context,
                  'strava ' + (login ? 'log in' : 'log out') + ' failed');
            }
          }),
        );
      },
    );
  }

  Widget _settingsForm(BuildContext context, SettingsState state) {
    _weightController.text = state.weight == 0
        ? (state.metric ? 70.0 : (70.0 * 2.205)).toStringAsFixed(1)
        : state.metric
            ? (state.weight / 100).toStringAsFixed(1)
            : (state.weight * 0.02205).toStringAsFixed(1);
    _weightController.selection = TextSelection.fromPosition(
        TextPosition(offset: _weightController.text.length));
    _bikeWeightController.text = state.bikeWeight == 0
        ? (state.metric ? 8.0 : (8.0 * 2.205)).toStringAsFixed(1)
        : state.metric
            ? (state.bikeWeight / 100).toStringAsFixed(1)
            : (state.bikeWeight * 0.02205).toStringAsFixed(1);
    _bikeWeightController.selection = TextSelection.fromPosition(
        TextPosition(offset: _bikeWeightController.text.length));
    return Column(children: [
      TextFormField(
        autocorrect: false,
        initialValue: state.nickname == '' ? '' : state.nickname,
        decoration: InputDecoration(labelText: 'Nickname', errorMaxLines: 2),
        /*validator: (value) => state.isValidNickname
            ? null
            : 'Nickname has to be atleast 4 characters long',*/
        onChanged: (value) =>
            context.read<SettingsBloc>().add(NicknameChanged(value)),
      ),
      TextFormField(
        autocorrect: false,
        keyboardType:
            TextInputType.numberWithOptions(signed: true, decimal: true),
        initialValue: state.age == 0 ? null : state.age.toString(),
        decoration: InputDecoration(labelText: 'Age', errorMaxLines: 1),
        validator: (value) => state.isValidAge ? null : '1-120',
        onChanged: (value) => context
            .read<SettingsBloc>()
            .add(AgeChanged(value == '' ? 0 : (int.tryParse(value) ?? -1))),
      ),
      Row(children: [
        Radio<int>(
            toggleable: true,
            value: 0,
            groupValue: state.sex,
            onChanged: (value) =>
                context.read<SettingsBloc>().add(SexChanged(value ?? -1))),
        Text('Male'),
        Radio<int>(
            toggleable: true,
            value: 1,
            groupValue: state.sex,
            onChanged: (value) =>
                context.read<SettingsBloc>().add(SexChanged(value ?? -1))),
        Text('Female'),
        Radio<int>(
            toggleable: true,
            value: 2,
            groupValue: state.sex,
            onChanged: (value) =>
                context.read<SettingsBloc>().add(SexChanged(value ?? -1))),
        Text('Others'),
      ]),
      Row(children: [
        Radio<int>(
            value: 0,
            groupValue: state.metric ? 0 : 1,
            onChanged: (value) => context
                .read<SettingsBloc>()
                .add(MetricChanged(value == 0 ? true : false))),
        Text('Metric'),
        Radio<int>(
            value: 1,
            groupValue: state.metric ? 0 : 1,
            onChanged: (value) {
              context
                  .read<SettingsBloc>()
                  .add(MetricChanged(value == 0 ? true : false));
            }),
        Text('Imperial'),
      ]),
      TextFormField(
          autocorrect: false,
          controller: _weightController,
          keyboardType:
              TextInputType.numberWithOptions(signed: true, decimal: true),
          decoration: InputDecoration(
              labelText: state.metric ? 'Weight (kg)' : 'Weight (lbs)',
              errorMaxLines: 1),
          validator: (value) => state.isValidWeight
              ? null
              : state.metric
                  ? '1-300 kg'
                  : '1-661 lbs',
          onFieldSubmitted: (value) {
            num buffer = double.tryParse(value) ?? 70;
            int weight =
                (state.metric ? buffer * 100 : buffer * 100 / 2.205).round();
            context.read<SettingsBloc>().add(WeightChanged(weight));
          }),
      TextFormField(
          autocorrect: false,
          controller: _bikeWeightController,
          keyboardType:
              TextInputType.numberWithOptions(signed: true, decimal: true),
          decoration: InputDecoration(
              labelText:
                  state.metric ? 'Bike Weight (kg)' : 'Bike Weight (lbs)',
              errorMaxLines: 1),
          validator: (value) => state.isValidBikeWeight
              ? null
              : state.metric
                  ? '1-30 kg'
                  : '1-66 lbs',
          onFieldSubmitted: (value) {
            num buffer = double.tryParse(value) ?? 8;
            int bikeWeight =
                (state.metric ? buffer * 100 : buffer * 100 / 2.205).round();
            context.read<SettingsBloc>().add(BikeWeightChanged(bikeWeight));
          }),
      TextFormField(
        autocorrect: false,
        keyboardType:
            TextInputType.numberWithOptions(signed: true, decimal: true),
        initialValue: state.wheelCircumference == 0
            ? '2105'
            : state.wheelCircumference.toString(),
        decoration: InputDecoration(
            labelText: 'Wheel Circumference (mm)', errorMaxLines: 1),
        validator: (value) => state.isValidWheelCircumference ? null : '>0',
        onChanged: (value) => context.read<SettingsBloc>().add(
            WheelCircumferenceChanged(
                value == '' ? 2105 : (int.tryParse(value) ?? -1))),
      ),
      //POWER
      Divider(),
      Text('POWER',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      TextFormField(
        autocorrect: false,
        keyboardType:
            TextInputType.numberWithOptions(signed: true, decimal: true),
        initialValue: state.ftp == 0 ? '200' : state.ftp.toString(),
        decoration: InputDecoration(labelText: 'FTP', errorMaxLines: 1),
        validator: (value) => state.isValidFtp ? null : '1-1000 W',
        onChanged: (value) => context
            .read<SettingsBloc>()
            .add(FtpChanged(value == '' ? 200 : (int.tryParse(value) ?? -1))),
      ),
      SizedBox(height: 8.0),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Zones', style: TextStyle(fontWeight: FontWeight.bold)),
          Text('Range (%)', style: TextStyle(fontWeight: FontWeight.bold)),
          Text('Range (W)', style: TextStyle(fontWeight: FontWeight.bold))
        ],
      ),
      SizedBox(height: 8.0),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Zone 1'),
          Row(children: [
            Text('0 - '),
            SizedBox(
                width: 30.0,
                height: 20.0,
                child: TextFormField(
                  autocorrect: false,
                  keyboardType: TextInputType.numberWithOptions(
                      signed: true, decimal: true),
                  initialValue:
                      state.zone1 == 0 ? '55' : state.zone1.toString(),
                  validator: (value) => state.isValidZone1 ? null : null,
                  onChanged: (value) => context.read<SettingsBloc>().add(
                      Zone1Changed(
                          value == '' ? 55 : (int.tryParse(value) ?? -1))),
                  style: TextStyle(fontSize: 14),
                ))
          ]),
          Text('0 - ' + (state.zone1 * state.ftp * 0.01).round().toString()),
        ],
      ),
      SizedBox(height: 8.0),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Zone 2'),
          Row(children: [
            Text('${state.zone1 + 1} - '),
            SizedBox(
                width: 30.0,
                height: 20.0,
                child: TextFormField(
                  autocorrect: false,
                  keyboardType: TextInputType.numberWithOptions(
                      signed: true, decimal: true),
                  initialValue:
                      state.zone2 == 0 ? '75' : state.zone2.toString(),
                  validator: (value) => state.isValidZone2 ? null : null,
                  onChanged: (value) => context.read<SettingsBloc>().add(
                      Zone2Changed(
                          value == '' ? 75 : (int.tryParse(value) ?? -1))),
                  style: TextStyle(fontSize: 14),
                ))
          ]),
          Text(((state.zone1 + 1) * state.ftp * 0.01).round().toString() +
              ' - ' +
              (state.zone2 * state.ftp * 0.01).round().toString())
        ],
      ),
      SizedBox(height: 8.0),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Zone 3'),
          Row(children: [
            Text('${state.zone2 + 1} - '),
            SizedBox(
                width: 30.0,
                height: 20.0,
                child: TextFormField(
                  autocorrect: false,
                  keyboardType: TextInputType.numberWithOptions(
                      signed: true, decimal: true),
                  initialValue:
                      state.zone3 == 0 ? '90' : state.zone3.toString(),
                  validator: (value) => state.isValidZone3 ? null : null,
                  onChanged: (value) => context.read<SettingsBloc>().add(
                      Zone3Changed(
                          value == '' ? 90 : (int.tryParse(value) ?? -1))),
                  style: TextStyle(fontSize: 14),
                ))
          ]),
          Text(((state.zone2 + 1) * state.ftp * 0.01).round().toString() +
              ' - ' +
              (state.zone3 * state.ftp * 0.01).round().toString())
        ],
      ),
      SizedBox(height: 8.0),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Zone 4'),
          Row(children: [
            Text('${state.zone3 + 1} - '),
            SizedBox(
                width: 30.0,
                height: 20.0,
                child: TextFormField(
                  autocorrect: false,
                  keyboardType: TextInputType.numberWithOptions(
                      signed: true, decimal: true),
                  initialValue:
                      state.zone4 == 0 ? '105' : state.zone4.toString(),
                  validator: (value) => state.isValidZone4 ? null : null,
                  onChanged: (value) => context.read<SettingsBloc>().add(
                      Zone4Changed(
                          value == '' ? 105 : (int.tryParse(value) ?? -1))),
                  style: TextStyle(fontSize: 14),
                ))
          ]),
          Text(((state.zone3 + 1) * state.ftp * 0.01).round().toString() +
              ' - ' +
              (state.zone4 * state.ftp * 0.01).round().toString())
        ],
      ),
      SizedBox(height: 8.0),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Zone 5'),
          Row(children: [
            Text('${state.zone4 + 1} - '),
            SizedBox(
                width: 30.0,
                height: 20.0,
                child: TextFormField(
                  autocorrect: false,
                  keyboardType: TextInputType.numberWithOptions(
                      signed: true, decimal: true),
                  initialValue:
                      state.zone5 == 0 ? '120' : state.zone5.toString(),
                  validator: (value) => state.isValidZone5 ? null : null,
                  onChanged: (value) => context.read<SettingsBloc>().add(
                      Zone5Changed(
                          value == '' ? 120 : (int.tryParse(value) ?? -1))),
                  style: TextStyle(fontSize: 14),
                ))
          ]),
          Text(((state.zone4 + 1) * state.ftp * 0.01).round().toString() +
              ' - ' +
              (state.zone5 * state.ftp * 0.01).round().toString())
        ],
      ),
      //Heart
      Divider(),
      Text('HEART RATE',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      TextFormField(
        autocorrect: false,
        keyboardType:
            TextInputType.numberWithOptions(signed: true, decimal: true),
        initialValue: state.rrHr == 0 ? '60' : state.rrHr.toString(),
        decoration:
            InputDecoration(labelText: 'Resting Heart Rate', errorMaxLines: 1),
        validator: (value) => state.isValidRRHR ? null : '>0',
        onChanged: (value) => context
            .read<SettingsBloc>()
            .add(RRHrChanged(value == '' ? 60 : (int.tryParse(value) ?? -1))),
      ),
      TextFormField(
        autocorrect: false,
        keyboardType:
            TextInputType.numberWithOptions(signed: true, decimal: true),
        initialValue: state.ltHr == 0 ? null : state.ltHr.toString(),
        decoration: InputDecoration(
            labelText: 'Lactate Threshold Heart Rate', errorMaxLines: 1),
        validator: (value) => state.isValidLTHR ? null : 'must be numeral',
        onChanged: (value) => context
            .read<SettingsBloc>()
            .add(LTHrChanged(value == '' ? 0 : (int.tryParse(value) ?? 0))),
      ),
      TextFormField(
        autocorrect: false,
        keyboardType:
            TextInputType.numberWithOptions(signed: true, decimal: true),
        initialValue: state.maxHr == 0 ? null : state.maxHr.toString(),
        decoration:
            InputDecoration(labelText: 'Maximum Heart Rate', errorMaxLines: 1),
        validator: (value) => state.isValidMaxHR ? null : 'must be numeral',
        onChanged: (value) => context
            .read<SettingsBloc>()
            .add(MaxHrChanged(value == '' ? 0 : (int.tryParse(value) ?? 0))),
      ),
      SizedBox(height: 8.0),
    ]);
  }

  Widget _chartForm(BuildContext context) {
    return BlocListener<SettingsBloc, SettingsState>(
      listener: (context, state) {
        final formStatus = state.formStatus;
        if (formStatus is SubmissionFailure) {
          _showSnackBar(context, formStatus.exception.toString());
        }
      },
      child: Column(children: [
        Text('CHART OPTIONS',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 8.0),
        FutureBuilder<SharedPreferences>(
            future: prefsFuture,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Column(children: [
                  CupertinoSlidingSegmentedControl(
                      groupValue: instantenousP,
                      children: {
                        true: Text('Instantenous Power'),
                        false: Text('3 Seconds-Power Smoothing',
                            textAlign: TextAlign.center)
                      },
                      onValueChanged: (bool? value) {
                        snapshot.data!
                            .setBool('instantenousP', value ?? instantenousP);
                        instantenousP = value!;
                        setState(() {});
                      }),
                  Row(children: [
                    Checkbox(
                        value: displayCadence,
                        onChanged: (dcd) {
                          snapshot.data!
                              .setBool('displayCadence', dcd ?? displayCadence);
                          displayCadence = dcd!;
                          setState(() {});
                        }),
                    Text('Display Cadence'),
                  ]),
                  Row(children: [
                    Checkbox(
                        value: displayHr,
                        onChanged: (dhr) {
                          snapshot.data!.setBool('displayHr', dhr ?? displayHr);
                          displayHr = dhr!;
                          setState(() {});
                        }),
                    Text('Display Heart Rate'),
                  ]),
                  Row(children: [
                    Checkbox(
                        value: simulatedSpeed,
                        onChanged: (simS) {
                          snapshot.data!.setBool(
                              'simulatedSpeed', simS ?? simulatedSpeed);
                          simulatedSpeed = simS!;
                          setState(() {});
                        }),
                    Text('Use Simulated Speed'),
                    Text(' *unticked uses wheel speed',
                        style: TextStyle(fontSize: 10))
                  ]),
                  Text('Display Chart Time Length',
                      style: TextStyle(fontSize: 16)),
                  SizedBox(height: 8.0),
                  CupertinoSlidingSegmentedControl(
                      groupValue: displayLength,
                      children: {
                        0: Text('Full Workout', textAlign: TextAlign.center),
                        1: Text('30 mins'),
                        2: Text('15 mins'),
                        3: Text('5 mins')
                      },
                      onValueChanged: (int? index) {
                        snapshot.data!
                            .setInt('displayLength', index ?? displayLength);
                        displayLength = index!;
                        setState(() {});
                      }),
                  Text('Countdown', style: TextStyle(fontSize: 16)),
                  SizedBox(height: 8.0),
                  CupertinoSlidingSegmentedControl(
                      groupValue: countdown,
                      children: {
                        0: Text('Sound + Vibrate', textAlign: TextAlign.center),
                        1: Text('Sound'),
                        2: Text('Vibrate'),
                        3: Text('None')
                      },
                      onValueChanged: (int? index) {
                        snapshot.data!.setInt('countdown', index ?? countdown);
                        countdown = index!;
                        setState(() {});
                      }),
                ]);
              } else {
                return CupertinoActivityIndicator();
              }
            })
      ]),
    );
  }

  void _showSnackBar(BuildContext context, String message) {
    int index = message.lastIndexOf('Exception: ');
    message = index == -1 ? message : message.substring(index + 11);
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void _signoutDialog(BuildContext ctx, SettingsState state) async {
    showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            title: Text('Confirm Sign Out', textAlign: TextAlign.center),
            children: [
              if (state.user.id == AppConstants().guestUUID)
                Center(
                  child: Text('Signing out would delete all data!',
                      style: TextStyle(color: Colors.red)),
                ),
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text('Cancel')),
                ElevatedButton(
                    onPressed: () async {
                      final prefs = await _prefs;
                      prefs.setBool('firstTime', true);
                      Navigator.of(context).pop();
                      ctx.read<SessionCubit>().signOut(true);
                    },
                    child: Text('SIGN OUT')),
              ]),
            ],
          );
        });
  }

  void _settingsSaved() {
    widget.settingsChanged(false);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SettingsBloc(
          user: context.read<SessionCubit>().currentUser,
          dataRepo: context.read<DataRepository>(),
          sessionCubit: BlocProvider.of<SessionCubit>(context),
          stravaAPI: context.read<stravaf.StravaAPI>()),
      child:
          BlocBuilder<SettingsBloc, SettingsState>(builder: (context, state) {
        return CustomScrollView(slivers: [
          SliverPersistentHeader(
              pinned: true,
              floating: true,
              delegate: SettingsSliverPersistentHeaderDelegate(
                  _formKey, state.nickname, _settingsSaved)),
          SliverList(
            delegate: SliverChildListDelegate([
              SafeArea(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  child: GestureDetector(
                    onTap: () =>
                        FocusScope.of(context).requestFocus(new FocusNode()),
                    child: Form(
                      onChanged: () {
                        widget.settingsChanged(true);
                      },
                      key: _formKey,
                      child: Column(children: [
                        if (state.user.id == AppConstants().guestUUID)
                          _unauthenticatedWarningWidget(context),
                        Divider(),
                        _settingsForm(context, state),
                        Divider(),
                        _stravaWidget(context, state),
                        Divider(),
                        _chartForm(context),
                        Divider(),
                        ElevatedButton(
                            onPressed: () => _signoutDialog(context, state),
                            child: Text('SIGN OUT')),
                        Divider(),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              TextButton(
                                  onPressed: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => EulaPage())),
                                  child: Text('EULA')),
                              TextButton(
                                  onPressed: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => PrivacyPage())),
                                  child: Text('Privacy policy')),
                            ]),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Issues/Feedback?   '),
                              TextButton(
                                  onPressed: () async {
                                    final Uri params = Uri(
                                      scheme: 'mailto',
                                      path: 'zilchworkout@gmail.com',
                                      query:
                                          'subject=Issue/Feedback&body=Please include account username for issues.',
                                    );
                                    final _url = params.toString();
                                    await canLaunch(_url)
                                        ? await launch(_url)
                                        : print('Could not launch');
                                  },
                                  child: Text('zilchworkout@gmail.com')),
                            ]),
                        SizedBox(height: 30.0),
                      ]),
                    ),
                  ),
                ),
              ),
            ]),
          ),
        ]);
      }),
    );
  }
}

class SettingsSliverPersistentHeaderDelegate
    extends SliverPersistentHeaderDelegate {
  final GlobalKey<FormState> key;
  final String nick;
  final VoidCallback settingsSaved;
  SettingsSliverPersistentHeaderDelegate(
      this.key, this.nick, this.settingsSaved);

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return BlocBuilder<SettingsBloc, SettingsState>(builder: (context, state) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        decoration: BoxDecoration(
            color: Colors.grey[50],
            border: Border(bottom: BorderSide(color: Colors.grey.shade200))),
        child: SafeArea(
          child: Column(children: [
            Text('Settings',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 20.0,
                    fontWeight: FontWeight.w500)),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Expanded(
                child: Text('Welcome, $nick',
                    maxLines: 1,
                    overflow: TextOverflow.fade,
                    softWrap: false,
                    style: TextStyle(color: Colors.black, fontSize: 18.0)),
              ),
              state.formStatus is FormSubmitting
                  ? CupertinoActivityIndicator()
                  : ElevatedButton(
                      onPressed: () {
                        if (key.currentState!.validate()) {
                          settingsSaved();
                          context.read<SettingsBloc>().add(SettingsSubmitted());
                        }
                      },
                      child: Text('Save Settings',
                          style: TextStyle(color: Colors.black)),
                      style:
                          ElevatedButton.styleFrom(primary: Colors.grey[200]),
                    ),
            ]),
          ]),
        ),
      );
    });
  }

  @override
  double get maxExtent => 2 * kToolbarHeight + 24;

  @override
  double get minExtent => 2 * kToolbarHeight + 12;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}
