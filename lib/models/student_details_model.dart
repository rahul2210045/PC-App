class StudentData {
  final String studentId;
  final String studentName;
  final bool isPaid;
  final bool isContestOnly;
  final bool day1Attendance;
  final bool day2Attendance;
  final bool contestAttendance;

  StudentData({
    required this.studentId,
    required this.studentName,
    required this.isPaid,
    required this.isContestOnly,
    required this.day1Attendance,
    required this.day2Attendance,
    required this.contestAttendance,
  });

  factory StudentData.fromJson(Map<String, dynamic> json) {
    return StudentData(
      studentId: json['student_id'],
      studentName: json['student_name'],
      isPaid: json['isPaid'],
      isContestOnly: json['isContestOnly'],
      day1Attendance: json['day1_attendance'],
      day2Attendance: json['day2_attendance'],
      contestAttendance: json['contest_attendance'],
    );
  }
}
