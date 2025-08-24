import 'dart:io';

import 'package:path_provider/path_provider.dart';

class TcxWriter {
  Future<File> _localFile(String filename) async {
    final directory = await getTemporaryDirectory();
    return File('${directory.path}/$filename');
  }

  Future<File> writeTCX(
      {required String filename,
      required DateTime dateActivity,
      required int duration,
      required int totalDistance,
      required int calories,
      required List<int> times,
      required List<int> distances,
      required List<int> speeds,
      required List<int> powers,
      required List<int> hrs,
      required List<int> cadences}) async {
    var tcxFile = await _localFile(filename);
    var sink = tcxFile.openWrite(mode: FileMode.writeOnly);
    String contents = '';
    final String prolog = """<?xml version="1.0" encoding="UTF-8"?>
<TrainingCenterDatabase
  xsi:schemaLocation="http://www.garmin.com/xmlschemas/TrainingCenterDatabase/v2 http://www.garmin.com/xmlschemas/TrainingCenterDatabasev2.xsd"
  xmlns:ns5="http://www.garmin.com/xmlschemas/ActivityGoals/v1"
  xmlns:ns3="http://www.garmin.com/xmlschemas/ActivityExtension/v2"
  xmlns:ns2="http://www.garmin.com/xmlschemas/UserProfile/v2"
  xmlns="http://www.garmin.com/xmlschemas/TrainingCenterDatabase/v2"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:ns4="http://www.garmin.com/xmlschemas/ProfileExtension/v1">\n""";
    final String tailActivity = """      <Creator xsi:type="Device_t">
        <Name>Zilch Workout</Name>
        <UnitId>0</UnitId>
        <ProductID>0</ProductID>
        <Version>
          <VersionMajor>1</VersionMajor>
          <VersionMinor>0</VersionMinor>
          <BuildMajor>1</BuildMajor>
          <BuildMinor>0</BuildMinor>
        </Version>
      </Creator>\n""";
    final String tail = """  <Author xsi:type="Application_t">
    <Name>Zilch Workout</Name>
    <Build>
      <Version>
        <VersionMajor>1</VersionMajor>
        <VersionMinor>0</VersionMinor>
        <BuildMajor>1</BuildMajor>
        <BuildMinor>0</BuildMinor>
      </Version>
    </Build>
    <LangID>en</LangID>
    <PartNumber>1</PartNumber>
  </Author>
</TrainingCenterDatabase>""";
    String activityContent =
        """  <Activities>\n    <Activity Sport="Biking">\n""";
    activityContent =
        activityContent + _addElement('Id', _createTimestamp(dateActivity), 6);

    String lapContent = '';
    lapContent = lapContent + _addElement('TotalTimeSeconds', '$duration', 8);
    lapContent =
        lapContent + _addElement('DistanceMeters', totalDistance.toString(), 8);
    lapContent = lapContent + _addElement('Calories', '$calories', 8);
    lapContent = lapContent + _addElement('TriggerMethod', 'Manual', 8);

    String trackContent = '';
    trackContent = trackContent + """        <Track>\n""";
    String firstTimeStamp = _createTimestamp(dateActivity);
    String firstTrackPoint =
        _addTrackPoint(firstTimeStamp, 0, 0, 0, hrs[0], cadences[0]);
    trackContent = trackContent + firstTrackPoint;
    for (int i = 0; i < powers.length; i++) {
      String timeStamp = _createTimestamp(DateTime.fromMillisecondsSinceEpoch(
          (times[i] / 1000).round() * 1000));
      int speed = (speeds[i] / 1000 / 3.6).round();
      String trackPoint = _addTrackPoint(
          timeStamp, distances[i], speed, powers[i], hrs[i], cadences[i]);
      trackContent = trackContent + trackPoint;
    }
    trackContent = trackContent + """        </Track>\n""";
    lapContent = lapContent + trackContent;
    activityContent = activityContent +
        _addAttribute(
            'Lap', 'StartTime', _createTimestamp(dateActivity), lapContent);
    activityContent = activityContent + tailActivity;
    activityContent =
        activityContent + """    </Activity>\n  </Activities>\n""";

    //add all contents
    contents = prolog + activityContent + tail;
    //write and close
    sink.write(contents);
    await sink.flush();
    await sink.close();

    return tcxFile;
  }

  String _addTrackPoint(String timeStamp, int distance, int speed, int power,
      int heartRate, int cadence) {
    String _returnString;

    _returnString = '          <Trackpoint>\n';
    _returnString = _returnString + _addElement('Time', timeStamp, 12);
    _returnString =
        _returnString + _addElement('DistanceMeters', distance.toString(), 12);
    _returnString = _returnString + _addHeartRate(heartRate);
    _returnString = _returnString + _addCadence(cadence);
    _returnString = _returnString +
        """            <Extensions>
              <ns3:TPX>
                <ns3:Speed>$speed</ns3:Speed>
                <ns3:Watts>$power</ns3:Watts>
              </ns3:TPX>
            </Extensions>\n""";
    _returnString = _returnString + "          </Trackpoint>\n";

    return _returnString;
  }

  /*String _addExtension(String tag, double value) {
    String returnString;
    String extensionBeg = """<Extensions>\n   <ns3:TPX>\n""";
    String extensionMid;

    String extensionEnd = """   </ns3:TPX>\n</Extensions>\n""";

    double _value = value;

    extensionMid =
        '     <ns3:' + tag + '>' + _value.toString() + '</ns3:' + tag + '>\n';

    returnString = extensionBeg + extensionMid + extensionEnd;

    return returnString;
  }*/

  String _addHeartRate(int heartRate) {
    String heartRateContentBeg =
        """            <HeartRateBpm>\n             <Value>""";

    String heartRateContentEnd = """</Value>\n            </HeartRateBpm>\n""";
    int _heartRate = heartRate;
    String _valueString = _heartRate.toString();
    return heartRateContentBeg + _valueString + heartRateContentEnd;
  }

  String _addCadence(int cadence) {
    String cadenceContentBeg = """            <Cadence>""";
    String cadenceContetEnd = """</Cadence>\n""";
    String _valueString = cadence.toString();
    return cadenceContentBeg + _valueString + cadenceContetEnd;
  }

  String _addElement(String tag, String content, int spaces) {
    String returnString = '';
    for (int i = 0; i < spaces; i++) {
      returnString += ' ';
    }
    returnString =
        returnString + ('<' + tag + '>' + content + '</' + tag + '>\n');

    return returnString;
  }

  /// create XML attribute
  /// from content string
  String _addAttribute(
      String tag, String attribute, String value, String content) {
    String returnString;

    returnString = '      <' + tag + ' ' + attribute + '="' + value + '">\n';
    returnString = returnString + content + '      </' + tag + '>\n';

    return returnString;
  }

  String _createTimestamp(DateTime dateTime) {
    String _returnString;

    _returnString = dateTime.toUtc().toString();
    _returnString = _returnString.replaceFirst(' ', 'T');
    _returnString = _returnString.replaceFirst('.000Z', 'Z');

    return _returnString;
  }
}
