import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:multi_agences_app/config/env.dart';

class ApiService {
  // Headers communs
  Map<String, String> getHeaders({String? token}) {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  // Gestion des erreurs
  String _handleError(dynamic error) {
    if (error is http.ClientException) {
      return 'Erreur réseau. Vérifiez votre connexion internet.';
    } else if (error is FormatException) {
      return 'Erreur de format de réponse du serveur.';
    }
    return 'Erreur: ${error.toString()}';
  }

  // Connexion
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final url = Uri.parse('${Env.baseUrl}/api/login');
      final body = json.encode({'email': email.trim(), 'password': password});

      final response = await http.post(url, headers: getHeaders(), body: body);

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'data': responseData['data']};
      } else {
        final errors = responseData['errors'] ?? {};
        String errorMessage = 'Email ou mot de passe incorrect';

        if (errors.isNotEmpty) {
          final firstError = errors.values.first;
          if (firstError is List && firstError.isNotEmpty) {
            errorMessage = firstError.first;
          } else if (firstError is String) {
            errorMessage = firstError;
          }
        } else if (responseData['message'] != null) {
          errorMessage = responseData['message'];
        }

        return {'success': false, 'message': errorMessage};
      }
    } catch (e) {
      return {'success': false, 'message': _handleError(e)};
    }
  }

  // Inscription
  Future<Map<String, dynamic>> register({
    required String firstname,
    required String lastname,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      final url = Uri.parse('${Env.baseUrl}/api/register');
      final body = json.encode({
        'firstname': firstname.trim(),
        'lastname': lastname.trim(),
        'email': email.trim(),
        'password': password,
        'password_confirmation': passwordConfirmation,
      });

      final response = await http.post(url, headers: getHeaders(), body: body);

      final responseData = json.decode(response.body);

      if (response.statusCode == 201) {
        return {'success': true, 'data': responseData['data']};
      } else {
        final errors = responseData['errors'] ?? {};
        String errorMessage = 'Erreur lors de l\'inscription';

        if (errors.isNotEmpty) {
          final firstError = errors.values.first;
          if (firstError is List && firstError.isNotEmpty) {
            errorMessage = firstError.first;
          } else if (firstError is String) {
            errorMessage = firstError;
          }
        } else if (responseData['message'] != null) {
          errorMessage = responseData['message'];
        }

        return {'success': false, 'message': errorMessage};
      }
    } catch (e) {
      return {'success': false, 'message': _handleError(e)};
    }
  }

  // Récupérer le profil utilisateur (avec token)
  Future<Map<String, dynamic>> getProfile(String token) async {
    try {
      final url = Uri.parse('${Env.baseUrl}/api/me');

      final response = await http.get(url, headers: getHeaders(token: token));

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'data': responseData['data']};
      } else {
        return {
          'success': false,
          'message': 'Impossible de récupérer le profil',
        };
      }
    } catch (e) {
      return {'success': false, 'message': _handleError(e)};
    }
  }

  // Rafraîchir le token
  Future<Map<String, dynamic>> refreshToken(String token) async {
    try {
      final url = Uri.parse('${Env.baseUrl}/api/refresh');

      final response = await http.post(url, headers: getHeaders(token: token));

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'data': responseData['data']};
      } else {
        return {
          'success': false,
          'message': 'Impossible de rafraîchir le token',
        };
      }
    } catch (e) {
      return {'success': false, 'message': _handleError(e)};
    }
  }

  // Déconnexion
  Future<Map<String, dynamic>> logout(String token) async {
    try {
      final url = Uri.parse('${Env.baseUrl}/api/logout');

      final response = await http.post(url, headers: getHeaders(token: token));

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Déconnexion réussie'};
      } else {
        return {'success': false, 'message': 'Erreur lors de la déconnexion'};
      }
    } catch (e) {
      return {'success': false, 'message': _handleError(e)};
    }
  }
}
