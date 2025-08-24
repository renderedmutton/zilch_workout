import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:convert/convert.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:zilch_workout/bluetooth/bleConstants.dart';

class BluetoothAPI {
  final FlutterBlue _flutterBlue = FlutterBlue.instance;
  FlutterBlue get flutterBlue => _flutterBlue;

  Map<BluetoothDevice, List<BleType>> _scannedDevices = {};
  Map<BluetoothDevice, List<BleType>> get scannedDevices => _scannedDevices;
  Map<BleType, BluetoothDevice> _connectedDevices = {};
  Map<BleType, BluetoothDevice> get connectedDevices => _connectedDevices;

  var trainerConnected = false;
  BleType trainerConnectedType = BleType.trainerFTMS;
  var hrConnected = false;
  var powerConnected = false;
  var cadenceConnected = false;

  var _previousCSC = [0, 0, 0, 0];
  //wheel(uint32),wheeltime(uint16),crank(uint16),cranktime(uint16)
  var _currentCSC = [0, 0, 0, 0];

  //StreamController<List<int>> streamController = StreamController<List<int>>.broadcast();
  StreamController<int> speedStream = StreamController<int>.broadcast();
  StreamController<int> powerStream = StreamController<int>.broadcast();
  StreamController<int> cadenceStream = StreamController<int>.broadcast();
  StreamController<int> heartRateStream = StreamController<int>.broadcast();
  late BluetoothCharacteristic controlPointChar;
  Map<int, String> controlPointResults = {
    0x01: 'success',
    0x02: 'not supported',
    0x03: 'invalid parameter',
    0x04: 'operation fail',
    0x05: 'not permitted'
  };

  int _fecCurrentPower = -1;
  int _fecCurrentGrade = -1000;
  bool fecCalibrationStarted = false;
  double fecTargetSpeed = 32;

  void dispose() {
    for (var d in _connectedDevices.values) {
      d.disconnect();
    }
    //streamController.close();
    speedStream.close();
    powerStream.close();
    cadenceStream.close();
    //heartRateStream.close();
  }

  void scanDevices() async {
    final isScanning = await _flutterBlue.isScanning.first;
    if (isScanning) return;
    print('blemanager scan');
    _flutterBlue.state.listen((event) {
      if (event == BluetoothState.on) {
        _flutterBlue.startScan(
          timeout: Duration(seconds: 5),
          withServices: [
            Guid(fullUUID(BleConstants.ftmsServiceUUID)),
            Guid(BleConstants.tacxFECPriServiceUUID),
            Guid(fullUUID(BleConstants.heartRateServiceUUID)),
            Guid(fullUUID(BleConstants.cyclingPowerServiceUUID)),
            Guid(fullUUID(BleConstants.cscServiceUUID))
          ],
        );
      }
    });
    _flutterBlue.scanResults.listen((results) {
      for (var r in results) {
        for (var service in r.advertisementData.serviceUuids) {
          //print('$r $service');
          if (isEqual(service, BleConstants.ftmsServiceUUID)) {
            if (_scannedDevices[r.device] == null)
              _scannedDevices[r.device] = [BleType.trainerFTMS];
            else
              _scannedDevices[r.device]!.add(BleType.trainerFTMS);
          }
          if (isEqual(service, BleConstants.tacxFECPriServiceUUID)) {
            if (_scannedDevices[r.device] == null)
              _scannedDevices[r.device] = [BleType.trainerANTBLE];
            else
              _scannedDevices[r.device]!.add(BleType.trainerANTBLE);
          }
          if (isEqual(service, BleConstants.heartRateServiceUUID)) {
            if (_scannedDevices[r.device] == null)
              _scannedDevices[r.device] = [BleType.heartRate];
            else
              _scannedDevices[r.device]!.add(BleType.heartRate);
          }
          if (isEqual(service, BleConstants.cyclingPowerServiceUUID)) {
            if (_scannedDevices[r.device] == null)
              _scannedDevices[r.device] = [BleType.power];
            else
              _scannedDevices[r.device]!.add(BleType.power);
          }
          if (isEqual(service, BleConstants.cscServiceUUID)) {
            if (_scannedDevices[r.device] == null)
              _scannedDevices[r.device] = [BleType.cadence];
            else
              _scannedDevices[r.device]!.add(BleType.cadence);
          }
        }
      }
    });
  }

