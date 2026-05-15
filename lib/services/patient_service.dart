import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/patient.dart';

class PatientService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Colección del usuario actual
  static CollectionReference get _userPatientsRef {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception("Usuario no autenticado");
    return _db.collection('users').doc(uid).collection('patients');
  }

  /// Obtener todos los pacientes (Stream)
  static Stream<List<Patient>> getPatientsStream() async* {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      yield [];
      return;
    }

    // Primero verificamos el rol
    final userDoc = await _db.collection('users').doc(uid).get();
    final role = userDoc.data()?['role'] ?? 'caregiver';

    if (role == 'admin') {
      // Si es admin, ve TODOS los pacientes de TODOS los cuidadores
      yield* _db.collectionGroup('patients').snapshots().map((snapshot) {
        return snapshot.docs.map((doc) {
          return Patient.fromMap(doc.data() as Map<String, dynamic>, doc.id);
        }).toList();
      });
    } else {
      // Si es cuidador, solo ve los SUYOS
      yield* _userPatientsRef.snapshots().map((snapshot) {
        return snapshot.docs.map((doc) {
          return Patient.fromMap(doc.data() as Map<String, dynamic>, doc.id);
        }).toList();
      });
    }
  }

  /// Comprobar si un DNI ya existe en TODO el sistema (Búsqueda global)
  static Future<bool> checkDniExists(String dni) async {
    final query = await _db.collectionGroup('patients')
        .where('dni', isEqualTo: dni.toUpperCase())
        .get();
    return query.docs.isNotEmpty;
  }

  /// Obtener todos los pacientes (Future)
  static Future<List<Patient>> getPatients() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return [];

    final userDoc = await _db.collection('users').doc(uid).get();
    final role = userDoc.data()?['role'] ?? 'caregiver';

    if (role == 'admin') {
      final snapshot = await _db.collectionGroup('patients').get();
      return snapshot.docs.map((doc) {
        return Patient.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    } else {
      final snapshot = await _userPatientsRef.get();
      return snapshot.docs.map((doc) {
        return Patient.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    }
  }

  /// Añadir paciente
  static Future<void> addPatient(Patient patient) async {
    // Usamos el caregiverId del objeto paciente para guardarlo en el lugar correcto
    await _db
        .collection('users')
        .doc(patient.caregiverId)
        .collection('patients')
        .add(patient.toMap());
  }

  static Future<void> updatePatient(Patient patient) async {
    await _db
        .collection('users')
        .doc(patient.caregiverId)
        .collection('patients')
        .doc(patient.id)
        .update(patient.toMap());
  }

  /// Transferir paciente a otro cuidador (Mover documento)
  static Future<void> transferPatient(Patient patient, String oldCaregiverId, String newCaregiverId, String newCaregiverName) async {
    final batch = _db.batch();

    // 1. Referencia al documento antiguo
    final oldRef = _db
        .collection('users')
        .doc(oldCaregiverId)
        .collection('patients')
        .doc(patient.id);

    // 2. Referencia al documento nuevo
    final newRef = _db
        .collection('users')
        .doc(newCaregiverId)
        .collection('patients')
        .doc(patient.id);

    // 3. Crear el nuevo documento con los datos actualizados
    final updatedPatient = patient.copyWith(
      caregiverId: newCaregiverId,
      caregiverName: newCaregiverName,
    );
    batch.set(newRef, updatedPatient.toMap());

    // 4. Borrar el documento antiguo
    batch.delete(oldRef);

    // 5. ACTUALIZACIÓN CRÍTICA: Cambiar el caregiverId en sus medicaciones y citas
    // Buscamos medicaciones
    final meds = await _db.collection('medications').where('patientId', isEqualTo: patient.id).get();
    for (var doc in meds.docs) {
      batch.update(doc.reference, {'caregiverId': newCaregiverId});
    }

    // Buscamos citas
    final appts = await _db.collection('appointments').where('patientId', isEqualTo: patient.id).get();
    for (var doc in appts.docs) {
      batch.update(doc.reference, {'caregiverId': newCaregiverId});
    }

    await batch.commit();
  }

  /// Eliminar paciente y todos sus datos relacionados (Borrado en cascada)
  static Future<void> deletePatient(Patient patient) async {
    final batch = _db.batch();

    // 1. Referencia al documento del paciente
    final patientRef = _db
        .collection('users')
        .doc(patient.caregiverId)
        .collection('patients')
        .doc(patient.id);
    
    batch.delete(patientRef);

    // 2. Buscar y borrar citas ligadas a este paciente (Colección Global)
    final appointmentsQuery = await _db
        .collection('appointments')
        .where('patientId', isEqualTo: patient.id)
        .get();
    
    for (var doc in appointmentsQuery.docs) {
      batch.delete(doc.reference);
    }

    // 3. Buscar y borrar medicaciones ligadas a este paciente (Colección Global)
    final medicationsQuery = await _db
        .collection('medications')
        .where('patientId', isEqualTo: patient.id)
        .get();

    for (var doc in medicationsQuery.docs) {
      batch.delete(doc.reference);
    }

    // Ejecutar todo en una sola transacción atómica
    await batch.commit();
  }
}
