import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../screens/categories_screen.dart';
import '../screens/clients_screen.dart';
import '../screens/suppliers_screen.dart';
import '../screens/units_screen.dart';

class PurchaseScreen extends StatefulWidget {
  const PurchaseScreen({Key? key}) : super(key: key);

  @override
  _PurchaseScreenState createState() => _PurchaseScreenState();
}

class _PurchaseScreenState extends State<PurchaseScreen> {
  final List<Map<String, dynamic>> _cartItems = [];
  final List<Map<String, dynamic>> _products = [
    {
      'id': '1',
      'name': 'iPhone 14 Pro',
      'purchasePrice': 11000.00,
      'salePrice': 12999.00,
      'stock': 15,
      'image': '',
      'category': 'Électronique',
    },
    {
      'id': '2',
      'name': 'Samsung Galaxy S23',
      'purchasePrice': 7500.00,
      'salePrice': 8999.00,
      'stock': 8,
      'image': '',
      'category': 'Électronique',
    },
    {
      'id': '3',
      'name': 'MacBook Pro 14"',
      'purchasePrice': 18000.00,
      'salePrice': 19999.00,
      'stock': 5,
      'image': '',
      'category': 'Électronique',
    },
  ];

  final List<Map<String, dynamic>> _suppliers = [
    {'id': '1', 'name': 'Fournisseur Principal', 'phone': '', 'email': ''},
    {
      'id': '2',
      'name': 'Tech Import SARL',
      'phone': '+212 5 22 78 45 12',
      'email': 'contact@techimport.ma',
    },
  ];

  Map<String, dynamic>? _selectedSupplier;
  String _paymentMethod = 'Virement';
  double _totalAmount = 0.0;
  double _shippingCost = 0.0;
  double _taxAmount = 0.0;
  double _paidAmount = 0.0;
  double _remainingAmount = 0.0;

  int _currentIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _shippingController = TextEditingController();
  final TextEditingController _taxController = TextEditingController();
  final TextEditingController _paidAmountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedSupplier = _suppliers.first;
    _calculateTotal();