  Future<bool> connectDevice(BluetoothDevice device, BleType bleType) async {
    //connect device
    if (!_connectedDevices.containsValue(device)) {
      if (Platform.isIOS)
        await device.connect();
      else if (Platform.isAndroid) await device.connect(autoConnect: false);
    }
    List<BluetoothService> services = await device.discoverServices();
    //run through service and read accordingly
    for (var s in services) {
      if (isEqual(BleConstants.ftmsServiceUUID, s.uuid.toString()) &&
          bleType == BleType.trainerFTMS) {
        debugPrint('found trainer ftms');
        await readTrainerFTMS(device, s);
        return true;
      }
      if (isEqual(BleConstants.tacxFECPriServiceUUID, s.uuid.toString()) &&
          bleType == BleType.trainerANTBLE) {
        debugPrint('found trainer ant-ble');
        await readTrainerFecBle(device, s);
        return true;
      }
      if (isEqual(BleConstants.heartRateServiceUUID, s.uuid.toString()) &&
          bleType == BleType.heartRate) {
        debugPrint('found hr');
        await readHr(device, s);
        return true;
      }
      if (isEqual(BleConstants.cyclingPowerServiceUUID, s.uuid.toString()) &&
          bleType == BleType.power) {
        print('found power');
        await readPower(device, s);
        return true;
      }
      if (isEqual(BleConstants.cscServiceUUID, s.uuid.toString()) &&
          bleType == BleType.cadence) {
        print('found cadence');
        await readCadence(device, s);
        return true;
      }
    }
    return false;
  }

