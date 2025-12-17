// lib/services/selected_agency_service.dart
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class SelectedAgencyService {
  // Clés pour SharedPreferences
  static const String _agencyIdKey = 'selected_agency_id';
  static const String _agencyNameKey = 'selected_agency_name';
  static const String _agencyDataKey = 'selected_agency_data';

  // Sauvegarder l'agence sélectionnée
  static Future<void> saveSelectedAgency(Map<String, dynamic> agency) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_agencyIdKey, agency['id']);
    await prefs.setString(_agencyNameKey, agency['name']);

    // Sauvegarder toutes les données de l'agence (optionnel)
    await prefs.setString(_agencyDataKey, json.encode(agency));
  }

  // Récupérer l'agence sélectionnée
  static Future<Map<String, dynamic>?> getSelectedAgency() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final agencyId = prefs.getInt(_agencyIdKey);
      final agencyName = prefs.getString(_agencyNameKey);
      final agencyDataString = prefs.getString(_agencyDataKey);

      if (agencyDataString != null) {
        // Retourner toutes les données
        return json.decode(agencyDataString);
      } else if (agencyId != null && agencyName != null) {
        // Retourner les données de base
        return {'id': agencyId, 'name': agencyName};
      }
      return null;
    } catch (e) {
      print('Error getting selected agency: $e');
      return null;
    }
  }

  // Récupérer seulement l'ID de l'agence
  static Future<int?> getSelectedAgencyId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_agencyIdKey);
  }

  // Vérifier si une agence est sélectionnée
  static Future<bool> hasSelectedAgency() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_agencyIdKey);
  }

  // Effacer l'agence sélectionnée
  static Future<void> clearSelectedAgency() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_agencyIdKey);
    await prefs.remove(_agencyNameKey);
    await prefs.remove(_agencyDataKey);
  }
}
