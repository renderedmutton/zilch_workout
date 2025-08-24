abstract class CreateStatus {
  const CreateStatus();
}

class InitialCreateStatus extends CreateStatus {
  const InitialCreateStatus();
}

class CreationInProgress extends CreateStatus {}

class CreationSuccess extends CreateStatus {}

class CreationFailure extends CreateStatus {}
