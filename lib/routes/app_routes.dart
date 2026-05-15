import 'package:flutter/material.dart';
import '../screens/auth/splash_screen.dart';

import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/terms_screen.dart';
import '../screens/auth/recover_password_screen.dart';

import '../screens/home/home_screen.dart';

import '../screens/patients/patients_list_screen.dart';
import '../screens/patients/patient_detail_screen.dart';
import '../screens/patients/add_patient_screen.dart';

import '../screens/medications/medications_list_screen.dart';
import '../screens/medications/add_medication_screen.dart';
import '../screens/medications/edit_medication_screen.dart';

import '../screens/emergency/emergency_screen.dart';
import '../screens/appointments/appointments_screen.dart';
import '../screens/settings/settings_screen.dart';

import '../screens/patients/edit_patient_screen.dart';
import '../screens/appointments/edit_appointment_screen.dart';
import '../screens/appointments/add_appointment_screen.dart';

import '../screens/appointments/agenda_screen.dart';
import '../screens/admin/admin_dashboard_screen.dart';
import '../screens/admin/caregivers_list_screen.dart';
import '../screens/admin/incidences_screen.dart';


// Clase donde centralizo todas las rutas de la aplicación
// Así evito tener rutas escritas por todo el proyecto
class AppRoutes {
  // ----------------------------
  // NOMBRES DE LAS RUTAS
  // ----------------------------

  // Pantalla inicial (login)
  static const String login = "/";

  // Pantalla principal después de iniciar sesión
  static const String home = "/home";

  // Lista de pacientes
  static const String patients = "/patients";

  // Detalle de un paciente
  static const String patientDetail = "/patientDetail";

  // Formulario para crear un paciente
  static const String addPatient = "/addPatient";

  // Lista de medicaciones de un paciente
  static const String medications = "/medications";

  // Formulario para añadir medicación
  static const String addMedication = "/addMedication";

  // Editar una medicación existente
  static const String editMedication = "/editMedication";

  // Pantalla del botón de emergencia
  static const String emergency = "/emergency";

  // Pantalla inicial de carga
  static const String splash = "/splash";

  // Registro
  static const String register = "/register";

  // Términos y condiciones
  static const String terms = "/terms";

  // Recuperar contraseña
  static const String recoverPassword = "/recoverPassword";

  // Citas médicas
  static const String appointments = "/appointments";

  // Configuración
  static const String settings = "/settings";

  // Editar paciente
  static const String editPatient = "/editPatient";

  // Editar cita médica
  static const String editAppointment = "/editAppointment";

  // Añadir cita médica
  static const String addAppointment = "/addAppointment";

  // Agenda médica general
  static const String agenda = "/agenda";

  // Panel de administración
  static const String adminHome = "/adminHome";
  static const String adminCaregivers = "/adminCaregivers";
  static const String adminIncidences = "/adminIncidences";

  // ----------------------------
  // MAPA DE RUTAS
  // ----------------------------
  // Aquí relacionamos cada ruta con su pantalla

  static Map<String, WidgetBuilder> routes = {
    // Login
    login: (context) => const LoginScreen(),

    // Menú principal
    home: (context) => const HomeScreen(),

    // Lista de pacientes
    patients: (context) => const PatientsListScreen(),

    // Pantalla de detalle de paciente
    patientDetail: (context) => const PatientDetailScreen(),

    // Crear paciente
    addPatient: (context) => const AddPatientScreen(),

    // Medicaciones del paciente
    medications: (context) => const MedicationsListScreen(),

    // Añadir medicación
    addMedication: (context) => const AddMedicationScreen(),

    // Editar medicación
    editMedication: (context) => const EditMedicationScreen(),

    // Pantalla de emergencia
    emergency: (context) => const EmergencyScreen(),

    // Pantalla de carga inicial
    splash: (context) => const SplashScreen(),

    //Pantalla de registro
    register: (context) => const RegisterScreen(),

    //Términos y condiciones
    terms: (context) => const TermsScreen(),

    //Pantalla de recuperación de contraseña
    recoverPassword: (context) => const RecoverPasswordScreen(),

    // Citas médicas
    appointments: (context) => const AppointmentsScreen(),

    // Configuración
    settings: (context) => const SettingsScreen(),
    
    // Editar paciente
    editPatient: (context) => const EditPatientScreen(),

    // Editar cita médica
    editAppointment: (context) => const EditAppointmentScreen(),

    // Añadir cita médica
    addAppointment: (context) => const AddAppointmentScreen(),

    // Agenda médica general
    agenda: (context) => const AgendaScreen(),

    // Panel de administración
    adminHome: (context) => const AdminDashboardScreen(),
    adminCaregivers: (context) => const CaregiversListScreen(),
    adminIncidences: (context) => const IncidencesScreen(),
  };
}
