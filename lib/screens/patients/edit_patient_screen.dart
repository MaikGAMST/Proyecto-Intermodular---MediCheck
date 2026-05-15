import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/common/app_layout.dart';
import '../../models/patient.dart';
import '../../providers/patient_provider.dart';
import '../../services/user_service.dart';

class EditPatientScreen extends StatefulWidget {
  const EditPatientScreen({super.key});

  @override
  State<EditPatientScreen> createState() => _EditPatientScreenState();
}

class _EditPatientScreenState extends State<EditPatientScreen> {
  late TextEditingController nameController;
  late TextEditingController surnameController;
  late TextEditingController dniController;
  late TextEditingController ageController;
  late TextEditingController notesController;
  late TextEditingController allergiesController;

  String? _selectedGender;
  String? _selectedBloodType;
  String? _selectedCaregiverId;
  String? _selectedCaregiverName;

  final List<String> _genders = ["Hombre", "Mujer", "Otro"];
  final List<String> _bloodTypes = ["A+", "A-", "B+", "B-", "AB+", "AB-", "O+", "O-"];

  bool _initialized = false;
  List<Map<String, dynamic>> _allCaregivers = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final patient = ModalRoute.of(context)!.settings.arguments as Patient;
      nameController = TextEditingController(text: patient.name);
      surnameController = TextEditingController(text: patient.surname);
      dniController = TextEditingController(text: patient.dni);
      ageController = TextEditingController(text: patient.age.toString());
      notesController = TextEditingController(text: patient.notes);
      allergiesController = TextEditingController(text: patient.allergies);
      _selectedGender = _genders.contains(patient.gender) ? patient.gender : _genders[0];
      _selectedBloodType = _bloodTypes.contains(patient.bloodType) ? patient.bloodType : _bloodTypes[0];
      _selectedCaregiverId = patient.caregiverId;
      _selectedCaregiverName = patient.caregiverName;
      
      _loadCaregivers();
      _initialized = true;
    }
  }

  Future<void> _loadCaregivers() async {
    final users = await UserService.getAllUsers();
    setState(() {
      _allCaregivers = users;
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    surnameController.dispose();
    dniController.dispose();
    ageController.dispose();
    notesController.dispose();
    allergiesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final patient = ModalRoute.of(context)!.settings.arguments as Patient;

    return AppLayout(
      child: Container(
        color: const Color(0xFF2F9C9C),
        width: double.infinity,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("EDITAR PACIENTE", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 20)),
              const Divider(color: Colors.white54),
              const SizedBox(height: 10),

              buildLabel("Nombre"),
              buildInput("Ej: Juan", nameController),
              const SizedBox(height: 15),

              buildLabel("Apellidos"),
              buildInput("Ej: García Pérez", surnameController),
              const SizedBox(height: 15),

              buildLabel("DNI / NIE"),
              buildInput("Ej: 12345678X", dniController),
              const SizedBox(height: 15),

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildLabel("Edad"),
                        buildInput("Ej: 75", ageController, isNumber: true),
                      ],
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildLabel("Sexo"),
                        buildDropdown(_genders, _selectedGender!, (val) => setState(() => _selectedGender = val!)),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 25),
              const Text("DATOS MÉDICOS", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
              const Divider(color: Colors.white54),
              const SizedBox(height: 10),

              buildLabel("Grupo Sanguíneo"),
              buildDropdown(_bloodTypes, _selectedBloodType!, (val) => setState(() => _selectedBloodType = val!)),
              const SizedBox(height: 15),

              buildLabel("Alergias"),
              buildInput("Alergias...", allergiesController),
              const SizedBox(height: 15),

              const SizedBox(height: 10),
              const Text("CUIDADOR RESPONSABLE", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
              const Divider(color: Colors.white54),
              const SizedBox(height: 10),
              
              buildLabel("Seleccionar Cuidador"),
              Container(
                height: 45,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6)),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedCaregiverId,
                    isExpanded: true,
                    hint: const Text("Seleccionar cuidador"),
                    items: _allCaregivers.map((user) {
                      return DropdownMenuItem<String>(
                        value: user['id'],
                        child: Text(user['name'] ?? 'Sin nombre'),
                      );
                    }).toList(),
                    onChanged: (val) {
                      final selectedUser = _allCaregivers.firstWhere((u) => u['id'] == val);
                      setState(() {
                        _selectedCaregiverId = val;
                        _selectedCaregiverName = selectedUser['name'];
                      });
                    },
                  ),
                ),
              ),

              const SizedBox(height: 25),
              buildLabel("Notas Médicas"),
              buildTextArea(),

              const SizedBox(height: 40),
              Center(
                child: GestureDetector(
                  onTap: () {
                    final dni = dniController.text.trim().toUpperCase();
                    final existingPatients = context.read<PatientProvider>().patients;
                    if (existingPatients.any((p) => p.dni == dni && p.id != patient.id)) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("DNI duplicado"), backgroundColor: Colors.redAccent));
                      return;
                    }

                    final updatedPatient = patient.copyWith(
                      name: nameController.text.trim(),
                      surname: surnameController.text.trim(),
                      dni: dni,
                      age: int.tryParse(ageController.text) ?? 0,
                      gender: _selectedGender,
                      bloodType: _selectedBloodType,
                      notes: notesController.text.trim(),
                      allergies: allergiesController.text.trim(),
                      caregiverId: _selectedCaregiverId,
                      caregiverName: _selectedCaregiverName,
                    );

                    if (_selectedCaregiverId != patient.caregiverId) {
                      // Si el cuidador ha cambiado, realizamos una transferencia (mover doc)
                      context.read<PatientProvider>().transferPatient(
                        patient, 
                        patient.caregiverId, 
                        _selectedCaregiverId!, 
                        _selectedCaregiverName!
                      );
                    } else {
                      // Si es el mismo cuidador, solo actualizamos los datos
                      context.read<PatientProvider>().updatePatient(updatedPatient);
                    }
                    
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: double.infinity,
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE74C3C),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4, offset: const Offset(0, 2))],
                    ),
                    child: const Center(
                      child: Text("GUARDAR CAMBIOS", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildLabel(String text) => Padding(padding: const EdgeInsets.only(bottom: 6), child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)));

  Widget buildInput(String hint, TextEditingController controller, {bool isNumber = false}) {
    return Container(
      height: 45,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6)),
      child: TextField(controller: controller, keyboardType: isNumber ? TextInputType.number : TextInputType.text, decoration: InputDecoration(hintText: hint, border: InputBorder.none, hintStyle: const TextStyle(fontSize: 14))),
    );
  }

  Widget buildDropdown(List<String> items, String currentVal, Function(String?) onChanged) {
    return Container(
      height: 45,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: currentVal,
          isExpanded: true,
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 14)))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget buildTextArea() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6)),
      child: TextField(controller: notesController, maxLines: 3, decoration: const InputDecoration(hintText: "Notas...", border: InputBorder.none, hintStyle: TextStyle(fontSize: 14))),
    );
  }
}
