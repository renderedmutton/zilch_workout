import 'package:flutter_blue/flutter_blue.dart';
import 'package:zilch_workout/bluetooth/bluetoothApi.dart';

abstract class DeviceEvent {}

class AddDevice extends DeviceEvent {}

class Refresh extends DeviceEvent {}

class Reset extends DeviceEvent {}

class ConnectDevice extends DeviceEvent {
  final BleType bleType;
  final BluetoothDevice device;
  ConnectDevice(this.bleType, this.device);
}

class DisconnectDevice extends DeviceEvent {
  final BleType bleType;
  final BluetoothDevice device;
  DisconnectDevice(this.bleType, this.device);
}
