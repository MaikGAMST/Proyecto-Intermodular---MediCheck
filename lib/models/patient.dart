class Patient {
  final String id;
  final String name;
  final String surname;
  final String dni;
  final int age;
  final String gender;
  final String bloodType;
  final String notes;
  final String allergies;
  final String caregiverId;
  final String caregiverName;

  Patient({
    required this.id,
    required this.name,
    required this.surname,
    required this.dni,
    required this.age,
    required this.gender,
    required this.bloodType,
    required this.notes,
    required this.allergies,
    required this.caregiverId,
    required this.caregiverName,
  });

  /// Permite crear una copia del paciente modificando solo algunos campos
  Patient copyWith({
    String? id,
    String? name,
    String? surname,
    String? dni,
    int? age,
    String? gender,
    String? bloodType,
    String? notes,
    String? allergies,
    String? caregiverId,
    String? caregiverName,
  }) {
    return Patient(
      id: id ?? this.id,
      name: name ?? this.name,
      surname: surname ?? this.surname,
      dni: dni ?? this.dni,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      bloodType: bloodType ?? this.bloodType,
      notes: notes ?? this.notes,
      allergies: allergies ?? this.allergies,
      caregiverId: caregiverId ?? this.caregiverId,
      caregiverName: caregiverName ?? this.caregiverName,
    );
  }

  /// Convertir objeto a Map
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'surname': surname,
      'dni': dni,
      'age': age,
      'gender': gender,
      'bloodType': bloodType,
      'notes': notes,
      'allergies': allergies,
      'caregiverId': caregiverId,
      'caregiverName': caregiverName,
    };
  }

  /// Crear objeto desde Map
  factory Patient.fromMap(Map<String, dynamic> map, String documentId) {
    return Patient(
      id: documentId,
      name: map['name'] ?? '',
      surname: map['surname'] ?? '',
      dni: map['dni'] ?? '',
      age: map['age'] ?? 0,
      gender: map['gender'] ?? '',
      bloodType: map['bloodType'] ?? '',
      notes: map['notes'] ?? '',
      allergies: map['allergies'] ?? '',
      caregiverId: map['caregiverId'] ?? '',
      caregiverName: map['caregiverName'] ?? '',
    );
  }
}
