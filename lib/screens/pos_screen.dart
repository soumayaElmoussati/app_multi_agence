import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/cart_item.dart';

class PosScreen extends StatefulWidget {
  @override
  _PosScreenState createState() => _PosScreenState();
}

class _PosScreenState extends State<PosScreen> {
  String _selectedSaleType = 'détail';
  final List<Map<String, dynamic>> _cartItems = [];
  double _totalAmount = 0.0;

  final List<Map<String, dynamic>> _products = [
    {
      'id': '1',
      'name': 'iPhone 14 Pro',
      'priceRetail': 1299.99,
      'priceWholesale': 1199.99,
      'priceHalfWholesale': 1249.99,
      'stock': 15,
    },
    {
      'id': '2',
      'name': 'MacBook Pro',
      'priceRetail': 2499.99,
      'priceWholesale': 2299.99,
      'priceHalfWholesale': 2399.99,
      'stock': 8,
    },
    {
      'id': '3',
      'name': 'Samsung Galaxy S23',
      'priceRetail': 899.99,
      'priceWholesale': 799.99,
      'priceHalfWholesale': 849.99,
      'stock': 25,
    },
    {
      'id': '4',
      'name': 'iPad Air',
      'priceRetail': 699.99,
      'priceWholesale': 599.99,
      'priceHalfWholesale': 649.99,
      'stock': 12,
    },
    {
      'id': '5',
      'name': 'AirPods Pro',
      'priceRetail': 279.99,
      'priceWholesale': 229.99,
      'priceHalfWholesale': 249.99,
      'stock': 30,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Point de Vente'),
        backgroundColor: AppTheme.white,
        foregroundColor: AppTheme.primaryRed,
        actions: [IconButton(icon: Icon(Icons.history), onPressed: () {})],
      ),
      body: Column(
        children: [
          // Products Section (Top)
          Expanded(flex: 3, child: _buildProductsSection()),

          // Cart Section (Bottom)
          Expanded(flex: 2, child: _buildCartSection()),
        ],
      ),
    );
  }

  Widget _buildProductsSection() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          // Sale Type Selector
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSaleTypeButton('Détail', 'détail'),
                _buildSaleTypeButton('Demi-Gros', 'demi-gros'),
                _buildSaleTypeButton('Gros', 'gros'),
              ],
            ),
          ),
          SizedBox(height: 16),

          // Search Bar
          TextField(
            decoration: InputDecoration(
              hintText: 'Rechercher un produit...',
              prefixIcon: Icon(Icons.search, color: AppTheme.primaryRed),
              filled: true,
              fillColor: AppTheme.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          SizedBox(height: 16),

          // Products Grid
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.9,
              ),
              itemCount: _products.length,
              itemBuilder: (context, index) {
                return _buildProductCard(_products[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaleTypeButton(String label, String value) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: _selectedSaleType == value
                ? AppTheme.primaryRed
                : AppTheme.white,
            foregroundColor: _selectedSaleType == value
                ? AppTheme.white
                : AppTheme.primaryRed,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 0,
          ),
          onPressed: () {
            setState(() {
              _selectedSaleType = value;
            });
          },
          child: Text(label, style: TextStyle(fontSize: 12)),
        ),
      ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
    double price = _getPriceByType(product);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          _addToCart(product);
        },
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image/Icon
              Container(
                height: 80,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppTheme.background,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getProductIcon(product['name']),
                  color: AppTheme.primaryRed,
                  size: 40,
                ),
              ),
              SizedBox(height: 8),

              // Product Name
              Text(
                product['name'],
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 4),

              // Price
              Text(
                '${price.toStringAsFixed(2)} DH',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryRed,
                ),
              ),
              SizedBox(height: 4),

              // Stock
              Text(
                'Stock: ${product['stock']}',
                style: TextStyle(fontSize: 10, color: AppTheme.textLight),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCartSection() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.white,
        border: Border(top: BorderSide(color: AppTheme.background, width: 2)),
      ),
      child: Column(
        children: [
          // Cart Header
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
                Icon(Icons.shopping_cart, color: AppTheme.white),
                SizedBox(width: 8),
                Text(
                  'Panier',
                  style: TextStyle(
                    color: AppTheme.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Spacer(),
                Text(
                  '${_cartItems.length} articles',
                  style: TextStyle(color: AppTheme.white),
                ),
              ],
            ),
          ),

          // Cart Items
          Expanded(
            child: _cartItems.isEmpty
                ? Center(
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
                            color: AppTheme.textLight,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Ajoutez des produits depuis la liste ci-dessus',
                          style: TextStyle(
                            color: AppTheme.textLight.withOpacity(0.7),
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: _cartItems.length,
                    itemBuilder: (context, index) {
                      return CartItem(
                        item: _cartItems[index],
                        onQuantityChanged: (newQuantity) {
                          _updateQuantity(index, newQuantity);
                        },
                        onRemove: () {
                          _removeFromCart(index);
                        },
                      );
                    },
                  ),
          ),

          // Cart Footer
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.background,
              border: Border(
                top: BorderSide(color: AppTheme.primaryRed.withOpacity(0.2)),
              ),
            ),
            child: Column(
              children: [
                // Total
                Container(
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppTheme.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppTheme.primaryRed.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${_totalAmount.toStringAsFixed(2)} DH',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryRed,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),

                // Payment Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryRed,
                          foregroundColor: AppTheme.white,
                          padding: EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: _cartItems.isEmpty ? null : _processPayment,
                        child: Text(
                          'PAIEMENT TOTAL',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.primaryRed,
                          side: BorderSide(color: AppTheme.primaryRed),
                          padding: EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: _cartItems.isEmpty
                            ? null
                            : _processPartialPayment,
                        child: Text('ACOMPTE'),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.orange,
                      side: BorderSide(color: Colors.orange),
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: _cartItems.isEmpty ? null : _processCredit,
                    child: Text('VENTE À CRÉDIT'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getProductIcon(String productName) {
    if (productName.toLowerCase().contains('iphone') ||
        productName.toLowerCase().contains('samsung')) {
      return Icons.phone_iphone;
    } else if (productName.toLowerCase().contains('macbook')) {
      return Icons.laptop;
    } else if (productName.toLowerCase().contains('ipad')) {
      return Icons.tablet;
    } else if (productName.toLowerCase().contains('airpods')) {
      return Icons.headphones;
    } else {
      return Icons.shopping_bag;
    }
  }

  double _getPriceByType(Map<String, dynamic> product) {
    switch (_selectedSaleType) {
      case 'gros':
        return product['priceWholesale'];
      case 'demi-gros':
        return product['priceHalfWholesale'];
      default:
        return product['priceRetail'];
    }
  }

  void _addToCart(Map<String, dynamic> product) {
    setState(() {
      double price = _getPriceByType(product);

      // Vérifier si le produit est déjà dans le panier
      int existingIndex = _cartItems.indexWhere(
        (item) => item['id'] == product['id'],
      );

      if (existingIndex != -1) {
        // Produit déjà dans le panier, augmenter la quantité
        _cartItems[existingIndex]['quantity'] += 1;
        _cartItems[existingIndex]['totalPrice'] =
            _cartItems[existingIndex]['unitPrice'] *
            _cartItems[existingIndex]['quantity'];
      } else {
        // Nouveau produit
        _cartItems.add({
          ...product,
          'quantity': 1,
          'unitPrice': price,
          'totalPrice': price,
        });
      }

      _calculateTotal();

      // Feedback visuel
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${product['name']} ajouté au panier'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 1),
        ),
      );
    });
  }

  void _updateQuantity(int index, int newQuantity) {
    setState(() {
      if (newQuantity <= 0) {
        _removeFromCart(index);
      } else {
        _cartItems[index]['quantity'] = newQuantity;
        _cartItems[index]['totalPrice'] =
            _cartItems[index]['unitPrice'] * newQuantity;
        _calculateTotal();
      }
    });
  }

  void _removeFromCart(int index) {
    setState(() {
      String productName = _cartItems[index]['name'];
      _cartItems.removeAt(index);
      _calculateTotal();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$productName retiré du panier'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 1),
        ),
      );
    });
  }

  void _calculateTotal() {
    _totalAmount = _cartItems.fold(0.0, (sum, item) {
      return sum + (item['totalPrice'] as double);
    });
  }

  void _processPayment() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Paiement Total'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Montant total: ${_totalAmount.toStringAsFixed(2)} DH'),
            SizedBox(height: 16),
            Text('Fonctionnalité en développement'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryRed,
            ),
            onPressed: () {
              Navigator.pop(context);
              _clearCart();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Paiement effectué avec succès !'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: Text('Confirmer'),
          ),
        ],
      ),
    );
  }

  void _processPartialPayment() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Paiement Partiel'),
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

  void _processCredit() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Vente à Crédit'),
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

  void _clearCart() {
    setState(() {
      _cartItems.clear();
      _totalAmount = 0.0;
    });
  }
}
