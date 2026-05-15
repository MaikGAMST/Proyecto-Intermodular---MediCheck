import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';

import 'routes/app_routes.dart';

// Providers
import 'providers/patient_provider.dart';
import 'providers/medication_provider.dart';
import 'providers/appointment_provider.dart';

import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await NotificationService.init();
  runApp(const MediCheckApp());
}

class MediCheckApp extends StatefulWidget {
  const MediCheckApp({super.key});

  @override
  State<MediCheckApp> createState() => _MediCheckAppState();
}

class _MediCheckAppState extends State<MediCheckApp> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PatientProvider()),
        ChangeNotifierProvider(create: (_) => MedicationProvider()),
        ChangeNotifierProvider(create: (_) => AppointmentProvider()),
      ],
      child: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          final user = snapshot.data;
          
          if (user != null) {
            // Iniciar escuchas si hay usuario
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Provider.of<PatientProvider>(context, listen: false).startListening();
              Provider.of<AppointmentProvider>(context, listen: false).startListening();
              Provider.of<MedicationProvider>(context, listen: false).startListeningAll();
            });
          }

          return MaterialApp(
            title: 'MediCheck',
            debugShowCheckedModeBanner: false,
            initialRoute: user != null ? AppRoutes.home : AppRoutes.splash,
            routes: AppRoutes.routes,
            theme: ThemeData(primarySwatch: Colors.deepPurple),
          );
        },
      ),
    );
  }
}
