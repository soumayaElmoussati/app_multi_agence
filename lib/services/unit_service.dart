// lib/services/unit_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:multi_agences_app/config/env.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:multi_agences_app/services/selected_agency_service.dart';

class UnitService {
  static const String endpoint = 'api/unites';

  // Méthode pour obtenir le token
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // Headers communs
  Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Gestion des réponses
  dynamic _handleResponse(http.Response response) {
    final statusCode = response.statusCode;
    final responseBody = json.decode(utf8.decode(response.bodyBytes));

    if (statusCode >= 200 && statusCode < 300) {
      return responseBody;
    } else if (statusCode == 401) {
      throw Exception('Non authentifié. Veuillez vous reconnecter.');
    } else if (statusCode == 403) {
      throw Exception('Accès non autorisé.');
    } else if (statusCode == 422) {
      // Retourner les erreurs de validation
      return {'success': false, 'errors': responseBody['errors']};
    } else {
      throw Exception(
        'Erreur serveur ($statusCode): ${responseBody['message'] ?? 'Erreur inconnue'}',
      );
    }
  }

  // Récupérer toutes les unités
  Future<List<dynamic>> getAllUnits() async {
    try {
      // Récupérer l'agence sélectionnée
      final selectedAgency = await SelectedAgencyService.getSelectedAgency();

      // Construire l'URL avec agency_id si disponible
      String url = '${Env.baseUrl}/$endpoint';
      if (selectedAgency != null && selectedAgency['id'] != null) {
        url += '?agency_id=${selectedAgency['id']}';
      }

      print('Fetching units from: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: await _getHeaders(),
      );

      final result = _handleResponse(response);

      if (result['success'] == true) {
        return result['data'] as List;
      } else {
        throw Exception('Erreur: ${result['message']}');
      }
    } catch (e) {
      print('Error in getAllUnits: $e');
      rethrow;
    }
  }

  // Créer une nouvelle unité
  Future<dynamic> createUnit(Map<String, dynamic> unitData) async {
    try {
      final url = Uri.parse('${Env.baseUrl}/$endpoint');

      // Ajouter l'agence sélectionnée aux données
      final selectedAgency = await SelectedAgencyService.getSelectedAgency();
      if (selectedAgency != null && selectedAgency['id'] != null) {
        // Convertir l'ID en String pour l'API Laravel
        unitData['agency_id'] = selectedAgency['id'].toString();
      }

      print('🟡 Creating unit at: $url');
      print('🟡 Unit data: $unitData');

      final response = await http.post(
        url,
        headers: await _getHeaders(),
        body: json.encode(unitData),
      );

      print('🟡 Response status: ${response.statusCode}');
      print('🟡 Response body: ${response.body}');

      return _handleResponse(response);
    } catch (e) {
      print('❌ Error in createUnit: $e');
      rethrow;
    }
  }

  // Mettre à jour une unité
  Future<dynamic> updateUnit(int id, Map<String, dynamic> unitData) async {
    try {
      final url = Uri.parse('${Env.baseUrl}/$endpoint/$id');
      print('Updating unit at: $url');

      final response = await http.put(
        url,
        headers: await _getHeaders(),
        body: json.encode(unitData),
      );

      return _handleResponse(response);
    } catch (e) {
      print('Error in updateUnit: $e');
      rethrow;
    }
  }

  // Supprimer une unité
  Future<bool> deleteUnit(int id) async {
    try {
      final url = Uri.parse('${Env.baseUrl}/$endpoint/$id');
      print('Deleting unit at: $url');

      final response = await http.delete(url, headers: await _getHeaders());

      final result = _handleResponse(response);

      if (result['success'] == true) {
        return true;
      } else {
        throw Exception('Erreur: ${result['message']}');
      }
    } catch (e) {
      print('Error in deleteUnit: $e');
      rethrow;
    }
  }
}
