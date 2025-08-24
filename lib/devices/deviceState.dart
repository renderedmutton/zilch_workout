import 'package:zilch_workout/bluetooth/bluetoothApi.dart';
import 'package:zilch_workout/devices/connectingStatus.dart';

class DeviceState {
  final BluetoothAPI bleRepo;
  final ConnectingStatus connectingStatus;
  DeviceState(
      {required BluetoothAPI bleRepo,
      this.connectingStatus = const InitialConnectingStatus()})
      : this.bleRepo = bleRepo;

  DeviceState copyWith({
    ConnectingStatus? connectingStatus,
    bool? hasScanned,
  }) {
    return DeviceState(
        bleRepo: this.bleRepo,
        connectingStatus: connectingStatus ?? this.connectingStatus);
  }
}