  Future<void> readTrainerFecBle(
      BluetoothDevice device, BluetoothService service) async {
    if (trainerConnected) {
      disconnectDevice(BleType.trainerFTMS);
      disconnectDevice(BleType.trainerANTBLE);
      trainerConnected = false;
    }
    var characteristics = service.characteristics;
    for (var c in characteristics) {
      if (isEqual(
          BleConstants.tacxFECReadCharacteristicUUID, c.uuid.toString())) {
        await c.setNotifyValue(true);
        c.value.listen((value) {
          if (value.isEmpty) return;
          if (value[0] != 0xA4) return;
          int pageNumber = value[4];
          if (pageNumber == 1) {
            String request = hexToBinary(hex.encode([value[5]]));
            String calibrationDone = request.substring(7, 8);
            fecCalibrationStarted = false;
            print(
                'FEC page 1 $value $request calibrationDone $calibrationDone');
          }
          if (pageNumber == 2) {
            String status = hexToBinary(hex.encode([value[5]]));
            String condition = hexToBinary(hex.encode([value[6]]));
            int targetSpeed = (value[9] << 8) + value[8];
            targetSpeed = (targetSpeed * 0.001 * 3.6 * 100).round();
            fecTargetSpeed = targetSpeed / 100;
            print('FEC page 2 $value');
            print('$status $condition ${targetSpeed / 100}');
          }
          if (pageNumber == 16) {
            int speed = -1;
            speed = (value[9] << 8) + value[8];
            speed = (speed * 0.001 * 3.6 * 100).round();
            //streamController.add([-1, -1, -1, speed]);
            speedStream.add(speed);
          }
          if (pageNumber == 25) {
            if (value.length < 13) return;
            //trainer data
            int cadence = -1;
            int power = -1;
            cadence = value[6];
            /*String status = hexToBinary(hex.encode([value[10]]));
            status = status.substring(4, 8);
            print('status $status');*/
            power = (value[10] << 8) + value[9];
            power = power & 0xFFF;
            /*if (!powerConnected && !cadenceConnected) {
              streamController.add([
                power >= 0 ? power : -1,
                cadence >= 0 ? cadence : -1,
                -1,
                -1
              ]);
            } else if (powerConnected && !cadenceConnected) {
              if (cadence >= 0) streamController.add([-1, cadence, -1, -1]);
            } else if (!powerConnected && cadenceConnected) {
              if (power >= 0) streamController.add([power, -1, -1, -1]);
            }*/
            if (!powerConnected) powerStream.add(power >= 0 ? power : -1);
            if (!cadenceConnected)
              cadenceStream.add(cadence >= 0 ? cadence : -1);
          }
          if (pageNumber == 48) {
            //resistance = value[11] * 0.5;
          }
          if (pageNumber == 49) {
            //fecCurrentPower = (((value[11] << 8) + value[10])/4).round();
            print('fec target power $_fecCurrentPower');
          }
          if (pageNumber == 50) {
            double windResistanceCoeff = value[9] * 0.01; //KgM
            int windSpeed = value[10] - 127; //kph
            double draftFactor = value[11] * 0.01;
            print(
                'windResistanceCoeff $windResistanceCoeff windSpeed $windSpeed draft $draftFactor');
          }
          if (pageNumber == 51) {
            double grade = ((value[10] << 8) + value[9]) * 0.01 - 200;
            double rr = value[11] * 0.00005;
            //fecCurrentGrade = grade;
            print('fec grade $grade rr $rr');
          }
          if (pageNumber == 54) {
            int maxResistance = (value[10] << 8) + value[9];
            String hexValue = hex.encode([value[11]]);
            String flags = hexToBinary(hexValue);
            bool resistMode = flags.substring(0, 1) == '1';
            bool ergMode = flags.substring(1, 2) == '1';
            bool simMode = flags.substring(2, 3) == '1';
            print(
                'page 54 ${maxResistance}N flags $flags resist $resistMode erg $ergMode sim $simMode');
          }
          if (pageNumber == 55) {
            print('FEC page 55 $value');
          }
          if (pageNumber == 71) {
            int lastReceived = value[5];
            int status = value[7];
            if (lastReceived == 49 && status == 0) {
              int power = (value[11] << 8) + value[10];
              power = (power / 4).round();
              _fecCurrentPower = power;
              print('page 71 $lastReceived $status $power');
            }
            if (lastReceived == 51 && status == 0) {
              int grade = (((value[10] << 8) + value[9]) * 0.01).round() - 200;
              _fecCurrentGrade = grade * 100;
              print('page 71 $lastReceived $status $grade');
            }
          }
          if (pageNumber != 1 &&
              pageNumber != 2 &&
              pageNumber != 16 &&
              pageNumber != 25 &&
              pageNumber != 48 &&
              pageNumber != 49 &&
              pageNumber != 50 &&
              pageNumber != 54 &&
              pageNumber != 5 &&
              pageNumber != 71) {
            //print('page $pageNumber ${value.sublist(5)}');
          }
        });
        //connected
        trainerConnected = true;
        trainerConnectedType = BleType.trainerANTBLE;
        _connectedDevices[BleType.trainerANTBLE] = device;
        debugPrint('ble manager trainer connected ${device.id}');
      }
      if (isEqual(
          BleConstants.tacxFECWriteCharacterisitcUUID, c.uuid.toString())) {
        controlPointChar = c;
        _readRequestPage();
      }
    }
  }

