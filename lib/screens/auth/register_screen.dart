import 'dart:async';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../routes/app_routes.dart';
import '../../widgets/inputs/text_input.dart';
import '../../widgets/buttons/primary_button.dart';
import '../../services/auth_service.dart';
import '../../services/maps_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _localityController = TextEditingController();
  
  DateTime? _birthDate;
  
  // Google Maps State
  List<Map<String, String>> _mapResults = [];
  bool _isSearchingMap = false;
  Timer? _debounce;
  String _selectedLocality = "";

  bool _termsAccepted = false;
  bool _notificationsEnabled = false;
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  void _searchLocality(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    
    if (query.length < 3) {
      setState(() => _mapResults = []);
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 600), () async {
      setState(() => _isSearchingMap = true);
      final results = await MapsService.searchLocalities(query);
      if (mounted) {
        setState(() {
          _mapResults = results;
          _isSearchingMap = false;
        });
      }
    });
  }

  void _selectLocality(String description) {
    setState(() {
      _selectedLocality = description.replaceAll(" (Usar texto libre)", "");
      _localityController.text = _selectedLocality;
      _mapResults = [];
    });
  }

  void _register() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();
    final name = _nameController.text.trim();
    final surname = _surnameController.text.trim();
    final phone = _phoneController.text.trim();

    // 1. Validaciones
    if (name.isEmpty || surname.isEmpty || phone.isEmpty || email.isEmpty) {
      _showError("Todos los campos obligatorios");
      return;
    }
    
    if (_selectedLocality.isEmpty) {
      _showError("Por favor, selecciona tu localidad");
      return;
    }

    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      _showError("Email no válido");
      return;
    }

    if (password.length < 6 || password != confirmPassword) {
      _showError("Contraseña no válida o no coincide");
      return;
    }

    if (_birthDate == null) {
      _showError("Fecha de nacimiento obligatoria");
      return;
    }

    // VALIDACIÓN EDAD (18+)
    final nowAge = DateTime.now();
    int age = nowAge.year - _birthDate!.year;
    if (nowAge.month < _birthDate!.month || (nowAge.month == _birthDate!.month && nowAge.day < _birthDate!.day)) {
      age--;
    }

    if (age < 18) {
      _showError("Debes ser mayor de 18 años");
      return;
    }

    if (!_termsAccepted) {
      _showError("Acepta los términos de uso");
      return;
    }

    setState(() => _isLoading = true);
    
    try {
      final user = await _authService.registerWithEmailAndPassword(email, password);

      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'name': name,
          'surname': surname,
          'phone': phone,
          'email': email,
          'locality': _selectedLocality,
          'birthDate': _birthDate,
          'notifications': _notificationsEnabled,
          'role': 'caregiver',
          'isActive': false,
          'createdAt': FieldValue.serverTimestamp(),
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Registro enviado. Un administrador activará tu cuenta pronto."), 
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 5),
            ),
          );
          // Cerramos sesión inmediatamente para que no entre a la app
          await _authService.signOut();
          Navigator.pushReplacementNamed(context, AppRoutes.login);
        }
      }
    } catch (e) {
      _showError("Error: ${e.toString()}");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _localityController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE6E6E6),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Container(
            width: 320,
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
            decoration: BoxDecoration(
              color: const Color(0xFF2F9C9C),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                Image.asset("assets/nombre_logo.png", height: 55),
                const SizedBox(height: 20),

                TextInput(hint: "Nombre", controller: _nameController),
                const SizedBox(height: 12),
                TextInput(hint: "Apellidos", controller: _surnameController),
                const SizedBox(height: 12),
                TextInput(hint: "Teléfono", controller: _phoneController),
                const SizedBox(height: 12),
                TextInput(hint: "Email", controller: _emailController),
                const SizedBox(height: 12),
                TextInput(hint: "Contraseña", obscure: true, controller: _passwordController),
                const SizedBox(height: 12),
                TextInput(hint: "Confirmar Contraseña", obscure: true, controller: _confirmPasswordController),
                const SizedBox(height: 12),

                buildDatePicker(),
                const SizedBox(height: 12),

                /// GOOGLE MAPS SEARCH
                Container(
                  height: 46,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6)),
                  child: TextField(
                    controller: _localityController,
                    onChanged: _searchLocality,
                    decoration: const InputDecoration(
                      hintText: "Localidad (Google Maps)",
                      border: InputBorder.none,
                      suffixIcon: Icon(Icons.location_on, size: 18, color: Color(0xFF2F9C9C)),
                    ),
                  ),
                ),

                if (_isSearchingMap)
                  const Padding(padding: EdgeInsets.all(8.0), child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),

                if (_mapResults.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 5),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6)),
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _mapResults.length,
                      itemBuilder: (context, index) {
                        final res = _mapResults[index];
                        return ListTile(
                          dense: true,
                          title: Text(res['description']!, style: const TextStyle(fontSize: 12)),
                          onTap: () => _selectLocality(res['description']!),
                        );
                      },
                    ),
                  ),

                const SizedBox(height: 14),

                buildTermsCheckbox(),
                buildNotificationsCheckbox(),

                const SizedBox(height: 18),

                _isLoading 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : PrimaryButton(text: "Registrarse", onTap: _register),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildDatePicker() {
    return GestureDetector(
      onTap: () async {
        final DateTime? picked = await showDatePicker(
          context: context, initialDate: DateTime(2000),
          firstDate: DateTime(1900), lastDate: DateTime.now(),
        );
        if (picked != null) setState(() => _birthDate = picked);
      },
      child: Container(
        height: 46,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _birthDate == null ? "Nacimiento" : "${_birthDate!.day}/${_birthDate!.month}/${_birthDate!.year}",
              style: TextStyle(color: _birthDate == null ? Colors.grey[600] : Colors.black, fontSize: 13),
            ),
            const Icon(Icons.calendar_today, size: 18, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget buildTermsCheckbox() {
    return Row(
      children: [
        SizedBox(width: 18, height: 18, child: Checkbox(value: _termsAccepted, onChanged: (val) => setState(() => _termsAccepted = val ?? false), side: const BorderSide(color: Colors.white))),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 11, color: Colors.white),
              children: [
                const TextSpan(text: "He leído y acepto los "),
                TextSpan(
                  text: "términos de uso",
                  style: const TextStyle(decoration: TextDecoration.underline, fontWeight: FontWeight.bold),
                  recognizer: TapGestureRecognizer()..onTap = () => Navigator.pushNamed(context, AppRoutes.terms),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget buildNotificationsCheckbox() {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          SizedBox(width: 18, height: 18, child: Checkbox(value: _notificationsEnabled, onChanged: (val) => setState(() => _notificationsEnabled = val ?? false), side: const BorderSide(color: Colors.white))),
          const SizedBox(width: 8),
          const Expanded(child: Text("Permito enviar notificaciones", style: TextStyle(fontSize: 11, color: Colors.white))),
        ],
      ),
    );
  }
}

