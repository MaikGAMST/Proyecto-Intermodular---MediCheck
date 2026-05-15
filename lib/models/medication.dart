class Medication {
  final String id;
  final String patientId;
  final String caregiverId; // Referencia al cuidador para privacidad
  final String patientName;
  final String name;
  final String reason;
  final String dosage;
  final String frequency;
  final List<String> intakeTimes; // Ej: ["08:00", "20:00"]
  final String instructions; // Ej: "Después de comer"
  final DateTime startDate;
  final DateTime endDate;
  final String type;
  final String genericName; // Principio activo (de OpenFDA)
  final String therapeuticClass; // Clase terapéutica (de OpenFDA)
  final int totalQuantity; // Cantidad total en la caja
  final int remainingQuantity; // Cantidad actual
  final bool reminderEnabled;

  Medication({
    required this.id,
    required this.patientId,
    required this.caregiverId,
    required this.patientName,
    required this.name,
    required this.reason,
    required this.dosage,
    required this.frequency,
    required this.intakeTimes,
    required this.instructions,
    required this.startDate,
    required this.endDate,
    required this.type,
    this.genericName = '',
    this.therapeuticClass = '',
    required this.totalQuantity,
    required this.remainingQuantity,
    required this.reminderEnabled,
  });

  Medication copyWith({
    String? id, String? patientId, String? caregiverId, String? patientName, String? name, String? reason,
    String? dosage, String? frequency, List<String>? intakeTimes,
    String? instructions, DateTime? startDate, DateTime? endDate,
    String? type, String? genericName, String? therapeuticClass,
    int? totalQuantity, int? remainingQuantity,
    bool? reminderEnabled,
  }) {
    return Medication(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      caregiverId: caregiverId ?? this.caregiverId,
      patientName: patientName ?? this.patientName,
      name: name ?? this.name,
      reason: reason ?? this.reason,
      dosage: dosage ?? this.dosage,
      frequency: frequency ?? this.frequency,
      intakeTimes: intakeTimes ?? this.intakeTimes,
      instructions: instructions ?? this.instructions,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      type: type ?? this.type,
      genericName: genericName ?? this.genericName,
      therapeuticClass: therapeuticClass ?? this.therapeuticClass,
      totalQuantity: totalQuantity ?? this.totalQuantity,
      remainingQuantity: remainingQuantity ?? this.remainingQuantity,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'patientId': patientId,
      'caregiverId': caregiverId,
      'patientName': patientName,
      'name': name,
      'reason': reason,
      'dosage': dosage,
      'frequency': frequency,
      'intakeTimes': intakeTimes,
      'instructions': instructions,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'type': type,
      'genericName': genericName,
      'therapeuticClass': therapeuticClass,
      'totalQuantity': totalQuantity,
      'remainingQuantity': remainingQuantity,
      'reminderEnabled': reminderEnabled,
    };
  }

  factory Medication.fromMap(Map<String, dynamic> map, [String? documentId]) {
    return Medication(
      id: documentId ?? map['id'] ?? '',
      patientId: map['patientId'] ?? '',
      caregiverId: map['caregiverId'] ?? '',
      patientName: map['patientName'] ?? 'Paciente',
      name: map['name'] ?? '',
      reason: map['reason'] ?? '',
      dosage: map['dosage'] ?? '',
      frequency: map['frequency'] ?? '',
      intakeTimes: List<String>.from(map['intakeTimes'] ?? []),
      instructions: map['instructions'] ?? '',
      startDate: map['startDate'] != null ? DateTime.parse(map['startDate']) : DateTime.now(),
      endDate: map['endDate'] != null ? DateTime.parse(map['endDate']) : DateTime.now(),
      type: map['type'] ?? '',
      genericName: map['genericName'] ?? '',
      therapeuticClass: map['therapeuticClass'] ?? '',
      totalQuantity: map['totalQuantity'] ?? 0,
      remainingQuantity: map['remainingQuantity'] ?? 0,
      reminderEnabled: map['reminderEnabled'] ?? true,
    );
  }
}

