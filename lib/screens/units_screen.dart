import 'package:flutter/material.dart';
import 'package:multi_agences_app/screens/categories_screen.dart';
import 'package:multi_agences_app/screens/clients_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';
import '../services/unit_service.dart';
import '../services/selected_agency_service.dart';

class UnitsScreen extends StatefulWidget {
  @override
  _UnitsScreenState createState() => _UnitsScreenState();
}

class _UnitsScreenState extends State<UnitsScreen> {
  List<dynamic> _units = [];
  bool _isLoading = true;
  String _errorMessage = '';
  int _currentIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Services
  final UnitService _unitService = UnitService();
  Map<String, dynamic>? _selectedAgency;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    // Vérifier si une agence est sélectionnée
    _selectedAgency = await SelectedAgencyService.getSelectedAgency();

    // Charger les unités
    await _loadUnits();
  }

  // Charger les unités depuis l'API
  Future<void> _loadUnits() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final units = await _unitService.getAllUnits();
      setState(() {
        _units = units;
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

  // Rafraîchir les données
  Future<void> _refreshData() async {
    await _loadUnits();
  }

  // Ajouter une unité
  Future<void> _addUnit() async {
    _showAddUnitModal();
  }

  // Modifier une unité
  Future<void> _editUnit(Map<String, dynamic> unit) async {
    _showEditUnitModal(unit);
  }

  // Supprimer une unité
  Future<void> _deleteUnit(int id, String name) async {
    final confirmed = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Supprimer l\'unité'),
        content: Text('Voulez-vous vraiment supprimer l\'unité "$name" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _unitService.deleteUnit(id);
        // Rafraîchir la liste
        await _loadUnits();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Unité supprimée avec succès'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: _buildModernAppBar(),
      bottomNavigationBar: _buildBottomNavBar(),
      drawer: _buildSidebar(),
      body: _isLoading
          ? _buildLoadingIndicator()
          : _errorMessage.isNotEmpty
          ? _buildErrorWidget()
          : RefreshIndicator(
              onRefresh: _refreshData,
              color: AppTheme.primaryRed,
              child: _buildMainContent(),
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primaryRed,
        onPressed: _addUnit,
        child: Icon(Icons.add, color: AppTheme.white, size: 28),
      ),
    );
  }

  Widget _buildMainContent() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatsHeader(),
          SizedBox(height: 20),
          if (_units.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.square_foot_outlined,
                      size: 64,
                      color: AppTheme.textLight,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Aucune unité trouvée',
                      style: TextStyle(color: AppTheme.textDark, fontSize: 18),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Ajoutez votre première unité',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppTheme.textLight),
                    ),
                  ],
                ),
              ),
            )
          else
            Expanded(child: _buildUnitsGrid()),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppTheme.primaryRed),
          SizedBox(height: 20),
          Text(
            'Chargement des unités...',
            style: TextStyle(color: AppTheme.textDark),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: AppTheme.primaryRed, size: 64),
            SizedBox(height: 20),
            Text(
              'Erreur de chargement',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark,
              ),
            ),
            SizedBox(height: 10),
            Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textLight),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryRed,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: _loadUnits,
              child: Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }

  // HEADER MODERNE
  PreferredSizeWidget _buildModernAppBar() {
    return PreferredSize(
      preferredSize: Size.fromHeight(100),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFD32F2F), Color(0xFFC2185B), Color(0xFF7B1FA2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(25),
            bottomRight: Radius.circular(25),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 15,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                  ),
                  child: IconButton(
                    icon: Icon(Icons.menu_rounded, color: Colors.white),
                    onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Gestion des unités',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                        ),
                      ),
                      child: IconButton(
                        icon: Icon(Icons.refresh, color: Colors.white),
                        onPressed: _refreshData,
                      ),
                    ),
                    SizedBox(width: 8),
                    Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                            ),
                          ),
                          child: IconButton(
                            icon: Icon(
                              Icons.notifications_rounded,
                              color: Colors.white,
                            ),
                            onPressed: _showNotifications,
                          ),
                        ),
                        Positioned(
                          right: 8,
                          top: 8,
                          child: Container(
                            padding: EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Color(0xFFFFA000),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 1.5,
                              ),
                            ),
                            constraints: BoxConstraints(
                              minWidth: 18,
                              minHeight: 18,
                            ),
                            child: Text(
                              '3',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // STATS HEADER
  Widget _buildStatsHeader() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [AppTheme.primaryRed, AppTheme.lightRed],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryRed.withOpacity(0.3),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.square_foot, color: Colors.white, size: 30),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_units.length} Unités',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Gestion des unités de mesure',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Actif',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // UNITS GRID
  Widget _buildUnitsGrid() {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.9,
      ),
      itemCount: _units.length,
      itemBuilder: (context, index) {
        final unit = _units[index];
        return _buildUnitCard(unit, index);
      },
    );
  }

  Widget _buildUnitCard(Map<String, dynamic> unit, int index) {
    // Couleurs fixes pour les unités
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.indigo,
      Colors.amber,
    ];
    final color = colors[index % colors.length];

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
          ),
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.square_foot,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    unit['name'] ?? 'Sans nom',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Symbole: ${unit['abbreviation'] ?? unit['symbol'] ?? 'N/A'}',
                    style: TextStyle(fontSize: 12, color: AppTheme.textLight),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Spacer(),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      unit['abbreviation'] ?? unit['symbol'] ?? '',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: PopupMenuButton<String>(
                icon: Icon(
                  Icons.more_vert,
                  color: AppTheme.textLight,
                  size: 20,
                ),
                itemBuilder: (context) => [
                  PopupMenuItem(value: 'edit', child: Text('Modifier')),
                  PopupMenuItem(
                    value: 'delete',
                    child: Text(
                      'Supprimer',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
                onSelected: (value) {
                  if (value == 'edit') {
                    _editUnit(unit);
                  } else if (value == 'delete') {
                    _deleteUnit(unit['id'], unit['name']);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =============================================
  // MODAL D'AJOUT D'UNITÉ (SÉPARÉ)
  // =============================================
  void _showAddUnitModal() {
    final nameController = TextEditingController();
    final abbreviationController = TextEditingController();
    bool _isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.75,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(25),
                topRight: Radius.circular(25),
              ),
            ),
            child: Column(
              children: [
                // Header du modal
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFFD32F2F),
                        Color(0xFFC2185B),
                        Color(0xFF7B1FA2),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(25),
                      topRight: Radius.circular(25),
                    ),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.close, color: Colors.white),
                        onPressed: _isSubmitting
                            ? null
                            : () => Navigator.pop(context),
                      ),
                      SizedBox(width: 16),
                      Text(
                        'NOUVELLE UNITÉ',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                // Contenu du formulaire
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Créer une nouvelle unité',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textDark,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Remplissez les informations ci-dessous',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textLight,
                          ),
                        ),
                        SizedBox(height: 20),

                        // Champ Nom
                        TextFormField(
                          controller: nameController,
                          enabled: !_isSubmitting,
                          decoration: InputDecoration(
                            labelText: 'Nom de l\'unité *',
                            hintText: 'Ex: Kilogramme',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            prefixIcon: Icon(
                              Icons.square_foot,
                              color: AppTheme.primaryRed,
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                          ),
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 20),

                        // Champ Abréviation
                        TextFormField(
                          controller: abbreviationController,
                          enabled: !_isSubmitting,
                          decoration: InputDecoration(
                            labelText: 'Abréviation *',
                            hintText: 'Ex: kg',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            prefixIcon: Icon(
                              Icons.text_fields,
                              color: AppTheme.primaryRed,
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                          ),
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 30),

                        // Info agence
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryRed.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.business,
                                color: AppTheme.primaryRed,
                                size: 20,
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  _selectedAgency != null
                                      ? 'Cette unité sera créée pour l\'agence: ${_selectedAgency!['name']}'
                                      : 'Aucune agence sélectionnée',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.textDark,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 20),

                        // Boutons d'action
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: _isSubmitting
                                    ? null
                                    : () => Navigator.pop(context),
                                style: OutlinedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  side: BorderSide(color: AppTheme.primaryRed),
                                ),
                                child: Text(
                                  'ANNULER',
                                  style: TextStyle(
                                    color: AppTheme.primaryRed,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _isSubmitting
                                    ? null
                                    : () async {
                                        if (nameController.text.isEmpty ||
                                            abbreviationController
                                                .text
                                                .isEmpty) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Le nom et l\'abréviation sont obligatoires',
                                              ),
                                              backgroundColor:
                                                  AppTheme.primaryRed,
                                            ),
                                          );
                                          return;
                                        }

                                        if (_selectedAgency == null) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Veuillez sélectionner une agence d\'abord',
                                              ),
                                              backgroundColor: Colors.orange,
                                            ),
                                          );
                                          return;
                                        }

                                        setState(() {
                                          _isSubmitting = true;
                                        });

                                        try {
                                          final unitData = {
                                            'name': nameController.text,
                                            'abbreviation':
                                                abbreviationController.text,
                                          };

                                          print('🟡 Creating unit: $unitData');

                                          final result = await _unitService
                                              .createUnit(unitData);

                                          if (result['success'] == true) {
                                            // Rafraîchir la liste
                                            await _loadUnits();
                                            Navigator.pop(context);

                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  'Unité créée avec succès',
                                                ),
                                                backgroundColor: Colors.green,
                                              ),
                                            );
                                          } else {
                                            // Afficher les erreurs de validation
                                            if (result['errors'] != null) {
                                              final errors = result['errors'];
                                              String errorMessage = '';

                                              if (errors['name'] != null) {
                                                errorMessage +=
                                                    'Nom: ${errors['name'][0]}\n';
                                              }
                                              if (errors['abbreviation'] !=
                                                  null) {
                                                errorMessage +=
                                                    'Abréviation: ${errors['abbreviation'][0]}\n';
                                              }
                                              if (errors['agency_id'] != null) {
                                                errorMessage +=
                                                    'Agence: ${errors['agency_id'][0]}\n';
                                              }

                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text(errorMessage),
                                                  backgroundColor: Colors.red,
                                                ),
                                              );
                                            } else {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    result['message'] ??
                                                        'Erreur',
                                                  ),
                                                  backgroundColor: Colors.red,
                                                ),
                                              );
                                            }
                                          }
                                        } catch (e) {
                                          print('❌ Error: $e');
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text('Erreur: $e'),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                        } finally {
                                          if (mounted) {
                                            setState(() {
                                              _isSubmitting = false;
                                            });
                                          }
                                        }
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primaryRed,
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 4,
                                ),
                                child: _isSubmitting
                                    ? SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Colors.white,
                                              ),
                                        ),
                                      )
                                    : Text(
                                        'CRÉER',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // =============================================
  // MODAL DE MODIFICATION D'UNITÉ (SÉPARÉ)
  // =============================================
  void _showEditUnitModal(Map<String, dynamic> unit) {
    final nameController = TextEditingController(text: unit['name'] ?? '');
    final abbreviationController = TextEditingController(
      text: unit['abbreviation'] ?? unit['symbol'] ?? '',
    );
    bool _isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.75,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(25),
                topRight: Radius.circular(25),
              ),
            ),
            child: Column(
              children: [
                // Header du modal
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFFD32F2F),
                        Color(0xFFC2185B),
                        Color(0xFF7B1FA2),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(25),
                      topRight: Radius.circular(25),
                    ),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.close, color: Colors.white),
                        onPressed: _isSubmitting
                            ? null
                            : () => Navigator.pop(context),
                      ),
                      SizedBox(width: 16),
                      Text(
                        'MODIFIER L\'UNITÉ',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                // Contenu du formulaire
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Modifier l\'unité',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textDark,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'ID: ${unit['id']}',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textLight,
                          ),
                        ),
                        SizedBox(height: 20),

                        // Champ Nom
                        TextFormField(
                          controller: nameController,
                          enabled: !_isSubmitting,
                          decoration: InputDecoration(
                            labelText: 'Nom de l\'unité *',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            prefixIcon: Icon(
                              Icons.square_foot,
                              color: AppTheme.primaryRed,
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                          ),
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 20),

                        // Champ Abréviation
                        TextFormField(
                          controller: abbreviationController,
                          enabled: !_isSubmitting,
                          decoration: InputDecoration(
                            labelText: 'Abréviation *',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            prefixIcon: Icon(
                              Icons.text_fields,
                              color: AppTheme.primaryRed,
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                          ),
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 30),

                        // Info agence
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryRed.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.business,
                                color: AppTheme.primaryRed,
                                size: 20,
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  _selectedAgency != null
                                      ? 'Agence: ${_selectedAgency!['name']}'
                                      : 'Aucune agence',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.textDark,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 20),

                        // Boutons d'action
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: _isSubmitting
                                    ? null
                                    : () => Navigator.pop(context),
                                style: OutlinedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  side: BorderSide(color: AppTheme.primaryRed),
                                ),
                                child: Text(
                                  'ANNULER',
                                  style: TextStyle(
                                    color: AppTheme.primaryRed,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _isSubmitting
                                    ? null
                                    : () async {
                                        if (nameController.text.isEmpty ||
                                            abbreviationController
                                                .text
                                                .isEmpty) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Le nom et l\'abréviation sont obligatoires',
                                              ),
                                              backgroundColor:
                                                  AppTheme.primaryRed,
                                            ),
                                          );
                                          return;
                                        }

                                        setState(() {
                                          _isSubmitting = true;
                                        });

                                        try {
                                          final unitData = {
                                            'name': nameController.text,
                                            'abbreviation':
                                                abbreviationController.text,
                                          };

                                          print(
                                            '🟡 Updating unit ${unit['id']}: $unitData',
                                          );

                                          final result = await _unitService
                                              .updateUnit(unit['id'], unitData);

                                          if (result['success'] == true) {
                                            // Rafraîchir la liste
                                            await _loadUnits();
                                            Navigator.pop(context);

                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  'Unité modifiée avec succès',
                                                ),
                                                backgroundColor: Colors.green,
                                              ),
                                            );
                                          } else {
                                            // Afficher les erreurs de validation
                                            if (result['errors'] != null) {
                                              final errors = result['errors'];
                                              String errorMessage = '';

                                              if (errors['name'] != null) {
                                                errorMessage +=
                                                    'Nom: ${errors['name'][0]}\n';
                                              }
                                              if (errors['abbreviation'] !=
                                                  null) {
                                                errorMessage +=
                                                    'Abréviation: ${errors['abbreviation'][0]}\n';
                                              }

                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text(errorMessage),
                                                  backgroundColor: Colors.red,
                                                ),
                                              );
                                            } else {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    result['message'] ??
                                                        'Erreur',
                                                  ),
                                                  backgroundColor: Colors.red,
                                                ),
                                              );
                                            }
                                          }
                                        } catch (e) {
                                          print('❌ Error: $e');
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text('Erreur: $e'),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                        } finally {
                                          if (mounted) {
                                            setState(() {
                                              _isSubmitting = false;
                                            });
                                          }
                                        }
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primaryRed,
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 4,
                                ),
                                child: _isSubmitting
                                    ? SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Colors.white,
                                              ),
                                        ),
                                      )
                                    : Text(
                                        'MODIFIER',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // BOTTOM NAVBAR
  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          backgroundColor: Colors.white,
          selectedItemColor: AppTheme.primaryRed,
          unselectedItemColor: Color(0xFF9E9E9E),
          selectedLabelStyle: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: TextStyle(fontSize: 11),
          type: BottomNavigationBarType.fixed,
          elevation: 8,
          items: [
            BottomNavigationBarItem(
              icon: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: _currentIndex == 0
                      ? AppTheme.primaryRed.withOpacity(0.1)
                      : Colors.transparent,
                ),
                child: Icon(Icons.home_rounded, size: 24),
              ),
              label: 'Accueil',
            ),
            BottomNavigationBarItem(
              icon: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: _currentIndex == 1
                      ? AppTheme.primaryRed.withOpacity(0.1)
                      : Colors.transparent,
                ),
                child: Icon(Icons.square_foot_rounded, size: 24),
              ),
              label: 'Unités',
            ),
            BottomNavigationBarItem(
              icon: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: _currentIndex == 2
                      ? AppTheme.primaryRed.withOpacity(0.1)
                      : Colors.transparent,
                ),
                child: Icon(Icons.analytics_rounded, size: 24),
              ),
              label: 'Stats',
            ),
            BottomNavigationBarItem(
              icon: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: _currentIndex == 3
                      ? AppTheme.primaryRed.withOpacity(0.1)
                      : Colors.transparent,
                ),
                child: Icon(Icons.person_rounded, size: 24),
              ),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }

  // SIDEBAR
  Widget _buildSidebar() {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            // Header du sidebar
            Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFFD32F2F),
                    Color(0xFFC2185B),
                    Color(0xFF7B1FA2),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.person,
                        size: 38,
                        color: AppTheme.primaryRed,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Mohamed Ali',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Administrateur',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 12,
                      ),
                    ),
                    SizedBox(height: 6),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Premium',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Menu items
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildSidebarItem(Icons.dashboard, 'Tableau de bord', () {
                    Navigator.pop(context);
                  }, isActive: false),
                  _buildSidebarItem(Icons.inventory_2, 'Gestion Produits', () {
                    Navigator.pop(context);
                  }, isActive: false),
                  _buildSidebarItem(Icons.category, 'Catégories', () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CategoriesScreen(),
                      ),
                    );
                  }, isActive: false),
                  _buildSidebarItem(Icons.square_foot, 'Unités', () {
                    Navigator.pop(context);
                  }, isActive: true),

                  _buildSidebarItem(Icons.category, 'Clients', () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ClientsScreen()),
                    );
                  }, isActive: false),

                  _buildSidebarItem(Icons.shopping_cart, 'Ventes', () {
                    Navigator.pop(context);
                  }, isActive: false),
                  _buildSidebarItem(Icons.analytics, 'Rapports', () {
                    Navigator.pop(context);
                  }, isActive: false),
                  _buildSidebarItem(Icons.settings, 'Paramètres', () {
                    Navigator.pop(context);
                  }, isActive: false),
                  _buildSidebarItem(Icons.receipt, 'Factures', () {
                    Navigator.pop(context);
                  }, isActive: false),
                  _buildSidebarItem(Icons.local_shipping, 'Fournisseurs', () {
                    Navigator.pop(context);
                  }, isActive: false),

                  Divider(height: 20, indent: 20, endIndent: 20),

                  _buildSidebarItem(Icons.help, 'Aide & Support', () {
                    Navigator.pop(context);
                  }, isActive: false),
                  _buildSidebarItem(Icons.info, 'À propos', () {
                    Navigator.pop(context);
                  }, isActive: false),
                  _buildSidebarItem(Icons.logout, 'Déconnexion', () {
                    Navigator.pop(context);
                    _showLogoutDialog();
                  }, isActive: false),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebarItem(
    IconData icon,
    String title,
    VoidCallback onTap, {
    bool isActive = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isActive ? AppTheme.primaryRed : AppTheme.textLight,
        size: 24,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isActive ? AppTheme.primaryRed : AppTheme.textDark,
          fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          fontSize: 16,
        ),
      ),
      trailing: isActive
          ? Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: AppTheme.primaryRed,
                shape: BoxShape.circle,
              ),
            )
          : Icon(Icons.chevron_right, color: AppTheme.textLight, size: 20),
      onTap: onTap,
      tileColor: isActive ? AppTheme.primaryRed.withOpacity(0.1) : null,
    );
  }

  void _showNotifications() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Notifications'),
        content: Text('Vous avez 3 nouvelles notifications'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Fermer', style: TextStyle(color: AppTheme.primaryRed)),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Déconnexion'),
        content: Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              // Effacer les données d'authentification
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();

              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/login');
            },
            child: Text(
              'Déconnexion',
              style: TextStyle(color: AppTheme.primaryRed),
            ),
          ),
        ],
      ),
    );
  }
}
