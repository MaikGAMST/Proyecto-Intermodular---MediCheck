import 'dart:convert';
import 'package:http/http.dart' as http;

class MapsService {
  // TODO: Reemplazar con una API Key real de Google Maps Platform
  static const String _apiKey = "YOUR_GOOGLE_MAPS_API_KEY";
  static const String _autocompleteUrl = "https://maps.googleapis.com/maps/api/place/autocomplete/json";

  /// Busca localidades usando Google Places Autocomplete
  static Future<List<Map<String, String>>> searchLocalities(String query) async {
    if (query.isEmpty) return [];

    final url = Uri.parse(
      '$_autocompleteUrl?input=$query&types=(cities)&components=country:es&language=es&key=$_apiKey'
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          final List predictions = data['predictions'];
          return predictions.map<Map<String, String>>((p) => {
            'description': p['description'] as String,
            'place_id': p['place_id'] as String,
          }).toList();
        } else {
          print("Google Maps API Status: ${data['status']}");
          if (data['status'] == 'REQUEST_DENIED' || data['status'] == 'INVALID_REQUEST') {
             // Si la API Key es inválida, usamos el mock extendido
             return _getMockLocalities(query);
          }
        }
      }
    } catch (e) {
      print("Error en Google Maps Autocomplete: $e");
    }

    return _getMockLocalities(query);
  }

  static List<Map<String, String>> _getMockLocalities(String query) {
    final list = [
      {'description': 'Madrid, España', 'place_id': 'm1'},
      {'description': 'Barcelona, España', 'place_id': 'm2'},
      {'description': 'Valencia, España', 'place_id': 'm3'},
      {'description': 'Sevilla, España', 'place_id': 'm4'},
      {'description': 'Zaragoza, España', 'place_id': 'm5'},
      {'description': 'Málaga, España', 'place_id': 'm6'},
      {'description': 'Murcia, España', 'place_id': 'm7'},
      {'description': 'Palma, España', 'place_id': 'm8'},
      {'description': 'Las Palmas de Gran Canaria, España', 'place_id': 'm9'},
      {'description': 'Bilbao, España', 'place_id': 'm10'},
      {'description': 'Alicante, España', 'place_id': 'm11'},
      {'description': 'Córdoba, España', 'place_id': 'm12'},
      {'description': 'Valladolid, España', 'place_id': 'm13'},
      {'description': 'Vigo, España', 'place_id': 'm14'},
      {'description': 'Gijón, España', 'place_id': 'm15'},
    ];
    
    final filtered = list.where((l) => l['description']!.toLowerCase().contains(query.toLowerCase())).toList();
    
    // Si no hay coincidencias en el mock, permitimos seleccionar lo que el usuario escribió
    // para que no se quede bloqueado sin poder registrarse.
    if (filtered.isEmpty) {
      return [
        {'description': '$query (Usar texto libre)', 'place_id': 'custom'}
      ];
    }
    
    return filtered;
  }
}
