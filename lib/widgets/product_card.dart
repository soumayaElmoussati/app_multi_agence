import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ProductCard extends StatelessWidget {
  final Map<String, dynamic> product;

  const ProductCard({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isLowStock = (product['stock'] ?? 0) <= (product['alertStock'] ?? 0);

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: isLowStock
              ? Border.all(color: Colors.orange.withOpacity(0.3), width: 1)
              : null,
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image placeholder
                  Container(
                    height: 90,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppTheme.background, // Utilisation de background
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child:
                        product['image_url'] == null ||
                            product['image_url'].isEmpty
                        ? Icon(
                            Icons.inventory_2_outlined,
                            color:
                                AppTheme.textLight, // Utilisation de textLight
                            size: 40,
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              product['image_url'],
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(
                                  Icons.broken_image,
                                  color: AppTheme
                                      .textLight, // Utilisation de textLight
                                  size: 40,
                                );
                              },
                            ),
                          ),
                  ),
                  SizedBox(height: 8),

                  // Nom du produit
                  Text(
                    product['name'] ?? 'Produit sans nom',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: AppTheme.textDark,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),

                  // Prix
                  Text(
                    '${product['price']?.toStringAsFixed(2) ?? '0.00'} DH',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: AppTheme.primaryRed,
                    ),
                  ),
                  SizedBox(height: 4),

                  // Stock
                  Row(
                    children: [
                      Icon(
                        Icons.inventory_2,
                        size: 12,
                        color: AppTheme.textLight,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Stock: ${product['stock'] ?? 0}',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppTheme.textLight,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 2),

                  // Catégorie
                  Row(
                    children: [
                      Icon(
                        Icons.category,
                        size: 12,
                        color: AppTheme.textLight, // Utilisation de textLight
                      ),
                      SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          product['category'] ?? 'Non catégorisé',
                          style: TextStyle(
                            fontSize: 11,
                            color:
                                AppTheme.textLight, // Utilisation de textLight
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Badge stock faible
            if (isLowStock)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.warning, size: 10, color: Colors.white),
                      SizedBox(width: 2),
                      Text(
                        'Stock faible',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
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
}
