import 'dart:convert';
import 'package:http/http.dart' as http;

class FhirService {
  static const String _baseUrl = "https://hapi.fhir.org/baseR4";

  /// Busca alergias e intolerancias usando el estándar FHIR
  static Future<List<Map<String, String>>> searchAllergies(String query) async {
    if (query.isEmpty) return [];

    // Buscamos recursos de tipo AllergyIntolerance que contengan el texto
    final url = Uri.parse('$_baseUrl/AllergyIntolerance?_content=$query&_summary=true&_count=10');

    try {
      final response = await http.get(url, headers: {'Accept': 'application/fhir+json'});
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['entry'] == null) return [];

        final List<Map<String, String>> results = [];
        final Set<String> seen = {};

        for (var entry in data['entry']) {
          final resource = entry['resource'];
          final code = resource['code'];
          
          String? display;
          if (code['coding'] != null && (code['coding'] as List).isNotEmpty) {
            display = code['coding'][0]['display'];
          } else {
            display = code['text'];
          }

          if (display != null && !seen.contains(display.toLowerCase())) {
            seen.add(display.toLowerCase());
            results.add({
              'display': display,
              'code': code['coding']?[0]?['code'] ?? 'N/A',
            });
          }
        }
        return results;
      }
    } catch (e) {
      print("Error en FHIR Search: $e");
    }
    
    // Si falla la API o no hay resultados, devolvemos algunos comunes para no dejar vacío el buscador
    return _getMockAllergies(query);
  }

  static List<Map<String, String>> _getMockAllergies(String query) {
    final common = [
      {'display': 'Penicilina', 'code': '76414002'},
      {'display': 'Polen', 'code': '256259004'},
      {'display': 'Lactosa', 'code': '190753003'},
      {'display': 'Frutos Secos', 'code': '91935009'},
      {'display': 'Aspirina', 'code': '293586001'},
      {'display': 'Látex', 'code': '300916003'},
      {'display': 'Marisco', 'code': '91934008'},
    ];
    return common.where((a) => a['display']!.toLowerCase().contains(query.toLowerCase())).toList();
  }
}
