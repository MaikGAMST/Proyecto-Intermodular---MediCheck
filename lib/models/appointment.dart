class Appointment {
  final String id;
  final String patientId;
  final String caregiverId; // Referencia al cuidador para privacidad
  final String patientName;
  final String place;
  final String time;
  final DateTime date;
  final String status; // 'scheduled', 'completed', 'delayed'

  Appointment({
    required this.id,
    required this.patientId,
    required this.caregiverId,
    required this.patientName,
    required this.place,
    required this.time,
    required this.date,
    this.status = 'scheduled',
  });

  Appointment copyWith({
    String? id,
    String? patientId,
    String? caregiverId,
    String? patientName,
    String? place,
    String? time,
    DateTime? date,
    String? status,
  }) {
    return Appointment(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      caregiverId: caregiverId ?? this.caregiverId,
      patientName: patientName ?? this.patientName,
      place: place ?? this.place,
      time: time ?? this.time,
      date: date ?? this.date,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'patientId': patientId,
      'caregiverId': caregiverId,
      'patientName': patientName,
      'place': place,
      'time': time,
      'date': date.toIso8601String(),
      'status': status,
    };
  }

  factory Appointment.fromMap(Map<String, dynamic> map, String documentId) {
    return Appointment(
      id: documentId,
      patientId: map['patientId'] ?? '',
      caregiverId: map['caregiverId'] ?? '',
      patientName: map['patientName'] ?? '',
      place: map['place'] ?? '',
      time: map['time'] ?? '',
      date: map['date'] != null ? DateTime.parse(map['date']) : DateTime.now(),
      status: map['status'] ?? 'scheduled',
    );
  }
}
