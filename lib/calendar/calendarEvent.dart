abstract class CalendarEvent {}

class InitializeCalendar extends CalendarEvent {}

class CreateNewSchedule extends CalendarEvent {
  final DateTime scheduledDateTime;
  final DateTime notifyDateTime;
  final String workoutName;
  CreateNewSchedule(
      this.scheduledDateTime, this.notifyDateTime, this.workoutName);
}

class DeleteSchedule extends CalendarEvent {
  final scheduleId;
  DeleteSchedule(this.scheduleId);
}
