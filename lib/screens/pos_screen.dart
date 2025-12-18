import 'package:flutter/material.dart';
import 'package:multi_agences_app/theme/app_theme.dart';
import 'package:multi_agences_app/widgets/cart_item.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:multi_agences_app/services/selected_agency_service.dart';
import 'package:intl/intl.dart';

class PosScreen extends StatefulWidget {
  const PosScreen({Key? key}) : super(key: key);

  @override
  _PosScreenState createState() => _PosScreenState();
}

class _PosScreenState extends State<PosScreen> {
  String _selectedSaleType = 'détail';
  final List<Map<String, dynamic>> _cartItems = [];
  List<Map<String, dynamic>> _allProducts = [];
  List<Map<String, dynamic>> _filteredProducts = [];
  List<Map<String, dynamic>> _clients = [];

  bool _isLoading = true;
  bool _isLoadingProducts = false;
  bool _isProcessingSale = false;
  String _errorMessage = '';

  Map<String, dynamic>? _selectedClient;
  String _paymentMethod = 'Espèces';
  double _totalAmount = 0.0;
  double _discount = 0.0;
  double _paidAmount = 0.0;
  double _remainingAmount = 0.0;

  // Champs pour la vente
  String _saleReference = '';
  DateTime _saleDate = DateTime.now();
  int _lastSaleNumber = 0;

  int _currentIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _discountController = TextEditingController();
  final TextEditingController _paidAmountController = TextEditingController();
  final TextEditingController _referenceController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeData();

    _discountController.text = _discount.toStringAsFixed(2);
    _paidAmountController.text = _paidAmount.toStringAsFixed(2);

    // Initialiser la date
    _dateController.text = DateFormat('dd/MM/yyyy').format(_saleDate);

