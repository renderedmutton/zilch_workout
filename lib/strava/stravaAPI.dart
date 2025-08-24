import 'dart:io';

import 'package:strava_flutter/Models/fault.dart';
import 'package:strava_flutter/strava.dart';
import 'package:strava_flutter/error_codes.dart' as error;

class StravaAPI {
  late Strava strava;
  bool isAuthOk = false;

  Future<bool> initialize(String clientId, String secret) async {
    strava = Strava(true, secret);
    Fault _fault = Fault(error.statusOk, '');
    isAuthOk =
        await strava.oauth(clientId, 'activity:write,read', secret, 'auto');
    if (isAuthOk) {
      print('isAuthOk $isAuthOk');
      return true;
    }
    print(_fault.message);
    return false;
  }

  Future<void> uploadWorkout(File tcxFile) async {
    Fault _fault = await strava.uploadActivity(null, null, tcxFile.path, 'tcx');
    print(_fault.message);
    return;
  }

  void deAuthorize(String secret) async {
    // need to get authorized before (valid token)
    final strava = Strava(
      true, // to get disply info in API
      secret, // Put your secret key in secret.dart file
    );
    final fault = await strava.deAuthorize();
    print(fault);
  }
}
