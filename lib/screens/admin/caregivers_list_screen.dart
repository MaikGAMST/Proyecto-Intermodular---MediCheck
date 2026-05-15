import 'package:flutter/material.dart';
import '../../services/user_service.dart';

class CaregiversListScreen extends StatefulWidget {
  const CaregiversListScreen({super.key});

  @override
  State<CaregiversListScreen> createState() => _CaregiversListScreenState();
}

class _CaregiversListScreenState extends State<CaregiversListScreen> {
  late Future<List<Map<String, dynamic>>> _caregiversFuture;

  @override
  void initState() {
    super.initState();
    _caregiversFuture = UserService.getAllUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Lista de Cuidadores"),
        backgroundColor: const Color(0xFF2F9C9C),
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _caregiversFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final users = snapshot.data ?? [];
          // Filtramos para mostrar solo los que NO son admin (opcional)
          final caregivers = users.where((u) => u['role'] != 'admin').toList();

          if (caregivers.isEmpty) {
            return const Center(child: Text("No hay cuidadores registrados"));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(15),
            itemCount: caregivers.length,
            itemBuilder: (context, index) {
              final cg = caregivers[index];
              return Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 15),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFF2F9C9C),
                    backgroundImage: cg['photoUrl'] != null ? NetworkImage(cg['photoUrl']) : null,
                    child: cg['photoUrl'] == null 
                        ? const Icon(Icons.person, color: Colors.white)
                        : null,
                  ),
                  title: Row(
                    children: [
                      Expanded(child: Text("${cg['name'] ?? ''} ${cg['surname'] ?? ''}", style: const TextStyle(fontWeight: FontWeight.bold))),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: (cg['isActive'] ?? false) ? Colors.green[100] : Colors.red[100],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          (cg['isActive'] ?? false) ? "Activo" : "Inactivo",
                          style: TextStyle(
                            fontSize: 10, 
                            fontWeight: FontWeight.bold,
                            color: (cg['isActive'] ?? false) ? Colors.green[800] : Colors.red[800],
                          ),
                        ),
                      ),
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(cg['email'] ?? ''),
                      Text("📍 ${cg['province'] ?? 'Sin provincia'}", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    _showCaregiverDetails(cg);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showCaregiverDetails(Map<String, dynamic> cg) {
    bool localActive = cg['isActive'] ?? false;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: const EdgeInsets.all(25),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Detalles del Cuidador", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.teal[800])),
              const Divider(),
              const SizedBox(height: 10),
              detailRow(Icons.phone, "Teléfono", cg['phone'] ?? 'N/A'),
              detailRow(Icons.email, "Email", cg['email'] ?? 'N/A'),
              detailRow(Icons.cake, "F. Nacimiento", cg['birthDate'] != null ? (cg['birthDate'] as dynamic).toDate().toString().split(' ')[0] : 'N/A'),
              detailRow(Icons.map, "Provincia", cg['province'] ?? 'N/A'),
              const SizedBox(height: 10),
              SwitchListTile(
                title: const Text("Cuenta Activa", style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text("Permitir al usuario iniciar sesión"),
                value: localActive,
                activeColor: const Color(0xFF2F9C9C),
                onChanged: (val) async {
                  await UserService.updateUserStatus(cg['id'], val);
                  setModalState(() => localActive = val);
                  setState(() {
                    _caregiversFuture = UserService.getAllUsers();
                  });
                },
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF2F9C9C)),
          const SizedBox(width: 15),
          Text("$label: ", style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }
}
