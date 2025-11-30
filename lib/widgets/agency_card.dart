import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AgencyCard extends StatelessWidget {
  final Map<String, dynamic> agency;

  const AgencyCard({Key? key, required this.agency}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            // Agency Icon
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppTheme.primaryRed.withOpacity(0.1),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Icon(Icons.business, color: AppTheme.primaryRed, size: 24),
            ),
            SizedBox(width: 12),

            // Agency Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    agency['name'],
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    agency['address'],
                    style: TextStyle(fontSize: 12, color: AppTheme.textLight),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Gérant: ${agency['manager']}',
                    style: TextStyle(fontSize: 12, color: AppTheme.textLight),
                  ),
                ],
              ),
            ),

            // Status & Menu
            Column(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: agency['status'] == 'active'
                        ? Colors.green.withOpacity(0.1)
                        : Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    agency['status'] == 'active' ? 'Active' : 'Inactive',
                    style: TextStyle(
                      color: agency['status'] == 'active'
                          ? Colors.green
                          : Colors.orange,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 8),
                PopupMenuButton(
                  icon: Icon(Icons.more_vert, size: 20),
                  itemBuilder: (context) => [
                    PopupMenuItem(value: 'edit', child: Text('Modifier')),
                    PopupMenuItem(value: 'view', child: Text('Voir détails')),
                    PopupMenuItem(value: 'disable', child: Text('Désactiver')),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
