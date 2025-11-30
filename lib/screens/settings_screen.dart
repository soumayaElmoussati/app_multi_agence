import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'login_screen.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  bool _biometricEnabled = false;
  String _selectedLanguage = 'fr';
  String _selectedCurrency = 'EUR';

  final List<Map<String, String>> _languages = [
    {'code': 'fr', 'name': 'Français'},
    {'code': 'ar', 'name': 'العربية'},
    {'code': 'en', 'name': 'English'},
  ];

  final List<Map<String, String>> _currencies = [
    {'code': 'EUR', 'name': 'Euro (DH)'},
    {'code': 'MAD', 'name': 'Dirham Marocain (MAD)'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Paramètres'),
        backgroundColor: AppTheme.white,
        foregroundColor: AppTheme.primaryRed,
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          // Profile Section
          _buildProfileSection(),
          SizedBox(height: 24),

          // Application Settings
          _buildSectionTitle('Paramètres de l\'Application'),
          _buildSettingCard(
            Icons.language,
            'Langue',
            _getLanguageName(_selectedLanguage),
            _showLanguageDialog,
          ),
          _buildSettingCard(
            Icons.attach_money,
            'Devise',
            _getCurrencyName(_selectedCurrency),
            _showCurrencyDialog,
          ),
          _buildSwitchSetting(
            Icons.dark_mode,
            'Mode Sombre',
            _darkModeEnabled,
            (value) => setState(() => _darkModeEnabled = value),
          ),
          SizedBox(height: 24),

          // Notifications
          _buildSectionTitle('Notifications'),
          _buildSwitchSetting(
            Icons.notifications,
            'Notifications',
            _notificationsEnabled,
            (value) => setState(() => _notificationsEnabled = value),
          ),
          SizedBox(height: 24),

          // Security
          _buildSectionTitle('Sécurité'),
          _buildSwitchSetting(
            Icons.fingerprint,
            'Authentification Biométrique',
            _biometricEnabled,
            (value) => setState(() => _biometricEnabled = value),
          ),
          _buildSettingCard(
            Icons.lock,
            'Changer le Mot de Passe',
            'Dernière modification: 15/03/2024',
            _changePassword,
          ),
          SizedBox(height: 24),

          // Company Settings
          _buildSectionTitle('Paramètres Entreprise'),
          _buildSettingCard(
            Icons.business,
            'Informations Entreprise',
            'Configurer les coordonnées',
            _editCompanyInfo,
          ),
          _buildSettingCard(
            Icons.receipt_long,
            'Paramètres Facturation',
            'Modèles et mentions légales',
            _editInvoiceSettings,
          ),
          SizedBox(height: 24),

          // Data Management
          _buildSectionTitle('Gestion des Données'),
          _buildSettingCard(
            Icons.backup,
            'Sauvegarde',
            'Dernière sauvegarde: Aujourd\'hui',
            _backupData,
          ),
          _buildSettingCard(
            Icons.restore,
            'Restauration',
            'Restaurer depuis une sauvegarde',
            _restoreData,
          ),
          SizedBox(height: 24),

          // Danger Zone
          _buildSectionTitle('Zone de Danger'),
          _buildDangerCard(
            Icons.delete,
            'Supprimer les Données',
            'Effacer toutes les données de l\'application',
            _deleteAllData,
          ),
          _buildDangerCard(
            Icons.logout,
            'Déconnexion',
            'Se déconnecter de l\'application',
            _logout,
          ),
          SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildProfileSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Row(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: AppTheme.primaryRed.withOpacity(0.1),
              child: Icon(Icons.person, size: 40, color: AppTheme.primaryRed),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'John Doe',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'john.doe@entreprise.com',
                    style: TextStyle(color: AppTheme.textLight),
                  ),
                  SizedBox(height: 8),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryRed.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Administrateur',
                      style: TextStyle(
                        color: AppTheme.primaryRed,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.edit, color: AppTheme.primaryRed),
              onPressed: _editProfile,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: AppTheme.textDark,
        ),
      ),
    );
  }

  Widget _buildSettingCard(
    IconData icon,
    String title,
    String subtitle,
    Function onTap,
  ) {
    return Card(
      margin: EdgeInsets.only(bottom: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppTheme.primaryRed.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppTheme.primaryRed, size: 20),
        ),
        title: Text(
          title,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(fontSize: 12, color: AppTheme.textLight),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: AppTheme.textLight,
        ),
        onTap: () => onTap(),
      ),
    );
  }

  Widget _buildSwitchSetting(
    IconData icon,
    String title,
    bool value,
    Function(bool) onChanged,
  ) {
    return Card(
      margin: EdgeInsets.only(bottom: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppTheme.primaryRed.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppTheme.primaryRed, size: 20),
        ),
        title: Text(
          title,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppTheme.primaryRed,
        ),
      ),
    );
  }

  Widget _buildDangerCard(
    IconData icon,
    String title,
    String subtitle,
    Function onTap,
  ) {
    return Card(
      margin: EdgeInsets.only(bottom: 8),
      elevation: 1,
      color: Colors.red.withOpacity(0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.red.withOpacity(0.2)),
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.red, size: 20),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.red,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(fontSize: 12, color: Colors.red.withOpacity(0.7)),
        ),
        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.red),
        onTap: () => onTap(),
      ),
    );
  }

  String _getLanguageName(String code) {
    return _languages.firstWhere(
      (lang) => lang['code'] == code,
      orElse: () => {'name': 'Français'},
    )['name']!;
  }

  String _getCurrencyName(String code) {
    return _currencies.firstWhere(
      (currency) => currency['code'] == code,
      orElse: () => {'name': 'Euro (DH)'},
    )['name']!;
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Changer la Langue'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _languages.map((language) {
            return RadioListTile<String>(
              title: Text(language['name']!),
              value: language['code']!,
              groupValue: _selectedLanguage,
              onChanged: (value) {
                setState(() {
                  _selectedLanguage = value!;
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Langue changée en ${language['name']}'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showCurrencyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Changer la Devise'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _currencies.map((currency) {
            return RadioListTile<String>(
              title: Text(currency['name']!),
              value: currency['code']!,
              groupValue: _selectedCurrency,
              onChanged: (value) {
                setState(() {
                  _selectedCurrency = value!;
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Devise changée en ${currency['name']}'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _editProfile() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Modifier le Profil'),
        content: Text('Fonctionnalité en développement'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _changePassword() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Changer le Mot de Passe'),
        content: Text('Fonctionnalité en développement'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _editCompanyInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Informations Entreprise'),
        content: Text('Fonctionnalité en développement'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _editInvoiceSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Paramètres Facturation'),
        content: Text('Fonctionnalité en développement'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _backupData() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sauvegarde des données en cours...'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _restoreData() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Restauration des Données'),
        content: Text('Fonctionnalité en développement'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _deleteAllData() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Supprimer Toutes les Données'),
        content: Text(
          'Êtes-vous sûr de vouloir supprimer toutes les données ? Cette action est irréversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler', style: TextStyle(color: AppTheme.textLight)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Toutes les données ont été supprimées'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: Text('Supprimer', style: TextStyle(color: AppTheme.white)),
          ),
        ],
      ),
    );
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Déconnexion'),
        content: Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler', style: TextStyle(color: AppTheme.textLight)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryRed,
            ),
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
            child: Text('Déconnexion', style: TextStyle(color: AppTheme.white)),
          ),
        ],
      ),
    );
  }
}
