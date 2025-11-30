import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AlertBadge extends StatelessWidget {
  final String value;

  const AlertBadge({Key? key, required this.value}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppTheme.primaryRed,
        borderRadius: BorderRadius.circular(10),
      ),
      constraints: BoxConstraints(minWidth: 16, minHeight: 16),
      child: Text(
        value,
        style: TextStyle(
          color: AppTheme.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
