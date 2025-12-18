import 'package:flutter/material.dart';
import 'package:multi_agences_app/theme/app_theme.dart';
import 'package:multi_agences_app/screens/categories_screen.dart';
import 'package:multi_agences_app/screens/clients_screen.dart';
import 'package:multi_agences_app/screens/suppliers_screen.dart';
import 'package:multi_agences_app/screens/units_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:multi_agences_app/services/selected_agency_service.dart';
import 'package:intl/intl.dart';

class PurchaseScreen extends StatefulWidget {
  const PurchaseScreen({Key? key}) : super(key: key);

  @override
  _PurchaseScreenState createState() => _PurchaseScreenState();
}

class _PurchaseScreenState extends State<PurchaseScreen> {
  final List<Map<String, dynamic>> _cartItems = [];
  List<Map<String, dynamic>> _allProducts = [];
  List<Map<String, dynamic>> _filteredProducts = [];
  List<Map<String, dynamic>> _suppliers = [];

  bool _isLoading = true;
  bool _isLoadingProducts = false;
  bool _isProcessingPurchase = false;
  String _errorMessage = '';

  Map<String, dynamic>? _selectedSupplier;
  String _paymentMethod = 'Virement';
  double _totalAmount = 0.0;
  double _shippingCost = 0.0;
  double _taxAmount = 0.0;
  double _paidAmount = 0.0;
  double _remainingAmount = 0.0;

  // Nouveaux champs pour l'API
  String _purchaseReference = '';
  DateTime _purchaseDate = DateTime.now();
  int _lastPurchaseNumber = 0;
  double _tvaPercentage = 20.0; // TVA par défaut à 20%

  int _currentIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _shippingController = TextEditingController();
  final TextEditingController _taxController = TextEditingController();
  final TextEditingController _paidAmountController = TextEditingController();
  final TextEditingController _referenceController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _tvaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeData();

    _shippingController.text = _shippingCost.toStringAsFixed(2);
    _taxController.text = _taxAmount.toStringAsFixed(2);
    _paidAmountController.text = _paidAmount.toStringAsFixed(2);
    _tvaController.text = _tvaPercentage.toStringAsFixed(2);

    // Initialiser la date
    _dateController.text = DateFormat('dd/MM/yyyy').format(_purchaseDate);

    // Générer la référence initiale
    _generatePurchaseReference();
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
      // Charger les fournisseurs
      await _loadSuppliers();

      // Charger le dernier numéro d'achat depuis l'API
      await _loadLastPurchaseNumber();

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

