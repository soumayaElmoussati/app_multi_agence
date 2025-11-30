import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AddClientScreen extends StatefulWidget {
  @override
  _AddClientScreenState createState() => _AddClientScreenState();
}

class _AddClientScreenState extends State<AddClientScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _postalCodeController = TextEditingController();
  final TextEditingController _companyController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  // Autres champs
  String? _selectedClientType = 'Particulier';
  String? _selectedStatus = 'Actif';
  String? _selectedCity = 'Casablanca';
  double _creditLimit = 0.0;

  final List<String> _clientTypes = [
    'Particulier',
    'Entreprise',
    'Revendeur',
    'VIP',
  ];
  final List<String> _statusTypes = ['Actif', 'Inactif', 'En attente', 'VIP'];
  final List<String> _cities = [
    'Casablanca',
    'Rabat',
    'Marrakech',
    'Fès',
    'Tanger',
    'Agadir',
    'Meknès',
    'Oujda',
    'Kenitra',
    'Tétouan',
    'Safi',
    'Mohammédia',
    'Laâyoune',
    'Nador',
    'Beni Mellal',
    'Taza',
    'El Jadida',
    'Khouribga',
    'Settat',
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildPersonalInfoSection(),
              SizedBox(height: 20),
              _buildContactInfoSection(),
              SizedBox(height: 20),
              _buildAddressSection(),
              SizedBox(height: 20),
              _buildBusinessInfoSection(),
              SizedBox(height: 20),
              _buildNotesSection(),
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
                        'NOUVEAU CLIENT',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Remplissez les informations du client',
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
                child: Icon(Icons.people_rounded, size: 24),
              ),
              label: 'Clients',
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

  // SIDEBAR
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
                  }, isActive: true),
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
                  }, isActive: false),

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

  // SECTION INFORMATIONS PERSONNELLES
  Widget _buildPersonalInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Informations Personnelles',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.textDark,
          ),
        ),
        SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _firstNameController,
                decoration: InputDecoration(
                  labelText: 'Prénom *',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Le prénom est obligatoire';
                  }
                  return null;
                },
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _lastNameController,
                decoration: InputDecoration(
                  labelText: 'Nom *',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Le nom est obligatoire';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  // SECTION COORDONNÉES
  Widget _buildContactInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Coordonnées',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.textDark,
          ),
        ),
        SizedBox(height: 16),
        TextFormField(
          controller: _emailController,
          decoration: InputDecoration(
            labelText: 'Email *',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            prefixIcon: Icon(Icons.email_outlined),
          ),
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'L\'email est obligatoire';
            }
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
              return 'Email invalide';
            }
            return null;
          },
        ),
        SizedBox(height: 16),
        TextFormField(
          controller: _phoneController,
          decoration: InputDecoration(
            labelText: 'Téléphone *',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            prefixIcon: Icon(Icons.phone_outlined),
          ),
          keyboardType: TextInputType.phone,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Le téléphone est obligatoire';
            }
            // Validation format marocain
            if (!RegExp(
              r'^(\+212|0)[5-7][0-9]{8}$',
            ).hasMatch(value.replaceAll(' ', ''))) {
              return 'Format invalide (ex: +212612345678 ou 0612345678)';
            }
            return null;
          },
        ),
      ],
    );
  }

  // SECTION ADRESSE
  Widget _buildAddressSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Adresse',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.textDark,
          ),
        ),
        SizedBox(height: 16),
        TextFormField(
          controller: _addressController,
          decoration: InputDecoration(
            labelText: 'Adresse complète *',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            prefixIcon: Icon(Icons.home_outlined),
          ),
          maxLines: 2,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'L\'adresse est obligatoire';
            }
            return null;
          },
        ),
        SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: DropdownButtonFormField<String>(
                value: _selectedCity,
                decoration: InputDecoration(
                  labelText: 'Ville *',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: Icon(Icons.location_city),
                ),
                items: _cities.map((city) {
                  return DropdownMenuItem(value: city, child: Text(city));
                }).toList(),
                onChanged: (value) => setState(() => _selectedCity = value),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'La ville est obligatoire';
                  }
                  return null;
                },
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              flex: 1,
              child: TextFormField(
                controller: _postalCodeController,
                decoration: InputDecoration(
                  labelText: 'Code Postal',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: Icon(Icons.markunread_mailbox),
                ),
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // SECTION INFORMATIONS COMMERCIALES
  Widget _buildBusinessInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Informations Commerciales',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.textDark,
          ),
        ),
        SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: _selectedClientType,
          decoration: InputDecoration(
            labelText: 'Type de client *',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            prefixIcon: Icon(Icons.category_outlined),
          ),
          items: _clientTypes.map((type) {
            return DropdownMenuItem(value: type, child: Text(type));
          }).toList(),
          onChanged: (value) => setState(() => _selectedClientType = value),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Le type de client est obligatoire';
            }
            return null;
          },
        ),
        SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: _selectedStatus,
          decoration: InputDecoration(
            labelText: 'Statut *',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            prefixIcon: Icon(Icons.flag_outlined),
          ),
          items: _statusTypes.map((status) {
            return DropdownMenuItem(value: status, child: Text(status));
          }).toList(),
          onChanged: (value) => setState(() => _selectedStatus = value),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Le statut est obligatoire';
            }
            return null;
          },
        ),
        SizedBox(height: 16),
        TextFormField(
          controller: _companyController,
          decoration: InputDecoration(
            labelText: 'Entreprise (optionnel)',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            prefixIcon: Icon(Icons.business_center_outlined),
          ),
        ),
        SizedBox(height: 16),
        TextFormField(
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Limite de crédit (DH)',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            prefixIcon: Icon(Icons.credit_card_outlined),
            suffixText: 'DH',
          ),
          onChanged: (value) {
            _creditLimit = double.tryParse(value) ?? 0.0;
          },
        ),
      ],
    );
  }

  // SECTION NOTES
  Widget _buildNotesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Notes',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.textDark,
          ),
        ),
        SizedBox(height: 16),
        TextFormField(
          controller: _notesController,
          decoration: InputDecoration(
            labelText: 'Notes supplémentaires',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            alignLabelWithHint: true,
          ),
          maxLines: 4,
        ),
      ],
    );
  }

  // BOUTON SAUVEGARDE
  Widget _buildSaveButton() {
    return ElevatedButton(
      onPressed: _saveClient,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.primaryRed,
        foregroundColor: AppTheme.white,
        padding: EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
        shadowColor: AppTheme.primaryRed.withOpacity(0.3),
      ),
      child: Text(
        'AJOUTER LE CLIENT',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  // MÉTHODES UTILITAIRES
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

  // SAUVEGARDE DU CLIENT
  void _saveClient() {
    if (_formKey.currentState!.validate()) {
      final newClient = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'firstName': _firstNameController.text,
        'lastName': _lastNameController.text,
        'email': _emailController.text,
        'phone': _phoneController.text,
        'address': _addressController.text,
        'city': _selectedCity,
        'postalCode': _postalCodeController.text,
        'company': _companyController.text,
        'type': _selectedClientType,
        'status': _selectedStatus,
        'creditLimit': _creditLimit,
        'notes': _notesController.text,
        'totalPurchases': 0.0,
        'lastPurchase': 'Aucun achat',
        'color': _getRandomColor(),
        'registrationDate': DateTime.now().toIso8601String(),
      };

      // Retourner au précédent écran avec les données
      Navigator.pop(context, newClient);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Client ${_firstNameController.text} ${_lastNameController.text} créé avec succès',
          ),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Color _getRandomColor() {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.indigo,
      Colors.amber,
    ];
    return colors[DateTime.now().millisecond % colors.length];
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _postalCodeController.dispose();
    _companyController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}
