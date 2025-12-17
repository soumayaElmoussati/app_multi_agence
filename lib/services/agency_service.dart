import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:multi_agences_app/config/env.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AgencyService {
  static const String endpoint = 'api/agencies';

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

    print('Status: $statusCode');
    print('Response: $responseBody');

    if (statusCode >= 200 && statusCode < 300) {
      return responseBody;
    } else if (statusCode == 401) {
      throw Exception('Non authentifié. Veuillez vous reconnecter.');
    } else if (statusCode == 403) {
      throw Exception('Accès non autorisé.');
    } else if (statusCode == 404) {
      throw Exception('Ressource non trouvée.');
    } else if (statusCode == 422) {
      throw Exception(responseBody['errors'] ?? 'Erreur de validation.');
    } else {
      throw Exception(
        'Erreur serveur ($statusCode): ${responseBody['message'] ?? 'Erreur inconnue'}',
      );
    }
  }

  // Récupérer toutes les agences
  Future<List<dynamic>> getAllAgencies() async {
    try {
      final url = Uri.parse('${Env.baseUrl}/$endpoint');
      print('Fetching agencies from: $url');

      final response = await http.get(url, headers: await _getHeaders());

      final result = _handleResponse(response);

      if (result['success'] == true) {
        return result['data'] as List;
      } else {
        throw Exception('Erreur: ${result['message']}');
      }
    } catch (e) {
      print('Error in getAllAgencies: $e');
      rethrow;
    }
  }

  // Récupérer une agence spécifique
  Future<Map<String, dynamic>> getAgency(int id) async {
    try {
      final url = Uri.parse('${Env.baseUrl}/$endpoint/$id');
      print('Fetching agency from: $url');

      final response = await http.get(url, headers: await _getHeaders());

      final result = _handleResponse(response);

      if (result['success'] == true) {
        return result['data'];
      } else {
        throw Exception('Erreur: ${result['message']}');
      }
    } catch (e) {
      print('Error in getAgency: $e');
      rethrow;
    }
  }

  // Créer une nouvelle agence
  Future<Map<String, dynamic>> createAgency(
    Map<String, dynamic> agencyData,
  ) async {
    try {
      final url = Uri.parse('${Env.baseUrl}/$endpoint');
      print('Creating agency at: $url');
      print('Agency data: $agencyData');

      final response = await http.post(
        url,
        headers: await _getHeaders(),
        body: json.encode(agencyData),
      );

      final result = _handleResponse(response);

      if (result['success'] == true) {
        return result['data'];
      } else {
        throw Exception('Erreur: ${result['message']}');
      }
    } catch (e) {
      print('Error in createAgency: $e');
      rethrow;
    }
  }

  // Mettre à jour une agence
  Future<Map<String, dynamic>> updateAgency(
    int id,
    Map<String, dynamic> agencyData,
  ) async {
    try {
      final url = Uri.parse('${Env.baseUrl}/$endpoint/$id');
      print('Updating agency at: $url');

      final response = await http.put(
        url,
        headers: await _getHeaders(),
        body: json.encode(agencyData),
      );

      final result = _handleResponse(response);

      if (result['success'] == true) {
        return result['data'];
      } else {
        throw Exception('Erreur: ${result['message']}');
      }
    } catch (e) {
      print('Error in updateAgency: $e');
      rethrow;
    }
  }

  // Supprimer une agence
  Future<bool> deleteAgency(int id) async {
    try {
      final url = Uri.parse('${Env.baseUrl}/$endpoint/$id');
      print('Deleting agency at: $url');

      final response = await http.delete(url, headers: await _getHeaders());

      final result = _handleResponse(response);

      if (result['success'] == true) {
        return true;
      } else {
        throw Exception('Erreur: ${result['message']}');
      }
    } catch (e) {
      print('Error in deleteAgency: $e');
      rethrow;
    }
  }

  // Rechercher des agences
  Future<List<dynamic>> searchAgencies(String query) async {
    try {
      final url = Uri.parse('${Env.baseUrl}/$endpoint/search?q=$query');
      print('Searching agencies at: $url');

      final response = await http.get(url, headers: await _getHeaders());

      final result = _handleResponse(response);

      if (result['success'] == true) {
        return result['data'] as List;
      } else {
        return []; // Retourner liste vide si pas de résultats
      }
    } catch (e) {
      print('Error in searchAgencies: $e');
      return []; // Retourner liste vide en cas d'erreur
    }
  }
}