  Future<void> readTrainerFTMS(
      BluetoothDevice device, BluetoothService service) async {
    if (trainerConnected) {
      disconnectDevice(BleType.trainerFTMS);
      disconnectDevice(BleType.trainerANTBLE);
      trainerConnected = false;
    }
    var characteristics = service.characteristics;
    for (var c in characteristics) {
      if (isEqual(BleConstants.ftmsIndoorBikeDataCharacteristicUUID,
          c.uuid.toString())) {
        await c.setNotifyValue(true);
        c.value.listen((value) {
          if (value.isEmpty) return;
          var flags = hex.encode(value);
          flags = hexToBinary(flags.substring(0, 4));
          int speed = -1;
          int cadence = -1;
          int power = -1;
          int offset = 2;
          if (flags[0] == '0') speed = (value[offset + 1] << 8) + value[offset];
          offset += flags[0] == '0' ? 2 : 0; //instant speed 2bytes 0=present
          offset += flags[1] == '1' ? 2 : 0; //avg speed 2bytes
          if (flags[2] == '1') {
            cadence =
                (((value[offset + 1] << 8) + value[offset]) * 0.5).round();
          }
          offset += flags[2] == '1' ? 2 : 0; //cadence 2bytes
          offset += flags[3] == '1' ? 2 : 0; //avg cadence 2bytes
          offset += flags[4] == '1' ? 3 : 0; //total dist 3bytes
          offset += flags[5] == '1' ? 2 : 0; //resistance lvl 2bytes
          if (flags[6] == '1') power = (value[offset + 1] << 8) + value[offset];
          /*if (!powerConnected && !cadenceConnected) {
            streamController.add([
              power >= 0 ? power : -1,
              cadence >= 0 ? cadence : -1,
              -1,
              speed
            ]);
          } else if (powerConnected && !cadenceConnected) {
            if (cadence >= 0) streamController.add([-1, cadence, -1, speed]);
          } else if (!powerConnected && cadenceConnected) {
            if (power >= 0) streamController.add([power, -1, -1, speed]);
          }*/
          speedStream.add(speed);
          if (!powerConnected) powerStream.add(power >= 0 ? power : -1);
          if (!cadenceConnected) cadenceStream.add(cadence >= 0 ? cadence : -1);
        });
        trainerConnected = true;
        trainerConnectedType = BleType.trainerFTMS;
        _connectedDevices[BleType.trainerFTMS] = device;
        debugPrint('ble manager trainer connected ${device.id}');
      }
      if (isEqual(BleConstants.ftmsCpCharacteristicUUID, c.uuid.toString())) {
        _activateTrainer(c);
      }
      if (isEqual(
          BleConstants.ftmsStatusCharacteristicUUID, c.uuid.toString())) {
        await c.setNotifyValue(true);
        c.value.listen((value) {
          if (value.isEmpty) return;
          if (value[0] == 0x14) {
            if (value[1] == 0x02) fecCalibrationStarted = false;
          }
          print(value);
        });
      }
    }
  }

  void _activateTrainer(BluetoothCharacteristic c) async {
    while (!trainerConnected) {
      Future.delayed(Duration(milliseconds: 100));
    }
    await c.setNotifyValue(true);
    controlPointChar = c;
    c.value.listen((value) {
      //get response when sent command
      if (value.isEmpty) return;
      String log = '';
      value.forEach((e) => log = log + e.toRadixString(16) + ',');
      print(log);
    });
    //write to control trainer
    bool written = false;
    while (!written) {
      controlPointChar.write([0x00]);
      List<int> result = await controlPointChar.read();
      if (result[0] == 0x80 && result[1] == 0x00 && result[2] == 0x01)
        written = true;
      else
        Future.delayed(Duration(milliseconds: 500));
    }
  }

  Future<void> readHr(BluetoothDevice device, BluetoothService service) async {
    if (hrConnected) {
      disconnectDevice(BleType.heartRate);
      hrConnected = false;
    }
    var characteristics = service.characteristics;
    for (var c in characteristics) {
      if (isEqual(BleConstants.heartRateMeasurementUUID, c.uuid.toString())) {
        await c.setNotifyValue(true);
        c.value.listen((value) {
          if (value.isEmpty) return;
          if (value[0] & 0x01 == 0)
            heartRateStream.add(value[1]);
          //streamController.add([-1, -1, value[1], -1]);
          else
            heartRateStream.add((value[2] << 8) + value[1]);
          //streamController.add([-1, -1, value[2] << 8 + value[1], -1]);
        });
        hrConnected = true;
        _connectedDevices[BleType.heartRate] = device;
        debugPrint('ble manager hr connected');
        return;
      }
    }
  }

  Future<void> readPower(
      BluetoothDevice device, BluetoothService service) async {
    if (powerConnected) {
      disconnectDevice(BleType.power);
      powerConnected = false;
    }
    var characteristics = service.characteristics;
    for (var c in characteristics) {
      if (isEqual(
          BleConstants.cyclingPowerMeasurementUUID, c.uuid.toString())) {
        await c.setNotifyValue(true);
        c.value.listen((value) {
          if (value.length >= 3) {
            int p = (value[3] << 8) + value[2];
            powerStream.add(p);
            //streamController.add([p, -1, -1, -1]);
          } else
            print('power ' + value.toString());
        });
        powerConnected = true;
        _connectedDevices[BleType.power] = device;
        debugPrint('ble manager power connected ${device.id}');
        return;
      }
    }
  }

