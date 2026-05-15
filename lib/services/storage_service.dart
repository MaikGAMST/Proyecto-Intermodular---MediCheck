import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StorageService {
  static final FirebaseStorage _storage = FirebaseStorage.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Subir una imagen de perfil y devolver la URL de descarga
  static Future<String?> uploadProfilePicture(File imageFile) async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) return null;

      // Ruta en el storage: profiles/uid.jpg
      final ref = _storage.ref().child('profiles').child('$uid.jpg');
      
      // Subir archivo
      await ref.putFile(imageFile);

      // Obtener URL
      final downloadUrl = await ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print("Error al subir imagen: $e");
      return null;
    }
  }
}
