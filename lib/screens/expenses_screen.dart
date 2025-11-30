import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../screens/categories_screen.dart';
import '../screens/clients_screen.dart';
import '../screens/suppliers_screen.dart';
import '../screens/units_screen.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({Key? key}) : super(key: key);

  @override
  _ExpensesScreenState createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  final List<Map<String, dynamic>> _expenses = [
    {
      'id': '1',
      'category': 'Loyer',
      'amount': 5000.0,
      'date': '2024-01-15',
      'description': 'Loyer du mois de Janvier',
      'paymentMethod': 'Virement',
      'status': 'Payé',
    },
    {
      'id': '2',
      'category': 'Électricité',
      'amount': 850.0,
      'date': '2024-01-10',
      'description': 'Facture d\'électricité',
      'paymentMethod': 'Espèces',
      'status': 'Payé',
    },
    {
      'id': '3',
      'category': 'Salaires',
      'amount': 25000.0,
      'date': '2024-01-05',
      'description': 'Paiement des salaires',
      'paymentMethod': 'Virement',
      'status': 'Payé',
    },
  ];

  final List<String> _categories = [
    'Loyer',
    'Électricité',
    'Eau',
    'Internet',
    'Salaires',
    'Fournitures',
    'Transport',
    'Marketing',
    'Entretien',
    'Autres',
  ];

  final List<String> _paymentMethods = [
    'Espèces',
    'Chèque',
    'Virement',
    'Carte bancaire',
    'Crédit',
  ];

  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  String _selectedCategory = 'Loyer';
  String _selectedPaymentMethod = 'Espèces';
  String _selectedStatus = 'Payé';
  DateTime _selectedDate = DateTime.now();

  double _totalExpenses = 0.0;
  double _monthlyBudget = 50000.0;

  int _currentIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _calculateTotalExpenses();
    _dateController.text = _formatDate(DateTime.now());
  }

  void _calculateTotalExpenses() {
    setState(() {
      _totalExpenses = _expenses.fold(
        0.0,
        (sum, expense) => sum + expense['amount'],
      );
    });
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = _formatDate(picked);
      });
    }
  }

  void _addExpense() {
    if (_amountController.text.isEmpty) {
      _showMessage('Veuillez saisir le montant');
      return;
    }

    final newExpense = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'category': _selectedCategory,
      'amount': double.parse(_amountController.text),
      'date': _selectedDate.toIso8601String().split('T')[0],
      'description': _descriptionController.text.isEmpty
          ? 'Dépense ${_selectedCategory.toLowerCase()}'
          : _descriptionController.text,
      'paymentMethod': _selectedPaymentMethod,
      'status': _selectedStatus,
    };

    setState(() {
      _expenses.insert(0, newExpense);
    });

    _calculateTotalExpenses();
    _clearForm();
    _showMessage('Dépense ajoutée avec succès');
  }

  void _editExpense(int index) {
    final expense = _expenses[index];

    _selectedCategory = expense['category'];
    _amountController.text = expense['amount'].toString();
    _selectedDate = DateTime.parse(expense['date']);
    _dateController.text = _formatDate(_selectedDate);
    _descriptionController.text = expense['description'];
    _selectedPaymentMethod = expense['paymentMethod'];
    _selectedStatus = expense['status'];

    _showExpenseModal(context, index);
  }

  void _updateExpense(int index) {
    if (_amountController.text.isEmpty) {
      _showMessage('Veuillez saisir le montant');
      return;
    }

    setState(() {
      _expenses[index] = {
        'id': _expenses[index]['id'],
        'category': _selectedCategory,
        'amount': double.parse(_amountController.text),
        'date': _selectedDate.toIso8601String().split('T')[0],
        'description': _descriptionController.text,
        'paymentMethod': _selectedPaymentMethod,
        'status': _selectedStatus,
      };
    });

    _calculateTotalExpenses();
    _clearForm();
    Navigator.pop(context);
    _showMessage('Dépense modifiée avec succès');
  }

  void _deleteExpense(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Supprimer la dépense'),
        content: Text('Êtes-vous sûr de vouloir supprimer cette dépense ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _expenses.removeAt(index);
              });
              _calculateTotalExpenses();
              Navigator.pop(context);
              _showMessage('Dépense supprimée avec succès');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryRed,
            ),
            child: Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  void _clearForm() {
    _amountController.clear();
    _descriptionController.clear();
    _selectedDate = DateTime.now();
    _dateController.text = _formatDate(_selectedDate);
    _selectedCategory = 'Loyer';
    _selectedPaymentMethod = 'Espèces';
    _selectedStatus = 'Payé';
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

  void _showExpenseModal(BuildContext context, [int? editIndex]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.primaryRed,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      editIndex == null
                          ? 'Nouvelle dépense'
                          : 'MODIFIER DÉPENSE',
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
              SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        decoration: InputDecoration(
                          labelText: 'Catégorie',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        items: _categories.map((category) {
                          return DropdownMenuItem(
                            value: category,
                            child: Text(category),
                          );
                        }).toList(),
                        onChanged: (category) {
                          setState(() {
                            _selectedCategory = category!;
                          });
                        },
                      ),
                      SizedBox(height: 12),
                      TextFormField(
                        controller: _amountController,
                        decoration: InputDecoration(
                          labelText: 'Montant (DH)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: Icon(
                            Icons.attach_money,
                            color: AppTheme.primaryRed,
                          ),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      SizedBox(height: 12),
                      TextFormField(
                        controller: _dateController,
                        decoration: InputDecoration(
                          labelText: 'Date',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: Icon(
                            Icons.calendar_today,
                            color: AppTheme.primaryRed,
                          ),
                        ),
                        readOnly: true,
                        onTap: () => _selectDate(context),
                      ),
                      SizedBox(height: 12),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: Icon(
                            Icons.description,
                            color: AppTheme.primaryRed,
                          ),
                        ),
                        maxLines: 3,
                      ),
                      SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: _selectedPaymentMethod,
                        decoration: InputDecoration(
                          labelText: 'Méthode de paiement',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        items: _paymentMethods.map((method) {
                          return DropdownMenuItem(
                            value: method,
                            child: Text(method),
                          );
                        }).toList(),
                        onChanged: (method) {
                          setState(() {
                            _selectedPaymentMethod = method!;
                          });
                        },
                      ),
                      SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: _selectedStatus,
                        decoration: InputDecoration(
                          labelText: 'Statut',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        items: ['Payé', 'En attente', 'Annulé'].map((status) {
                          return DropdownMenuItem(
                            value: status,
                            child: Text(status),
                          );
                        }).toList(),
                        onChanged: (status) {
                          setState(() {
                            _selectedStatus = status!;
                          });
                        },
                      ),
                      SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: editIndex == null
                              ? _addExpense
                              : () => _updateExpense(editIndex),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryRed,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            editIndex == null
                                ? 'Ajouter dépense'
                                : 'MODIFIER DÉPENSE',
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExpenseCard(Map<String, dynamic> expense, int index) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    expense['category'],
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryRed,
                    ),
                  ),
                ),
                PopupMenuButton(
                  icon: Icon(Icons.more_vert, color: AppTheme.textLight),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, color: AppTheme.primaryRed),
                          SizedBox(width: 8),
                          Text('Modifier'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Supprimer'),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    if (value == 'edit') {
                      _editExpense(index);
                    } else if (value == 'delete') {
                      _deleteExpense(index);
                    }
                  },
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              expense['description'],
              style: TextStyle(color: AppTheme.textLight),
            ),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Montant',
                      style: TextStyle(fontSize: 12, color: AppTheme.textLight),
                    ),
                    Text(
                      '${expense['amount'].toStringAsFixed(2)} DH',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryRed,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Date',
                      style: TextStyle(fontSize: 12, color: AppTheme.textLight),
                    ),
                    Text(
                      expense['date'].split('-').reversed.join('/'),
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Paiement',
                      style: TextStyle(fontSize: 12, color: AppTheme.textLight),
                    ),
                    Text(
                      expense['paymentMethod'],
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 8),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: _getStatusColor(expense['status']),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                expense['status'],
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Payé':
        return Colors.green;
      case 'En attente':
        return Colors.orange;
      case 'Annulé':
        return Colors.red;
      default:
        return AppTheme.primaryRed;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: _buildModernAppBar(),
      bottomNavigationBar: _buildBottomNavBar(),
      drawer: _buildSidebar(),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _clearForm();
          _showExpenseModal(context);
        },
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
                        'Gestion des dépenses',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Total: ${_totalExpenses.toStringAsFixed(2)} DH',
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

  Widget _buildBody() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cartes de statistiques - CORRIGÉ
            _buildStatsCards(),
            SizedBox(height: 20),

            // En-tête de la liste
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Historique des dépenses',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryRed,
                  ),
                ),
                Text(
                  '${_expenses.length} dépense${_expenses.length > 1 ? 's' : ''}',
                  style: TextStyle(color: AppTheme.textLight),
                ),
              ],
            ),
            SizedBox(height: 16),

            // Liste des dépenses
            _expenses.isEmpty
                ? _buildEmptyState()
                : Column(
                    children: [
                      ..._expenses.asMap().entries.map((entry) {
                        final index = entry.key;
                        final expense = entry.value;
                        return _buildExpenseCard(expense, index);
                      }),
                    ],
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCards() {
    final remainingBudget = _monthlyBudget - _totalExpenses;
    final budgetPercentage = (_totalExpenses / _monthlyBudget * 100).clamp(
      0.0,
      100.0,
    );

    return Column(
      children: [
        Row(
          children: [
            // Carte total dépenses - CORRIGÉ
            Expanded(
              child: Card(
                elevation: 4,
                color: AppTheme.primaryRed,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.arrow_downward,
                            color: Colors.white,
                            size: 20,
                          ),
                          SizedBox(width: 4), // Réduit l'espacement
                          Expanded(
                            child: Text(
                              'Dépenses',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        '${_totalExpenses.toStringAsFixed(2)} DH',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18, // Taille réduite
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(width: 12),

            // Carte budget restant - CORRIGÉ
            Expanded(
              child: Card(
                elevation: 4,
                color: budgetPercentage > 80 ? Colors.orange : Colors.green,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.account_balance_wallet,
                            color: Colors.white,
                            size: 20,
                          ),
                          SizedBox(width: 4), // Réduit l'espacement
                          Expanded(
                            child: Text(
                              'Budget',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        '${remainingBudget.toStringAsFixed(2)} DH',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18, // Taille réduite
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: budgetPercentage / 100,
                        backgroundColor: Colors.white.withOpacity(0.3),
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        // Carte pourcentage budget
        Card(
          elevation: 4,
          color: Colors.blue,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Icon(Icons.pie_chart, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${budgetPercentage.toStringAsFixed(1)}% du budget utilisé',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: 200,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.money_off, size: 60, color: AppTheme.textLight),
            SizedBox(height: 16),
            Text(
              'Aucune dépense',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.textLight,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Appuyez sur le bouton + pour ajouter une dépense',
              style: TextStyle(color: AppTheme.textLight, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
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
                    'Gestionnaire',
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
                  isActive: false,
                ),
                _buildSidebarItem(
                  Icons.money_off,
                  'Dépenses',
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
