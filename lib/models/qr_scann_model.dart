class QrScannModel {
  String? studentId;
  String? studentName;
  bool? isPaid;
  bool? isContestOnly;
  bool? day1Attendance;
  bool? day2Attendance;
  bool? contestAttendance;

  QrScannModel(
      {this.studentId,
      this.studentName,
      this.isPaid,
      this.isContestOnly,
      this.day1Attendance,
      this.day2Attendance,
      this.contestAttendance});

  QrScannModel.fromJson(Map<String, dynamic> json) {
    studentId = json['student_id'];
    studentName = json['student_name'];
    isPaid = json['isPaid'];
    isContestOnly = json['isContestOnly'];
    day1Attendance = json['day1_attendance'];
    day2Attendance = json['day2_attendance'];
    contestAttendance = json['contest_attendance'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['student_id'] = this.studentId;
    data['student_name'] = this.studentName;
    data['isPaid'] = this.isPaid;
    data['isContestOnly'] = this.isContestOnly;
    data['day1_attendance'] = this.day1Attendance;
    data['day2_attendance'] = this.day2Attendance;
    data['contest_attendance'] = this.contestAttendance;
    return data;
  }
}
