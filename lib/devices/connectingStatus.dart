abstract class ConnectingStatus {
  const ConnectingStatus();
}

class InitialConnectingStatus extends ConnectingStatus {
  const InitialConnectingStatus();
}

class StartedConnecting extends ConnectingStatus {}

class FinishedConnecting extends ConnectingStatus {}