  Future<void> _loadLastPurchaseNumber() async {
    try {
      final selectedAgency = await SelectedAgencyService.getSelectedAgency();
      final headers = await _getHeaders();

      String url = 'http://localhost:8000/api/purchases/last-number';
      if (selectedAgency != null && selectedAgency['id'] != null) {
        url += '?agency_id=${selectedAgency['id']}';
      }

      final response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['success'] == true) {
          setState(() {
            // Utilisez le next_reference fourni par l'API
            _purchaseReference = jsonResponse['next_reference'] ?? 'P-00001';
            _referenceController.text = _purchaseReference;

            // Gardez aussi le next_number pour la génération future
            _lastPurchaseNumber = jsonResponse['next_number'] ?? 1;
          });
        } else {
          // En cas d'erreur, générer une référence par défaut
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
      _purchaseReference = 'P-00001';
      _referenceController.text = _purchaseReference;
      _lastPurchaseNumber = 1;
    });
  }

  void _generatePurchaseReference() {
    final nextNumber = _lastPurchaseNumber + 1;
    final formattedNumber = nextNumber.toString().padLeft(5, '0');
    setState(() {
      _purchaseReference = 'P-$formattedNumber';
      _referenceController.text = _purchaseReference;
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
                'purchasePrice': _parseDouble(product['purchase_price']),
                'salePrice': _parseDouble(product['sale_price']),
                'stock': _parseInt(product['stock']),
                'image': product['image_url'] ?? '',
                'category': product['category']?['name'] ?? 'Non catégorisé',
                'reference': product['reference'] ?? '',
              };
            }).toList();
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

  Future<void> _loadProductsBySupplier(String? supplierId) async {
    if (supplierId == null) {
      setState(() {
        _filteredProducts = [];
        _isLoadingProducts = false;
      });
      return;
    }

    setState(() {
      _isLoadingProducts = true;
    });

    try {
      final selectedAgency = await SelectedAgencyService.getSelectedAgency();
      final headers = await _getHeaders();

      String url = 'http://localhost:8000/api/products';
      final params = <String>[];

      if (selectedAgency != null && selectedAgency['id'] != null) {
        params.add('agency_id=${selectedAgency['id']}');
      }

      params.add('supplier_id=$supplierId');

      if (params.isNotEmpty) {
        url += '?${params.join('&')}';
      }

      final response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['success'] == true) {
          final productsData = jsonResponse['data'] as List;

          setState(() {
            _filteredProducts = productsData.map<Map<String, dynamic>>((
              product,
            ) {
              return {
                'id': product['id'].toString(),
                'name': product['name'] ?? 'Produit sans nom',
                'purchasePrice': _parseDouble(product['purchase_price']),
                'salePrice': _parseDouble(product['sale_price']),
                'stock': _parseInt(product['stock']),
                'image': product['image_url'] ?? '',
                'category': product['category']?['name'] ?? 'Non catégorisé',
                'reference': product['reference'] ?? '',
              };
            }).toList();
            _isLoadingProducts = false;
          });
        } else {
          setState(() {
            _filteredProducts = [];
            _isLoadingProducts = false;
          });
        }
      } else {
        setState(() {
          _filteredProducts = [];
          _isLoadingProducts = false;
        });
      }
    } catch (e) {
      setState(() {
        _filteredProducts = [];
        _isLoadingProducts = false;
      });
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

  Future<void> _loadSuppliers() async {
    try {
      final selectedAgency = await SelectedAgencyService.getSelectedAgency();
      final headers = await _getHeaders();

      String url = 'http://localhost:8000/api/suppliers';
      if (selectedAgency != null && selectedAgency['id'] != null) {
        url += '?agency_id=${selectedAgency['id']}';
      }

      final response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['success'] == true) {
          final suppliersData = jsonResponse['data'] as List;

          setState(() {
            _suppliers = suppliersData.map<Map<String, dynamic>>((supplier) {
              return {
                'id': supplier['id'].toString(),
                'name': supplier['name'] ?? 'Fournisseur sans nom',
                'phone': supplier['phone'] ?? '',
                'email': supplier['email'] ?? '',
                'address': supplier['address'] ?? '',
                'credit_balance': _parseDouble(supplier['credit_balance']),
                'credit_limit': _parseDouble(supplier['credit_limit']),
              };
            }).toList();

            _selectedSupplier = _suppliers.isNotEmpty ? _suppliers.first : null;
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
        _suppliers = [];
        _selectedSupplier = null;
      });
    }
  }

  void _calculateTotal() {
    setState(() {
      double subtotal = _cartItems.fold(
        0.0,
        (sum, item) => sum + (item['purchasePrice'] * item['quantity']),
      );

      // Calculer la TVA
      double tvaAmount = subtotal * (_tvaPercentage / 100);

      _totalAmount = subtotal + _shippingCost + tvaAmount;
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
      setState(() {
        _cartItems.add({
          'id': product['id'],
          'name': product['name'],
          'purchasePrice': product['purchasePrice'],
          'quantity': 1,
        });
      });
    }
    _calculateTotal();

    _showMessage('${product['name']} ajouté au panier d\'achat');
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

  Future<void> _selectDate(BuildContext context) async {
    // Utiliser Builder pour obtenir un contexte avec MaterialLocalizations
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _purchaseDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppTheme.primaryRed, // Couleur principale
              onPrimary:
                  Colors.white, // Couleur du texte sur la couleur principale
              surface: Colors.white, // Couleur de surface
              onSurface: Colors.black, // Couleur du texte sur la surface
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: AppTheme.primaryRed),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _purchaseDate) {
      setState(() {
        _purchaseDate = picked;
        _dateController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  Future<void> _processPurchase() async {
    if (_cartItems.isEmpty) {
      _showMessage('Le panier d\'achat est vide');
      return;
    }

    if (_selectedSupplier == null) {
      _showMessage('Veuillez sélectionner un fournisseur');
      return;
    }

    final confirmed = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirmer l\'achat'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Référence: $_purchaseReference'),
            Text('Date: ${DateFormat('dd/MM/yyyy').format(_purchaseDate)}'),
            Text('Fournisseur: ${_selectedSupplier!['name']}'),
            Text('TVA: $_tvaPercentage%'),
            Text('Total: ${_totalAmount.toStringAsFixed(2)} DH'),
            SizedBox(height: 10),
            Text('Êtes-vous sûr de vouloir confirmer cet achat ?'),
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
      await _savePurchaseToApi();
    }
  }

  Future<void> _savePurchaseToApi_old() async {
    setState(() {
      _isProcessingPurchase = true;
    });

    try {
      final selectedAgency = await SelectedAgencyService.getSelectedAgency();
      final headers = await _getHeaders();

      // Calculer le total HT (sans TVA)
      double totalHT = _cartItems.fold(
        0.0,
        (sum, item) => sum + (item['purchasePrice'] * item['quantity']),
      );

      // Préparer les données selon la structure de votre API
      final purchaseData = {
        'supplier_id': _selectedSupplier!['id'],
        'agency_id': selectedAgency?['id'],
        'payment_method': _paymentMethod,
        'tva': _tvaPercentage,
        'date': DateFormat('yyyy-MM-dd').format(_purchaseDate),
        'reference': _purchaseReference,
        'items': _cartItems.map((item) {
          return {
            'product_id': item['id'],
            'quantity': item['quantity'],
            'unit_price': item['purchasePrice'],
          };
        }).toList(),
      };

      print('Données envoyées: ${json.encode(purchaseData)}');

      final response = await http.post(
        Uri.parse('http://localhost:8000/api/purchases'),
        headers: headers,
        body: json.encode(purchaseData),
      );

      print('Code réponse: ${response.statusCode}');
      print('Réponse: ${response.body}');

      if (response.statusCode == 201) {
        final jsonResponse = json.decode(response.body);

        if (jsonResponse['success'] == true) {
          //   _showSuccessDialog();
          // Recharger les produits pour mettre à jour les stocks
          //  await _loadAllProducts();
          // Recharger les produits par fournisseur
          await _loadProductsBySupplier(_selectedSupplier!['id']);
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
        _isProcessingPurchase = false;
      });
    }
  }

  Future<void> _savePurchaseToApi() async {
    setState(() {
      _isProcessingPurchase = true;
    });

    try {
      final selectedAgency = await SelectedAgencyService.getSelectedAgency();
      final headers = await _getHeaders();

      // Calculer le total HT (sans TVA)
      double totalHT = _cartItems.fold(
        0.0,
        (sum, item) => sum + (item['purchasePrice'] * item['quantity']),
      );

      // Préparer les données selon la structure de votre API
      final purchaseData = {
        'supplier_id': _selectedSupplier!['id'],
        'agency_id': selectedAgency?['id'],
        'payment_method': _paymentMethod,
        'tva': _tvaPercentage,
        'date': DateFormat('yyyy-MM-dd').format(_purchaseDate),
        'reference': _purchaseReference,
        'items': _cartItems.map((item) {
          return {
            'product_id': item['id'],
            'quantity': item['quantity'],
            'unit_price': item['purchasePrice'],
          };
        }).toList(),
      };

      print('Données envoyées: ${json.encode(purchaseData)}');

      final response = await http.post(
        Uri.parse('http://localhost:8000/api/purchases'),
        headers: headers,
        body: json.encode(purchaseData),
      );

      print('Code réponse: ${response.statusCode}');
      print('Réponse: ${response.body}');

      if (response.statusCode == 201) {
        final jsonResponse = json.decode(response.body);

        if (jsonResponse['success'] == true) {
          // Afficher message de succès rapide
          _showMessage('Achat créé avec succès !');

          // Attendre un peu pour que l'utilisateur voie le message
          await Future.delayed(Duration(milliseconds: 800));

          // Retourner directement à la page PurchasesHistoryScreen
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
        _isProcessingPurchase = false;
      });
    }
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
            Text('Référence: $_purchaseReference'),
            Text('Total: ${_totalAmount.toStringAsFixed(2)} DH'),
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

      // Régénérer une nouvelle référence
      _generatePurchaseReference();

      // Réinitialiser la date
      _purchaseDate = DateTime.now();
      _dateController.text = DateFormat('dd/MM/yyyy').format(_purchaseDate);
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
    if (_selectedSupplier == null) {
      _showMessage('Veuillez d\'abord sélectionner un fournisseur');
      return;
    }

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
                        'Fournisseur: ${_selectedSupplier!['name']}',
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
              child: _isLoadingProducts
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
                            'Aucun produit disponible\npour ce fournisseur',
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
      if (_selectedSupplier != null) {
        _loadProductsBySupplier(_selectedSupplier!['id']);
      }
    } else {
      final searchLower = searchTerm.toLowerCase();
      setState(() {
        _filteredProducts = _filteredProducts.where((product) {
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
                'Achat: ${product['purchasePrice'].toStringAsFixed(0)} DH',
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
      floatingActionButton: _selectedSupplier != null
          ? FloatingActionButton(
              onPressed: _showProductSelectionModal,
              backgroundColor: AppTheme.primaryRed,
              child: Icon(Icons.add, color: Colors.white, size: 30),
            )
          : null,
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

  Widget _buildMainContent() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSupplierSection(),
            SizedBox(height: 16),
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
                  child: Text(supplier['name'] ?? 'Fournisseur sans nom'),
                );
              }).toList(),
              onChanged: (supplier) async {
                setState(() {
                  _selectedSupplier = supplier;
                  _isLoadingProducts = true;
                  _filteredProducts = [];
                });

                await _loadProductsBySupplier(supplier?['id']);
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
                          labelText: 'Date d\'achat',
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

            SizedBox(height: 16),

            TextFormField(
              controller: _tvaController,
              decoration: InputDecoration(
                labelText: 'TVA (%)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: Icon(Icons.percent, color: AppTheme.primaryRed),
                suffixText: '%',
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  _tvaPercentage = double.tryParse(value) ?? 20.0;
                  _calculateTotal();
                });
              },
            ),

            if (_selectedSupplier != null)
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
                          _selectedSupplier!['phone']?.isNotEmpty ?? false
                              ? _selectedSupplier!['phone']
                              : 'Pas de téléphone',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                  if (_selectedSupplier!['credit_limit'] != null &&
                      _parseDouble(_selectedSupplier!['credit_limit']) > 0)
                    SizedBox(height: 4),
                  if (_selectedSupplier!['credit_limit'] != null &&
                      _parseDouble(_selectedSupplier!['credit_limit']) > 0)
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
                            'Crédit disponible: ${(_parseDouble(_selectedSupplier!['credit_limit']) - _parseDouble(_selectedSupplier!['credit_balance'])).toStringAsFixed(2)} DH',
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
            if (_selectedSupplier == null)
              Text(
                'Sélectionnez d\'abord un fournisseur',
                style: TextStyle(color: AppTheme.textLight, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            if (_selectedSupplier != null)
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
                        initialValue: item['purchasePrice'].toStringAsFixed(2),
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
                              double.tryParse(value) ?? item['purchasePrice'];
                          _updatePurchasePrice(index, newPrice);
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
    double totalHT = _cartItems.fold(
      0.0,
      (sum, item) => sum + (item['purchasePrice'] * item['quantity']),
    );
    double tvaAmount = totalHT * (_tvaPercentage / 100);
    double totalTTC = totalHT + tvaAmount + _shippingCost;

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
                    _purchaseReference,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryRed,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),

            _buildSummaryRow('Total HT', totalHT),
            SizedBox(height: 8),

            Row(
              children: [
                Expanded(child: Text('TVA ($_tvaPercentage%):')),
                Text('${tvaAmount.toStringAsFixed(2)} DH'),
              ],
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
            SizedBox(height: 12),

            _buildSummaryRow('Total TTC', totalTTC, isTotal: true),
            SizedBox(height: 16),

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

            SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: _isProcessingPurchase
                  ? Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppTheme.primaryRed,
                        ),
                      ),
                    )
                  : ElevatedButton(
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
