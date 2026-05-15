class MedicationLog {
  final String id;
  final String medicationId;
  final String patientId;
  final DateTime takenAt;
  final String medicationName;
  final String caregiverName;

  MedicationLog({
    required this.id,
    required this.medicationId,
    required this.patientId,
    required this.takenAt,
    required this.medicationName,
    required this.caregiverName,
  });

  Map<String, dynamic> toMap() {
    return {
      'medicationId': medicationId,
      'patientId': patientId,
      'takenAt': takenAt.toIso8601String(),
      'medicationName': medicationName,
      'caregiverName': caregiverName,
    };
  }

  factory MedicationLog.fromMap(Map<String, dynamic> map, String id) {
    return MedicationLog(
      id: id,
      medicationId: map['medicationId'] ?? '',
      patientId: map['patientId'] ?? '',
      takenAt: map['takenAt'] != null ? DateTime.parse(map['takenAt']) : DateTime.now(),
      medicationName: map['medicationName'] ?? '',
      caregiverName: map['caregiverName'] ?? '',
    );
  }
}
