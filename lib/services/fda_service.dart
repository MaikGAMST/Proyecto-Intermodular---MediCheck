import 'dart:convert';
import 'package:http/http.dart' as http;

class FdaService {
  static const String _baseUrl = "https://api.fda.gov/drug/label.json";

  /// Busca medicamentos por nombre comercial o genérico
  static Future<List<Map<String, dynamic>>> searchMedications(String query) async {
    if (query.isEmpty) return [];

    // Limpiamos el query para evitar errores en la URL
    final cleanQuery = query.replaceAll(' ', '+');
    
    // Buscamos tanto en el nombre comercial como en el genérico
    // Usamos comodín (*) para encontrar coincidencias parciales
    final url = Uri.parse('$_baseUrl?search=(openfda.brand_name:$cleanQuery*+OR+openfda.generic_name:$cleanQuery*)&limit=10');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List;

        // Usamos un Set para evitar duplicados en los resultados
        final Set<String> seen = {};
        final List<Map<String, dynamic>> uniqueResults = [];

        for (var res in results) {
          final openfda = res['openfda'] ?? {};
          final brandName = (openfda['brand_name'] as List?)?.first ?? 'Desconocido';
          
          if (!seen.contains(brandName.toLowerCase())) {
            seen.add(brandName.toLowerCase());
            uniqueResults.add({
              'brand_name': brandName,
              'generic_name': (openfda['generic_name'] as List?)?.first ?? 'Desconocido',
              'pharm_class': (openfda['pharm_class_epc'] as List?)?.first ?? 'Sin clase',
            });
          }
        }

        return uniqueResults;
      }
    } catch (e) {
      print("Error en OpenFDA Search: $e");
    }
    return [];
  }

  /// Obtiene los detalles específicos de un medicamento
  static Future<Map<String, dynamic>?> getMedicationDetails(String brandName) async {
    final url = Uri.parse('$_baseUrl?search=openfda.brand_name:"$brandName"&limit=1');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final openfda = data['results'][0]['openfda'] ?? {};

        return {
          'brand_name': (openfda['brand_name'] as List?)?.first ?? brandName,
          'generic_name': (openfda['generic_name'] as List?)?.first ?? 'Desconocido',
          'pharm_class': (openfda['pharm_class_epc'] as List?)?.first ?? 'Sin clase',
        };
      }
    } catch (e) {
      print("Error en OpenFDA Details: $e");
    }
    return null;
  }
}
