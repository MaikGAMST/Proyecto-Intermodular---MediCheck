import 'package:cloud_firestore/cloud_firestore.dart';

class Incidence {
  final String id;
  final String type; // 'medication' | 'appointment'
  final String title;
  final String description;
  final String caregiverId;
  final String caregiverName;
  final String patientId;
  final String patientName;
  final DateTime createdAt;
  final String status; // 'pending' | 'resolved'

  Incidence({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.caregiverId,
    required this.caregiverName,
    required this.patientId,
    required this.patientName,
    required this.createdAt,
    this.status = 'pending',
  });

  factory Incidence.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Incidence(
      id: doc.id,
      type: data['type'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      caregiverId: data['caregiverId'] ?? '',
      caregiverName: data['caregiverName'] ?? '',
      patientId: data['patientId'] ?? '',
      patientName: data['patientName'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      status: data['status'] ?? 'pending',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'title': title,
      'description': description,
      'caregiverId': caregiverId,
      'caregiverName': caregiverName,
      'patientId': patientId,
      'patientName': patientName,
      'createdAt': Timestamp.fromDate(createdAt),
      'status': status,
    };
  }
}
