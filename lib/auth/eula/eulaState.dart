class EulaState {
  final bool accept;
  EulaState({this.accept = false});

  EulaState copyWith(bool? accept) {
    return EulaState(accept: accept ?? this.accept);
  }
}
