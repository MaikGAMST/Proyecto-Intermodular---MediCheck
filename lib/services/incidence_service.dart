import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/incidence.dart';

class IncidenceService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Reportar una nueva incidencia
  static Future<void> reportIncidence(Incidence incidence) async {
    await _db.collection('incidences').add(incidence.toMap());
  }

  /// Obtener todas las incidencias (Para Admin)
  static Stream<List<Incidence>> getIncidencesStream() {
    return _db
        .collection('incidences')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Incidence.fromFirestore(doc)).toList());
  }

  /// Resolver una incidencia
  static Future<void> resolveIncidence(String id) async {
    await _db.collection('incidences').doc(id).update({'status': 'resolved'});
  }

  /// Eliminar incidencia (Opcional)
  static Future<void> deleteIncidence(String id) async {
    await _db.collection('incidences').doc(id).delete();
  }
}
