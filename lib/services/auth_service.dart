import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Stream de estado de autenticación
  Stream<User?> get user => _auth.authStateChanges();

  // Registro con Email y Contraseña
  Future<User?> registerWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } on FirebaseAuthException catch (e) {
      // Lanzamos la excepción para que la UI pueda mostrar el mensaje específico
      rethrow;
    } catch (e) {
      throw Exception("Error inesperado en el registro: ${e.toString()}");
    }
  }

  // Inicio de Sesión con Email y Contraseña
  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('No se encontró ningún usuario para ese email.');
      } else if (e.code == 'wrong-password') {
        print('Contraseña incorrecta.');
      }
      print("Error en login: ${e.message}");
      return null;
    } catch (e) {
      print("Error en login: ${e.toString()}");
      return null;
    }
  }

  // Cerrar Sesión
  Future<void> signOut() async {
    try {
      return await _auth.signOut();
    } catch (e) {
      print("Error al cerrar sesión: ${e.toString()}");
    }
  }

  // Recuperar Contraseña
  Future<bool> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return true;
    } catch (e) {
      print("Error al enviar email de recuperación: ${e.toString()}");
      return false;
    }
  }
}
