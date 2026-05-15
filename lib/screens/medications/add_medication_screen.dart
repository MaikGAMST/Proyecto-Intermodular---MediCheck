import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';

import '../../widgets/common/app_layout.dart';
import '../../models/medication.dart';
import '../../models/patient.dart';
import '../../providers/medication_provider.dart';
import '../../services/fda_service.dart';

class AddMedicationScreen extends StatefulWidget {
  const AddMedicationScreen({super.key});

  @override
  State<AddMedicationScreen> createState() => _AddMedicationScreenState();
}

class _AddMedicationScreenState extends State<AddMedicationScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController reasonController = TextEditingController();
  final TextEditingController dosageController = TextEditingController();
  final TextEditingController instructionsController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();

  DateTime? startDate;
  DateTime? endDate;
  String medicationType = "Pastilla / Cápsula";
  String medicationFrequency = "Diario";
  List<TimeOfDay> selectedTimes = [];
  bool reminderEnabled = true;

  // Estados para OpenFDA
  List<Map<String, dynamic>> _fdaResults = [];
  bool _isSearching = false;
  String _genericName = '';
  String _pharmClass = '';
  
  // Debouncer para la búsqueda
  Timer? _debounce;

  final List<String> _types = [
    "Pastilla / Cápsula", "Jarabe / Líquido", "Inyección",
    "Crema / Pomada", "Gotas", "Inhalador", "Parche",
    "Supositorio", "Polvos", "Spray / Aerosol"
  ];

  final List<String> _frequencies = ["Diario", "Cada 6h", "Cada 8h", "Cada 12h", "Semanal"];

  @override
  void dispose() {
    nameController.dispose();
    reasonController.dispose();
    dosageController.dispose();
    instructionsController.dispose();
    quantityController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _searchFda(String query) async {
    if (_debounce?.isActive ?? false) _debounce?.cancel();

    if (query.length < 3) {
      setState(() => _fdaResults = []);
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 500), () async {
      setState(() => _isSearching = true);
      final results = await FdaService.searchMedications(query);
      if (mounted) {
        setState(() {
          _fdaResults = results;
          _isSearching = false;
        });
      }
    });
  }

  void _selectMedication(Map<String, dynamic> fdaMed) {
    setState(() {
      nameController.text = fdaMed['brand_name'];
      _genericName = fdaMed['generic_name'];
      _pharmClass = fdaMed['pharm_class'];
      _fdaResults = []; // Limpiamos sugerencias
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Seleccionado: ${fdaMed['brand_name']} (${fdaMed['generic_name']})"),
        backgroundColor: const Color(0xFF2F9C9C),
      ),
    );
  }

  Future<void> pickStartDate() async {
    final DateTime now = DateTime.now();
    final DateTime? date = await showDatePicker(
      context: context, initialDate: now,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(2035),
    );
    if (date != null) setState(() => startDate = date);
  }

  Future<void> pickEndDate() async {
    final DateTime initial = startDate ?? DateTime.now();
    final DateTime? date = await showDatePicker(
      context: context, initialDate: initial,
      firstDate: initial, lastDate: DateTime(2035),
    );
    if (date != null) setState(() => endDate = date);
  }

  Future<void> addTime() async {
    final TimeOfDay? time = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (time != null && !selectedTimes.contains(time)) {
      setState(() => selectedTimes.add(time));
      selectedTimes.sort((a, b) => (a.hour * 60 + a.minute).compareTo(b.hour * 60 + b.minute));
    }
  }

  @override
  Widget build(BuildContext context) {
    final Patient patient = ModalRoute.of(context)!.settings.arguments as Patient;

    return AppLayout(
      child: Container(
        color: const Color(0xFF2F9C9C),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("NUEVA MEDICACIÓN", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
              Text("Para: ${patient.name} ${patient.surname}", style: const TextStyle(color: Colors.white70, fontSize: 16)),
              const SizedBox(height: 30),

              /// CARD 1: INFORMACIÓN BÁSICA (Con buscador OpenFDA)
              buildSectionCard(
                icon: Icons.medication,
                title: "Información General",
                children: [
                  buildLabel("Nombre del medicamento (Buscador OpenFDA)"),
                  buildSearchInput("Ej: Xanax, Ibuprofen...", nameController, _searchFda),
                  
                  if (_isSearching)
                    const Padding(padding: EdgeInsets.all(8.0), child: Center(child: CircularProgressIndicator())),

                  if (_fdaResults.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(top: 5),
                      constraints: const BoxConstraints(maxHeight: 200),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.teal.shade100),
                      ),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: _fdaResults.length,
                        itemBuilder: (context, index) {
                          final fdaMed = _fdaResults[index];
                          return ListTile(
                            dense: true,
                            title: Text(fdaMed['brand_name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text("Ingrediente: ${fdaMed['generic_name']}"),
                            onTap: () => _selectMedication(fdaMed),
                          );
                        },
                      ),
                    ),

                  const SizedBox(height: 15),
                  buildLabel("¿Para qué se utiliza?"),
                  buildInput("Ej: Ansiedad, Dolor...", reasonController),
                ],
              ),

              const SizedBox(height: 20),

              /// CARD 2: DOSIS Y FORMATO
              buildSectionCard(
                icon: Icons.science,
                title: "Dosis y Formato",
                children: [
                  Row(
                    children: [
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [buildLabel("Dosis"), buildInput("Ej: 5mg", dosageController)])),
                      const SizedBox(width: 15),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [buildLabel("Formato"), buildDropdown(_types, medicationType, (v) => setState(() => medicationType = v!))])),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 20),

              /// CARD 3: PAUTA HORARIA
              buildSectionCard(
                icon: Icons.access_time_filled,
                title: "Horarios y Recordatorios",
                children: [
                  buildLabel("Frecuencia"),
                  buildDropdown(_frequencies, medicationFrequency, (v) => setState(() => medicationFrequency = v!)),
                  const SizedBox(height: 15),
                  buildLabel("Horas de las tomas"),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ...selectedTimes.map((time) => Chip(
                        backgroundColor: const Color(0xFF2F9C9C).withOpacity(0.1),
                        label: Text(time.format(context), style: const TextStyle(color: Color(0xFF2F9C9C), fontWeight: FontWeight.bold)),
                        onDeleted: () => setState(() => selectedTimes.remove(time)),
                        deleteIconColor: const Color(0xFFE74C3C),
                      )),
                      ActionChip(
                        backgroundColor: const Color(0xFF2F9C9C),
                        avatar: const Icon(Icons.add, size: 18, color: Colors.white),
                        label: const Text("Añadir hora", style: TextStyle(color: Colors.white)),
                        onPressed: addTime,
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 20),

              /// CARD 4: DURACIÓN Y CONTROL
              buildSectionCard(
                icon: Icons.calendar_month,
                title: "Duración y Control",
                children: [
                  Row(
                    children: [
                      Expanded(child: buildDatePicker("Fecha Inicio", startDate, pickStartDate)),
                      const SizedBox(width: 15),
                      Expanded(child: buildDatePicker("Fecha Fin", endDate, pickEndDate)),
                    ],
                  ),
                  const SizedBox(height: 15),
                  buildLabel("Instrucciones de toma"),
                  buildInput("Ej: Con el desayuno", instructionsController),
                  const SizedBox(height: 15),
                  buildLabel("Cantidad en el envase (Stock)"),
                  buildInput("Ej: 30", quantityController, isNumber: true),
                ],
              ),

              const SizedBox(height: 40),

              /// BOTÓN GUARDAR
              Center(
                child: GestureDetector(
                  onTap: () => saveMedication(patient),
                  child: Container(
                    width: double.infinity,
                    height: 55,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE74C3C),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10, offset: const Offset(0, 4))],
                    ),
                    child: const Center(
                      child: Text("REGISTRAR MEDICACIÓN", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1.2)),
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

  Widget buildSectionCard({required IconData icon, required String title, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF2F9C9C), size: 22),
              const SizedBox(width: 10),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)),
            ],
          ),
          const Divider(height: 25),
          ...children,
        ],
      ),
    );
  }

  Widget buildLabel(String text) => Padding(padding: const EdgeInsets.only(bottom: 6), child: Text(text, style: TextStyle(color: Colors.grey[700], fontSize: 12, fontWeight: FontWeight.w600)));

  Widget buildInput(String hint, TextEditingController controller, {bool isNumber = false}) {
    return Container(
      height: 45,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(hintText: hint, hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14), border: InputBorder.none),
      ),
    );
  }

  Widget buildSearchInput(String hint, TextEditingController controller, Function(String) onChanged) {
    return Container(
      height: 45,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
          hintText: hint, 
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14), 
          border: InputBorder.none,
          suffixIcon: const Icon(Icons.search, size: 18, color: Colors.teal),
        ),
      ),
    );
  }

  Widget buildDropdown(List<String> items, String currentVal, Function(String?) onChanged) {
    return Container(
      height: 45,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: currentVal,
          isExpanded: true,
          style: const TextStyle(color: Colors.black87, fontSize: 14),
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget buildDatePicker(String label, DateTime? date, VoidCallback onTap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildLabel(label),
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: 45,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(date == null ? "Seleccionar" : "${date.day}/${date.month}/${date.year}", style: TextStyle(color: date == null ? Colors.grey[400] : Colors.black87, fontSize: 14)),
            ),
          ),
        ),
      ],
    );
  }

  void saveMedication(Patient patient) {
    final name = nameController.text.trim();
    if (name.isEmpty || startDate == null || endDate == null || selectedTimes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Completa nombre, fechas y al menos una hora"), backgroundColor: Colors.orangeAccent));
      return;
    }

    final existingMeds = context.read<MedicationProvider>().medications;

    // Función auxiliar para comprobar solapamiento de fechas
    bool datesOverlap(DateTime start1, DateTime end1, DateTime start2, DateTime end2) {
      return start1.isBefore(end2.add(const Duration(days: 1))) && 
             end1.isAfter(start2.subtract(const Duration(days: 1)));
    }

    // 1. VALIDACIÓN POR PRINCIPIO ACTIVO (GENERIC NAME)
    if (_genericName.isNotEmpty && _genericName != 'Desconocido') {
      final duplicateIngredient = existingMeds.where((m) => 
        m.patientId == patient.id && 
        m.genericName.toLowerCase() == _genericName.toLowerCase()
      );

      for (var m in duplicateIngredient) {
        if (datesOverlap(startDate!, endDate!, m.startDate, m.endDate)) {
          _showOverdoseWarning(name, m.name, _genericName);
          return;
        }
      }
    }

    // 2. VALIDACIÓN POR NOMBRE COMERCIAL
    final duplicateName = existingMeds.where((m) => 
      m.patientId == patient.id && 
      m.name.toLowerCase() == name.toLowerCase()
    );

    for (var m in duplicateName) {
      if (datesOverlap(startDate!, endDate!, m.startDate, m.endDate)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("¡Atención! Ya existe un tratamiento activo de $name en esas fechas."),
            backgroundColor: Colors.redAccent,
          ),
        );
        return;
      }
    }

    final medication = Medication(
      id: "", 
      patientId: patient.id,
      caregiverId: patient.caregiverId,
      patientName: "${patient.name} ${patient.surname}",
      name: name, 
      reason: reasonController.text.trim(),
      dosage: dosageController.text.trim(), 
      frequency: medicationFrequency,
      intakeTimes: selectedTimes.map((t) => "${t.hour.toString().padLeft(2,'0')}:${t.minute.toString().padLeft(2,'0')}").toList(),
      instructions: instructionsController.text.trim(),
      startDate: startDate!, 
      endDate: endDate!, 
      type: medicationType,
      genericName: _genericName,
      therapeuticClass: _pharmClass,
      totalQuantity: int.tryParse(quantityController.text) ?? 0,
      remainingQuantity: int.tryParse(quantityController.text) ?? 0,
      reminderEnabled: reminderEnabled,
    );

    Provider.of<MedicationProvider>(context, listen: false).addMedication(medication);
    Navigator.pop(context);
  }

  void _showOverdoseWarning(String newName, String existingName, String ingredient) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red),
            SizedBox(width: 10),
            Text("Alerta de Seguridad"),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("No se puede añadir '$newName' porque solapa con '$existingName'."),
            const SizedBox(height: 10),
            Text("Ambos comparten el principio activo: $ingredient.", style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const Text("Riesgo de sobredosis detectado por validación clínica."),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Entendido", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

