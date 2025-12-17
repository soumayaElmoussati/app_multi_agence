import 'package:flutter/material.dart';
import 'package:multi_agences_app/screens/add_supplier_screen.dart';
import '../theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/supplier_service.dart';
import '../services/selected_agency_service.dart';

class SuppliersScreen extends StatefulWidget {
  @override
  _SuppliersScreenState createState() => _SuppliersScreenState();
}

class _SuppliersScreenState extends State<SuppliersScreen> {
  List<Map<String, dynamic>> _suppliers = [];
  bool _isLoading = true;
  String _errorMessage = '';

  int _currentIndex = 1;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Services
  final SupplierService _supplierService = SupplierService();
  Map<String, dynamic>? _selectedAgency;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    // Vérifier si une agence est sélectionnée
    _selectedAgency = await SelectedAgencyService.getSelectedAgency();

    // Charger les fournisseurs
    await _loadSuppliers();
  }

  Future<void> _loadSuppliers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final suppliers = await _supplierService.getAllSuppliers();
      setState(() {
        _suppliers = suppliers.map((supplier) {
          // Convertir la réponse API au format de votre interface
          return {
            'id': supplier['id'].toString(),
            'name': supplier['name'],
            'contact': supplier['name'],
            'email': supplier['email'],
            'phone': supplier['phone'],
            'address': supplier['address'],
            'totalOrders': 0,
            'totalAmount':
                double.tryParse(supplier['credit_balance'] ?? '0') ?? 0.0,
            'lastDelivery': '',
            'status': 'Actif',
            'color': _getRandomColor(_suppliers.length),
            'credit_limit': supplier['credit_limit'],
            'ice': supplier['ice'],
            'rc': supplier['rc'],
            'agency_id': supplier['agency_id'],
            'user_id': supplier['user_id'],
            'cnss': supplier['cnss'],
            'if': supplier['if'],
            'latitude': supplier['latitude'],
            'longitude': supplier['longitude'],
          };
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
      print('Erreur: $e');
    }
  }

  Color _getRandomColor(int index) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.indigo,
      Colors.pink,
    ];
    return colors[index % colors.length];
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
              onRefresh: _loadSuppliers,
              color: AppTheme.primaryRed,
              child: _buildMainContent(),
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primaryRed,
        onPressed: _addSupplier,
        child: Icon(Icons.add_business, color: AppTheme.white, size: 28),
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
          _buildSearchBar(),
          SizedBox(height: 20),
          if (_suppliers.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.business_outlined,
                      color: AppTheme.textLight,
                      size: 60,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Aucun fournisseur trouvé',
                      style: TextStyle(
                        color: AppTheme.textDark,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Ajoutez votre premier fournisseur',
                      style: TextStyle(color: AppTheme.textLight, fontSize: 14),
                    ),
                  ],
                ),
              ),
            )
          else
            Expanded(child: _buildSuppliersList()),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryRed),
          ),
          SizedBox(height: 20),
          Text(
            'Chargement des fournisseurs...',
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
              onPressed: _loadSuppliers,
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
                        'Gestion des fournisseurs',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      if (_selectedAgency != null)
                        Text(
                          _selectedAgency!['name'],
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
                        icon: Icon(Icons.refresh, color: Colors.white),
                        onPressed: _loadSuppliers,
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
                              '2',
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
    final totalSuppliers = _suppliers.length;
    final totalAmount = _suppliers.fold(
      0.0,
      (sum, supplier) => sum + (supplier['totalAmount'] as double),
    );
    final premiumSuppliers = _suppliers
        .where((supplier) => supplier['status'] == 'Premium')
        .length;

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
            child: Icon(Icons.local_shipping, color: Colors.white, size: 30),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$totalSuppliers Fournisseurs',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '${totalAmount.toStringAsFixed(0)} DH d\'achats • $premiumSuppliers Premium',
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

  // BARRE DE RECHERCHE
  Widget _buildSearchBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.search, color: AppTheme.textLight),
          SizedBox(width: 12),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Rechercher un fournisseur...',
                border: InputBorder.none,
                hintStyle: TextStyle(color: AppTheme.textLight),
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.filter_list, color: AppTheme.primaryRed),
            onPressed: _showFilterOptions,
          ),
        ],
      ),
    );
  }

  // LISTE DES FOURNISSEURS
  Widget _buildSuppliersList() {
    return ListView.builder(
      itemCount: _suppliers.length,
      itemBuilder: (context, index) {
        final supplier = _suppliers[index];
        return _buildSupplierCard(supplier, index);
      },
    );
  }

  Widget _buildSupplierCard(Map<String, dynamic> supplier, int index) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              _getRandomColor(index).withOpacity(0.1),
              _getRandomColor(index).withOpacity(0.05),
            ],
          ),
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Avatar
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: _getRandomColor(index),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.business,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                  SizedBox(width: 16),

                  // Informations fournisseur
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          supplier['name'],
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textDark,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          supplier['phone'],
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textLight,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          supplier['email'],
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textLight,
                          ),
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 12,
                              color: AppTheme.textLight,
                            ),
                            SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                supplier['address'],
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.textLight,
                                  fontWeight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            SizedBox(width: 16),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: _getStatusColor(supplier['status']),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                supplier['status'],
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
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
                  PopupMenuItem(value: 'view', child: Text('Voir détails')),
                  PopupMenuItem(value: 'orders', child: Text('Commandes')),
                  PopupMenuItem(
                    value: 'delete',
                    child: Text(
                      'Supprimer',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
                onSelected: (value) async {
                  if (value == 'edit') {
                    _editSupplier(supplier);
                  } else if (value == 'view') {
                    _viewSupplierDetails(supplier);
                  } else if (value == 'orders') {
                    _viewSupplierOrders(supplier);
                  } else if (value == 'delete') {
                    await _deleteSupplier(supplier);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Premium':
        return Colors.orange;
      case 'Actif':
        return Colors.green;
      case 'Inactif':
        return Colors.grey;
      default:
        return AppTheme.primaryRed;
    }
  }

  void _addSupplier() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddSupplierScreen()),
    ).then((newSupplier) {
      if (newSupplier != null) {
        // Rafraîchir la liste après l'ajout
        _loadSuppliers();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fournisseur ajouté avec succès'),
            backgroundColor: Colors.green,
          ),
        );
      }
    });
  }

  Future<void> _editSupplier(Map<String, dynamic> supplier) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Modifier le fournisseur'),
        content: Text('Fonctionnalité en développement'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Fermer'),
          ),
        ],
      ),
    );
  }

  void _viewSupplierDetails(Map<String, dynamic> supplier) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Détails du Fournisseur'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailItem('Nom', supplier['name']),
              _buildDetailItem('Contact', supplier['contact']),
              _buildDetailItem('Email', supplier['email']),
              _buildDetailItem('Téléphone', supplier['phone']),
              _buildDetailItem('Adresse', supplier['address']),
              _buildDetailItem('ICE', supplier['ice'] ?? 'N/A'),
              _buildDetailItem('RC', supplier['rc'] ?? 'N/A'),
              _buildDetailItem('IF', supplier['if'] ?? 'N/A'),
              _buildDetailItem('CNSS', supplier['cnss'] ?? 'N/A'),
              _buildDetailItem(
                'Limite de crédit',
                '${supplier['credit_limit'] ?? '0.00'} DH',
              ),
              _buildDetailItem(
                'Solde crédit',
                '${supplier['totalAmount'].toStringAsFixed(2)} DH',
              ),
              _buildDetailItem(
                'Agence ID',
                supplier['agency_id']?.toString() ?? '',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Fermer', style: TextStyle(color: AppTheme.primaryRed)),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label: ', style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _viewSupplierOrders(Map<String, dynamic> supplier) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Commandes - ${supplier['name']}'),
        content: Text('Fonctionnalité en développement...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Fermer', style: TextStyle(color: AppTheme.primaryRed)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteSupplier(Map<String, dynamic> supplier) async {
    final confirmed = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Supprimer le fournisseur'),
        content: Text(
          'Êtes-vous sûr de vouloir supprimer le fournisseur "${supplier['name']}" ?',
        ),
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
        await _supplierService.deleteSupplier(int.parse(supplier['id']));
        // Rafraîchir la liste
        await _loadSuppliers();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fournisseur supprimé avec succès'),
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
                child: Icon(Icons.local_shipping_rounded, size: 24),
              ),
              label: 'Fournisseurs',
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

  // SIDEBAR (identique)
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
                  }, isActive: false),
                  _buildSidebarItem(Icons.square_foot, 'Unités', () {
                    Navigator.pop(context);
                  }, isActive: false),
                  _buildSidebarItem(Icons.people, 'Clients', () {
                    Navigator.pop(context);
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
                  }, isActive: true),

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

  void _showFilterOptions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Filtrer les fournisseurs'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.local_shipping, color: AppTheme.primaryRed),
              title: Text('Tous les fournisseurs'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: Icon(Icons.star, color: Colors.orange),
              title: Text('Fournisseurs Premium'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: Icon(Icons.attach_money, color: Colors.green),
              title: Text('Par volume d\'achats'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showNotifications() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Notifications'),
        content: Text('Vous avez 2 nouvelles notifications'),
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
              final SharedPreferences prefs =
                  await SharedPreferences.getInstance();
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
