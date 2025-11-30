import 'package:flutter/material.dart';
import 'package:multi_agences_app/screens/categories_screen.dart';
import 'package:multi_agences_app/screens/clients_screen.dart';
import 'package:multi_agences_app/screens/suppliers_screen.dart';
import 'package:multi_agences_app/screens/units_screen.dart';
import '../theme/app_theme.dart';

class AddProductScreen extends StatefulWidget {
  final Map<String, dynamic>? product;

  const AddProductScreen({Key? key, this.product}) : super(key: key);

  @override
  _AddProductScreenState createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _refController = TextEditingController();
  final TextEditingController _purchasePriceController =
      TextEditingController();
  final TextEditingController _salePriceController = TextEditingController();
  final TextEditingController _wholesalePriceController =
      TextEditingController();
  final TextEditingController _resellerPriceController =
      TextEditingController();
  final TextEditingController _stockController = TextEditingController();
  final TextEditingController _alertStockController = TextEditingController();

  String? _selectedCategory;
  String? _selectedUnit;
  String? _imageUrl;

  List<String> _categories = [];
  List<String> _units = [];

  int _currentIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _loadCategoriesAndUnits();
    if (widget.product != null) {
      _loadProductData();
    }
  }

  void _loadCategoriesAndUnits() async {
    setState(() {
      _categories = ['Électronique', 'Informatique', 'Mobile', 'Accessoires'];
      _units = ['Pièce', 'Kg', 'Litre', 'Mètre', 'Carton'];
    });
  }

  void _loadProductData() {
    final product = widget.product!;
    _nameController.text = product['name'] ?? '';
    _refController.text = product['ref'] ?? '';
    _purchasePriceController.text = product['purchasePrice']?.toString() ?? '';
    _salePriceController.text = product['price']?.toString() ?? '';
    _wholesalePriceController.text =
        product['wholesalePrice']?.toString() ?? '';
    _resellerPriceController.text = product['resellerPrice']?.toString() ?? '';
    _stockController.text = product['stock']?.toString() ?? '';
    _alertStockController.text = product['alertStock']?.toString() ?? '';
    _selectedCategory = product['category'];
    _selectedUnit = product['unit'];
    _imageUrl = product['image'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: _buildModernAppBar(),
      bottomNavigationBar: _buildBottomNavBar(),
      drawer: _buildSidebar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildImageSection(),
              SizedBox(height: 20),
              _buildReferenceField(),
              SizedBox(height: 16),
              _buildNameField(),
              SizedBox(height: 16),
              _buildCategoryAndUnitRow(),
              SizedBox(height: 16),
              _buildPurchasePriceField(),
              SizedBox(height: 16),
              _buildSalePriceField(),
              SizedBox(height: 16),
              _buildWholesalePriceField(),
              SizedBox(height: 16),
              _buildResellerPriceField(),
              SizedBox(height: 16),
              _buildStockField(),
              SizedBox(height: 16),
              _buildAlertStockField(),
              SizedBox(height: 30),
              _buildSaveButton(),
            ],
          ),
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
                        widget.product == null
                            ? 'NOUVEAU PRODUIT'
                            : 'MODIFIER PRODUIT',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Remplissez les informations du produit',
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
                        icon: Icon(Icons.search_rounded, color: Colors.white),
                        onPressed: () {},
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

  // SIDEBAR CORRIGÉ - FONCTIONNEL
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
                    // Navigator.pushReplacementNamed(context, '/dashboard');
                  }, isActive: false),
                  _buildSidebarItem(Icons.inventory_2, 'Gestion Produits', () {
                    Navigator.pop(context);
                    // Navigator.pushNamed(context, '/products');
                  }, isActive: true),

                  _buildSidebarItem(Icons.category, 'Catégories', () {
                    Navigator.pop(context); // Ferme le drawer
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CategoriesScreen(),
                      ),
                    );
                  }, isActive: false),

                  _buildSidebarItem(Icons.category, 'Unités', () {
                    Navigator.pop(context); // Ferme le drawer
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
                    // Navigator.pushNamed(context, '/sales');
                  }, isActive: false),
                  _buildSidebarItem(Icons.analytics, 'Rapports', () {
                    Navigator.pop(context);
                    // Navigator.pushNamed(context, '/reports');
                  }, isActive: false),

                  _buildSidebarItem(Icons.settings, 'Paramètres', () {
                    Navigator.pop(context);
                    // Navigator.pushNamed(context, '/settings');
                  }, isActive: false),
                  _buildSidebarItem(Icons.receipt, 'Factures', () {
                    Navigator.pop(context);
                    // Navigator.pushNamed(context, '/invoices');
                  }, isActive: false),

                  Divider(height: 20, indent: 20, endIndent: 20),

                  _buildSidebarItem(Icons.help, 'Aide & Support', () {
                    Navigator.pop(context);
                    // Afficher l'aide
                  }, isActive: false),
                  _buildSidebarItem(Icons.info, 'À propos', () {
                    Navigator.pop(context);
                    // Afficher about
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

  // METHODES DU FORMULAIRE
  Widget _buildImageSection() {
    return Column(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: AppTheme.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.textLight.withOpacity(0.3)),
          ),
          child: _imageUrl == null || _imageUrl!.isEmpty
              ? Icon(
                  Icons.add_photo_alternate,
                  size: 40,
                  color: AppTheme.textLight,
                )
              : ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(_imageUrl!, fit: BoxFit.cover),
                ),
        ),
        SizedBox(height: 8),
        TextButton.icon(
          onPressed: _pickImage,
          icon: Icon(Icons.camera_alt, color: AppTheme.primaryRed),
          label: Text(
            'Ajouter une image',
            style: TextStyle(color: AppTheme.primaryRed),
          ),
        ),
      ],
    );
  }

  Widget _buildReferenceField() {
    return TextFormField(
      controller: _refController,
      decoration: InputDecoration(
        labelText: 'Référence *',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        prefixIcon: Icon(Icons.code),
      ),
      validator: (value) {
        if (value == null || value.isEmpty)
          return 'La référence est obligatoire';
        return null;
      },
    );
  }

  Widget _buildNameField() {
    return TextFormField(
      controller: _nameController,
      decoration: InputDecoration(
        labelText: 'Nom du produit *',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        prefixIcon: Icon(Icons.shopping_bag),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return 'Le nom est obligatoire';
        return null;
      },
    );
  }

  Widget _buildCategoryAndUnitRow() {
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: _buildCategoryDropdown(),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: _buildUnitDropdown(),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedCategory,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: 'Catégorie *',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      ),
      icon: Icon(Icons.arrow_drop_down, color: AppTheme.primaryRed),
      items: _categories.map((category) {
        return DropdownMenuItem(value: category, child: Text(category));
      }).toList(),
      onChanged: (value) => setState(() => _selectedCategory = value),
      validator: (value) =>
          value == null ? 'La catégorie est obligatoire' : null,
    );
  }

  Widget _buildUnitDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedUnit,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: 'Unité *',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      ),
      icon: Icon(Icons.arrow_drop_down, color: AppTheme.primaryRed),
      items: _units.map((unit) {
        return DropdownMenuItem(value: unit, child: Text(unit));
      }).toList(),
      onChanged: (value) => setState(() => _selectedUnit = value),
      validator: (value) => value == null ? 'L\'unité est obligatoire' : null,
    );
  }

  Widget _buildPurchasePriceField() {
    return TextFormField(
      controller: _purchasePriceController,
      decoration: InputDecoration(
        labelText: 'Prix d\'achat *',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        prefixIcon: Icon(Icons.attach_money),
        suffixText: 'DH',
      ),
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value == null || value.isEmpty)
          return 'Le prix d\'achat est obligatoire';
        if (double.tryParse(value) == null) return 'Prix invalide';
        return null;
      },
    );
  }

  Widget _buildSalePriceField() {
    return TextFormField(
      controller: _salePriceController,
      decoration: InputDecoration(
        labelText: 'Prix de vente *',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        prefixIcon: Icon(Icons.sell),
        suffixText: 'DH',
      ),
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value == null || value.isEmpty)
          return 'Le prix de vente est obligatoire';
        if (double.tryParse(value) == null) return 'Prix invalide';
        return null;
      },
    );
  }

  Widget _buildWholesalePriceField() {
    return TextFormField(
      controller: _wholesalePriceController,
      decoration: InputDecoration(
        labelText: 'Prix grossiste',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        prefixIcon: Icon(Icons.business),
        suffixText: 'DH',
      ),
      keyboardType: TextInputType.number,
    );
  }

  Widget _buildResellerPriceField() {
    return TextFormField(
      controller: _resellerPriceController,
      decoration: InputDecoration(
        labelText: 'Prix revendeur',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        prefixIcon: Icon(Icons.store),
        suffixText: 'DH',
      ),
      keyboardType: TextInputType.number,
    );
  }

  Widget _buildStockField() {
    return TextFormField(
      controller: _stockController,
      decoration: InputDecoration(
        labelText: 'Stock *',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        prefixIcon: Icon(Icons.inventory),
      ),
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value == null || value.isEmpty) return 'Le stock est obligatoire';
        if (int.tryParse(value) == null) return 'Stock invalide';
        return null;
      },
    );
  }

  Widget _buildAlertStockField() {
    return TextFormField(
      controller: _alertStockController,
      decoration: InputDecoration(
        labelText: 'Alerte de stock',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        prefixIcon: Icon(Icons.warning),
      ),
      keyboardType: TextInputType.number,
    );
  }

  Widget _buildSaveButton() {
    return ElevatedButton(
      onPressed: _saveProduct,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.primaryRed,
        foregroundColor: AppTheme.white,
        padding: EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
        shadowColor: AppTheme.primaryRed.withOpacity(0.3),
      ),
      child: Text(
        widget.product == null ? 'AJOUTER LE PRODUIT' : 'MODIFIER LE PRODUIT',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  void _pickImage() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Ajouter une image'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.photo_library, color: AppTheme.primaryRed),
              title: Text('Galerie'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: Icon(Icons.camera_alt, color: AppTheme.primaryRed),
              title: Text('Appareil photo'),
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

  void _saveProduct() {
    if (_formKey.currentState!.validate()) {
      final product = {
        'name': _nameController.text,
        'ref': _refController.text,
        'category': _selectedCategory,
        'unit': _selectedUnit,
        'purchasePrice': double.parse(_purchasePriceController.text),
        'price': double.parse(_salePriceController.text),
        'wholesalePrice': _wholesalePriceController.text.isNotEmpty
            ? double.parse(_wholesalePriceController.text)
            : null,
        'resellerPrice': _resellerPriceController.text.isNotEmpty
            ? double.parse(_resellerPriceController.text)
            : null,
        'stock': int.parse(_stockController.text),
        'alertStock': _alertStockController.text.isNotEmpty
            ? int.parse(_alertStockController.text)
            : null,
        'image': _imageUrl,
      };
      Navigator.pop(context, product);
    }
  }

  void _deleteProduct() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Supprimer le produit'),
        content: Text('Êtes-vous sûr de vouloir supprimer ce produit ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context, {'delete': true});
            },
            child: Text(
              'Supprimer',
              style: TextStyle(color: AppTheme.primaryRed),
            ),
          ),
        ],
      ),
    );
  }
}
