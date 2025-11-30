import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ReportsScreen extends StatefulWidget {
  @override
  _ReportsScreenState createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  String _selectedReport = 'sales';
  DateTimeRange? _selectedDateRange;

  final List<Map<String, dynamic>> _reportTypes = [
    {
      'id': 'sales',
      'title': 'Rapport des Ventes',
      'icon': Icons.shopping_cart,
      'color': Colors.green,
    },
    {
      'id': 'purchases',
      'title': 'Rapport des Achats',
      'icon': Icons.local_shipping,
      'color': Colors.blue,
    },
    {
      'id': 'expenses',
      'title': 'Rapport des Dépenses',
      'icon': Icons.trending_down,
      'color': Colors.orange,
    },
    {
      'id': 'stock',
      'title': 'Rapport du Stock',
      'icon': Icons.inventory_2,
      'color': AppTheme.primaryRed,
    },
    {
      'id': 'debts',
      'title': 'Rapport des Dettes',
      'icon': Icons.money_off,
      'color': Colors.red,
    },
    {
      'id': 'profit',
      'title': 'Profit et Perte',
      'icon': Icons.bar_chart,
      'color': Colors.purple,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Rapports & Analytics'),
        backgroundColor: AppTheme.white,
        foregroundColor: AppTheme.primaryRed,
        actions: [
          IconButton(icon: Icon(Icons.download), onPressed: _exportReport),
          IconButton(icon: Icon(Icons.print), onPressed: _printReport),
        ],
      ),
      body: Column(
        children: [
          // Date Range Selector
          _buildDateRangeSelector(),

          // Report Types Grid
          Expanded(child: _buildReportsGrid()),

          // Report Details
          _buildReportDetails(),
        ],
      ),
    );
  }

  Widget _buildDateRangeSelector() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.white,
        border: Border(bottom: BorderSide(color: AppTheme.background)),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              icon: Icon(Icons.calendar_today, size: 18),
              label: Text(
                _selectedDateRange == null
                    ? 'Sélectionner la période'
                    : '${_formatDate(_selectedDateRange!.start)} - ${_formatDate(_selectedDateRange!.end)}',
                style: TextStyle(fontSize: 14),
              ),
              onPressed: _selectDateRange,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.primaryRed,
                side: BorderSide(color: AppTheme.primaryRed),
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              ),
            ),
          ),
          SizedBox(width: 12),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.primaryRed.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '7 derniers jours',
              style: TextStyle(
                color: AppTheme.primaryRed,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportsGrid() {
    return GridView.builder(
      padding: EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.3,
      ),
      itemCount: _reportTypes.length,
      itemBuilder: (context, index) {
        return _buildReportCard(_reportTypes[index]);
      },
    );
  }

  Widget _buildReportCard(Map<String, dynamic> report) {
    bool isSelected = _selectedReport == report['id'];

    return Card(
      elevation: isSelected ? 4 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? report['color'] : Colors.transparent,
          width: isSelected ? 2 : 0,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          setState(() {
            _selectedReport = report['id'];
          });
        },
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: report['color'].withOpacity(0.1),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Icon(report['icon'], color: report['color'], size: 24),
              ),
              SizedBox(height: 12),
              Text(
                report['title'],
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 4),
              if (isSelected)
                Icon(Icons.check_circle, color: report['color'], size: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReportDetails() {
    return Container(
      height: 200,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.white,
        border: Border(top: BorderSide(color: AppTheme.background)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _getReportTitle(),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textDark,
            ),
          ),
          SizedBox(height: 12),
          Expanded(
            child: Container(
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
                      'Graphique du rapport ${_getReportTitle().toLowerCase()}',
                      style: TextStyle(color: AppTheme.textLight, fontSize: 14),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Données et statistiques détaillées',
                      style: TextStyle(
                        color: AppTheme.textLight.withOpacity(0.7),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getReportTitle() {
    return _reportTypes.firstWhere(
      (report) => report['id'] == _selectedReport,
      orElse: () => {'title': 'Rapport'},
    )['title'];
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      currentDate: DateTime.now(),
      saveText: 'Appliquer',
    );

    if (picked != null) {
      setState(() {
        _selectedDateRange = picked;
      });
    }
  }

  void _exportReport() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Exporter le Rapport'),
        content: Text(
          'Exporter le rapport ${_getReportTitle()} en format PDF/Excel ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler', style: TextStyle(color: AppTheme.textLight)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryRed,
            ),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Rapport exporté avec succès'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: Text('Exporter', style: TextStyle(color: AppTheme.white)),
          ),
        ],
      ),
    );
  }

  void _printReport() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Imprimer le Rapport'),
        content: Text('Imprimer le rapport ${_getReportTitle()} ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler', style: TextStyle(color: AppTheme.textLight)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryRed,
            ),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Rapport envoyé à l\'impression'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: Text('Imprimer', style: TextStyle(color: AppTheme.white)),
          ),
        ],
      ),
    );
  }
}
