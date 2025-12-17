import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:multi_agences_app/config/env.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:multi_agences_app/services/selected_agency_service.dart';

class SupplierService {
  static const String endpoint = 'api/suppliers';

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
      return {'success': false, 'errors': responseBody['errors']};
    } else {
      throw Exception(
        'Erreur serveur ($statusCode): ${responseBody['message'] ?? 'Erreur inconnue'}',
      );
    }
  }

  // Récupérer tous les fournisseurs
  Future<List<dynamic>> getAllSuppliers() async {
    try {
      // Récupérer l'agence sélectionnée
      final selectedAgency = await SelectedAgencyService.getSelectedAgency();

      // Construire l'URL avec agency_id si disponible
      String url = '${Env.baseUrl}/$endpoint';
      if (selectedAgency != null && selectedAgency['id'] != null) {
        url += '?agency_id=${selectedAgency['id']}';
      }

      print('🔵 Fetching suppliers from: $url');

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
      print('❌ Error in getAllSuppliers: $e');
      rethrow;
    }
  }

  // Créer un nouveau fournisseur
  Future<dynamic> createSupplier(Map<String, dynamic> supplierData) async {
    try {
      final url = Uri.parse('${Env.baseUrl}/$endpoint');

      // Ajouter l'agence sélectionnée aux données
      final selectedAgency = await SelectedAgencyService.getSelectedAgency();
      if (selectedAgency != null && selectedAgency['id'] != null) {
        supplierData['agency_id'] = selectedAgency['id'].toString();
      }

      print('🔵 Creating supplier at: $url');
      print('🔵 Supplier data: $supplierData');

      final response = await http.post(
        url,
        headers: await _getHeaders(),
        body: json.encode(supplierData),
      );

      final result = _handleResponse(response);
      return result;
    } catch (e) {
      print('❌ Error in createSupplier: $e');
      rethrow;
    }
  }

  // Mettre à jour un fournisseur
  Future<dynamic> updateSupplier(
    int id,
    Map<String, dynamic> supplierData,
  ) async {
    try {
      final url = Uri.parse('${Env.baseUrl}/$endpoint/$id');
      print('🔵 Updating supplier at: $url');

      final response = await http.put(
        url,
        headers: await _getHeaders(),
        body: json.encode(supplierData),
      );

      return _handleResponse(response);
    } catch (e) {
      print('❌ Error in updateSupplier: $e');
      rethrow;
    }
  }

  // Supprimer un fournisseur
  Future<bool> deleteSupplier(int id) async {
    try {
      final url = Uri.parse('${Env.baseUrl}/$endpoint/$id');
      print('🔵 Deleting supplier at: $url');

      final response = await http.delete(url, headers: await _getHeaders());

      final result = _handleResponse(response);

      if (result['success'] == true) {
        return true;
      } else {
        throw Exception('Erreur: ${result['message']}');
      }
    } catch (e) {
      print('❌ Error in deleteSupplier: $e');
      rethrow;
    }
  }

  // Récupérer un fournisseur spécifique
  Future<Map<String, dynamic>> getSupplier(int id) async {
    try {
      final url = Uri.parse('${Env.baseUrl}/$endpoint/$id');
      print('🔵 Fetching supplier from: $url');

      final response = await http.get(url, headers: await _getHeaders());

      final result = _handleResponse(response);

      if (result['success'] == true) {
        return result['data'];
      } else {
        throw Exception('Erreur: ${result['message']}');
      }
    } catch (e) {
      print('❌ Error in getSupplier: $e');
      rethrow;
    }
  }
}
