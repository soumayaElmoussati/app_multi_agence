import 'package:flutter/material.dart';
import 'package:multi_agences_app/screens/cash_screen.dart';
import 'package:multi_agences_app/screens/clients_screen.dart';
import 'package:multi_agences_app/screens/expenses_screen.dart';
import 'package:multi_agences_app/screens/invoicing_screen.dart';
import 'package:multi_agences_app/screens/purchase_screen.dart';
import 'package:multi_agences_app/screens/purchases_list_screen.dart';
import 'package:multi_agences_app/screens/reports_screen.dart';
import 'package:multi_agences_app/screens/sales_screen.dart';
import 'package:multi_agences_app/screens/settings_screen.dart';
import 'package:multi_agences_app/screens/suppliers_screen.dart';
import 'package:multi_agences_app/widgets/alert_badge.dart';
import 'package:multi_agences_app/widgets/recent_activity_item.dart';
import 'package:multi_agences_app/widgets/stat_card.dart';
import '../theme/app_theme.dart';
import 'login_screen.dart';
import 'agencies_screen.dart';
import 'products_screen.dart';
import 'pos_screen.dart';

class DashboardScreen extends StatefulWidget {
  final Map<String, dynamic>? userData;
  final String? token;
  final Map<String, dynamic>? selectedAgency;

  const DashboardScreen({
    Key? key,
    this.userData,
    this.token,
    this.selectedAgency,
  }) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  // Données simulées
  final List<Map<String, dynamic>> _stats = [
    {
      'title': 'Chiffre d\'affaires',
      'value': '12,540 DH',
      'icon': Icons.trending_up,
      'color': AppTheme.primaryRed,
      'trend': '+12%',
    },
    {
      'title': 'Ventes du jour',
      'value': '24',
      'icon': Icons.shopping_cart,
      'color': Colors.green,
      'trend': '+8%',
    },
    {
      'title': 'Dépenses',
      'value': '3,210 DH',
      'icon': Icons.trending_down,
      'color': Colors.orange,
      'trend': '-5%',
    },
    {
      'title': 'Bénéfice Net',
      'value': '9,330 DH',
      'icon': Icons.attach_money,
      'color': Colors.green,
      'trend': '+15%',
    },
  ];

  final List<Map<String, dynamic>> _stockAlerts = [
    {'product': 'iPhone 14 Pro', 'stock': '2', 'alert': true},
    {'product': 'MacBook Pro', 'stock': '1', 'alert': true},
    {'product': 'Samsung S23', 'stock': '5', 'alert': false},
    {'product': 'AirPods Pro', 'stock': '3', 'alert': true},
  ];

