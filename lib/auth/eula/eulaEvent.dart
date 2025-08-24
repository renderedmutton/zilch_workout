abstract class EulaEvent {}

class EulaAcceptChanged extends EulaEvent {
  final bool accept;
  EulaAcceptChanged(this.accept);
}

class EulaSubmitted extends EulaEvent {}
