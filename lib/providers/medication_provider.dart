import 'dart:async';
import 'package:flutter/material.dart';
import '../models/medication.dart';
import '../services/medication_service.dart';
import '../services/notification_service.dart';

class MedicationProvider extends ChangeNotifier {
  List<Medication> _medications = [];
  List<String> _todayIntakeIds = []; // IDs de medicaciones tomadas hoy
  StreamSubscription? _subscription;
  StreamSubscription? _intakeSubscription;
  String? _currentPatientId;

  List<Medication> get medications => _medications;
  List<String> get todayIntakeIds => _todayIntakeIds;

  /// Iniciar escucha de todas las medicaciones y de las tomas de hoy
  void startListeningAll() {
    _currentPatientId = null;
    _subscription?.cancel();
    _intakeSubscription?.cancel();

    _subscription = MedicationService.getAllMedicationsStream().listen((meds) {
      _medications = meds;
      _scheduleAllNotifications();
      notifyListeners();
    });

    _intakeSubscription = MedicationService.getTodayIntakesStream().listen((ids) {
      _todayIntakeIds = ids;
      notifyListeners();
    });
  }

  /// Iniciar escucha de medicaciones de un paciente
  void startListeningPatient(String patientId) {
    _currentPatientId = patientId;
    _subscription?.cancel();
    _subscription = MedicationService.getMedicationsByPatientStream(patientId).listen((meds) {
      _medications = meds;
      _scheduleAllNotifications();
      notifyListeners();
    });
  }
  /// Registrar toma
  Future<void> confirmIntake(Medication medication, String caregiverName) async {
    await MedicationService.registerIntake(medication, caregiverName);
    // El stream de hoy actualizará automáticamente la UI
  }

  /// Detener escucha
  void stopListening() {
    _subscription?.cancel();
    _intakeSubscription?.cancel();
  }

  /// Cargar medicaciones próximas (para el Home)
  Future<void> loadUpcomingMedications() async {
    _currentPatientId = null;
    _medications = await MedicationService.getUpcomingMedications();
    notifyListeners();
  }

  /// Añadir medicación
  Future<void> addMedication(Medication medication) async {
    await MedicationService.addMedication(medication);
  }

  /// Actualizar medicación
  Future<void> updateMedication(Medication medication) async {
    await MedicationService.updateMedication(medication);
  }

  /// Eliminar medicación
  Future<void> deleteMedication(String id) async {
    await MedicationService.deleteMedication(id);
  }

  void _scheduleAllNotifications() {
    for (var med in _medications) {
      NotificationService.scheduleMedicationNotifications(med);
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
