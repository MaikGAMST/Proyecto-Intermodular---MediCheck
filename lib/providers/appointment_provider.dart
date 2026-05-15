import 'dart:async';
import 'package:flutter/material.dart';
import '../models/appointment.dart';
import '../services/appointment_service.dart';
import '../services/notification_service.dart';

class AppointmentProvider extends ChangeNotifier {
  List<Appointment> _appointments = [];
  StreamSubscription? _subscription;

  List<Appointment> get appointments => List<Appointment>.from(_appointments);

  /// Iniciar escucha en tiempo real
  void startListening() {
    _subscription?.cancel();
    _subscription = AppointmentService.getAppointmentsStream().listen((appointments) {
      _appointments = appointments;
      _scheduleAllNotifications();
      notifyListeners();
    });
  }

  /// Detener escucha
  void stopListening() {
    _subscription?.cancel();
  }

  /// Obtener citas de hoy
  List<Appointment> getTodayAppointments() {
    final now = DateTime.now();
    return _appointments.where((appointment) {
      return appointment.date.year == now.year &&
          appointment.date.month == now.month &&
          appointment.date.day == now.day;
    }).toList();
  }

  /// Añadir cita
  Future<void> addAppointment(Appointment appointment) async {
    await AppointmentService.addAppointment(appointment);
  }

  /// Eliminar cita
  Future<void> removeAppointment(String id) async {
    await AppointmentService.deleteAppointment(id);
  }

  /// Actualizar cita
  Future<void> updateAppointment(Appointment updatedAppointment) async {
    await AppointmentService.updateAppointment(updatedAppointment);
  }

  /// Actualizar estado (Realizada/Retraso)
  Future<void> updateStatus(String id, String newStatus) async {
    await AppointmentService.updateAppointmentStatus(id, newStatus);
    // El stream actualizará la lista automáticamente
  }

  /// Buscar cita por id
  Appointment? getAppointmentById(String id) {
    try {
      return _appointments.firstWhere((a) => a.id == id);
    } catch (e) {
      return null;
    }
  }

  void _scheduleAllNotifications() {
    for (var appt in _appointments) {
      NotificationService.scheduleAppointmentNotification(appt);
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
