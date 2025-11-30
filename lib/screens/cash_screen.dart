import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../screens/categories_screen.dart';
import '../screens/clients_screen.dart';
import '../screens/suppliers_screen.dart';
import '../screens/units_screen.dart';

class CashRegisterScreen extends StatefulWidget {
  const CashRegisterScreen({Key? key}) : super(key: key);

  @override
  _CashRegisterScreenState createState() => _CashRegisterScreenState();
}

class _CashRegisterScreenState extends State<CashRegisterScreen> {
  final List<Map<String, dynamic>> _cartItems = [];
  final List<Map<String, dynamic>> _quickProducts = [
    {
      'id': '1',
      'name': 'Café Noir',
      'price': 15.0,
      'category': 'Boissons',
      'image': '',
    },
    {
      'id': '2',
      'name': 'Thé à la Menthe',
      'price': 12.0,
      'category': 'Boissons',
      'image': '',
    },
    {
      'id': '3',
      'name': 'Croissant',
      'price': 8.0,
      'category': 'Pâtisserie',
      'image': '',
    },
    {
      'id': '4',
      'name': 'Sandwich Poulet',
      'price': 25.0,
      'category': 'Sandwichs',
      'image': '',
    },
  ];

  final List<Map<String, dynamic>> _todayTransactions = [
    {
      'id': 'TRX-001',
      'time': '08:30',
      'amount': 45.0,
      'items': 3,
      'paymentMethod': 'Espèces',
      'status': 'completed',
    },
    {
      'id': 'TRX-002',
      'time': '09:15',
      'amount': 32.0,
      'items': 2,
      'paymentMethod': 'Carte',
      'status': 'completed',
    },
    {
      'id': 'TRX-003',
      'time': '10:05',
      'amount': 67.5,
      'items': 4,
      'paymentMethod': 'Espèces',
      'status': 'completed',
    },
  ];

  double _totalAmount = 0.0;
  double _taxAmount = 0.0;
  double _discountAmount = 0.0;
  double _finalAmount = 0.0;
  double _cashReceived = 0.0;
  double _changeAmount = 0.0;

  String _selectedPaymentMethod = 'Espèces';
  final List<String> _paymentMethods = [
    'Espèces',
    'Carte',
    'Virement',
    'Chèque',
    'Mobile',
  ];

  int _currentIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _discountController = TextEditingController();
  final TextEditingController _cashController = TextEditingController();

  double _dailyTotal = 0.0;
  int _totalTransactions = 0;
  int _activeTables = 3;

  @override
  void initState() {
    super.initState();
    _calculateDailyStats();
    _calculateTotal();
  }

  void _calculateDailyStats() {
    setState(() {
      _dailyTotal = _todayTransactions.fold(
        0.0,
        (sum, transaction) => sum + transaction['amount'],
      );
      _totalTransactions = _todayTransactions.length;
    });
  }