    // Générer la référence initiale
    _generateSaleReference();
  }

  Future<void> _initializeData() async {
    await _loadData();
  }

  Future<Map<String, String>> _getHeaders() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Charger les clients
      await _loadClients();

      // Charger le dernier numéro de vente depuis l'API
      await _loadLastSaleNumber();

      setState(() {
        _isLoading = false;
      });
      _calculateTotal();
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur de chargement: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadLastSaleNumber() async {
    try {
      final selectedAgency = await SelectedAgencyService.getSelectedAgency();
      final headers = await _getHeaders();

      String url = 'http://localhost:8000/api/sales/last-number';
      if (selectedAgency != null && selectedAgency['id'] != null) {
        url += '?agency_id=${selectedAgency['id']}';
      }

      final response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['success'] == true) {
          setState(() {
            _saleReference = jsonResponse['next_reference'] ?? 'V-00001';
            _referenceController.text = _saleReference;
            _lastSaleNumber = jsonResponse['next_number'] ?? 1;
          });
        } else {
          _generateDefaultReference();
        }
      } else {
        _generateDefaultReference();
      }
    } catch (e) {
      _generateDefaultReference();
    }
  }

  void _generateDefaultReference() {
    setState(() {
      _saleReference = 'V-00001';
      _referenceController.text = _saleReference;
      _lastSaleNumber = 1;
    });
  }

  void _generateSaleReference() {
    final nextNumber = _lastSaleNumber + 1;
    final formattedNumber = nextNumber.toString().padLeft(5, '0');
    setState(() {
      _saleReference = 'V-$formattedNumber';
      _referenceController.text = _saleReference;
    });
  }

  Future<void> _loadAllProducts() async {
    try {
      final selectedAgency = await SelectedAgencyService.getSelectedAgency();
      final headers = await _getHeaders();

      String url = 'http://localhost:8000/api/products';
      if (selectedAgency != null && selectedAgency['id'] != null) {
        url += '?agency_id=${selectedAgency['id']}';
      }

      final response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['success'] == true) {
          final productsData = jsonResponse['data'] as List;

          setState(() {
            _allProducts = productsData.map<Map<String, dynamic>>((product) {
              return {
                'id': product['id'].toString(),
                'name': product['name'] ?? 'Produit sans nom',
                'priceRetail': _parseDouble(product['sale_price']),
                'priceWholesale': _parseDouble(product['wholesale_price']),
                'priceHalfWholesale': _parseDouble(
                  product['half_wholesale_price'],
                ),
                'stock': _parseInt(product['stock']),
                'image': product['image_url'] ?? '',
                'category': product['category']?['name'] ?? 'Non catégorisé',
                'reference': product['reference'] ?? '',
              };
            }).toList();
            _filteredProducts = List.from(_allProducts);
          });
        } else {
          throw Exception(jsonResponse['message'] ?? 'Erreur inconnue');
        }
      } else if (response.statusCode == 401) {
        throw Exception('Session expirée. Veuillez vous reconnecter.');
      } else {
        throw Exception('Erreur serveur: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur lors du chargement des produits: $e');
    }
  }

  double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    return 0.0;
  }

  int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    return 0;
  }

  Future<void> _loadClients() async {
    try {
      final selectedAgency = await SelectedAgencyService.getSelectedAgency();
      final headers = await _getHeaders();

      String url = 'http://localhost:8000/api/clients';
      if (selectedAgency != null && selectedAgency['id'] != null) {
        url += '?agency_id=${selectedAgency['id']}';
      }

      final response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['success'] == true) {
          final clientsData = jsonResponse['data'] as List;

          setState(() {
            _clients = clientsData.map<Map<String, dynamic>>((client) {
              return {
                'id': client['id'].toString(),
                'name': client['name'] ?? 'Client sans nom',
                'phone': client['phone'] ?? '',
                'email': client['email'] ?? '',
                'address': client['address'] ?? '',
                'credit_balance': _parseDouble(client['credit_balance']),
                'credit_limit': _parseDouble(client['credit_limit']),
              };
            }).toList();

            _selectedClient = _clients.isNotEmpty ? _clients.first : null;
          });
        } else {
          throw Exception(jsonResponse['message'] ?? 'Erreur inconnue');
        }
      } else if (response.statusCode == 401) {
        throw Exception('Session expirée. Veuillez vous reconnecter.');
      } else {
        throw Exception('Erreur serveur: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _clients = [];
        _selectedClient = null;
      });
    }
  }

  void _calculateTotal() {
    setState(() {
      double subtotal = _cartItems.fold(
        0.0,
        (sum, item) => sum + (item['unitPrice'] * item['quantity']),
      );

      _totalAmount = subtotal - _discount;
      _remainingAmount = _totalAmount - _paidAmount;
      if (_remainingAmount < 0) _remainingAmount = 0;
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
      double price = _getPriceByType(product);

      setState(() {
        _cartItems.add({
          'id': product['id'],
          'name': product['name'],
          'unitPrice': price,
          'quantity': 1,
        });
      });
    }
    _calculateTotal();

    _showMessage('${product['name']} ajouté au panier');
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

  void _updateUnitPrice(int index, double newPrice) {
    setState(() {
      _cartItems[index]['unitPrice'] = newPrice;
    });
    _calculateTotal();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _saleDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppTheme.primaryRed,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: AppTheme.primaryRed),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _saleDate) {
      setState(() {
        _saleDate = picked;
        _dateController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  Future<void> _processSale() async {
    if (_cartItems.isEmpty) {
      _showMessage('Le panier est vide');
      return;
    }

    final confirmed = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirmer la vente'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Référence: $_saleReference'),
            Text('Date: ${DateFormat('dd/MM/yyyy').format(_saleDate)}'),
            if (_selectedClient != null)
              Text('Client: ${_selectedClient!['name']}'),
            Text('Type de vente: ${_selectedSaleType.toUpperCase()}'),
            Text('Total: ${_totalAmount.toStringAsFixed(2)} DH'),
            SizedBox(height: 10),
            Text('Êtes-vous sûr de vouloir confirmer cette vente ?'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryRed,
            ),
            child: Text('Confirmer'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _saveSaleToApi();
    }
  }

  Future<void> _saveSaleToApi() async {
    setState(() {
      _isProcessingSale = true;
    });

    try {
      final selectedAgency = await SelectedAgencyService.getSelectedAgency();
      final headers = await _getHeaders();

      // Préparer les données selon la structure de votre API
      final saleData = {
        'client_id': _selectedClient?['id'],
        'agency_id': selectedAgency?['id'],
        'payment_method': _paymentMethod,
        'sale_type': _selectedSaleType,
        'date': DateFormat('yyyy-MM-dd').format(_saleDate),
        'reference': _saleReference,
        'discount': _discount,
        'items': _cartItems.map((item) {
          return {
            'product_id': item['id'],
            'quantity': item['quantity'],
            'unit_price': item['unitPrice'],
          };
        }).toList(),
      };

      final response = await http.post(
        Uri.parse('http://localhost:8000/api/sales'),
        headers: headers,
        body: json.encode(saleData),
      );

      if (response.statusCode == 201) {
        final jsonResponse = json.decode(response.body);

        if (jsonResponse['success'] == true) {
          _showMessage('Vente créée avec succès !');

          await Future.delayed(Duration(milliseconds: 800));

          // Retourner directement à l'écran précédent
          Navigator.of(context).pop(true);
        } else {
          _showMessage(
            jsonResponse['message'] ?? 'Erreur lors de l\'enregistrement',
          );
        }
      } else if (response.statusCode == 422) {
        final jsonResponse = json.decode(response.body);
        final errors = jsonResponse['errors'];
        if (errors != null) {
          final errorMessages = [];
          errors.forEach((key, value) {
            errorMessages.addAll(value);
          });
          _showMessage(errorMessages.join(', '));
        } else {
          _showMessage('Erreur de validation');
        }
      } else if (response.statusCode == 401) {
        _showMessage('Session expirée. Veuillez vous reconnecter.');
      } else {
        _showMessage('Erreur serveur: ${response.statusCode}');
      }
    } catch (e) {
      _showMessage('Erreur: $e');
      print('Erreur détaillée: $e');
    } finally {
      setState(() {
        _isProcessingSale = false;
      });
    }
  }

  void _clearCart() {
    setState(() {
      _cartItems.clear();
      _discount = 0.0;
      _paidAmount = 0.0;
      _remainingAmount = 0.0;
      _discountController.text = '0.00';
      _paidAmountController.text = '0.00';

      // Régénérer une nouvelle référence
      _generateSaleReference();

      // Réinitialiser la date
      _saleDate = DateTime.now();
      _dateController.text = DateFormat('dd/MM/yyyy').format(_saleDate);
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sélectionner un produit',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Type: ${_selectedSaleType.toUpperCase()}',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 12,
                        ),
                      ),
                    ],
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
                onChanged: (value) {
                  _filterProductsBySearch(value);
                },
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
              child: _isLoading
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppTheme.primaryRed,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Chargement des produits...',
                            style: TextStyle(
                              color: AppTheme.textDark,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    )
                  : _filteredProducts.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inventory_2_outlined,
                            size: 60,
                            color: AppTheme.textLight,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Aucun produit disponible',
                            style: TextStyle(
                              color: AppTheme.textLight,
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  : GridView.builder(
                      padding: EdgeInsets.all(16),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.85,
                      ),
                      itemCount: _filteredProducts.length,
                      itemBuilder: (context, index) {
                        final product = _filteredProducts[index];
                        return _buildProductCard(product);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _filterProductsBySearch(String searchTerm) {
    if (searchTerm.isEmpty) {
      setState(() {
        _filteredProducts = List.from(_allProducts);
      });
    } else {
      final searchLower = searchTerm.toLowerCase();
      setState(() {
        _filteredProducts = _allProducts.where((product) {
          final productName = product['name']?.toString().toLowerCase() ?? '';
          final productReference =
              product['reference']?.toString().toLowerCase() ?? '';
          return productName.contains(searchLower) ||
              productReference.contains(searchLower);
        }).toList();
      });
    }
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
    final stock = _parseInt(product['stock']);
    double price = _getPriceByType(product);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          _addToCart(product);
          Navigator.pop(context);
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
                child: (product['image']?.isNotEmpty ?? false)
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          product['image'],
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Center(
                              child: Icon(
                                Icons.shopping_bag,
                                size: 35,
                                color: AppTheme.textLight,
                              ),
                            );
                          },
                        ),
                      )
                    : Center(
                        child: Icon(
                          Icons.shopping_bag,
                          size: 35,
                          color: AppTheme.textLight,
                        ),
                      ),
              ),
              SizedBox(height: 6),
              Text(
                product['name'] ?? 'Produit sans nom',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 4),
              Text(
                '${price.toStringAsFixed(0)} DH',
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                ),
              ),
              Row(
                children: [
                  Text(
                    'Stock: ',
                    style: TextStyle(color: AppTheme.textLight, fontSize: 10),
                  ),
                  Text(
                    '$stock',
                    style: TextStyle(
                      color: stock > 5 ? Colors.green : Colors.orange,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              if ((product['reference']?.isNotEmpty ?? false))
                Text(
                  'Ref: ${product['reference']}',
                  style: TextStyle(color: AppTheme.textLight, fontSize: 9),
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
      body: _isLoading
          ? _buildLoadingIndicator()
          : _errorMessage.isNotEmpty
          ? _buildErrorWidget()
          : _buildMainContent(),
      floatingActionButton: FloatingActionButton(
        onPressed: _showProductSelectionModal,
        backgroundColor: AppTheme.primaryRed,
        child: Icon(Icons.add, color: Colors.white, size: 30),
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
            'Chargement des données...',
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
            Icon(Icons.error_outline, color: Colors.red, size: 50),
            SizedBox(height: 16),
            Text(
              _errorMessage,
              style: TextStyle(color: AppTheme.textDark, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loadData,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryRed,
              ),
              child: Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }

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
                        'Point de Vente',
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

  Widget _buildMainContent() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildClientSection(),
            SizedBox(height: 16),
            _buildSaleTypeSelector(),
            SizedBox(height: 16),
            _buildCartSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildClientSection() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField<Map<String, dynamic>>(
              value: _selectedClient,
              decoration: InputDecoration(
                labelText: 'Client (optionnel)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: [
                DropdownMenuItem(
                  value: null,
                  child: Text('Aucun client (Vente au détail)'),
                ),
                ..._clients.map((client) {
                  return DropdownMenuItem(
                    value: client,
                    child: Text(client['name'] ?? 'Client sans nom'),
                  );
                }).toList(),
              ],
              onChanged: (client) {
                setState(() {
                  _selectedClient = client;
                });
              },
            ),

            SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _referenceController,
                    decoration: InputDecoration(
                      labelText: 'Référence',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: Icon(
                        Icons.confirmation_number,
                        color: AppTheme.primaryRed,
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    readOnly: true,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryRed,
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _selectDate(context),
                    child: AbsorbPointer(
                      child: TextFormField(
                        controller: _dateController,
                        decoration: InputDecoration(
                          labelText: 'Date de vente',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: Icon(
                            Icons.calendar_today,
                            color: AppTheme.primaryRed,
                          ),
                          suffixIcon: Icon(
                            Icons.calendar_month,
                            color: AppTheme.textLight,
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textDark,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            if (_selectedClient != null)
              Column(
                children: [
                  SizedBox(height: 16),
                  Divider(color: Colors.grey[300]),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.phone, size: 16, color: AppTheme.textLight),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _selectedClient!['phone']?.isNotEmpty ?? false
                              ? _selectedClient!['phone']
                              : 'Pas de téléphone',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                  if (_selectedClient!['credit_limit'] != null &&
                      _parseDouble(_selectedClient!['credit_limit']) > 0)
                    SizedBox(height: 4),
                  if (_selectedClient!['credit_limit'] != null &&
                      _parseDouble(_selectedClient!['credit_limit']) > 0)
                    Row(
                      children: [
                        Icon(
                          Icons.credit_card,
                          size: 16,
                          color: AppTheme.textLight,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Crédit disponible: ${(_parseDouble(_selectedClient!['credit_limit']) - _parseDouble(_selectedClient!['credit_balance'])).toStringAsFixed(2)} DH',
                            style: TextStyle(fontSize: 12, color: Colors.blue),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            if (_cartItems.isNotEmpty) ...[
              SizedBox(height: 16),
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

  Widget _buildSaleTypeSelector() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Type de vente',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryRed,
              ),
            ),
            SizedBox(height: 12),
            Row(
              children: [
                _buildSaleTypeButton('Détail', 'détail'),
                SizedBox(width: 8),
                _buildSaleTypeButton('Demi-Gros', 'demi-gros'),
                SizedBox(width: 8),
                _buildSaleTypeButton('Gros', 'gros'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaleTypeButton(String label, String value) {
    return Expanded(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: _selectedSaleType == value
              ? AppTheme.primaryRed
              : Colors.grey[200],
          foregroundColor: _selectedSaleType == value
              ? Colors.white
              : Colors.black,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: EdgeInsets.symmetric(vertical: 12),
        ),
        onPressed: () {
          setState(() {
            _selectedSaleType = value;
            // Mettre à jour les prix dans le panier
            for (var item in _cartItems) {
              final product = _allProducts.firstWhere(
                (p) => p['id'] == item['id'],
                orElse: () => {},
              );
              if (product.isNotEmpty) {
                item['unitPrice'] = _getPriceByType(product);
              }
            }
            _calculateTotal();
          });
        },
        child: Text(label),
      ),
    );
  }

  double _getPriceByType(Map<String, dynamic> product) {
    switch (_selectedSaleType) {
      case 'gros':
        return product['priceWholesale'] ?? product['priceRetail'];
      case 'demi-gros':
        return product['priceHalfWholesale'] ?? product['priceRetail'];
      default:
        return product['priceRetail'];
    }
  }

  Widget _buildCartSection() {
    if (_cartItems.isEmpty) {
      return _buildEmptyCart();
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ..._cartItems.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return _buildCartItem(item, index);
          }),

          SizedBox(height: 16),

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
                    item['name'] ?? 'Produit sans nom',
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Prix unitaire:',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      SizedBox(height: 4),
                      TextFormField(
                        initialValue: item['unitPrice'].toStringAsFixed(2),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          final newPrice =
                              double.tryParse(value) ?? item['unitPrice'];
                          _updateUnitPrice(index, newPrice);
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Quantité:',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.remove_circle,
                              color: AppTheme.primaryRed,
                              size: 20,
                            ),
                            onPressed: () =>
                                _updateQuantity(index, item['quantity'] - 1),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryRed.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${item['quantity']}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: AppTheme.primaryRed,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.add_circle,
                              color: AppTheme.primaryRed,
                              size: 20,
                            ),
                            onPressed: () =>
                                _updateQuantity(index, item['quantity'] + 1),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(
                  '${(item['unitPrice'] * item['quantity']).toStringAsFixed(2)} DH',
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Détails de paiement',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryRed,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryRed.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppTheme.primaryRed.withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    _saleReference,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryRed,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),

            _buildSummaryRow('Sous-total', _totalAmount + _discount),
            SizedBox(height: 8),

            TextFormField(
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
            SizedBox(height: 8),

            _buildSummaryRow('Total', _totalAmount, isTotal: true),
            SizedBox(height: 16),

            DropdownButtonFormField<String>(
              value: _paymentMethod,
              decoration: InputDecoration(
                labelText: 'Méthode de paiement',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              items:
                  [
                    'Espèces',
                    'Carte bancaire',
                    'Chèque',
                    'Virement',
                    'Crédit',
                  ].map((method) {
                    return DropdownMenuItem(value: method, child: Text(method));
                  }).toList(),
              onChanged: (method) {
                setState(() {
                  _paymentMethod = method!;
                });
              },
            ),

            if (_paymentMethod == 'Crédit')
              Column(
                children: [
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
                  SizedBox(height: 8),
                  _buildSummaryRow('Reste à payer', _remainingAmount),
                ],
              ),

            SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: _isProcessingSale
                  ? Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppTheme.primaryRed,
                        ),
                      ),
                    )
                  : ElevatedButton(
                      onPressed: _processSale,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryRed,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Confirmer la vente',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
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
                  isActive: true,
                ),
                _buildSidebarItem(Icons.history, 'Historique Ventes', () {
                  Navigator.pop(context);
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(builder: (context) => SalesHistoryScreen()),
                  // );
                }, isActive: false),
                _buildSidebarItem(Icons.people, 'Clients', () {
                  Navigator.pop(context);
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(builder: (context) => ClientsScreen()),
                  // );
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