  Future<void> readCadence(
      BluetoothDevice device, BluetoothService service) async {
    if (cadenceConnected) {
      disconnectDevice(BleType.cadence);
      cadenceConnected = false;
    }
    var characteristics = service.characteristics;
    for (var c in characteristics) {
      if (isEqual(BleConstants.cscMeasurementUUID, c.uuid.toString())) {
        await c.setNotifyValue(true);
        c.value.listen((value) {
          //bool hasWheel = (value[0] & 0x01) > 0;
          //bool hasCrank = (value[0] & 0x02) > 0;
          int crank = (value[8] << 8 + value[7]);
          int crankTime = (value[10] << 8 + value[9]);
          _previousCSC = _currentCSC;
          _currentCSC[2] = crank;
          _currentCSC[3] = crankTime;
          double crankTimeDiff =
              _calculateDifference(_currentCSC[3], _previousCSC[3]).toDouble();
          crankTimeDiff /= 1024;
          var crankDiff = _calculateDifference(_currentCSC[2], _previousCSC[2]);
          cadenceStream.add(crankTimeDiff == 0
              ? 0
              : (60 * crankDiff / crankTimeDiff).round());
          /*streamController.add([
            -1,
            crankTimeDiff == 0 ? 0 : (60 * crankDiff / crankTimeDiff).round(),
            -1,
            -1
          ]);*/
        });
        cadenceConnected = true;
        _connectedDevices[BleType.cadence] = device;
        debugPrint('ble manager cadence connected');
        return;
      }
    }
  }

  int _calculateDifference(int current, int previous) {
    if (current <= previous)
      return current - previous;
    else
      return (65536 - previous) + current;
  }

  void writePower(int power) async {
    if (!trainerConnected) {
      print('Error: trainer not connected');
      return;
    }
    if (_connectedDevices[BleType.trainerANTBLE] != null) {
      List<int> bytes = BluetoothANT().sendChangePower(power);
      print('writing to fec power $bytes');
      while (power != _fecCurrentPower) {
        await controlPointChar.write(bytes);
        await Future.delayed(Duration(milliseconds: 100));
        List<int> pageBytes = BluetoothANT().sendRequestPage(71);
        await controlPointChar.write(pageBytes);
        await Future.delayed(Duration(milliseconds: 1000));
      }
      print('FEC $power W');
      return;
    }
    //write to characteristic
    List<int> bytes = [0x05, power & 0xff, (power >> 8) & 0xff];
    bool written = false;
    while (!written) {
      await controlPointChar.write(bytes);
      List<int> result = await controlPointChar.read();
      if (result[0] == 0x80 && result[1] == 0x05 && result[2] == 0x01)
        written = true;
      else
        await Future.delayed(Duration(milliseconds: 100));
    }
    print('wrote power $bytes W');
  }

  void writeSim(
      {int wind = 0, int grade = 0, int crr = 32, int drag = 0}) async {
    if (!trainerConnected) {
      print('Error: trainer not connected');
      return;
    }
    if (_connectedDevices[BleType.trainerANTBLE] != null) {
      List<int> bytes = BluetoothANT().sendChangeGrade(grade, crr);
      while (grade != _fecCurrentGrade) {
        await controlPointChar.write(bytes);
        await Future.delayed(Duration(milliseconds: 100));
        List<int> pageBytes = BluetoothANT().sendRequestPage(71);
        await controlPointChar.write(pageBytes);
        await Future.delayed(Duration(milliseconds: 1000));
      }
      print('FEC $grade %');
      return;
    }
    //write to characteristic
    List<int> bytes = [
      0x11,
      wind & 0xff, //m/s 0.001
      (wind >> 8) & 0xff,
      grade & 0xff, //% 0.01
      (grade >> 8) & 0xff,
      crr & 0xff, //0.0001
      drag & 0xff //kg/m 0.01
    ];
    bool written = false;
    while (!written) {
      await controlPointChar.write(bytes);
      List<int> result = await controlPointChar.read();
      if (result[0] == 0x80 && result[1] == 0x11 && result[2] == 0x01)
        written = true;
      else
        await Future.delayed(Duration(milliseconds: 100));
    }
    print('wrote sim $bytes');
  }

  void writeResistance(int resistance) async {
    if (!trainerConnected) {
      print('Error: trainer not connected');
      return;
    }
    //write to characteristic
    List<int> bytes = [0x04, resistance & 0xff, (resistance >> 8) & 0xff];
    await controlPointChar.write(bytes);
  }

