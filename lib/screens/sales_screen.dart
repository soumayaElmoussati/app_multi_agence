import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../screens/categories_screen.dart';
import '../screens/clients_screen.dart';
import '../screens/suppliers_screen.dart';
import '../screens/units_screen.dart';

class SalesScreen extends StatefulWidget {
  const SalesScreen({Key? key}) : super(key: key);

  @override
  _SalesScreenState createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  final List<Map<String, dynamic>> _cartItems = [];
  final List<Map<String, dynamic>> _products = [
    {
      'id': '1',
      'name': 'iPhone 14 Pro',
      'price': 12999.00,
      'stock': 15,
      'image': '',
      'category': 'Électronique',
    },
    {
      'id': '2',
      'name': 'Samsung Galaxy S23',
      'price': 8999.00,
      'stock': 8,
      'image': '',
      'category': 'Électronique',
    },
    {
      'id': '3',
      'name': 'MacBook Air M2',
      'price': 18999.00,
      'stock': 5,
      'image': '',
      'category': 'Informatique',
    },
    {
      'id': '4',
      'name': 'AirPods Pro',
      'price': 2999.00,
      'stock': 20,
      'image': '',
      'category': 'Accessoires',
    },
  ];

  final List<Map<String, dynamic>> _clients = [
    {'id': '1', 'name': 'Client Général', 'phone': '', 'email': ''},
    {
      'id': '2',
      'name': 'Mohamed Ahmed',
      'phone': '+212 6 12 34 56 78',
      'email': 'm.ahmed@email.com',
    },
  ];

  Map<String, dynamic>? _selectedClient;
  String _paymentMethod = 'Espèces';
  double _totalAmount = 0.0;
  double _discount = 0.0;
  double _paidAmount = 0.0;
  double _change = 0.0;

