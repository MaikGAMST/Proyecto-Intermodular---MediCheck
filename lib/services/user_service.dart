import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Obtener los datos del perfil del usuario actual
  static Stream<DocumentSnapshot> getUserProfileStream() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception("Usuario no autenticado");
    return _db.collection('users').doc(uid).snapshots();
  }

  /// Actualizar datos del perfil
  static Future<void> updateUserProfile(Map<String, dynamic> data) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception("Usuario no autenticado");
    await _db.collection('users').doc(uid).update(data);
  }

  /// Obtener el rol del usuario actual
  static Future<String> getUserRole() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return 'caregiver';
    
    final doc = await _db.collection('users').doc(uid).get();
    if (doc.exists) {
      return (doc.data() as Map<String, dynamic>)['role'] ?? 'caregiver';
    }
    return 'caregiver';
  }

  /// Obtener todos los datos de un usuario por su UID
  static Future<Map<String, dynamic>?> getUserData(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (doc.exists) {
      return {
        'id': doc.id,
        ...doc.data() as Map<String, dynamic>
      };
    }
    return null;
  }

  /// Actualizar el estado de activación de un usuario (Solo Admin)
  static Future<void> updateUserStatus(String uid, bool isActive) async {
    await _db.collection('users').doc(uid).update({'isActive': isActive});
  }

  /// Obtener todos los usuarios registrados (Cuidadores)
  static Future<List<Map<String, dynamic>>> getAllUsers() async {
    final snapshot = await _db.collection('users').get();
    return snapshot.docs.map((doc) => {
      'id': doc.id,
      ...doc.data() as Map<String, dynamic>
    }).toList();
  }
}
