import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class RecentActivityItem extends StatelessWidget {
  final String type;
  final String description;
  final String amount;
  final String time;

  const RecentActivityItem({
    Key? key,
    required this.type,
    required this.description,
    required this.amount,
    required this.time,
  }) : super(key: key);

  IconData _getIcon() {
    switch (type) {
      case 'sale':
        return Icons.shopping_cart;
      case 'purchase':
        return Icons.local_shipping;
      case 'payment':
        return Icons.payment;
      case 'expense':
        return Icons.money_off;
      default:
        return Icons.receipt;
    }
  }

  Color _getColor() {
    switch (type) {
      case 'sale':
        return Colors.green;
      case 'payment':
        return Colors.green;
      case 'purchase':
        return Colors.orange;
      case 'expense':
        return Colors.red;
      default:
        return AppTheme.primaryRed;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.background),
        borderRadius: BorderRadius.circular(12),
        color: AppTheme.white,
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _getColor().withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(_getIcon(), color: _getColor(), size: 18),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textDark,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  time,
                  style: TextStyle(fontSize: 12, color: AppTheme.textLight),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: amount.startsWith('+') ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}
