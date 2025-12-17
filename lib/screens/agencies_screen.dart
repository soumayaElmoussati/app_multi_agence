import 'package:flutter/material.dart';
import 'package:multi_agences_app/screens/add_agency_screen.dart';
import '../theme/app_theme.dart';
import '../widgets/agency_card.dart';
import '../screens/categories_screen.dart';
import '../screens/clients_screen.dart';
import '../screens/suppliers_screen.dart';
import '../screens/units_screen.dart';
import '../services/agency_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AgenciesScreen extends StatefulWidget {
  @override
  _AgenciesScreenState createState() => _AgenciesScreenState();
}

class _AgenciesScreenState extends State<AgenciesScreen> {
  List<dynamic> _agencies = [];
  bool _isLoading = true;
  String _errorMessage = '';
  String _searchQuery = '';

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Service
  final AgencyService _agencyService = AgencyService();

  @override
  void initState() {
    super.initState();
    _loadAgencies();
  }

  // Charger les agences
  Future<void> _loadAgencies() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final agencies = await _agencyService.getAllAgencies();
      setState(() {
        _agencies = agencies;
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
    await _loadAgencies();
  }

  // Filtrer les agences par recherche
  List<dynamic> get _filteredAgencies {
    if (_searchQuery.isEmpty) {
      return _agencies;
    }
    return _agencies.where((agency) {
      final name = agency['name']?.toString().toLowerCase() ?? '';
      final address = agency['address']?.toString().toLowerCase() ?? '';
      final manager = agency['manager']?.toString().toLowerCase() ?? '';
      final phone = agency['phone']?.toString().toLowerCase() ?? '';
      final query = _searchQuery.toLowerCase();

      return name.contains(query) ||
          address.contains(query) ||
          manager.contains(query) ||
          phone.contains(query);
    }).toList();
  }

  // Supprimer une agence
  Future<void> _deleteAgency(int id, String name) async {
    final confirmed = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirmer la suppression'),
        content: Text('Voulez-vous vraiment supprimer l\'agence "$name" ?'),
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
        await _agencyService.deleteAgency(id);
        // Supprimer de la liste locale
        setState(() {
          _agencies.removeWhere((agency) => agency['id'] == id);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Agence supprimée avec succès'),
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

  // Méthode pour vérifier si l'utilisateur est connecté
  Future<bool> _checkIfLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    return token != null && token.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: _buildModernAppBar(),
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
        onPressed: _addAgency,
        child: Icon(Icons.add, color: AppTheme.white),
      ),
    );
  }

  Widget _buildMainContent() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          // Header Stats
          _buildStatsHeader(),
          SizedBox(height: 20),

          // Search Bar
          TextField(
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
            decoration: InputDecoration(
              hintText: 'Rechercher une agence...',
              prefixIcon: Icon(Icons.search, color: AppTheme.primaryRed),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.clear, color: AppTheme.primaryRed),
                      onPressed: () {
                        setState(() {
                          _searchQuery = '';
                        });
                      },
                    )
                  : null,
              filled: true,
              fillColor: AppTheme.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          SizedBox(height: 20),

          // Message si pas d'agences
          if (_filteredAgencies.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _searchQuery.isEmpty
                          ? Icons.business_outlined
                          : Icons.search_off,
                      size: 64,
                      color: AppTheme.textLight,
                    ),
                    SizedBox(height: 16),
                    Text(
                      _searchQuery.isEmpty
                          ? 'Aucune agence trouvée'
                          : 'Aucune agence correspondant à "$_searchQuery"',
                      style: TextStyle(color: AppTheme.textLight, fontSize: 16),
                    ),
                    if (_searchQuery.isEmpty)
                      Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Text(
                          'Ajoutez votre première agence en cliquant sur le bouton +',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppTheme.textLight,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            )
          else
            // Agencies List
            Expanded(
              child: ListView.builder(
                itemCount: _filteredAgencies.length,
                itemBuilder: (context, index) {
                  final agency = _filteredAgencies[index];
                  return AgencyCard(
                    agency: agency,
                    //    onDelete: () => _deleteAgency(agency['id'], agency['name']),
                    //   onEdit: () => _editAgency(agency),
                  );
                },
              ),
            ),
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
            'Chargement des agences...',
            style: TextStyle(color: AppTheme.textDark, fontSize: 16),
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
              onPressed: _loadAgencies,
              child: Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsHeader() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryRed.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(_agencies.length.toString(), 'Agences'),
          _buildStatItem('${_agencies.length * 620}', 'Ventes/mois'),
          _buildStatItem('${_agencies.length * 620 * 37} DH', 'CA Total'),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryRed,
          ),
        ),
        SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, color: AppTheme.textLight)),
      ],
    );
  }

  // HEADER MODERNE (identique à votre code)
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
                        'MES AGENCES',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '${_agencies.length} agences gérées',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 12,
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
                        icon: Icon(Icons.refresh_rounded, color: Colors.white),
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

  void _addAgency() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddAgencyScreen()),
    ).then((newAgency) {
      if (newAgency != null) {
        // Rafraîchir la liste après ajout
        _loadAgencies();
      }
    });
  }

  // void _editAgency(Map<String, dynamic> agency) {
  //   Navigator.push(
  //  context,
  //   MaterialPageRoute(builder: (context) => AddAgencyScreen(agency: agency)),
  //   ).then((updatedAgency) {
  //     if (updatedAgency != null) {
  // Rafraîchir la liste après modification
  //     _loadAgencies();
  //    }
  //  });
  // }

  // SIDEBAR (identique à votre code)
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

            // Menu items avec scroll
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
                  _buildSidebarItem(Icons.business, 'Mes Agences', () {
                    Navigator.pop(context);
                  }, isActive: true),
                  _buildSidebarItem(Icons.category, 'Catégories', () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CategoriesScreen(),
                      ),
                    );
                  }, isActive: false),
                  _buildSidebarItem(Icons.category, 'Unités', () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => UnitsScreen()),
                    );
                  }, isActive: false),
                  _buildSidebarItem(Icons.category, 'Clients', () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ClientsScreen()),
                    );
                  }, isActive: false),
                  _buildSidebarItem(Icons.local_shipping, 'Fournisseurs', () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SuppliersScreen(),
                      ),
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
              // Logout logic
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('auth_token');
              await prefs.remove('user');

              Navigator.pop(context); // Fermer la boîte de dialogue
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
}
