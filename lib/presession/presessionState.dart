import 'package:zilch_workout/dataRepository.dart';
import 'package:zilch_workout/session/sessionCubit.dart';

class PresessionState {
  final String userId;
  final DataRepository dataRepo;
  final SessionCubit sessionCubit;
  final bool ready;
  PresessionState(
      {required this.userId,
      required this.dataRepo,
      required this.sessionCubit,
      required this.ready});

  PresessionState copyWith({bool? ready}) {
    return PresessionState(
        userId: this.userId,
        dataRepo: this.dataRepo,
        sessionCubit: this.sessionCubit,
        ready: ready ?? this.ready);
  }
}