    _shippingController.text = _shippingCost.toStringAsFixed(2);
    _taxController.text = _taxAmount.toStringAsFixed(2);
    _paidAmountController.text = _paidAmount.toStringAsFixed(2);
  }

  void _calculateTotal() {
    setState(() {
      double subtotal = _cartItems.fold(
        0.0,
        (sum, item) => sum + (item['purchasePrice'] * item['quantity']),
      );
      _totalAmount = subtotal + _shippingCost + _taxAmount;
      _remainingAmount = _totalAmount - _paidAmount;
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
          'purchasePrice': product['purchasePrice'],
          'salePrice': product['salePrice'],
          'quantity': 1,
          'stock': product['stock'],
        });
      });
    }
    _calculateTotal();

    print('Produit ajouté: ${product['name']}');
    print('Panier contient: ${_cartItems.length} articles');
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

  void _updatePurchasePrice(int index, double newPrice) {
    setState(() {
      _cartItems[index]['purchasePrice'] = newPrice;
    });
    _calculateTotal();
  }

  void _processPurchase() {
    if (_cartItems.isEmpty) {
      _showMessage('Le panier d\'achat est vide');
      return;
    }

    if (_selectedSupplier == null) {
      _showMessage('Veuillez sélectionner un fournisseur');
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirmer l\'achat'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Fournisseur: ${_selectedSupplier!['name']}'),
            Text('Total: ${_totalAmount.toStringAsFixed(2)} DH'),
            Text('Montant payé: ${_paidAmount.toStringAsFixed(2)} DH'),
            if (_remainingAmount > 0)
              Text('Reste à payer: ${_remainingAmount.toStringAsFixed(2)} DH'),
            SizedBox(height: 10),
            Text('Êtes-vous sûr de vouloir confirmer cet achat ?'),
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
            Text('Achat confirmé'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('L\'achat a été enregistré avec succès.'),
            SizedBox(height: 10),
            Text('Montant total: ${_totalAmount.toStringAsFixed(2)} DH'),
            if (_remainingAmount > 0)
              Text('Reste à payer: ${_remainingAmount.toStringAsFixed(2)} DH'),
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
      _shippingCost = 0.0;
      _taxAmount = 0.0;
      _paidAmount = 0.0;
      _remainingAmount = 0.0;
      _shippingController.text = '0.00';
      _taxController.text = '0.00';
      _paidAmountController.text = '0.00';
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
                    'Sélectionner un produit',
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
            Expanded(
              child: GridView.builder(
                padding: EdgeInsets.all(16),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.85,
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
          _showMessage('${product['name']} ajouté au panier d\'achat');
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 70,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppTheme.background,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: product['image']?.isEmpty ?? true
                    ? Icon(
                        Icons.shopping_bag,
                        size: 35,
                        color: AppTheme.textLight,
                      )
                    : Image.network(product['image'], fit: BoxFit.cover),
              ),
              SizedBox(height: 6),
              Text(
                product['name'],
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 4),
              Text(
                'Achat: ${product['purchasePrice'].toStringAsFixed(0)} DH',
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                ),
              ),
              Text(
                'Vente: ${product['salePrice'].toStringAsFixed(0)} DH',
                style: TextStyle(
                  color: AppTheme.primaryRed,
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                ),
              ),
              Text(
                'Stock: ${product['stock']}',
                style: TextStyle(color: AppTheme.textLight, fontSize: 10),
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
      body: _buildMainContent(),
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
                        'Achat et Approvisionnement',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
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

  // CONTENU PRINCIPAL - STRUCTURE COMPLÈTEMENT REFAITE
  Widget _buildMainContent() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section fournisseur
            _buildSupplierSection(),
            SizedBox(height: 16),

            // Section panier
            _buildCartSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildSupplierSection() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField<Map<String, dynamic>>(
              value: _selectedSupplier,
              decoration: InputDecoration(
                labelText: 'Fournisseur',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: _suppliers.map((supplier) {
                return DropdownMenuItem(
                  value: supplier,
                  child: Text(supplier['name']),
                );
              }).toList(),
              onChanged: (supplier) {
                setState(() {
                  _selectedSupplier = supplier;
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
    );
  }

  Widget _buildCartSection() {
    if (_cartItems.isEmpty) {
      return _buildEmptyCart();
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Liste des articles
          ..._cartItems.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return _buildCartItem(item, index);
          }),

          SizedBox(height: 16),

          // Section paiement
          _buildPaymentSection(),
        ],
      );
    }
  }

  Widget _buildEmptyCart() {
    return Container(
      height: 300,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 80,
              color: AppTheme.textLight,
            ),
            SizedBox(height: 16),
            Text(
              'Panier d\'achat vide',
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
            Row(
              children: [
                Text(
                  'Prix d\'achat:',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    initialValue: item['purchasePrice'].toStringAsFixed(2),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 8),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      final newPrice =
                          double.tryParse(value) ?? item['purchasePrice'];
                      _updatePurchasePrice(index, newPrice);
                    },
                  ),
                ),
                SizedBox(width: 8),
                Text('DH'),
              ],
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Quantité:',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total achat:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  '${(item['purchasePrice'] * item['quantity']).toStringAsFixed(2)} DH',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.blue,
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Détails de paiement',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryRed,
              ),
            ),
            SizedBox(height: 16),

            _buildSummaryRow(
              'Sous-total',
              (_totalAmount - _shippingCost - _taxAmount),
            ),
            SizedBox(height: 8),

            TextFormField(
              controller: _shippingController,
              decoration: InputDecoration(
                labelText: 'Frais de transport (DH)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  _shippingCost = double.tryParse(value) ?? 0.0;
                  _calculateTotal();
                });
              },
            ),
            SizedBox(height: 8),

            TextFormField(
              controller: _taxController,
              decoration: InputDecoration(
                labelText: 'Taxes et droits (DH)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  _taxAmount = double.tryParse(value) ?? 0.0;
                  _calculateTotal();
                });
              },
            ),
            SizedBox(height: 12),

            _buildSummaryRow('Total achat', _totalAmount, isTotal: true),
            SizedBox(height: 16),

            TextFormField(
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
              items: ['Virement', 'Chèque', 'Espèces', 'Crédit'].map((method) {
                return DropdownMenuItem(value: method, child: Text(method));
              }).toList(),
              onChanged: (method) {
                setState(() {
                  _paymentMethod = method!;
                });
              },
            ),

            if (_remainingAmount > 0) ...[
              SizedBox(height: 12),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Reste à payer:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                    Text(
                      '${_remainingAmount.toStringAsFixed(2)} DH',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _processPurchase,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryRed,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Confirmer l\'achat',
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
                    'Acheteur',
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