  void writeSpindown() async {
    fecCalibrationStarted = true;
    if (_connectedDevices[BleType.trainerANTBLE] != null) {
      List<int> pageBytes = BluetoothANT().sendCalibration();
      controlPointChar.write(pageBytes);
      print('FEC calibration sent');
      return;
    }
    controlPointChar.write([0x13, 0x01]);
    List<int> result = await controlPointChar.read();
    if (result.length == 7) {
      int lso = (result[4] << 8) + result[3];
      int mso = (result[6] << 8) + result[5];
      fecTargetSpeed = lso / 100;
      print('lso $lso, mso $mso');
    }
  }

  void _readRequestPage() async {
    List<int> bytes = BluetoothANT().sendRequestPage(54);
    controlPointChar.write(bytes);
  }

  void disconnectDevice(BleType bleType) {
    if (_connectedDevices[bleType] != null) {
      if (bleType == BleType.heartRate) {
        hrConnected = false;
      } else if (bleType == BleType.trainerFTMS ||
          bleType == BleType.trainerANTBLE) {
        trainerConnected = false;
      } else if (bleType == BleType.power) {
        powerConnected = false;
      } else if (bleType == BleType.cadence) {
        cadenceConnected = false;
      }
      if (bleType == BleType.power || bleType == BleType.cadence) {
        if (_connectedDevices[BleType.trainerFTMS] ==
            _connectedDevices[bleType]) {
          _connectedDevices.remove(bleType);
        }
      } else {
        _connectedDevices[bleType]!.disconnect();
        _connectedDevices.remove(bleType);
      }
    } else
      debugPrint('no such device connected');
  }

  Future<void> resetAll() async {
    _flutterBlue.connectedDevices.then((value) => value.forEach((d) {
          d.disconnect();
        }));
    _connectedDevices.clear();
    _scannedDevices.clear();
    hrConnected = false;
    trainerConnected = false;
    powerConnected = false;
    cadenceConnected = false;
  }

  String fullUUID(String uuid) {
    return BleConstants.fullUUID.replaceAll("****", uuid);
  }

  bool isEqual(String uuid1, String uuid2) {
    if (uuid1.length == 4) {
      uuid1 = fullUUID(uuid1);
    }
    if (uuid2.length == 4) {
      uuid2 = fullUUID(uuid2);
    }
    return (uuid1.toUpperCase().compareTo(uuid2.toUpperCase()) == 0);
  }

  String hexToBinary(String hexString) {
    String binary = '';
    for (int i = 0; i < hexString.length; i += 2) {
      String split = hexString.substring(i, i + 2);
      var s = (int.parse(split, radix: 16)).toRadixString(2).padLeft(8, '0');
      //print('split $split s $s');
      var characters = Characters(s);
      binary += characters.toList().reversed.join();
    }
    return binary;
  }
}

class BluetoothANT {
  List<int> sendChangePower(int power) {
    power = power * 4; //power/0.25W
    List<int> powerBytes = [power & 0xff, (power >> 8) & 0xff];
    List<int> bytes = new List<int>.filled(13, 0xFF);
    //Command to send
    bytes[0] = 0xA4; //Sync
    bytes[1] = 0x09; //Length
    bytes[2] = 0x4F; //Acknowledge message type
    bytes[3] = 0x05; //Channel
    //Data
    bytes[4] = 0x31; //Page 49
    bytes[5] = 0xFF;
    bytes[6] = 0xFF;
    bytes[7] = 0xFF;
    bytes[8] = 0xFF;
    bytes[9] = 0xFF;
    bytes[10] = powerBytes[0]; //first byte of total power
    bytes[11] = powerBytes[1]; //second byte of total power
    int checksum = getCheckSumWithArray(bytes.sublist(0, 11));
    bytes[12] = checksum;
    return bytes;
  }

