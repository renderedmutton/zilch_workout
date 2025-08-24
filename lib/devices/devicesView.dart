import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:zilch_workout/bluetooth/bluetoothApi.dart';
import 'package:zilch_workout/customAppBar/customAppBar.dart';
import 'package:zilch_workout/devices/calibrationPage.dart';
import 'package:zilch_workout/devices/connectingStatus.dart';
import 'package:zilch_workout/devices/deviceBloc.dart';
import 'package:zilch_workout/devices/deviceEvent.dart';
import 'package:zilch_workout/devices/deviceState.dart';

class DevicesView extends StatefulWidget {
  @override
  _DevicesViewState createState() => _DevicesViewState();
}

class _DevicesViewState extends State<DevicesView> {
  void _showCalibration(BuildContext context, DeviceState state) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CalibrationPage(state.bleRepo)),
    );
  }

  void _showConnectingWidget(BuildContext context, DeviceBloc deviceBloc) {
    showDialog(
      context: context,
      builder: (context) => BlocProvider.value(
        value: deviceBloc,
        child:
            BlocConsumer<DeviceBloc, DeviceState>(listener: (context, state) {
          if (state.connectingStatus is FinishedConnecting) {
            Navigator.of(context).maybePop();
          }
        }, builder: (context, state) {
          return SimpleDialog(
              title: Text('Connecting', textAlign: TextAlign.center),
              children: [CupertinoActivityIndicator()]);
        }),
      ),
    );
  }

  Widget _deviceWidget(BuildContext context, DeviceState state,
      BluetoothDevice device, BleType bleType) {
    String deviceName = device.name;
    bool connected = state.bleRepo.connectedDevices.containsKey(bleType);
    if (bleType == BleType.trainerFTMS) deviceName += ' - FTMS';
    if (bleType == BleType.trainerANTBLE) deviceName += ' - FEC-BLE';
    String buttonString = connected ? 'DISCONNECT' : 'CONNECT';
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(deviceName),
      ElevatedButton(
        onPressed: () {
          if (connected)
            context.read<DeviceBloc>().add(DisconnectDevice(bleType, device));
          else {
            context.read<DeviceBloc>().add(ConnectDevice(bleType, device));
            _showConnectingWidget(
                context, BlocProvider.of<DeviceBloc>(context));
          }
        },
        child: Text(buttonString),
      )
    ]);
  }

  List<Widget> _trainers(BuildContext context, DeviceState state) {
    List<Widget> buffer = [];
    state.bleRepo.scannedDevices.forEach((key, value) {
      if (value.contains(BleType.trainerFTMS))
        buffer.add(_deviceWidget(context, state, key, BleType.trainerFTMS));
      if (value.contains(BleType.trainerANTBLE))
        buffer.add(_deviceWidget(context, state, key, BleType.trainerANTBLE));
    });
    return buffer;
  }

  List<Widget> _heartRates(BuildContext context, DeviceState state) {
    List<Widget> buffer = [];
    state.bleRepo.scannedDevices.forEach((key, value) {
      if (value.contains(BleType.heartRate))
        buffer.add(_deviceWidget(context, state, key, BleType.heartRate));
    });
    return buffer;
  }

  List<Widget> _powerMeters(BuildContext context, DeviceState state) {
    List<Widget> buffer = [];
    state.bleRepo.scannedDevices.forEach((key, value) {
      if (value.contains(BleType.power))
        buffer.add(_deviceWidget(context, state, key, BleType.power));
    });
    return buffer;
  }

  List<Widget> _cadences(BuildContext context, DeviceState state) {
    List<Widget> buffer = [];
    state.bleRepo.scannedDevices.forEach((key, value) {
      if (value.contains(BleType.cadence))
        buffer.add(_deviceWidget(context, state, key, BleType.cadence));
    });
    return buffer;
  }

  Widget _deviceList(BuildContext context, DeviceState state) {
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 10.0),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(Icons.bluetooth),
              Expanded(
                  child: Center(
                      child: Text('Connect Devices',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)))),
              ElevatedButton(
                  onPressed: () => context.read<DeviceBloc>().add(Refresh()),
                  child: Text('Refresh')),
            ],
          ),
          Divider(),
          Text('Trainers', style: TextStyle(fontWeight: FontWeight.bold)),
          Column(children: _trainers(context, state)),
          Divider(),
          Text('Heart Rate Sensors',
              style: TextStyle(fontWeight: FontWeight.bold)),
          Column(children: _heartRates(context, state)),
          Divider(),
          Text('Power Meters', style: TextStyle(fontWeight: FontWeight.bold)),
          Column(children: _powerMeters(context, state)),
          Divider(),
          Text('Cadence Sensors',
              style: TextStyle(fontWeight: FontWeight.bold)),
          Column(children: _cadences(context, state)),
          Divider(),
          if (state.bleRepo.trainerConnected)
            ElevatedButton(
                style: ElevatedButton.styleFrom(primary: Colors.teal),
                onPressed: () => _showCalibration(context, state),
                child: Text('CALIBRATE')),
          SizedBox(height: 24.0),
          ElevatedButton(
              style: ElevatedButton.styleFrom(primary: Colors.red),
              onPressed: () => context.read<DeviceBloc>().add(Reset()),
              child: Text('RESET')),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          DeviceBloc(bleRepo: context.read<BluetoothAPI>())..add(Refresh()),
      child: BlocBuilder<DeviceBloc, DeviceState>(builder: (context, state) {
        return SafeArea(
          child: Container(
            color: Colors.white,
            child: CustomScrollView(slivers: [
              CustomAppBar(state.bleRepo, 'Devices'),
              StreamBuilder<BluetoothState>(
                  stream: state.bleRepo.flutterBlue.state,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      if (snapshot.data! == BluetoothState.on) {
                        return _deviceList(context, state);
                      }
                      return SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(8, 20, 8, 20),
                          child: Center(child: Text(snapshot.data!.toString())),
                        ),
                      );
                    }
                    return SliverFillRemaining(
                      child: Center(child: CupertinoActivityIndicator()),
                    );
                  }),
            ]),
          ),
        );
      }),
    );
  }
}
