import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/appointment.dart';

class AppointmentService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Colección global de citas
  static CollectionReference get _appointmentsRef {
    return _db.collection('appointments');
  }

  /// Obtener las citas del cuidador actual (Stream)
  static Stream<List<Appointment>> getAppointmentsStream() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return Stream.value([]);

    return _appointmentsRef
        .where('caregiverId', isEqualTo: uid)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Appointment.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  /// Añadir cita
  static Future<void> addAppointment(Appointment appointment) async {
    await _appointmentsRef.add(appointment.toMap());
  }

  /// Actualizar cita
  static Future<void> updateAppointment(Appointment appointment) async {
    await _appointmentsRef.doc(appointment.id).update(appointment.toMap());
  }

  /// Eliminar cita
  static Future<void> deleteAppointment(String id) async {
    await _appointmentsRef.doc(id).delete();
  }

  /// Actualizar estado de la cita
  static Future<void> updateAppointmentStatus(String id, String newStatus) async {
    await _appointmentsRef.doc(id).update({
      'status': newStatus,
    });
  }
}
