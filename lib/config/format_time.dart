class FormatTime {
  String coverTimeFromIso(String isoString) {
    DateTime dateTime = DateTime.parse(isoString);

    int hours = dateTime.hour;
    int minutes = dateTime.minute;

    String ampm = hours >= 12 ? 'P.M' : 'A.M';
    hours = hours % 12;
    hours = hours == 0 ? 12 : hours;

    String minutesString = minutes < 10 ? '0$minutes' : '$minutes';

    String timeString = '$hours:$minutesString $ampm';
    return timeString;
  }
}
