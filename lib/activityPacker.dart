import 'dart:typed_data';
import 'package:messagepack/messagepack.dart';

class ActivityPacker {
  final List<int> powers;
  final List<int> cadences;
  final List<int> hrs;
  final List<int> times;
  final List<int> speeds;
  final List<int> distances;
  final List<int> laps;
  final int startTime;
  final int totalAscent;
  ActivityPacker({
    required this.powers,
    required this.cadences,
    required this.hrs,
    required this.times,
    required this.speeds,
    required this.distances,
    required this.laps,
    required this.startTime,
    required this.totalAscent,
  });

  factory ActivityPacker.fromBytes(Uint8List bytes) =>
      _$ActivityFromBytes(bytes);

  Uint8List toBytes() => _$AcvtivityToBytes(this);
}

ActivityPacker _$ActivityFromBytes(Uint8List bytes) {
  List<int> powers = [];
  List<int> cadences = [];
  List<int> hrs = [];
  List<int> times = [];
  List<int> speeds = [];
  List<int> distances = [];
  List<int> laps = [];
  int startTime;
  int totalAscent;

  final u = Unpacker(bytes);
  var listLength = u.unpackListLength();
  for (int i = 0; i < listLength; i++) {
    powers.add(u.unpackInt()!);
  }
  listLength = u.unpackListLength();
  for (int i = 0; i < listLength; i++) {
    cadences.add(u.unpackInt()!);
  }
  listLength = u.unpackListLength();
  for (int i = 0; i < listLength; i++) {
    hrs.add(u.unpackInt()!);
  }
  listLength = u.unpackListLength();
  for (int i = 0; i < listLength; i++) {
    times.add(u.unpackInt()!);
  }
  listLength = u.unpackListLength();
  for (int i = 0; i < listLength; i++) {
    speeds.add(u.unpackInt()!);
  }
  listLength = u.unpackListLength();
  for (int i = 0; i < listLength; i++) {
    distances.add(u.unpackInt()!);
  }
  listLength = u.unpackListLength();
  for (int i = 0; i < listLength; i++) {
    laps.add(u.unpackInt()!);
  }
  startTime = u.unpackInt()!;
  totalAscent = u.unpackInt()!;
  return ActivityPacker(
      powers: powers,
      cadences: cadences,
      hrs: hrs,
      times: times,
      speeds: speeds,
      distances: distances,
      laps: laps,
      startTime: startTime,
      totalAscent: totalAscent);
}

Uint8List _$AcvtivityToBytes(ActivityPacker instance) {
  final p = new Packer();
  p.packListLength(instance.powers.length);
  instance.powers.forEach(p.packInt);
  p.packListLength(instance.cadences.length);
  instance.cadences.forEach(p.packInt);
  p.packListLength(instance.hrs.length);
  instance.hrs.forEach(p.packInt);
  p.packListLength(instance.times.length);
  instance.times.forEach(p.packInt);
  p.packListLength(instance.speeds.length);
  instance.speeds.forEach(p.packInt);
  p.packListLength(instance.distances.length);
  instance.distances.forEach(p.packInt);
  p.packListLength(instance.laps.length);
  instance.laps.forEach(p.packInt);
  p.packInt(instance.startTime);
  p.packInt(instance.totalAscent);
  final bytes = p.takeBytes();
  return bytes;
}
