import 'package:flutter/material.dart';
import 'package:multi_agences_app/screens/add_product_screen.dart';
import 'package:multi_agences_app/screens/categories_screen.dart';
import 'package:multi_agences_app/screens/units_screen.dart';
import '../theme/app_theme.dart';
import '../widgets/product_card.dart';

class ProductsScreen extends StatefulWidget {
  @override
  _ProductsScreenState createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  String _selectedCategory = 'Tous';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  final List<String> _categories = [
    'Tous',
    'Électronique',
    'Informatique',
    'Mobile',
    'Accessoires',
  ];

  final List<Map<String, dynamic>> _products = [
    {
      'id': '1',
      'name': 'iPhone 14 Pro',
      'image': '',
      'price': 1299.99,
      'purchasePrice': 1000.00,
      'stock': 15,
      'alertStock': 5,
      'category': 'Mobile',
      'barcode': '1234567890123',
      'unit': 'Pièce',
    },
    {
      'id': '2',
      'name': 'MacBook Pro 16"',
      'image': '',
      'price': 2499.99,
      'purchasePrice': 2000.00,
      'stock': 8,
      'alertStock': 3,
      'category': 'Informatique',
      'barcode': '1234567890124',
      'unit': 'Pièce',
    },
    {
      'id': '3',
      'name': 'Samsung Galaxy S23 Ultra',
      'image': '',
      'price': 1199.99,
      'purchasePrice': 900.00,
      'stock': 2,
      'alertStock': 5,
      'category': 'Mobile',
      'barcode': '1234567890125',
      'unit': 'Pièce',
    },
    {
      'id': '4',
      'name': 'Casque Bluetooth Sony WH-1000XM4',
      'image': '',
      'price': 349.99,
      'purchasePrice': 250.00,
      'stock': 12,
      'alertStock': 3,
      'category': 'Accessoires',
      'barcode': '1234567890126',
      'unit': 'Pièce',
    },
    {
      'id': '5',
      'name': 'iPad Air 5',
      'image': '',
      'price': 749.99,
      'purchasePrice': 600.00,
      'stock': 6,
      'alertStock': 2,
      'category': 'Électronique',
      'barcode': '1234567890127',
      'unit': 'Pièce',
    },
    {
      'id': '6',
      'name': 'Clavier Mécanique Logitech',
      'image': '',
      'price': 129.99,
      'purchasePrice': 80.00,
      'stock': 20,
      'alertStock': 5,
      'category': 'Accessoires',
      'barcode': '1234567890128',
      'unit': 'Pièce',
    },
  ];

  List<Map<String, dynamic>> get _filteredProducts {
    return _products.where((product) {
      final matchesCategory =
          _selectedCategory == 'Tous' ||
          product['category'] == _selectedCategory;
      final matchesSearch =
          _searchQuery.isEmpty ||
          product['name'].toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Produits',
          style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.white),
        ),
        backgroundColor: AppTheme.primaryRed,
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: AppTheme.white),
            onPressed: () {
              // Focus sur le champ de recherche
            },
          ),
          IconButton(
            icon: Icon(Icons.filter_alt, color: AppTheme.white),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Rechercher un produit...',
                  prefixIcon: Icon(Icons.search, color: AppTheme.primaryRed),
                  filled: true,
                  fillColor: AppTheme.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            SizedBox(height: 16),

            // Categories Filter avec indicateur
            Row(
              children: [
                Text(
                  'Catégories:',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textDark,
                    fontSize: 14,
                  ),
                ),
                SizedBox(width: 8),
                if (_selectedCategory != 'Tous')
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryRed.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _selectedCategory,
                          style: TextStyle(
                            color: AppTheme.primaryRed,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(width: 4),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedCategory = 'Tous';
                            });
                          },
                          child: Icon(
                            Icons.close,
                            size: 14,
                            color: AppTheme.primaryRed,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            SizedBox(height: 12),

            // Categories Horizontal List
            Container(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(_categories[index]),
                      selected: _selectedCategory == _categories[index],
                      onSelected: (bool value) {
                        setState(() {
                          _selectedCategory = _categories[index];
                        });
                      },
                      selectedColor: AppTheme.primaryRed,
                      checkmarkColor: AppTheme.white,
                      labelStyle: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: _selectedCategory == _categories[index]
                            ? AppTheme.white
                            : AppTheme.textDark,
                      ),
                      backgroundColor: AppTheme
                          .background, // Utilisation de background au lieu de lightGrey
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 16),

            // Résultats et compteur
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_filteredProducts.length} produit(s) trouvé(s)',
                  style: TextStyle(color: AppTheme.textLight, fontSize: 12),
                ),
                if (_searchQuery.isNotEmpty || _selectedCategory != 'Tous')
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _searchQuery = '';
                        _selectedCategory = 'Tous';
                        _searchController.clear();
                      });
                    },
                    child: Text(
                      'Réinitialiser',
                      style: TextStyle(
                        color: AppTheme.primaryRed,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 8),

            // Products Grid ou message vide
            Expanded(
              child: _filteredProducts.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inventory_2_outlined,
                            size: 64,
                            color: AppTheme
                                .textLight, // Utilisation de textLight au lieu de mediumGrey
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Aucun produit trouvé',
                            style: TextStyle(
                              color: AppTheme.textLight,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Essayez de modifier vos critères de recherche',
                            style: TextStyle(
                              color: AppTheme.textLight,
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  : GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 0.75, // Ajusté pour éviter l'overflow
                      ),
                      itemCount: _filteredProducts.length,
                      itemBuilder: (context, index) {
                        return ProductCard(product: _filteredProducts[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primaryRed,
        onPressed: _addProduct,
        child: Icon(Icons.add, color: AppTheme.white, size: 28),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  void _addProduct() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddProductScreen()),
    );

    if (result != null) {
      if (result['delete'] == true) {
        // Supprimer le produit
      } else {
        // Ajouter le produit
        setState(() {
          _products.add({
            ...result,
            'id': DateTime.now().millisecondsSinceEpoch.toString(),
          });
        });
      }
    }
  }

  void _navigateToCategories() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CategoriesScreen()),
    );
  }

  void _navigateToUnits() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => UnitsScreen()),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Filtres avancés'),
        content: Text('Fonctionnalité de filtres avancés à implémenter'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Appliquer',
              style: TextStyle(color: AppTheme.primaryRed),
            ),
          ),
        ],
      ),
    );
  }
}
