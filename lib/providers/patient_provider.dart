import 'dart:async';
import 'package:flutter/material.dart';
import '../models/patient.dart';
import '../services/patient_service.dart';

class PatientProvider extends ChangeNotifier {
  List<Patient> _patients = [];
  StreamSubscription? _subscription;

  List<Patient> get patients => _patients;

  /// Iniciar escucha en tiempo real
  void startListening() {
    _subscription?.cancel();
    _subscription = PatientService.getPatientsStream().listen((patients) {
      _patients = patients;
      notifyListeners();
    });
  }

  /// Detener escucha
  void stopListening() {
    _subscription?.cancel();
  }

  /// Cargar pacientes (una sola vez)
  Future<void> loadPatients() async {
    _patients = await PatientService.getPatients();
    notifyListeners();
  }

  /// Añadir paciente
  Future<void> addPatient(Patient patient) async {
    await PatientService.addPatient(patient);
    // No hace falta recargar manualmente si usamos streams
  }

  /// Actualizar paciente
  Future<void> updatePatient(Patient patient) async {
    await PatientService.updatePatient(patient);
  }

  /// Transferir paciente
  Future<void> transferPatient(Patient patient, String oldCaregiverId, String newCaregiverId, String newCaregiverName) async {
    await PatientService.transferPatient(patient, oldCaregiverId, newCaregiverId, newCaregiverName);
  }

  /// Eliminar paciente
  Future<void> deletePatient(Patient patient) async {
    await PatientService.deletePatient(patient);
  }

  /// Buscar paciente por ID
  Patient? getPatientById(String id) {
    try {
      return _patients.firstWhere((patient) => patient.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
