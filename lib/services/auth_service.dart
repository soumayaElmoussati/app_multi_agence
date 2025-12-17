import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  static const String _tokenKey = 'auth_token';
  static const String _userDataKey = 'user_data';
  static const String _rememberMeKey = 'remember_me';

  // Sauvegarder le token
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  // Récupérer le token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // Supprimer le token (déconnexion)
  Future<void> deleteToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userDataKey);
    await prefs.remove(_rememberMeKey);
  }

  // Sauvegarder les données utilisateur
  Future<void> saveUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userDataKey, json.encode(userData));
  }

  // Récupérer les données utilisateur
  Future<Map<String, dynamic>?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataString = prefs.getString(_userDataKey);
    if (userDataString != null) {
      return json.decode(userDataString) as Map<String, dynamic>;
    }
    return null;
  }

  // Sauvegarder l'option "Se souvenir de moi"
  Future<void> saveRememberMe(bool rememberMe) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_rememberMeKey, rememberMe);
  }

  // Récupérer l'option "Se souvenir de moi"
  Future<bool> getRememberMe() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_rememberMeKey) ?? false;
  }

  // Vérifier si l'utilisateur est connecté
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // Sauvegarder toutes les données d'authentification
  Future<void> saveAuthData({
    required String token,
    required Map<String, dynamic> userData,
    bool rememberMe = false,
  }) async {
    await saveToken(token);
    await saveUserData(userData);
    await saveRememberMe(rememberMe);
  }

  // Récupérer toutes les données d'authentification
  Future<Map<String, dynamic>?> getAuthData() async {
    final token = await getToken();
    final userData = await getUserData();

    if (token != null && userData != null) {
      return {'token': token, 'user': userData};
    }
    return null;
  }

  // Effacer toutes les données d'authentification
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
