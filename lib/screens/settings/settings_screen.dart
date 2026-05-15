import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../widgets/common/app_layout.dart';
import '../../routes/app_routes.dart';
import '../../services/auth_service.dart';
import '../../services/user_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../services/storage_service.dart';
import '../../providers/patient_provider.dart';
import '../../providers/appointment_provider.dart';
import '../../providers/medication_provider.dart';
import 'dart:async';
import '../../services/maps_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool medicationNotifications = true;
  bool appointmentNotifications = true;
  bool _isUploading = false;

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );

    if (image != null) {
      setState(() => _isUploading = true);
      
      try {
        final downloadUrl = await StorageService.uploadProfilePicture(File(image.path));
        
        if (downloadUrl != null) {
          await UserService.updateUserProfile({'photoUrl': downloadUrl});
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("¡Foto de perfil actualizada!"),
                backgroundColor: Colors.green,
              ),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Error al subir la imagen. Revisa tu conexión o reglas de Firebase."),
                backgroundColor: Colors.redAccent,
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Error inesperado: ${e.toString()}"),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      } finally {
        if (mounted) setState(() => _isUploading = false);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (doc.exists && mounted) {
        final data = doc.data() as Map<String, dynamic>;
        setState(() {
          medicationNotifications = data['medicationNotifications'] ?? true;
          appointmentNotifications = data['appointmentNotifications'] ?? true;
        });
      }
    }
  }

  void _showChangePasswordDialog() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.email == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Cambiar contraseña"),
        content: Text("Se enviará un correo de restablecimiento a: \n\n${user.email}"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
          ElevatedButton(
            onPressed: () async {
              await AuthService().sendPasswordResetEmail(user.email!);
              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Email enviado correctamente"), backgroundColor: Colors.green),
                );
              }
            },
            child: const Text("Enviar"),
          ),
        ],
      ),
    );
  }

  void _showChangeEmailDialog() {
    final emailController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Cambiar Email"),
        content: TextField(
          controller: emailController,
          decoration: const InputDecoration(labelText: "Nuevo Email"),
          keyboardType: TextInputType.emailAddress,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
          ElevatedButton(
            onPressed: () async {
              final newEmail = emailController.text.trim();
              if (newEmail.isEmpty) return;
              try {
                await FirebaseAuth.instance.currentUser?.verifyBeforeUpdateEmail(newEmail);
                await UserService.updateUserProfile({'email': newEmail});
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Email de verificación enviado al nuevo correo"), backgroundColor: Colors.green),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Error: Reautenticación necesaria"), backgroundColor: Colors.redAccent),
                  );
                }
              }
            },
            child: const Text("Actualizar"),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicy() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Política de Privacidad"),
        content: const SingleChildScrollView(
          child: Text(
            "En MediCheck, tu privacidad es nuestra prioridad. \n\n"
            "1. Protección de Datos: Todos tus datos clínicos y personales están cifrados en nuestros servidores de Firebase.\n\n"
            "2. Uso de la Información: Solo utilizamos tus datos para proporcionarte recordatorios de salud y gestionar tus pacientes.\n\n"
            "3. Terceros: No compartimos tu información con ninguna entidad externa sin tu consentimiento explícito.\n\n"
            "4. Derechos: Puedes solicitar la eliminación total de tu cuenta y datos en cualquier momento desde esta aplicación.",
            textAlign: TextAlign.justify,
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Entendido")),
        ],
      ),
    );
  }

  Future<void> _showEditProfileDialog(Map<String, dynamic> userData) async {
    final nameController = TextEditingController(text: userData['name']);
    final surnameController = TextEditingController(text: userData['surname']);
    final localityController = TextEditingController(text: userData['locality'] ?? userData['province'] ?? '');
    
    List<Map<String, String>> fhirResults = [];
    bool isSearching = false;
    Timer? debounce;
    String selectedLocality = userData['locality'] ?? userData['province'] ?? '';

    return showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text("Editar Información"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: "Nombre"),
                ),
                TextField(
                  controller: surnameController,
                  decoration: const InputDecoration(labelText: "Apellidos"),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: localityController,
                  decoration: const InputDecoration(
                    labelText: "Localidad (Google Maps)",
                    suffixIcon: Icon(Icons.location_on, size: 18),
                  ),
                  onChanged: (query) {
                    if (debounce?.isActive ?? false) debounce?.cancel();
                    if (query.length < 3) {
                      setDialogState(() => fhirResults = []);
                      return;
                    }
                    debounce = Timer(const Duration(milliseconds: 600), () async {
                      setDialogState(() => isSearching = true);
                      final results = await MapsService.searchLocalities(query);
                      setDialogState(() {
                        fhirResults = results;
                        isSearching = false;
                      });
                    });
                  },
                ),
                if (isSearching)
                  const Padding(padding: EdgeInsets.all(8.0), child: LinearProgressIndicator()),
                
                if (fhirResults.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 5),
                    constraints: const BoxConstraints(maxHeight: 150),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: fhirResults.length,
                      itemBuilder: (context, index) {
                        final res = fhirResults[index];
                        return ListTile(
                          dense: true,
                          title: Text(res['description']!, style: const TextStyle(fontSize: 12)),
                          onTap: () {
                            setDialogState(() {
                              selectedLocality = res['description']!;
                              localityController.text = res['description']!;
                              fhirResults = [];
                            });
                          },
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                debounce?.cancel();
                Navigator.pop(context);
              },
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () async {
                debounce?.cancel();
                await UserService.updateUserProfile({
                  'name': nameController.text.trim(),
                  'surname': surnameController.text.trim(),
                  'locality': selectedLocality.isNotEmpty ? selectedLocality : localityController.text.trim(),
                });
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text("Guardar"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      child: Container(
        color: const Color(0xFF2F9C9C),
        width: double.infinity,

        child: Column(
          children: [
            const SizedBox(height: 20),

            /// PERFIL DEL USUARIO
            StreamBuilder<DocumentSnapshot>(
              stream: UserService.getUserProfileStream(),
              builder: (context, snapshot) {
                String name = "...";
                String email = "...";
                String province = "...";
                String? photoUrl;

                if (snapshot.hasData && snapshot.data!.exists) {
                  final data = snapshot.data!.data() as Map<String, dynamic>;
                  name = "${data['name'] ?? ''} ${data['surname'] ?? ''}";
                  email = data['email'] ?? "...";
                  province = data['locality'] ?? data['province'] ?? "...";
                  photoUrl = data['photoUrl'];
                }

                return Column(
                  children: [
                    GestureDetector(
                      onTap: _isUploading ? null : _pickAndUploadImage,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: Colors.white,
                            backgroundImage: photoUrl != null 
                                ? NetworkImage(photoUrl) 
                                : null,
                            child: photoUrl == null 
                                ? const Icon(Icons.person, size: 50, color: Color(0xFF2F9C9C))
                                : null,
                          ),
                          if (_isUploading)
                            const CircularProgressIndicator(color: Colors.white),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.camera_alt, size: 16, color: Color(0xFF2F9C9C)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      "$email • $province",
                      style: const TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                    const SizedBox(height: 15),
                    ElevatedButton.icon(
                      onPressed: () => _showEditProfileDialog(
                        snapshot.data!.data() as Map<String, dynamic>,
                      ),
                      icon: const Icon(Icons.edit, size: 16),
                      label: const Text("Editar Perfil"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.2),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 30),

            const Text(
              "Opciones",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),

                children: [
                  sectionTitle("Cuenta"),

                  buildOption(
                    icon: Icons.lock_outline,
                    text: "Cambiar contraseña",
                    onTap: _showChangePasswordDialog,
                  ),

                  buildOption(
                    icon: Icons.email_outlined,
                    text: "Cambiar email",
                    onTap: _showChangeEmailDialog,
                  ),

                  const SizedBox(height: 20),

                  sectionTitle("Notificaciones"),

                  buildSwitchOption(
                    icon: Icons.medication_outlined,
                    text: "Recordatorios de medicación",
                    value: medicationNotifications,
                    onChanged: (value) async {
                      setState(() => medicationNotifications = value);
                      await UserService.updateUserProfile({'medicationNotifications': value});
                    },
                  ),

                  buildSwitchOption(
                    icon: Icons.calendar_month_outlined,
                    text: "Recordatorios de citas",
                    value: appointmentNotifications,
                    onChanged: (value) async {
                      setState(() => appointmentNotifications = value);
                      await UserService.updateUserProfile({'appointmentNotifications': value});
                    },
                  ),

                  const SizedBox(height: 20),

                  sectionTitle("Información"),

                  buildOption(
                    icon: Icons.info_outline,
                    text: "Sobre MediCheck",
                    onTap: () {
                      showAboutDialog(
                        context: context,
                        applicationName: "MediCheck",
                        applicationVersion: "1.0.0",
                        applicationLegalese: "© 2026 MediCheck Team",
                        applicationIcon: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.asset("assets/logo.png", height: 60),
                        ),
                        children: const [
                          SizedBox(height: 15),
                          Text(
                            "MediCheck es la solución integral para el cuidado de la salud de personas dependientes.",
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                          ),
                          SizedBox(height: 10),
                          Text(
                            "Gestiona medicaciones, citas médicas y seguridad clínica con estándares profesionales HL7 FHIR y validación FDA.",
                            style: TextStyle(fontSize: 13),
                          ),
                        ],
                      );
                    },
                  ),

                  buildOption(
                    icon: Icons.privacy_tip_outlined,
                    text: "Política de privacidad",
                    onTap: _showPrivacyPolicy,
                  ),

                  const SizedBox(height: 30),

                  Center(child: logoutButton(context)),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// TITULO DE SECCIÓN
  Widget sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),

      child: Text(
        text,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  /// OPCIÓN NORMAL
  Widget buildOption({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 2,

      child: ListTile(
        leading: Icon(icon),
        title: Text(text),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  /// OPCIÓN CON SWITCH
  Widget buildSwitchOption({
    required IconData icon,
    required String text,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),

      child: SwitchListTile(
        secondary: Icon(icon),
        title: Text(text),
        value: value,
        onChanged: onChanged,
      ),
    );
  }

  /// BOTÓN CERRAR SESIÓN
  Widget logoutButton(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        // Mostrar diálogo de confirmación (opcional pero recomendado)
        final confirm = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Cerrar sesión"),
            content: const Text("¿Estás seguro de que quieres salir?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Cancelar"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text("Salir", style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        );

        if (confirm == true) {
          // 1. Detener escuchas de los providers
          Provider.of<PatientProvider>(context, listen: false).stopListening();
          Provider.of<AppointmentProvider>(context, listen: false).stopListening();
          Provider.of<MedicationProvider>(context, listen: false).stopListening();

          // 2. Cerrar sesión en Firebase
          await AuthService().signOut();

          // 3. Ir al login
          if (context.mounted) {
            Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (route) => false);
          }
        }
      },

      child: Container(
        width: 200,
        height: 45,

        decoration: BoxDecoration(
          color: const Color(0xFFE74C3C),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.black, width: 1.5),
        ),

        child: const Center(
          child: Text(
            "Cerrar sesión",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
