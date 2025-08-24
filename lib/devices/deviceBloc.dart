import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zilch_workout/bluetooth/bluetoothApi.dart';
import 'package:zilch_workout/devices/connectingStatus.dart';
import 'package:zilch_workout/devices/deviceEvent.dart';
import 'package:zilch_workout/devices/deviceState.dart';

class DeviceBloc extends Bloc<DeviceEvent, DeviceState> {
  final BluetoothAPI bleRepo;
  DeviceBloc({required this.bleRepo}) : super(DeviceState(bleRepo: bleRepo));

  @override
  Stream<DeviceState> mapEventToState(DeviceEvent event) async* {
    if (event is AddDevice) {
      yield state.copyWith();
    } else if (event is Refresh) {
      print('scan');
      state.bleRepo.scanDevices();
      Timer.periodic(Duration(milliseconds: 500), (timer) {
        if (timer.tick > 9) timer.cancel();
        add(AddDevice());
      });

      //
    } else if (event is Reset) {
      print('reset');
      await state.bleRepo.resetAll();
      yield state.copyWith();
      add(Refresh());

      //
    } else if (event is ConnectDevice) {
      print('connect');
      yield state.copyWith(connectingStatus: StartedConnecting());
      try {
        await state.bleRepo.connectDevice(event.device, event.bleType);
        yield state.copyWith(connectingStatus: FinishedConnecting());
        print('connected ${event.device.name}');
      } catch (e) {
        print(e);
      }

      //
    } else if (event is DisconnectDevice) {
      print('disconnect');
      state.bleRepo.disconnectDevice(event.bleType);
      yield state.copyWith(connectingStatus: InitialConnectingStatus());

      //
    }
  }
}
