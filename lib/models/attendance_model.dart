class AttendanceRecord {
  final int id;
  final int enfantId;
  final String date;
  final String? heure_arrivee;
  final String? heure_depart;
  final bool repas_midi;
  final bool repas_gouter;
  final String? notes;
  final String statut; // "present", "retard", "absent"

  AttendanceRecord({
    required this.id,
    required this.enfantId,
    required this.date,
    this.heure_arrivee,
    this.heure_depart,
    required this.repas_midi,
    required this.repas_gouter,
    this.notes,
    required this.statut,
  });

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    return AttendanceRecord(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      enfantId: json['enfant_id'] is int ? json['enfant_id'] : int.parse(json['enfant_id'].toString()),
      date: json['date'] ?? '',
      heure_arrivee: json['heure_arrivee'],
      heure_depart: json['heure_depart'],
      repas_midi: json['repas_midi'] is bool
          ? json['repas_midi']
          : (json['repas_midi'].toString().toLowerCase() == 'true'),
      repas_gouter: json['repas_gouter'] is bool
          ? json['repas_gouter']
          : (json['repas_gouter'].toString().toLowerCase() == 'true'),
      notes: json['notes'],
      statut: json['statut'] ?? 'present',
    );
  }
}

class AttendanceSummary {
  final int totalDays;
  final int presentDays;
  final int absentDays;
  final double attendanceRate;
  final int lateDays;

  AttendanceSummary({
    required this.totalDays,
    required this.presentDays,
    required this.absentDays,
    required this.attendanceRate,
    required this.lateDays,
  });

  factory AttendanceSummary.fromJson(Map<String, dynamic> json) {
    return AttendanceSummary(
      totalDays: json['total_days'] ?? 0,
      presentDays: json['present_days'] ?? 0,
      absentDays: json['absent_days'] ?? 0,
      attendanceRate: (json['attendance_rate'] is double
          ? json['attendance_rate']
          : double.parse(json['attendance_rate'].toString())) ?? 0.0,
      lateDays: json['late_days'] ?? 0,
    );
  }
}

// Alias for AbsenceRecord - just an AttendanceRecord with statut == 'absent'
class AbsenceRecord extends AttendanceRecord {
  AbsenceRecord({
    required int id,
    required int enfantId,
    required String date,
    String? heure_arrivee,
    String? heure_depart,
    required bool repas_midi,
    required bool repas_gouter,
    String? notes,
  }) : super(
    id: id,
    enfantId: enfantId,
    date: date,
    heure_arrivee: heure_arrivee,
    heure_depart: heure_depart,
    repas_midi: repas_midi,
    repas_gouter: repas_gouter,
    notes: notes,
    statut: 'absent',
  );

  factory AbsenceRecord.fromJson(Map<String, dynamic> json) {
    return AbsenceRecord(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      enfantId: json['enfant_id'] is int ? json['enfant_id'] : int.parse(json['enfant_id'].toString()),
      date: json['date'] ?? '',
      heure_arrivee: json['heure_arrivee'],
      heure_depart: json['heure_depart'],
      repas_midi: json['repas_midi'] is bool
          ? json['repas_midi']
          : (json['repas_midi'].toString().toLowerCase() == 'true'),
      repas_gouter: json['repas_gouter'] is bool
          ? json['repas_gouter']
          : (json['repas_gouter'].toString().toLowerCase() == 'true'),
      notes: json['notes'],
    );
  }
}
