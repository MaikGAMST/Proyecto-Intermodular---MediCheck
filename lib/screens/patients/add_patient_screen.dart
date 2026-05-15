import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../widgets/common/app_layout.dart';
import '../../providers/patient_provider.dart';
import '../../models/patient.dart';
import '../../services/user_service.dart';
import '../../services/patient_service.dart';
import '../../services/fhir_service.dart';

class AddPatientScreen extends StatefulWidget {
  const AddPatientScreen({super.key});

  @override
  State<AddPatientScreen> createState() => _AddPatientScreenState();
}

class _AddPatientScreenState extends State<AddPatientScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController surnameController = TextEditingController();
  final TextEditingController dniController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController notesController = TextEditingController();
  final TextEditingController allergiesController = TextEditingController();

  String _selectedGender = "Hombre";
  String _selectedBloodType = "A+";
  
  // Variables para el Admin
  bool _isAdmin = false;
  List<Map<String, dynamic>> _caregivers = [];
  Map<String, dynamic>? _selectedCaregiver;
  bool _isLoadingRole = true;

  // Variables para FHIR
  List<Map<String, String>> _fhirResults = [];
  bool _isSearchingAllergies = false;
  Timer? _debounce;
  final List<String> _selectedAllergies = [];

  final List<String> _genders = ["Hombre", "Mujer", "Otro"];
  final List<String> _bloodTypes = ["A+", "A-", "B+", "B-", "AB+", "AB-", "O+", "O-"];

  @override
  void initState() {
    super.initState();
    _checkRole();
  }

  Future<void> _checkRole() async {
    final role = await UserService.getUserRole();
    if (role == 'admin') {
      final users = await UserService.getAllUsers();
      setState(() {
        _isAdmin = true;
        _caregivers = users.where((u) => u['role'] != 'admin').toList();
        _isLoadingRole = false;
      });
    } else {
      setState(() => _isLoadingRole = false);
    }
  }

  void _searchFhirAllergies(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    
    if (query.length < 3) {
      setState(() => _fhirResults = []);
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 600), () async {
      setState(() => _isSearchingAllergies = true);
      final results = await FhirService.searchAllergies(query);
      if (mounted) {
        setState(() {
          _fhirResults = results;
          _isSearchingAllergies = false;
        });
      }
    });
  }

  void _addAllergy(String name) {
    if (!_selectedAllergies.contains(name)) {
      setState(() {
        _selectedAllergies.add(name);
        allergiesController.clear();
        _fhirResults = [];
      });
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    surnameController.dispose();
    dniController.dispose();
    ageController.dispose();
    notesController.dispose();
    allergiesController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingRole) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return AppLayout(
      child: Container(
        width: double.infinity,
        color: const Color(0xFF2F9C9C),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("DATOS PERSONALES", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18)),
              const Divider(color: Colors.white54),
              const SizedBox(height: 10),

              if (_isAdmin) ...[
                buildLabel("ASIGNAR A CUIDADOR"),
                buildCaregiverDropdown(),
                const SizedBox(height: 20),
              ],

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
                        buildDropdown(_genders, _selectedGender, (val) => setState(() => _selectedGender = val!)),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),
              const Text("DATOS MÉDICOS", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18)),
              const Divider(color: Colors.white54),
              const SizedBox(height: 10),

              buildLabel("Grupo Sanguíneo"),
              buildDropdown(_bloodTypes, _selectedBloodType, (val) => setState(() => _selectedBloodType = val!)),
              const SizedBox(height: 15),

              /// SECCIÓN ALERGIAS FHIR
              buildLabel("Alergias e Intolerancias (Buscador FHIR)"),
              buildSearchInput("Buscar alergia (ej: Penicilina, Lactosa...)", allergiesController, _searchFhirAllergies),
              
              if (_isSearchingAllergies)
                const Padding(padding: EdgeInsets.all(8.0), child: Center(child: CircularProgressIndicator(color: Colors.white))),

              if (_fhirResults.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(top: 5),
                  constraints: const BoxConstraints(maxHeight: 200),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _fhirResults.length,
                    itemBuilder: (context, index) {
                      final item = _fhirResults[index];
                      return ListTile(
                        dense: true,
                        leading: const Icon(Icons.warning_amber_rounded, color: Colors.red),
                        title: Text(item['display']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                        onTap: () => _addAllergy(item['display']!),
                      );
                    },
                  ),
                ),

              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                children: _selectedAllergies.map((a) => Chip(
                  label: Text(a, style: const TextStyle(color: Colors.white, fontSize: 12)),
                  backgroundColor: const Color(0xFFE74C3C),
                  onDeleted: () => setState(() => _selectedAllergies.remove(a)),
                  deleteIconColor: Colors.white,
                )).toList(),
              ),

              const SizedBox(height: 15),

              buildLabel("Notas adicionales"),
              buildTextArea(),

              const SizedBox(height: 40),
              Center(child: buildSaveButton(context)),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildCaregiverDropdown() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Map<String, dynamic>>(
          hint: const Text("Seleccionar cuidador"),
          value: _selectedCaregiver,
          isExpanded: true,
          items: _caregivers.map((cg) => DropdownMenuItem(
            value: cg,
            child: Text("${cg['name']} ${cg['surname']} (${cg['email']})"),
          )).toList(),
          onChanged: (val) => setState(() => _selectedCaregiver = val),
        ),
      ),
    );
  }

  Widget buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
    );
  }

  Widget buildInput(String hint, TextEditingController controller, {bool isNumber = false}) {
    return Container(
      height: 45,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6)),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(hintText: hint, border: InputBorder.none),
      ),
    );
  }

  Widget buildSearchInput(String hint, TextEditingController controller, Function(String) onChanged) {
    return Container(
      height: 45,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6)),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hint, 
          border: InputBorder.none,
          suffixIcon: const Icon(Icons.search, color: Color(0xFF2F9C9C)),
        ),
      ),
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
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget buildTextArea() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6)),
      child: TextField(
        controller: notesController,
        maxLines: 3,
        decoration: const InputDecoration(hintText: "Otras observaciones...", border: InputBorder.none),
      ),
    );
  }

  Widget buildSaveButton(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        if (_isAdmin && _selectedCaregiver == null) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Debes asignar un cuidador")));
          return;
        }

        final dni = dniController.text.trim().toUpperCase();
        if (nameController.text.isEmpty || dni.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Nombre y DNI son obligatorios")));
          return;
        }

        final user = FirebaseAuth.instance.currentUser;
        if (user == null) return;

        String caregiverId;
        String caregiverName;

        if (_isAdmin) {
          caregiverId = _selectedCaregiver!['id'];
          caregiverName = "${_selectedCaregiver!['name']} ${_selectedCaregiver!['surname']}";
        } else {
          final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
          caregiverId = user.uid;
          caregiverName = userDoc.data()?['name'] ?? "Cuidador";
        }

        final newPatient = Patient(
          id: "", 
          name: nameController.text.trim(),
          surname: surnameController.text.trim(),
          dni: dni,
          age: int.tryParse(ageController.text) ?? 0,
          gender: _selectedGender,
          bloodType: _selectedBloodType,
          notes: notesController.text.trim(),
          allergies: _selectedAllergies.join(", "),
          caregiverId: caregiverId,
          caregiverName: caregiverName,
        );

        try {
          final exists = await PatientService.checkDniExists(dni);
          if (exists) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Ya existe un paciente con el DNI: $dni"),
                  backgroundColor: Colors.redAccent,
                ),
              );
            }
            return;
          }

          if (mounted) {
            context.read<PatientProvider>().addPatient(newPatient);
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Paciente registrado correctamente"), backgroundColor: Colors.green)
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Error: ${e.toString()}"), backgroundColor: Colors.orangeAccent),
            );
          }
        }
      },
      child: Container(
        width: 220, height: 50,
        decoration: BoxDecoration(
          color: const Color(0xFFE74C3C),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 4, offset: const Offset(0, 2))],
        ),
        child: const Center(
          child: Text("REGISTRAR PACIENTE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.1)),
        ),
      ),
    );
  }
}