  int _currentIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _discountController = TextEditingController();
  final TextEditingController _paidAmountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedClient = _clients.first;
    _calculateTotal();
  }

  void _calculateTotal() {
    setState(() {
      _totalAmount = _cartItems.fold(
        0.0,
        (sum, item) => sum + (item['price'] * item['quantity']),
      );
      _totalAmount -= _discount;
      _change = _paidAmount - _totalAmount;
    });
  }

  void _addToCart(Map<String, dynamic> product) {
    final existingItemIndex = _cartItems.indexWhere(
      (item) => item['id'] == product['id'],
    );

    if (existingItemIndex != -1) {
      setState(() {
        _cartItems[existingItemIndex]['quantity'] += 1;
      });
    } else {
      setState(() {
        _cartItems.add({
          'id': product['id'],
          'name': product['name'],
          'price': product['price'],
          'quantity': 1,
          'stock': product['stock'],
        });
      });
    }
    _calculateTotal();
  }

  void _removeFromCart(int index) {
    setState(() {
      _cartItems.removeAt(index);
    });
    _calculateTotal();
  }

  void _updateQuantity(int index, int newQuantity) {
    if (newQuantity > 0) {
      setState(() {
        _cartItems[index]['quantity'] = newQuantity;
      });
    } else {
      _removeFromCart(index);
    }
    _calculateTotal();
  }

  void _processSale() {
    if (_cartItems.isEmpty) {
      _showMessage('Le panier est vide');
      return;
    }

    if (_paidAmount < _totalAmount) {
      _showMessage('Le montant payé est insuffisant');
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirmer la vente'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Client: ${_selectedClient!['name']}'),
            Text('Total: ${_totalAmount.toStringAsFixed(2)} DH'),
            Text('Montant payé: ${_paidAmount.toStringAsFixed(2)} DH'),
            if (_change > 0) Text('Monnaie: ${_change.toStringAsFixed(2)} DH'),
            SizedBox(height: 10),
            Text('Êtes-vous sûr de vouloir finaliser cette vente ?'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showSuccessDialog();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryRed,
            ),
            child: Text('Confirmer'),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 10),
            Text('Vente réussie'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('La vente a été enregistrée avec succès.'),
            SizedBox(height: 10),
            Text('Montant total: ${_totalAmount.toStringAsFixed(2)} DH'),
            if (_change > 0)
              Text('Monnaie rendue: ${_change.toStringAsFixed(2)} DH'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _clearCart();
            },
            child: Text('Fermer'),
          ),
        ],
      ),
    );
  }

  void _clearCart() {
    setState(() {
      _cartItems.clear();
      _discount = 0.0;
      _paidAmount = 0.0;
      _change = 0.0;
      _discountController.clear();
      _paidAmountController.clear();
    });
    _calculateTotal();
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

  void _showProductSelectionModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            // Header du modal
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryRed,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'SÉLECTIONNER UN PRODUIT',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Barre de recherche
            Padding(
              padding: EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Rechercher un produit...',
                  prefixIcon: Icon(Icons.search, color: AppTheme.primaryRed),
                  filled: true,
                  fillColor: AppTheme.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            // Liste des produits
            Expanded(
              child: GridView.builder(
                padding: EdgeInsets.all(16),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.8,
                ),
                itemCount: _products.length,
                itemBuilder: (context, index) {
                  final product = _products[index];
                  return _buildProductCard(product);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          _addToCart(product);
          Navigator.pop(context);
          _showMessage('${product['name']} ajouté au panier');
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 80,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppTheme.background,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: product['image']?.isEmpty ?? true
                    ? Icon(
                        Icons.shopping_bag,
                        size: 40,
                        color: AppTheme.textLight,
                      )
                    : Image.network(product['image'], fit: BoxFit.cover),
              ),
              SizedBox(height: 8),
              Text(
                product['name'],
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 4),
              Text(
                '${product['price'].toStringAsFixed(2)} DH',
                style: TextStyle(
                  color: AppTheme.primaryRed,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Stock: ${product['stock']}',
                style: TextStyle(color: AppTheme.textLight, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: _buildModernAppBar(),
      bottomNavigationBar: _buildBottomNavBar(),
      drawer: _buildSidebar(),
      body: _buildCartSection(),
      floatingActionButton: FloatingActionButton(
        onPressed: _showProductSelectionModal,
        backgroundColor: AppTheme.primaryRed,
        child: Icon(Icons.add, color: Colors.white, size: 30),
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
                        'POINT DE VENTE',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Panier - ${_cartItems.length} article${_cartItems.length > 1 ? 's' : ''}',
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

  // SECTION PANIER PRINCIPALE - CORRIGÉE
  Widget _buildCartSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // En-tête avec sélection client - SIMPLIFIÉ
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  DropdownButtonFormField<Map<String, dynamic>>(
                    value: _selectedClient,
                    decoration: InputDecoration(
                      labelText: 'Client',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: _clients.map((client) {
                      return DropdownMenuItem(
                        value: client,
                        child: Text(client['name']),
                      );
                    }).toList(),
                    onChanged: (client) {
                      setState(() {
                        _selectedClient = client;
                      });
                    },
                  ),
                  if (_cartItems.isNotEmpty) ...[
                    SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _clearCart,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                        child: Text('Vider le panier'),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          SizedBox(height: 16),

          // Liste des articles du panier
          Expanded(
            child: _cartItems.isEmpty
                ? _buildEmptyCart()
                : ListView.builder(
                    itemCount: _cartItems.length,
                    itemBuilder: (context, index) {
                      final item = _cartItems[index];
                      return _buildCartItem(item, index);
                    },
                  ),
          ),

          // Section paiement
          if (_cartItems.isNotEmpty) _buildPaymentSection(),
        ],
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 80,
            color: AppTheme.textLight,
          ),
          SizedBox(height: 16),
          Text(
            'Panier vide',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.textLight,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Appuyez sur le bouton + pour ajouter des produits',
            style: TextStyle(color: AppTheme.textLight, fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(Map<String, dynamic> item, int index) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Première ligne : Nom du produit
            Row(
              children: [
                Expanded(
                  child: Text(
                    item['name'],
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _removeFromCart(index),
                ),
              ],
            ),
            SizedBox(height: 8),

            // Deuxième ligne : Prix unitaire et contrôle quantité
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${item['price'].toStringAsFixed(2)} DH',
                    style: TextStyle(color: AppTheme.textLight, fontSize: 14),
                  ),
                ),
                // Contrôle des quantités
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.remove_circle,
                        color: AppTheme.primaryRed,
                      ),
                      onPressed: () =>
                          _updateQuantity(index, item['quantity'] - 1),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryRed.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${item['quantity']}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppTheme.primaryRed,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.add_circle, color: AppTheme.primaryRed),
                      onPressed: () =>
                          _updateQuantity(index, item['quantity'] + 1),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 8),

            // Troisième ligne : Prix total
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text('Total: ', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(
                  '${(item['price'] * item['quantity']).toStringAsFixed(2)} DH',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppTheme.primaryRed,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentSection() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Résumé des prix
            _buildSummaryRow('Sous-total', (_totalAmount + _discount)),
            SizedBox(height: 8),

            // Remise
            TextField(
              controller: _discountController,
              decoration: InputDecoration(
                labelText: 'Remise (DH)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  _discount = double.tryParse(value) ?? 0.0;
                  _calculateTotal();
                });
              },
            ),
            SizedBox(height: 12),

            // Total
            _buildSummaryRow('Total', _totalAmount, isTotal: true),
            SizedBox(height: 16),

            // Paiement - EN COLONNE pour éviter l'overflow
            Column(
              children: [
                TextField(
                  controller: _paidAmountController,
                  decoration: InputDecoration(
                    labelText: 'Montant payé (DH)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    setState(() {
                      _paidAmount = double.tryParse(value) ?? 0.0;
                      _calculateTotal();
                    });
                  },
                ),
                SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _paymentMethod,
                  decoration: InputDecoration(
                    labelText: 'Méthode de paiement',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  items: ['Espèces', 'Carte bancaire', 'Virement', 'Chèque']
                      .map((method) {
                        return DropdownMenuItem(
                          value: method,
                          child: Text(method),
                        );
                      })
                      .toList(),
                  onChanged: (method) {
                    setState(() {
                      _paymentMethod = method!;
                    });
                  },
                ),
              ],
            ),

            // Monnaie
            if (_change > 0) ...[
              SizedBox(height: 12),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Monnaie à rendre:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    Text(
                      '${_change.toStringAsFixed(2)} DH',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            SizedBox(height: 16),

            // Bouton valider
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _processSale,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryRed,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'VALIDER LA VENTE',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, double amount, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            fontSize: isTotal ? 18 : 16,
            color: isTotal ? AppTheme.primaryRed : Colors.black,
          ),
        ),
        Text(
          '${amount.toStringAsFixed(2)} DH',
          style: TextStyle(
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            fontSize: isTotal ? 20 : 16,
            color: isTotal ? AppTheme.primaryRed : Colors.black,
          ),
        ),
      ],
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
                    'Vendeur',
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
                _buildSidebarItem(Icons.dashboard, 'Tableau de bord', () {
                  Navigator.pop(context);
                }, isActive: false),
                _buildSidebarItem(Icons.inventory_2, 'Gestion Produits', () {
                  Navigator.pop(context);
                }, isActive: false),
                _buildSidebarItem(Icons.business, 'Mes Agences', () {
                  Navigator.pop(context);
                }, isActive: false),
                _buildSidebarItem(Icons.shopping_cart, 'Point de Vente', () {
                  Navigator.pop(context);
                }, isActive: true),
                _buildSidebarItem(Icons.people, 'Clients', () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ClientsScreen()),
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
              // Navigator.pushReplacementNamed(context, '/login');
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
