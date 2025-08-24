import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:zilch_workout/appConstants.dart';
import 'package:zilch_workout/bluetooth/bluetoothApi.dart';
import 'package:zilch_workout/customAppBar/customAppBar.dart';
import 'package:zilch_workout/dataRepository.dart';
import 'package:zilch_workout/models/Workout.dart';
import 'package:zilch_workout/ride/rideBloc.dart';
import 'package:zilch_workout/ride/rideEvent.dart';
import 'package:zilch_workout/ride/rideState.dart';
import 'package:zilch_workout/session/sessionCubit.dart';
import 'package:zilch_workout/workouts/ergPage.dart';
import 'package:zilch_workout/workouts/simPage.dart';
import 'package:zilch_workout/workouts/workoutPage.dart';

class RideView extends StatefulWidget {
  final bool showAd;
  RideView({this.showAd = true});

  @override
  _RideViewState createState() => _RideViewState();
}

class _RideViewState extends State<RideView> {
  BannerAd? _anchoredBanner;
  bool _loadingAnchoredBanner = false;

  @override
  void dispose() {
    _anchoredBanner?.dispose();
    super.dispose();
  }

  void _startWorkout(RideState state, Workout w) {
    double totalWeight = (state.user.weight + state.user.bikeWeight) / 100;
    List<int> zones = [
      (state.user.zone1 * state.user.ftp * 0.01).round(),
      (state.user.zone2 * state.user.ftp * 0.01).round(),
      (state.user.zone3 * state.user.ftp * 0.01).round(),
      (state.user.zone4 * state.user.ftp * 0.01).round(),
      (state.user.zone5 * state.user.ftp * 0.01).round(),
    ];
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => WorkoutPage(
              bleRepo: state.bleRepo,
              user: state.user,
              workout: w,
              ftp: state.user.ftp,
              zones: zones,
              totalWeight: totalWeight,
              isMetric: state.user.metric)),
    );
  }

  void _startFreeRide(RideState state, int i) {
    double totalWeight = (state.user.weight + state.user.bikeWeight) / 100;
    List<int> zones = [
      (state.user.zone1 * state.user.ftp * 0.01).round(),
      (state.user.zone2 * state.user.ftp * 0.01).round(),
      (state.user.zone3 * state.user.ftp * 0.01).round(),
      (state.user.zone4 * state.user.ftp * 0.01).round(),
      (state.user.zone5 * state.user.ftp * 0.01).round(),
    ];
    if (i == 0) {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ErgPage(
                bleRepo: state.bleRepo,
                user: state.user,
                ftp: state.user.ftp,
                zones: zones,
                totalWeight: totalWeight,
                isMetric: state.user.metric)),
      );
    } else if (i == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => SimPage(
                bleRepo: state.bleRepo,
                user: state.user,
                ftp: state.user.ftp,
                zones: zones,
                totalWeight: totalWeight,
                isMetric: state.user.metric)),
      );
    }
  }

  void _checkTrainer(
      BuildContext context, RideState state, Workout? w, int? i) {
    if (state.bleRepo.trainerConnected) {
      if (w != null)
        _startWorkout(state, w);
      else if (i != null) _startFreeRide(state, i);
    } else {
      showDialog(
        context: context,
        builder: (context) => SimpleDialog(
          title: Text('Trainer not connected', textAlign: TextAlign.center),
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Cancel')),
              ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    if (w != null)
                      _startWorkout(state, w);
                    else if (i != null) _startFreeRide(state, i);
                  },
                  child: Text('Continue')),
            ]),
          ],
        ),
      );
    }
  }

  Widget _workoutWidget(BuildContext context, RideState state, Workout w) {
    int duration = 0;
    int avgP = 0;
    for (int i = 0; i < w.duration!.length; i++) {
      duration += w.duration![i];
      avgP += w.power![i] * w.duration![i];
    }
    avgP = (avgP / duration).round();
    return Container(
      decoration: BoxDecoration(
          color: Colors.grey[300],
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.all(Radius.circular(18.0))),
      child: GestureDetector(
        onTap: () => _checkTrainer(context, state, w, null),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(w.name!, style: TextStyle(decoration: TextDecoration.underline)),
          Text('Average Power: $avgP W'),
          Text('Duration: ' + AppConstants().getTimeFormat(duration)),
        ]),
      ),
    );
  }

  Future<void> _createAnchoredBanner(BuildContext context) async {
    if (!widget.showAd) return;
    AdRequest request = AdRequest(
      keywords: AppConstants.keywords,
      //contentUrl: 'http://foo.com/bar.html',
      //nonPersonalizedAds: true,
    );
    AdSize size = AdSize.mediumRectangle;
    final BannerAd banner = BannerAd(
        size: size,
        adUnitId: AppConstants.rideBannerUnitId,
        listener: BannerAdListener(
            onAdLoaded: (Ad ad) {
              print('$BannerAd loaded');
              setState(() {
                _anchoredBanner = ad as BannerAd?;
              });
            },
            onAdFailedToLoad: (Ad ad, LoadAdError error) {
              print('$BannerAd failedtoload:  $error');
              ad.dispose();
            },
            onAdOpened: (Ad ad) => print('$BannerAd onAdOpened'),
            onAdClosed: (Ad ad) => print('$BannerAd onAdClosed')),
        request: request);
    return banner.load();
  }

  @override
  Widget build(BuildContext context) {
    if (!_loadingAnchoredBanner) {
      _loadingAnchoredBanner = true;
      _createAnchoredBanner(context);
    }

    return BlocProvider(
      create: (context) => RideBloc(
          user: context.read<SessionCubit>().currentUser,
          dataRepo: context.read<DataRepository>(),
          bleRepo: context.read<BluetoothAPI>())
        ..add(GetWorkouts()),
      child: BlocBuilder<RideBloc, RideState>(builder: (context, state) {
        return SafeArea(
          child: Container(
            color: Colors.white,
            child: CustomScrollView(slivers: [
              CustomAppBar(state.bleRepo, 'Ride'),
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 10.0),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    SizedBox(height: 8.0),
                    Text('Workouts',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8.0),
                    SizedBox(
                      height: 211,
                      width: MediaQuery.of(context).size.width - 2 * 8.0,
                      child: state.workouts.isEmpty
                          ? Container(
                              child: Center(child: Text('No Workout File')))
                          : GridView.builder(
                              scrollDirection: Axis.horizontal,
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      crossAxisSpacing: 8.0,
                                      mainAxisSpacing: 8.0,
                                      childAspectRatio: (211 + 16.0) /
                                          MediaQuery.of(context).size.width),
                              itemCount: state.workouts.length,
                              itemBuilder: (context, index) {
                                return _workoutWidget(
                                    context, state, state.workouts[index]);
                              }),
                    ),
                    Divider(),
                    Text('Just Ride',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _checkTrainer(context, state, null, 0),
                            child: Container(
                              decoration: BoxDecoration(
                                  color: Colors.green[600],
                                  border:
                                      Border.all(color: Colors.green.shade800),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(18.0))),
                              padding: EdgeInsets.all(10.0),
                              height: 90.0,
                              child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Icon(Icons.flash_on),
                                        Text('Power',
                                            style: TextStyle(fontSize: 17)),
                                      ],
                                    ),
                                    Text('ERG Mode'),
                                    Text('START'),
                                  ]),
                            ),
                          ),
                        ),
                        SizedBox(width: 8.0),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _checkTrainer(context, state, null, 1),
                            child: Container(
                              decoration: BoxDecoration(
                                  color: Colors.yellow[700],
                                  border:
                                      Border.all(color: Colors.yellow.shade900),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(18.0))),
                              padding: EdgeInsets.all(10.0),
                              height: 90.0,
                              child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Icon(Icons.terrain_rounded),
                                        Text('Slope',
                                            style: TextStyle(fontSize: 17)),
                                      ],
                                    ),
                                    Text('Resistance Mode'),
                                    Text('START'),
                                  ]),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (_anchoredBanner != null) SizedBox(height: 12.0),
                    if (_anchoredBanner != null) Divider(),
                    if (_anchoredBanner != null)
                      Container(
                        color: Colors.white,
                        width: _anchoredBanner!.size.width.toDouble(),
                        height: _anchoredBanner!.size.height.toDouble(),
                        child: AdWidget(ad: _anchoredBanner!),
                      ),
                    if (_anchoredBanner != null) SizedBox(height: 12.0),
                  ]),
                ),
              ),
            ]),
          ),
        );
      }),
    );
  }
}
