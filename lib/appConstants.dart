import 'dart:io';
import 'dart:math';

class AppConstants {
  String guestUUID = '80968707-42cc-4681-96ab-43ea90270eec';

  String getTimeFormat(int seconds) {
    int hours = (seconds / 3600).floor();
    int minutes = (seconds / 60).floor() - hours * 60;
    seconds -= minutes * 60 + hours * 3600;
    return hours.toString().padLeft(2, '0') +
        ':' +
        minutes.toString().padLeft(2, '0') +
        ':' +
        seconds.toString().padLeft(2, '0');
  }

  static int getTSS(int startTime, List<int> times, List<int> powers, int ftp) {
    //get TSS
    int dur = ((times[times.length - 1] - startTime) / 1000).round();
    int avgP = (powers.reduce((p, c) => p + c) / powers.length).round();
    int normalizedPower = avgP;
    if (powers.length > 30) {
      List<double> pSmooth = [];
      for (int i = 29; i < powers.length; i++) {
        List<int> buf = powers.sublist(i - 29, i).toList();
        double avg = buf.reduce((p, c) => p + c) / buf.length;
        pSmooth.add(avg * avg * avg * avg);
      }
      double averagePSmooth_4 =
          pSmooth.reduce((p, c) => p + c) / pSmooth.length;
      normalizedPower = pow(averagePSmooth_4, 0.25).round();
    }
    double intensity = normalizedPower / ftp;
    double trainingLoad =
        (normalizedPower * dur * intensity * intensity) / (ftp * 3600);
    trainingLoad *= 100;
    return trainingLoad.round();
  }

  static List<String> keywords = [
    'cycling',
    'cycle',
    'bicycle',
    'sports',
    'triathlon',
    'run',
    'swim',
    'indoor trainer',
    'trainer',
    'coach',
    'travel',
    'adventure',
    'zwift',
    'rgt',
    'bkool',
    'wahoo',
    'garmin',
    'tacx',
    'kinetic',
    'magene',
    'saris',
    'elite',
    'stages',
    'wattbike',
    'specialized',
    'cannondale',
    'giant',
    'bianchi',
    'look',
    'giant',
    'factor',
    'colnago',
    'bontrager',
    'felt',
    'trek',
    'canyon',
    'pinarello',
    'orbea',
    'cube',
    'devinci',
    'fuji',
    'mountain bike',
    'e-bike',
    'e bike',
    'e-bicycle',
    'e bicycle',
    'foldable bike',
    'foldable bicycle'
  ];

  static String calendarBannerUnitId = Platform.isAndroid
      ? 'ca-app-pub-3289972821596247/7724451621' //ca-app-pub-3940256099942544/6300978111
      : 'ca-app-pub-3289972821596247/6605691515';

  static String rideBannerUnitId = Platform.isAndroid
      ? 'ca-app-pub-3289972821596247/2902729154' //ca-app-pub-3940256099942544/6300978111
      : 'ca-app-pub-3289972821596247/8131360325';

  static String intersitialUnitId = Platform.isAndroid
      ? 'ca-app-pub-3289972821596247/1589647482' //InterstitialAd.testAdUnitId
      : 'ca-app-pub-3289972821596247/9280790468';
}
