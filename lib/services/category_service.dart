import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:multi_agences_app/config/env.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CategoryService {
  static const String endpoint = 'api/categories';

  // Méthode pour obtenir le token
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // Méthode pour obtenir l'agence sélectionnée
  Future<int?> _getSelectedAgencyId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('selected_agency_id');
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

  // Récupérer toutes les catégories
  Future<List<dynamic>> getAllCategories({int? agencyId}) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('Token non trouvé. Veuillez vous reconnecter.');
      }

      // Utiliser l'agence sélectionnée ou celle passée en paramètre
      final selectedAgencyId = agencyId ?? await _getSelectedAgencyId();

      String url = '${Env.baseUrl}/$endpoint';
      if (selectedAgencyId != null) {
        url += '?agency_id=$selectedAgencyId';
      }

      print('Fetching categories from: $url');

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
      print('Error in getAllCategories: $e');
      rethrow;
    }
  }

  // Créer une nouvelle catégorie
  Future<Map<String, dynamic>> createCategory(
    Map<String, dynamic> categoryData,
  ) async {
    try {
      final url = Uri.parse('${Env.baseUrl}/$endpoint');

      // Ajouter l'agence sélectionnée aux données
      final selectedAgencyId = await _getSelectedAgencyId();
      if (selectedAgencyId != null) {
        categoryData['agency_id'] = selectedAgencyId;
      }

      print('Creating category at: $url');
      print('Category data: $categoryData');

      final response = await http.post(
        url,
        headers: await _getHeaders(),
        body: json.encode(categoryData),
      );

      final result = _handleResponse(response);

      if (result['success'] == true) {
        return result['data'];
      } else {
        throw Exception('Erreur: ${result['message']}');
      }
    } catch (e) {
      print('Error in createCategory: $e');
      rethrow;
    }
  }

  // Mettre à jour une catégorie
  Future<Map<String, dynamic>> updateCategory(
    int id,
    Map<String, dynamic> categoryData,
  ) async {
    try {
      final url = Uri.parse('${Env.baseUrl}/$endpoint/$id');
      print('Updating category at: $url');

      final response = await http.put(
        url,
        headers: await _getHeaders(),
        body: json.encode(categoryData),
      );

      final result = _handleResponse(response);

      if (result['success'] == true) {
        return result['data'];
      } else {
        throw Exception('Erreur: ${result['message']}');
      }
    } catch (e) {
      print('Error in updateCategory: $e');
      rethrow;
    }
  }

  // Supprimer une catégorie
  Future<bool> deleteCategory(int id) async {
    try {
      final url = Uri.parse('${Env.baseUrl}/$endpoint/$id');
      print('Deleting category at: $url');

      final response = await http.delete(url, headers: await _getHeaders());

      final result = _handleResponse(response);

      if (result['success'] == true) {
        return true;
      } else {
        throw Exception('Erreur: ${result['message']}');
      }
    } catch (e) {
      print('Error in deleteCategory: $e');
      rethrow;
    }
  }
}