  final List<Map<String, dynamic>> _recentActivities = [
    {
      'type': 'sale',
      'description': 'Vente #001245',
      'amount': '+299 DH',
      'time': '10:30',
    },
    {
      'type': 'purchase',
      'description': 'Achat fournisseur',
      'amount': '-1,200 DH',
      'time': '09:15',
    },
    {
      'type': 'payment',
      'description': 'Paiement client',
      'amount': '+500 DH',
      'time': 'Hier',
    },
    {
      'type': 'expense',
      'description': 'Frais bureau',
      'amount': '-150 DH',
      'time': 'Hier',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(
          'Tableau de Bord',
          style: TextStyle(
            color: AppTheme.textDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppTheme.white,
        elevation: 2,
        iconTheme: IconThemeData(color: AppTheme.primaryRed),
        actions: [
          IconButton(
            icon: Stack(
              children: [
                Icon(Icons.notifications_outlined),
                Positioned(right: 0, child: AlertBadge(value: '3')),
              ],
            ),
            onPressed: () {},
          ),
          IconButton(icon: Icon(Icons.person_outline), onPressed: () {}),
        ],
      ),
      drawer: _buildDrawer(),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeHeader(),
            SizedBox(height: 24),
            _buildStatsGrid(),
            SizedBox(height: 24),
            _buildPerformanceChart(),
            SizedBox(height: 24),
            _buildStockAlerts(),
            SizedBox(height: 24),
            _buildRecentActivities(),
            SizedBox(height: 24),
            _buildPopularProducts(),
            SizedBox(height: 24),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primaryRed,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => PosScreen()),
          );
        },
        child: Icon(Icons.add, color: AppTheme.white, size: 28),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildWelcomeHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [AppTheme.primaryRed, AppTheme.lightRed],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryRed.withOpacity(0.3),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: AppTheme.white,
            child: Icon(Icons.person, color: AppTheme.primaryRed, size: 30),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bonjour, John!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.white,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Voici votre résumé du jour',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.celebration, color: AppTheme.white, size: 30),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.2,
      ),
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: _stats.length,
      itemBuilder: (context, index) {
        return StatCard(
          title: _stats[index]['title'],
          value: _stats[index]['value'],
          icon: _stats[index]['icon'],
          color: _stats[index]['color'],
          trend: _stats[index]['trend'],
        );
      },
    );
  }

  Widget _buildPerformanceChart() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Performance des Ventes',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                ),
                Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryRed.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '7 derniers jours',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.primaryRed,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Container(
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: AppTheme.primaryRed.withOpacity(0.2)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.bar_chart,
                      size: 50,
                      color: AppTheme.primaryRed.withOpacity(0.3),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Graphique des performances',
                      style: TextStyle(color: AppTheme.textLight, fontSize: 14),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Intégration Chart.js ou Flutter Charts',
                      style: TextStyle(
                        color: AppTheme.textLight.withOpacity(0.7),
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStockAlerts() {
    final criticalAlerts = _stockAlerts
        .where((alert) => alert['alert'] == true)
        .toList();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.warning, color: AppTheme.primaryRed, size: 24),
                SizedBox(width: 12),
                Text(
                  'Alertes Stock Critique',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                ),
                SizedBox(width: 8),
                AlertBadge(value: criticalAlerts.length.toString()),
                Spacer(),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ProductsScreen()),
                    );
                  },
                  child: Text(
                    'Voir stock',
                    style: TextStyle(color: AppTheme.primaryRed, fontSize: 12),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            if (criticalAlerts.isNotEmpty) ...[
              ...criticalAlerts.map(
                (alert) => Container(
                  margin: EdgeInsets.only(bottom: 12),
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryRed.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.primaryRed.withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryRed.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.inventory_2,
                          color: AppTheme.primaryRed,
                          size: 20,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              alert['product'],
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textDark,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Stock restant: ${alert['stock']} unités',
                              style: TextStyle(
                                color: AppTheme.primaryRed,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: AppTheme.textLight,
                      ),
                    ],
                  ),
                ),
              ),
            ] else ...[
              Container(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Column(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 50),
                    SizedBox(height: 12),
                    Text(
                      'Aucune alerte de stock',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppTheme.textLight,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Tous vos produits sont bien approvisionnés',
                      style: TextStyle(
                        color: AppTheme.textLight.withOpacity(0.7),
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivities() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.history, color: AppTheme.primaryRed, size: 24),
                SizedBox(width: 12),
                Text(
                  'Activités Récentes',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                ),
                Spacer(),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ReportsScreen()),
                    );
                  },
                  child: Text(
                    'Voir tout',
                    style: TextStyle(color: AppTheme.primaryRed, fontSize: 12),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            ..._recentActivities
                .map(
                  (activity) => RecentActivityItem(
                    type: activity['type'],
                    description: activity['description'],
                    amount: activity['amount'],
                    time: activity['time'],
                  ),
                )
                .toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildPopularProducts() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.trending_up, color: AppTheme.primaryRed, size: 24),
                SizedBox(width: 12),
                Text(
                  'Produits Populaires',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                ),
                Spacer(),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ProductsScreen()),
                    );
                  },
                  child: Text(
                    'Voir plus',
                    style: TextStyle(color: AppTheme.primaryRed, fontSize: 12),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Container(
              height: 140,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildProductItem(
                    'iPhone 14',
                    '24 ventes',
                    Icons.phone_iphone,
                  ),
                  _buildProductItem(
                    'MacBook Pro',
                    '18 ventes',
                    Icons.laptop_mac,
                  ),
                  _buildProductItem(
                    'AirPods Pro',
                    '15 ventes',
                    Icons.headphones,
                  ),
                  _buildProductItem('iPad Air', '12 ventes', Icons.tablet_mac),
                  _buildProductItem('Apple Watch', '10 ventes', Icons.watch),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductItem(String name, String sales, IconData icon) {
    return Container(
      width: 140,
      margin: EdgeInsets.only(right: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.white,
        border: Border.all(color: AppTheme.primaryRed.withOpacity(0.2)),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppTheme.primaryRed.withOpacity(0.1),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Icon(icon, size: 28, color: AppTheme.primaryRed),
          ),
          SizedBox(height: 12),
          Text(
            name,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppTheme.textDark,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
          ),
          SizedBox(height: 4),
          Text(
            sales,
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.textLight,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppTheme.primaryRed, AppTheme.darkRed],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppTheme.white,
                  child: Icon(
                    Icons.person,
                    color: AppTheme.primaryRed,
                    size: 30,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  'John Doe',
                  style: TextStyle(
                    color: AppTheme.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Administrateur',
                  style: TextStyle(color: AppTheme.white.withOpacity(0.8)),
                ),
              ],
            ),
          ),
          _buildDrawerItem(
            Icons.dashboard,
            'Tableau de Bord',
            DashboardScreen(),
            isSelected: true,
          ),
          _buildDrawerItem(Icons.business, 'Mes Agences', AgenciesScreen()),
          _buildDrawerItem(Icons.inventory_2, 'Produits', ProductsScreen()),
          _buildDrawerItem(Icons.shopping_cart, 'Point de Vente', PosScreen()),
          _buildDrawerItem(Icons.people, 'Clients', ClientsScreen()),
          _buildDrawerItem(
            Icons.local_shipping,
            'Fournisseurs',
            SuppliersScreen(),
          ),
          _buildDrawerItem(
            Icons.attach_money,
            'Caisse & Trésorerie',
            CashRegisterScreen(),
          ),
          _buildDrawerItem(Icons.business, 'Mes ventes', SalesScreen()),
          _buildDrawerItem(
            Icons.business,
            'Mes achats',
            PurchasesHistoryScreen(),
          ),
          _buildDrawerItem(Icons.business, 'Dépenses', ExpensesScreen()),
          _buildDrawerItem(Icons.bar_chart, 'Rapports', ReportsScreen()),
          _buildDrawerItem(Icons.receipt, 'Facturation', InvoicingScreen()),
          Divider(),
          _buildDrawerItem(Icons.settings, 'Paramètres', SettingsScreen()),
          _buildDrawerItem(Icons.logout, 'Déconnexion', LoginScreen()),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    IconData icon,
    String title,
    Widget screen, {
    bool isSelected = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? AppTheme.primaryRed : AppTheme.textLight,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? AppTheme.primaryRed : AppTheme.textDark,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      tileColor: isSelected ? AppTheme.primaryRed.withOpacity(0.1) : null,
      onTap: () {
        Navigator.pop(context);
        if (screen is! DashboardScreen) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => screen),
          );
        }
      },
    );
  }

  BottomNavigationBar _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (index) {
        setState(() {
          _selectedIndex = index;
        });

        switch (index) {
          case 0:
            break;
          case 1:
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => PosScreen()),
            );
            break;
          case 2:
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ClientsScreen()),
            );
            break;
          case 3:
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ReportsScreen()),
            );
            break;
        }
      },
      selectedItemColor: AppTheme.primaryRed,
      unselectedItemColor: AppTheme.textLight,
      type: BottomNavigationBarType.fixed,
      backgroundColor: AppTheme.white,
      elevation: 8,
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_cart),
          label: 'Ventes',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Clients'),
        BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Rapports'),
      ],
    );
  }
}
