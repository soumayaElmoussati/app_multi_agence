import 'package:flutter/material.dart';
import 'package:multi_agences_app/services/selected_agency_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';
import '../services/agency_service.dart';
import '../screens/dashboard_screen.dart';
import '../screens/add_agency_screen.dart';

class SelectAgencyScreen extends StatefulWidget {
  final Map<String, dynamic> userData;
  final String token;

  const SelectAgencyScreen({
    Key? key,
    required this.userData,
    required this.token,
  }) : super(key: key);

  @override
  _SelectAgencyScreenState createState() => _SelectAgencyScreenState();
}

class _SelectAgencyScreenState extends State<SelectAgencyScreen> {
  List<dynamic> _agencies = [];
  bool _isLoading = true;
  String _errorMessage = '';
  int? _selectedAgencyId;
  final AgencyService _agencyService = AgencyService();

  @override
  void initState() {
    super.initState();
    _loadUserAgencies();
  }

  Future<void> _loadUserAgencies() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final agencies = await _agencyService.getAllAgencies();
      setState(() {
        _agencies = agencies;
        // Sélectionner la première agence par défaut
        if (agencies.isNotEmpty) {
          _selectedAgencyId = agencies[0]['id'];
        }
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
      print('Erreur: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveSelectedAgencyAndContinue() async {
    if (_selectedAgencyId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Veuillez sélectionner une agence'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final selectedAgency = _agencies.firstWhere(
      (agency) => agency['id'] == _selectedAgencyId,
    );

    await SelectedAgencyService.saveSelectedAgency(selectedAgency);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => DashboardScreen(
          userData: widget.userData,
          token: widget.token,
          selectedAgency: selectedAgency,
        ),
      ),
    );
  }

  Future<void> _createNewAgency() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddAgencyScreen()),
    );

    if (result != null) {
      // Rafraîchir la liste des agences
      await _loadUserAgencies();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppTheme.white, AppTheme.background],
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo/Icon
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppTheme.primaryRed,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.business, color: AppTheme.white, size: 50),
              ),
              SizedBox(height: 32),

              Text(
                'Sélectionnez votre agence',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Bienvenue ${widget.userData['firstname']} ${widget.userData['lastname']}',
                style: TextStyle(fontSize: 16, color: AppTheme.textLight),
              ),
              SizedBox(height: 32),

              if (_isLoading)
                Center(
                  child: CircularProgressIndicator(color: AppTheme.primaryRed),
                )
              else if (_errorMessage.isNotEmpty)
                Text(
                  'Erreur: $_errorMessage',
                  style: TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                )
              else if (_agencies.isEmpty)
                Column(
                  children: [
                    Icon(
                      Icons.business_outlined,
                      size: 64,
                      color: AppTheme.textLight,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Aucune agence trouvée',
                      style: TextStyle(color: AppTheme.textDark, fontSize: 18),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Créez votre première agence pour commencer',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppTheme.textLight),
                    ),
                    SizedBox(height: 24),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryRed,
                        foregroundColor: AppTheme.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: _createNewAgency,
                      child: Text('CRÉER UNE AGENCE'),
                    ),
                  ],
                )
              else
                // Liste des agences
                Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          itemCount: _agencies.length,
                          itemBuilder: (context, index) {
                            final agency = _agencies[index];
                            final isSelected =
                                _selectedAgencyId == agency['id'];

                            return Card(
                              margin: EdgeInsets.only(bottom: 12),
                              color: isSelected
                                  ? AppTheme.primaryRed.withOpacity(0.1)
                                  : Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(
                                  color: isSelected
                                      ? AppTheme.primaryRed
                                      : Colors.grey.shade200,
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: ListTile(
                                leading: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryRed,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.business,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                                title: Text(
                                  agency['name'] ?? 'Sans nom',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.textDark,
                                  ),
                                ),
                                subtitle: Text(
                                  agency['address'] ?? 'Pas d\'adresse',
                                  style: TextStyle(color: AppTheme.textLight),
                                ),
                                trailing: isSelected
                                    ? Icon(
                                        Icons.check_circle,
                                        color: AppTheme.primaryRed,
                                      )
                                    : null,
                                onTap: () {
                                  setState(() {
                                    _selectedAgencyId = agency['id'];
                                  });
                                },
                              ),
                            );
                          },
                        ),
                      ),

                      SizedBox(height: 20),

                      // Bouton Continuer
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _saveSelectedAgencyAndContinue,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryRed,
                            foregroundColor: AppTheme.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 2,
                          ),
                          child: Text(
                            'CONTINUER',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 16),

                      // Bouton Créer une nouvelle agence
                      OutlinedButton(
                        onPressed: _createNewAgency,
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: AppTheme.primaryRed),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          '+ CRÉER UNE NOUVELLE AGENCE',
                          style: TextStyle(color: AppTheme.primaryRed),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
