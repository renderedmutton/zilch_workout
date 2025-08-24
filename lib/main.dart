import 'dart:async';

import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_datastore/amplify_datastore.dart';
import 'package:amplify_datastore/types/DataStoreHubEvents/ModelSyncedEvent.dart';
import 'package:amplify_flutter/amplify.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zilch_workout/amplifyconfiguration.dart';
import 'package:zilch_workout/appConstants.dart';
import 'package:zilch_workout/appNavigator.dart';
import 'package:zilch_workout/auth/authRepository.dart';
import 'package:zilch_workout/bluetooth/bluetoothApi.dart';
import 'package:zilch_workout/dataRepository.dart';
import 'package:zilch_workout/loadingView.dart';
import 'package:zilch_workout/models/ModelProvider.dart';
import 'package:zilch_workout/session/sessionCubit.dart';
import 'package:zilch_workout/storageRepository.dart';
import 'package:uuid/uuid.dart' as uuidv4;
import 'package:zilch_workout/strava/stravaAPI.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isAmplifiedConfigured = false;
  StreamSubscription? hubSub;

  @override
  void initState() {
    super.initState();
    _configureAmplify();
    _getPrefs();
  }

  @override
  void dispose() {
    if (hubSub != null) hubSub?.cancel();
    super.dispose();
  }

  Future<void> _configureAmplify() async {
    try {
      await Amplify.addPlugins([
        AmplifyAuthCognito(),
        AmplifyAPI(),
        AmplifyDataStore(modelProvider: ModelProvider.instance),
        AmplifyStorageS3(),
      ]);

      if (!Amplify.isConfigured) {
        await Amplify.configure(amplifyconfig);
      }

      hubSub = Amplify.Hub.listen([HubChannel.DataStore], (event) {
        print(event.eventName);
        String eventName = event.eventName;
        if (eventName == 'networkStatus')
          print('$eventName active:${event.payload.active}');
        if (eventName == 'syncQueriesStarted')
          print('$eventName models:${event.payload.models}');
        if (eventName == 'modelSynced') {
          final payload = event.payload as ModelSyncedEvent;
          print(
              '$eventName modelName:${payload.modelName} isFullSync:${payload.isFullSync} isDeltaSync:${payload.isDeltaSync} added:${payload.added} updated:${payload.updated} deleted:${payload.deleted}');
        }
        if (eventName == 'outboxMutationEnqueued' ||
            eventName == 'outboxMutationProcessed')
          print(
              '$eventName ${event.payload.modelName} ${event.payload.element.model}');
        if (eventName == 'outboxStatus')
          print('$eventName isEmpty:${event.payload.isEmpty}');
      });

      //await Amplify.Auth.signOut();
      //await Amplify.DataStore.clear();

      setState(() => _isAmplifiedConfigured = true);
    } catch (e) {
      print(e);
    }
  }

  void _getPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('firstTime') || prefs.getBool('firstTime')!) {
      var uuid = uuidv4.Uuid();
      AppConstants().guestUUID = uuid.v4();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Zilch Workout',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: (_isAmplifiedConfigured)
          ? MultiRepositoryProvider(
              providers: [
                RepositoryProvider(create: (context) => AuthRepository()),
                RepositoryProvider(create: (context) => DataRepository()),
                RepositoryProvider(create: (context) => StorageRepository()),
                RepositoryProvider(create: (context) => BluetoothAPI()),
                RepositoryProvider(create: (context) => StravaAPI()),
              ],
              child: BlocProvider(
                  create: (context) => SessionCubit(
                      authRepo: context.read<AuthRepository>(),
                      dataRepo: context.read<DataRepository>(),
                      storageRepo: context.read<StorageRepository>(),
                      bleRepo: context.read<BluetoothAPI>(),
                      stravaRepo: context.read<StravaAPI>()),
                  child: AppNavigator()),
            )
          : LoadingView(),
    );
  }
}
