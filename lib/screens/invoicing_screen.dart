import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../screens/categories_screen.dart';
import '../screens/clients_screen.dart';
import '../screens/suppliers_screen.dart';
import '../screens/units_screen.dart';

class InvoicingScreen extends StatefulWidget {
  @override
  _InvoicingScreenState createState() => _InvoicingScreenState();
}

class _InvoicingScreenState extends State<InvoicingScreen> {
  final List<Map<String, dynamic>> _invoices = [
    {
      'id': 'FAC-2024-001245',
      'client': 'SARL TechMaroc',
      'date': '15/03/2024',
      'amount': 2999.99,
      'status': 'paid',
      'type': 'sale',
    },
    {
      'id': 'FAC-2024-001244',
      'client': 'Entreprise SoftLine',
      'date': '14/03/2024',
      'amount': 1599.99,
      'status': 'pending',
      'type': 'sale',
    },
    {
      'id': 'ACH-2024-000789',
      'supplier': 'Apple Distribution',
      'date': '13/03/2024',
      'amount': 12500.00,
      'status': 'paid',
      'type': 'purchase',
    },
  ];

  int _currentIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: _buildModernAppBar(),
      bottomNavigationBar: _buildBottomNavBar(),
      drawer: _buildSidebar(),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primaryRed,
        onPressed: _createInvoice,
        child: Icon(Icons.receipt_long, color: Colors.white, size: 30),
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
                        'Gestion des factures',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '${_invoices.length} facture${_invoices.length > 1 ? 's' : ''}',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.notifications_rounded,
                      color: Colors.white,
                    ),
                    onPressed: _showNotifications,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Quick Stats
          _buildQuickStats(),

          // Invoices List
          _buildInvoicesList(),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    final totalAmount = _invoices.fold(
      0.0,
      (sum, invoice) => sum + invoice['amount'],
    );
    final paidInvoices = _invoices
        .where((invoice) => invoice['status'] == 'paid')
        .length;
    final pendingInvoices = _invoices
        .where((invoice) => invoice['status'] == 'pending')
        .length;

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryRed.withOpacity(0.1),
            AppTheme.primaryRed.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            '${totalAmount.toStringAsFixed(0)} DH',
            'CA Facturé',
            Icons.trending_up,
          ),
          _buildStatItem('${_invoices.length}', 'Factures', Icons.receipt),
          _buildStatItem('$pendingInvoices', 'En attente', Icons.pending),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label, IconData icon) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primaryRed.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: AppTheme.primaryRed),
              SizedBox(width: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryRed,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 6),
        Text(label, style: TextStyle(fontSize: 11, color: AppTheme.textLight)),
      ],
    );
  }

  Widget _buildInvoicesList() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'HISTORIQUE DES FACTURES',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryRed,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.search, color: AppTheme.primaryRed),
                    onPressed: _searchInvoices,
                  ),
                  IconButton(
                    icon: Icon(Icons.filter_list, color: AppTheme.primaryRed),
                    onPressed: _filterInvoices,
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 16),
          ..._invoices.map((invoice) => _buildInvoiceCard(invoice)).toList(),
        ],
      ),
    );
  }

  Widget _buildInvoiceCard(Map<String, dynamic> invoice) {
    Color statusColor = _getStatusColor(invoice['status']);
    Color typeColor = invoice['type'] == 'sale' ? Colors.green : Colors.blue;

    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: typeColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    invoice['type'] == 'sale' ? 'VENTE' : 'ACHAT',
                    style: TextStyle(
                      color: typeColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    _getStatusText(invoice['status']),
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),

            // Invoice Details
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        invoice['id'],
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textDark,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        invoice['type'] == 'sale'
                            ? invoice['client']
                            : invoice['supplier'],
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.textLight,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Date: ${invoice['date']}',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textLight,
                        ),
                      ),
                    ],
                  ),
                ),

                // Amount and Actions
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${invoice['amount'].toStringAsFixed(2)} DH',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryRed,
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.visibility, size: 18),
                          onPressed: () => _viewInvoice(invoice),
                          color: AppTheme.primaryRed,
                        ),
                        IconButton(
                          icon: Icon(Icons.download, size: 18),
                          onPressed: () => _downloadInvoice(invoice),
                          color: AppTheme.primaryRed,
                        ),
                        IconButton(
                          icon: Icon(Icons.print, size: 18),
                          onPressed: () => _printInvoice(invoice),
                          color: AppTheme.primaryRed,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'paid':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return AppTheme.textLight;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'paid':
        return 'PAYÉE';
      case 'pending':
        return 'EN ATTENTE';
      case 'cancelled':
        return 'ANNULÉE';
      default:
        return 'INCONNU';
    }
  }

  void _createInvoice() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Nouvelle Facture'),
        content: Text('Créer une nouvelle facture de vente ou d\'achat ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler', style: TextStyle(color: AppTheme.textLight)),
          ),
          OutlinedButton(
            onPressed: () {
              Navigator.pop(context);
              _createSaleInvoice();
            },
            child: Text('Facture Vente'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryRed,
            ),
            onPressed: () {
              Navigator.pop(context);
              _createPurchaseInvoice();
            },
            child: Text('Facture Achat', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _createSaleInvoice() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Création d\'une facture de vente - Fonctionnalité en développement',
        ),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _createPurchaseInvoice() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Création d\'une facture d\'achat - Fonctionnalité en développement',
        ),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _viewInvoice(Map<String, dynamic> invoice) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Facture ${invoice['id']}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Client: ${invoice['client'] ?? invoice['supplier']}'),
              Text('Date: ${invoice['date']}'),
              Text('Montant: ${invoice['amount'].toStringAsFixed(2)} DH'),
              Text('Statut: ${_getStatusText(invoice['status'])}'),
              SizedBox(height: 16),
              Text('Détails de la facture en développement...'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Fermer'),
          ),
        ],
      ),
    );
  }

  void _downloadInvoice(Map<String, dynamic> invoice) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Téléchargement de la facture ${invoice['id']}'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _printInvoice(Map<String, dynamic> invoice) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Impression de la facture ${invoice['id']}'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _searchInvoices() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Rechercher une facture'),
        content: TextField(
          decoration: InputDecoration(
            hintText: 'Numéro de facture, client...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showMessage('Recherche en cours...');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryRed,
            ),
            child: Text('Rechercher'),
          ),
        ],
      ),
    );
  }

  void _filterInvoices() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Filtrer les factures'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text('Toutes les factures'),
              onTap: () {
                Navigator.pop(context);
                _showMessage('Filtre: Toutes les factures');
              },
            ),
            ListTile(
              title: Text('Factures de vente'),
              onTap: () {
                Navigator.pop(context);
                _showMessage('Filtre: Factures de vente');
              },
            ),
            ListTile(
              title: Text('Factures d\'achat'),
              onTap: () {
                Navigator.pop(context);
                _showMessage('Filtre: Factures d\'achat');
              },
            ),
            ListTile(
              title: Text('Factures payées'),
              onTap: () {
                Navigator.pop(context);
                _showMessage('Filtre: Factures payées');
              },
            ),
            ListTile(
              title: Text('Factures en attente'),
              onTap: () {
                Navigator.pop(context);
                _showMessage('Filtre: Factures en attente');
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.primaryRed,
        behavior: SnackBarBehavior.floating,
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
                child: Icon(Icons.inventory_2_rounded, size: 24),
              ),
              label: 'Produits',
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
                child: Icon(Icons.shopping_cart_rounded, size: 24),
              ),
              label: 'Ventes',
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
                child: Icon(Icons.shopping_basket_rounded, size: 24),
              ),
              label: 'Achats',
            ),
            BottomNavigationBarItem(
              icon: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: _currentIndex == 4
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
      child: Column(
        children: [
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
                    'Gestionnaire',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildSidebarItem(
                  Icons.dashboard,
                  'Tableau de bord',
                  () => Navigator.pop(context),
                  isActive: false,
                ),
                _buildSidebarItem(
                  Icons.inventory_2,
                  'Gestion Produits',
                  () => Navigator.pop(context),
                  isActive: false,
                ),
                _buildSidebarItem(
                  Icons.business,
                  'Mes Agences',
                  () => Navigator.pop(context),
                  isActive: false,
                ),
                _buildSidebarItem(
                  Icons.shopping_cart,
                  'Point de Vente',
                  () => Navigator.pop(context),
                  isActive: false,
                ),
                _buildSidebarItem(
                  Icons.shopping_basket,
                  'Achats',
                  () => Navigator.pop(context),
                  isActive: false,
                ),
                _buildSidebarItem(
                  Icons.receipt_long,
                  'Facturation',
                  () => Navigator.pop(context),
                  isActive: true,
                ),
                _buildSidebarItem(Icons.local_shipping, 'Fournisseurs', () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SuppliersScreen()),
                  );
                }, isActive: false),
                Divider(height: 20),
                _buildSidebarItem(Icons.logout, 'Déconnexion', () {
                  Navigator.pop(context);
                  _showLogoutDialog();
                }, isActive: false),
              ],
            ),
          ),
        ],
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
        ),
      ),
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
            onPressed: () {
              Navigator.pop(context);
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