  List<int> sendChangeGrade(int grade, int crr) {
    grade = grade + 200 * 100; //grade*100% -200%
    crr = crr * 2; //crr*0.0001/0.00005 //0-0.0127
    List<int> gradeBytes = [grade & 0xff, (grade >> 8) & 0xff];
    List<int> bytes = new List<int>.filled(13, 0xFF);
    //Command to send
    bytes[0] = 0xA4; //Sync
    bytes[1] = 0x09; //Length
    bytes[2] = 0x4F; //Acknowledge message type
    bytes[3] = 0x05; //Channel
    //Data
    bytes[4] = 0x33; //Page 51
    bytes[5] = 0xFF;
    bytes[6] = 0xFF;
    bytes[7] = 0xFF;
    bytes[8] = 0xFF;
    bytes[9] = gradeBytes[0]; //grade LSB
    bytes[10] = gradeBytes[1]; //grade MSB
    bytes[11] = crr; //coef rolling resistance
    int checksum = getCheckSumWithArray(bytes.sublist(0, 11));
    bytes[12] = checksum;
    return bytes;
  }

  List<int> sendCalibration() {
    int calibrationRequestMode = 128 + 64; //128=spindown, 64=zeroOffset
    List<int> bytes = new List<int>.filled(13, 0xFF);
    //Command to send
    bytes[0] = 0xA4; //Sync
    bytes[1] = 0x09; //Length
    bytes[2] = 0x4F; //Acknowledge message type
    bytes[3] = 0x05; //Channel
    //Data
    bytes[4] = 0x01; //Page 1
    bytes[5] = calibrationRequestMode; //calibration request
    bytes[6] = 0x00;
    bytes[7] = 0xFF;
    bytes[8] = 0xFF;
    bytes[9] = 0xFF;
    bytes[10] = 0xFF;
    bytes[11] = 0xFF;
    int checksum = getCheckSumWithArray(bytes.sublist(0, 11));
    bytes[12] = checksum;
    return bytes;
  }

  List<int> sendRequestPage(int page) {
    List<int> bytes = new List<int>.filled(13, 0xFF);
    //Command to send
    bytes[0] = 0xA4; //Sync
    bytes[1] = 0x09; //Length
    bytes[2] = 0x4F; //Acknowledge message type
    bytes[3] = 0x05; //Channel
    //Data
    bytes[4] = 0x46; //Page 70
    bytes[5] = 0xFF;
    bytes[6] = 0xFF;
    bytes[7] = 0xFF; //Descriptor byte 1 (0xFF for no value)
    bytes[8] = 0xFF; //Descriptor byte 2 (0xFF for no value)
    bytes[9] = 0x80; //Requested transmission response
    bytes[10] = page; //page number
    bytes[11] = 0x01;
    //Command type (0x01 for request data page, 0x02 for request ANT-FS session)
    int checksum = getCheckSumWithArray(bytes.sublist(0, 11));
    bytes[12] = checksum;
    return bytes;
  }

  int getCheckSumWithArray(List<int> data) {
    String xorBinary = '';
    for (int i = 1; i < data.length - 1; i++) {
      int decimalValue = data[i];
      String hexValue = hex.encode([decimalValue]);
      String binary = hexToBinary(hexValue);
      String previousBinary = '';
      if (xorBinary != '')
        previousBinary = xorBinary;
      else {
        int previousDecimalValue = data[i - 1];
        String previousHexValue = hex.encode([previousDecimalValue]);
        previousBinary = hexToBinary(previousHexValue);
      }
      xorBinary = xorBetweenBinary(previousBinary, binary);
    }
    return binaryToUint8(xorBinary);
  }

  String hexToBinary(String hexString) {
    String binary = '';
    for (int i = 0; i < hexString.length; i += 2) {
      String split = hexString.substring(i, i + 2);
      var s = (int.parse(split, radix: 16)).toRadixString(2).padLeft(8, '0');
      var characters = Characters(s);
      binary += characters.toList().reversed.join();
    }
    return binary;
  }

  String bytesToString(List<int> bytes) {
    String result = "";
    for (var b in bytes) result += b.toRadixString(16);
    return result;
  }

  int hextoUint8(String hexString) {
    int i = int.parse(hexString, radix: 16);
    return i;
  }

  int binaryToUint8(String binary) {
    int data = int.parse(binary, radix: 2);
    return data;
  }

  String xorBetweenBinary(String a, String b) {
    String result = "";
    for (int i = 0; i < a.length; i++) {
      if (a[i] == b[i])
        result += "0";
      else
        result += "1";
    }
    return result;
  }
}

enum BleType { trainerFTMS, trainerANTBLE, heartRate, power, cadence }