  void _calculateTotal() {
    setState(() {
      _totalAmount = _cartItems.fold(
        0.0,
        (sum, item) => sum + (item['price'] * item['quantity']),
      );
      _taxAmount = _totalAmount * 0.1; // 10% TVA
      _finalAmount = _totalAmount + _taxAmount - _discountAmount;
      _changeAmount = _cashReceived - _finalAmount;
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
          'category': product['category'],
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

  void _applyDiscount() {
    final discount = double.tryParse(_discountController.text) ?? 0.0;
    setState(() {
      _discountAmount = discount;
    });
    _calculateTotal();
  }

  void _processPayment() {
    if (_cartItems.isEmpty) {
      _showMessage('Le panier est vide');
      return;
    }

    if (_selectedPaymentMethod == 'Espèces' && _cashReceived < _finalAmount) {
      _showMessage('Montant insuffisant');
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.payment, color: AppTheme.primaryRed),
            SizedBox(width: 10),
            Text('Confirmer le Paiement'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Total: ${_finalAmount.toStringAsFixed(2)} DH'),
            Text('Méthode: $_selectedPaymentMethod'),
            if (_selectedPaymentMethod == 'Espèces') ...[
              Text('Reçu: ${_cashReceived.toStringAsFixed(2)} DH'),
              Text('Monnaie: ${_changeAmount.toStringAsFixed(2)} DH'),
            ],
            SizedBox(height: 10),
            Text('Confirmer la transaction ?'),
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
              _completeTransaction();
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

  void _completeTransaction() {
    // Simuler l'ajout de la transaction
    final newTransaction = {
      'id': 'TRX-${DateTime.now().millisecondsSinceEpoch}',
      'time': '${DateTime.now().hour}:${DateTime.now().minute}',
      'amount': _finalAmount,
      'items': _cartItems.fold(
        0,
        (int sum, item) => sum + (item['quantity'] as int),
      ),
      'paymentMethod': _selectedPaymentMethod,
      'status': 'completed',
    };

    setState(() {
      _todayTransactions.insert(0, newTransaction);
    });

    _calculateDailyStats();
    _clearCart();
    _showSuccessDialog();
  }

  void _clearCart() {
    setState(() {
      _cartItems.clear();
      _discountAmount = 0.0;
      _cashReceived = 0.0;
      _changeAmount = 0.0;
      _discountController.clear();
      _cashController.clear();
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

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 10),
            Text('Paiement Réussi'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Transaction effectuée avec succès.'),
            SizedBox(height: 10),
            Text('Montant: ${_finalAmount.toStringAsFixed(2)} DH'),
            if (_changeAmount > 0)
              Text('Monnaie à rendre: ${_changeAmount.toStringAsFixed(2)} DH'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Imprimer le ticket'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryRed,
            ),
            child: Text('Terminer'),
          ),
        ],
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
      body: _buildBody(),
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
                        'Caisse enregistreuse',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '${_cartItems.length} article${_cartItems.length > 1 ? 's' : ''} | ${_finalAmount.toStringAsFixed(2)} DH',
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
                    icon: Icon(Icons.point_of_sale, color: Colors.white),
                    onPressed: _showDailyReport,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // CORPS PRINCIPAL - STRUCTURE VERTICALE
  Widget _buildBody() {
    return Column(
      children: [
        // Partie supérieure - Produits et Statistiques
        Expanded(flex: 3, child: _buildTopPanel()),

        // Partie inférieure - Panier et Paiement
        Expanded(flex: 2, child: _buildBottomPanel()),
      ],
    );
  }

  Widget _buildTopPanel() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Statistiques du jour
          _buildDailyStats(),
          SizedBox(height: 20),

          // Produits rapides
          _buildQuickProducts(),
          SizedBox(height: 20),

          // Transactions du jour
          _buildTodayTransactions(),
        ],
      ),
    );
  }

  Widget _buildBottomPanel() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.background,
        border: Border(top: BorderSide(color: Colors.grey.shade300, width: 1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          // En-tête du panier
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primaryRed,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.shopping_cart, color: Colors.white),
                SizedBox(width: 8),
                Text(
                  'PANIER EN COURS',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Spacer(),
                if (_cartItems.isNotEmpty)
                  TextButton(
                    onPressed: _clearCart,
                    child: Text('Vider', style: TextStyle(color: Colors.white)),
                  ),
              ],
            ),
          ),

          // Contenu scrollable du panier et paiement
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Liste des articles
                  _cartItems.isEmpty
                      ? Container(height: 150, child: _buildEmptyCart())
                      : Column(
                          children: [
                            ..._cartItems.asMap().entries.map((entry) {
                              final index = entry.key;
                              final item = entry.value;
                              return _buildCartItem(item, index);
                            }),
                            SizedBox(height: 16),
                          ],
                        ),

                  // Section paiement
                  _buildPaymentSection(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyStats() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem(
              _dailyTotal.toStringAsFixed(0),
              'DH',
              'Chiffre d\'affaires',
              Icons.attach_money,
            ),
            _buildStatItem(
              _totalTransactions.toString(),
              '',
              'Transactions',
              Icons.receipt,
            ),
            _buildStatItem(
              _activeTables.toString(),
              '',
              'Tables actives',
              Icons.table_restaurant,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    String value,
    String suffix,
    String label,
    IconData icon,
  ) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.primaryRed.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 20, color: AppTheme.primaryRed),
              SizedBox(width: 8),
              Text(
                '$value$suffix',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryRed,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 6),
        Text(label, style: TextStyle(fontSize: 12, color: AppTheme.textLight)),
      ],
    );
  }

  Widget _buildQuickProducts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PRODUITS RAPIDES',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryRed,
          ),
        ),
        SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.5,
          ),
          itemCount: _quickProducts.length,
          itemBuilder: (context, index) {
            final product = _quickProducts[index];
            return _buildProductCard(product);
          },
        ),
      ],
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () => _addToCart(product),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.coffee, size: 24, color: AppTheme.primaryRed),
              SizedBox(height: 8),
              Text(
                product['name'],
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
                maxLines: 2,
              ),
              SizedBox(height: 4),
              Text(
                '${product['price'].toStringAsFixed(0)} DH',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryRed,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTodayTransactions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'TRANSACTIONS DU JOUR',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryRed,
              ),
            ),
            TextButton(
              onPressed: _showAllTransactions,
              child: Text(
                'Voir tout',
                style: TextStyle(color: AppTheme.primaryRed),
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        ..._todayTransactions
            .take(5)
            .map((transaction) => _buildTransactionItem(transaction))
            .toList(),
      ],
    );
  }

  Widget _buildTransactionItem(Map<String, dynamic> transaction) {
    return Card(
      margin: EdgeInsets.only(bottom: 8),
      elevation: 1,
      child: ListTile(
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primaryRed.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.receipt, size: 20, color: AppTheme.primaryRed),
        ),
        title: Text(
          transaction['id'],
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${transaction['time']} • ${transaction['items']} article${transaction['items'] > 1 ? 's' : ''}',
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${transaction['amount'].toStringAsFixed(2)} DH',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryRed,
              ),
            ),
            Text(
              transaction['paymentMethod'],
              style: TextStyle(fontSize: 10, color: AppTheme.textLight),
            ),
          ],
        ),
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
            size: 60,
            color: AppTheme.textLight,
          ),
          SizedBox(height: 16),
          Text(
            'Panier vide',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textLight,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Ajoutez des produits pour commencer',
            style: TextStyle(color: AppTheme.textLight),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(Map<String, dynamic> item, int index) {
    return Card(
      margin: EdgeInsets.only(bottom: 8),
      elevation: 1,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppTheme.primaryRed.withOpacity(0.1),
          child: Text(
            '${item['quantity']}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryRed,
            ),
          ),
        ),
        title: Text(
          item['name'],
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('${item['price'].toStringAsFixed(2)} DH'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.remove, size: 18),
              onPressed: () => _updateQuantity(index, item['quantity'] - 1),
            ),
            IconButton(
              icon: Icon(Icons.add, size: 18),
              onPressed: () => _updateQuantity(index, item['quantity'] + 1),
            ),
            IconButton(
              icon: Icon(Icons.delete, size: 18, color: Colors.red),
              onPressed: () => _removeFromCart(index),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentSection() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppTheme.background)),
      ),
      child: Column(
        children: [
          // Résumé des prix
          _buildSummaryRow('Sous-total', _totalAmount),
          _buildSummaryRow('TVA (10%)', _taxAmount),
          if (_discountAmount > 0) _buildSummaryRow('Remise', -_discountAmount),
          _buildSummaryRow('Total', _finalAmount, isTotal: true),
          SizedBox(height: 16),

          // Remise
          TextField(
            controller: _discountController,
            decoration: InputDecoration(
              labelText: 'Remise (DH)',
              border: OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: Icon(Icons.discount),
                onPressed: _applyDiscount,
              ),
            ),
            keyboardType: TextInputType.number,
          ),
          SizedBox(height: 12),

          // Paiement en espèces
          if (_selectedPaymentMethod == 'Espèces') ...[
            TextField(
              controller: _cashController,
              decoration: InputDecoration(
                labelText: 'Espèces reçus (DH)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  _cashReceived = double.tryParse(value) ?? 0.0;
                  _changeAmount = _cashReceived - _finalAmount;
                });
              },
            ),
            SizedBox(height: 8),
            if (_changeAmount > 0)
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Monnaie à rendre:'),
                    Text(
                      '${_changeAmount.toStringAsFixed(2)} DH',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
            SizedBox(height: 12),
          ],

          // Méthode de paiement
          DropdownButtonFormField<String>(
            value: _selectedPaymentMethod,
            decoration: InputDecoration(
              labelText: 'Méthode de paiement',
              border: OutlineInputBorder(),
            ),
            items: _paymentMethods.map((method) {
              return DropdownMenuItem(value: method, child: Text(method));
            }).toList(),
            onChanged: (method) {
              setState(() {
                _selectedPaymentMethod = method!;
                _cashController.clear();
                _cashReceived = 0.0;
                _changeAmount = 0.0;
              });
            },
          ),
          SizedBox(height: 16),

          // Bouton de paiement
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _processPayment,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryRed,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'PROCÉDER AU PAIEMENT',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, double amount, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? AppTheme.primaryRed : Colors.black,
            ),
          ),
          Text(
            '${amount.toStringAsFixed(2)} DH',
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? AppTheme.primaryRed : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  void _showDailyReport() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Rapport Journalier'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildReportItem(
                'Chiffre d\'affaires',
                '${_dailyTotal.toStringAsFixed(2)} DH',
              ),
              _buildReportItem(
                'Nombre de transactions',
                _totalTransactions.toString(),
              ),
              _buildReportItem(
                'Transaction moyenne',
                '${(_dailyTotal / _totalTransactions).toStringAsFixed(2)} DH',
              ),
              _buildReportItem('Tables actives', _activeTables.toString()),
              SizedBox(height: 16),
              Text(
                'Détail des transactions:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              ..._todayTransactions
                  .map(
                    (transaction) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text(
                        '${transaction['id']} - ${transaction['amount']} DH',
                      ),
                    ),
                  )
                  .toList(),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Fermer'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showMessage('Rapport imprimé');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryRed,
            ),
            child: Text('Imprimer'),
          ),
        ],
      ),
    );
  }

  Widget _buildReportItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _showAllTransactions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Toutes les Transactions'),
        content: Container(
          width: double.maxFinite,
          height: 400,
          child: ListView.builder(
            itemCount: _todayTransactions.length,
            itemBuilder: (context, index) {
              return _buildTransactionItem(_todayTransactions[index]);
            },
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
                child: Icon(Icons.point_of_sale, size: 24),
              ),
              label: 'Caisse',
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
                    'Caissier',
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
                  Icons.point_of_sale,
                  'Caisse',
                  () => Navigator.pop(context),
                  isActive: true,
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
                  isActive: false,
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
