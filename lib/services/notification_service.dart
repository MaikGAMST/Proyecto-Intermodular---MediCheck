import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'dart:typed_data';
import '../models/medication.dart';
import '../models/appointment.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  static Future<void> init() async {
    try {
      tz.initializeTimeZones();
      
      // Configuración Local Notifications
      const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
      const InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid);

      await _notificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          // Manejar clic en la notificación
        },
      );

      // Configuración Firebase Messaging (Push) - No bloqueamos el inicio por esto
      _initFCM();
    } catch (e) {
      print("Error inicializando NotificationService: $e");
    }
  }

  static Future<void> _initFCM() async {
    try {
      NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      print('User granted permission: ${settings.authorizationStatus}');

      // Obtener token
      String? token = await _messaging.getToken();
      print("FCM Token: $token");

      // Manejar mensajes en primer plano
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        if (message.notification != null) {
          showNotification(
            id: message.hashCode,
            title: message.notification!.title ?? "Mensaje de MediCheck",
            body: message.notification!.body ?? "",
          );
        }
      });
    } catch (e) {
      print("Error inicializando FCM: $e");
    }
  }

  /// Mostrar notificación inmediata
  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'medicheck_channel',
      'MediCheck Alerts',
      channelDescription: 'Canal principal de alertas de MediCheck',
      importance: Importance.max,
      priority: Priority.high,
      vibrationPattern: Int64List.fromList([0, 500, 200, 500]),
    );

    final NotificationDetails details = NotificationDetails(android: androidDetails);
    await _notificationsPlugin.show(id, title, body, details);
  }

  /// Programar notificaciones de una medicación para las próximas 48h
  static Future<void> scheduleMedicationNotifications(Medication medication) async {
    final now = DateTime.now();
    
    for (String timeStr in medication.intakeTimes) {
      final parts = timeStr.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);

      for (int i = 0; i < 2; i++) { // Hoy y mañana
        DateTime scheduledDate = DateTime(now.year, now.month, now.day + i, hour, minute);
        
        // Si ya pasó hoy, no programar
        if (scheduledDate.isBefore(now)) continue;
        // Si está fuera del rango del tratamiento, no programar
        if (scheduledDate.isAfter(medication.endDate)) continue;

        // ID único combinando hash de med y el tiempo
        int notifyId = medication.id.hashCode + scheduledDate.hashCode;

        await _notificationsPlugin.zonedSchedule(
          notifyId,
          "Hora de la toma: ${medication.name}",
          "Paciente: ${medication.patientName}. Dosis: ${medication.dosage}.",
          tz.TZDateTime.from(scheduledDate, tz.local),
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'medicheck_meds_channel',
              'Recordatorios Medicación',
              importance: Importance.max,
              priority: Priority.high,
            ),
          ),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        );
      }
    }
  }

  /// Programar aviso de cita médica (30 min antes)
  static Future<void> scheduleAppointmentNotification(Appointment appointment) async {
    final now = DateTime.now();
    final parts = appointment.time.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);

    DateTime appointmentDateTime = DateTime(
      appointment.date.year,
      appointment.date.month,
      appointment.date.day,
      hour,
      minute,
    );

    DateTime scheduledDate = appointmentDateTime.subtract(const Duration(minutes: 30));

    if (scheduledDate.isBefore(now)) return;

    await _notificationsPlugin.zonedSchedule(
      appointment.id.hashCode,
      "Cita médica próxima",
      "Paciente: ${appointment.patientName} en ${appointment.place} a las ${appointment.time}",
      tz.TZDateTime.from(scheduledDate, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'medicheck_appts_channel',
          'Recordatorios Citas',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  /// Cancelar todo (útil al cerrar sesión o refrescar)
  static Future<void> cancelAll() async {
    await _notificationsPlugin.cancelAll();
  }
}
