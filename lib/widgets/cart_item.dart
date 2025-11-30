import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CartItem extends StatefulWidget {
  final Map<String, dynamic> item;
  final Function(int) onQuantityChanged;
  final VoidCallback onRemove; // ← Changé de Function à VoidCallback

  const CartItem({
    Key? key,
    required this.item,
    required this.onQuantityChanged,
    required this.onRemove, // ← Maintenant VoidCallback
  }) : super(key: key);

  @override
  _CartItemState createState() => _CartItemState();
}

class _CartItemState extends State<CartItem> {
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    _quantity = widget.item['quantity'] ?? 1;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.background),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Product Icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.primaryRed.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.shopping_bag,
              color: AppTheme.primaryRed,
              size: 20,
            ),
          ),
          SizedBox(width: 12),

          // Product Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.item['name'],
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4),
                Text(
                  '${widget.item['unitPrice'].toStringAsFixed(2)} DH',
                  style: TextStyle(fontSize: 12, color: AppTheme.textLight),
                ),
                SizedBox(height: 4),
                Text(
                  'Total: ${widget.item['totalPrice'].toStringAsFixed(2)} DH',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryRed,
                  ),
                ),
              ],
            ),
          ),

          // Quantity Controls
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: AppTheme.primaryRed.withOpacity(0.3)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                // Decrease Button
                IconButton(
                  icon: Icon(Icons.remove, size: 16),
                  onPressed: _quantity > 1 ? _decreaseQuantity : null,
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(minWidth: 32, minHeight: 32),
                  color: AppTheme.primaryRed,
                ),

                // Quantity Display
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    _quantity.toString(),
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ),

                // Increase Button
                IconButton(
                  icon: Icon(Icons.add, size: 16),
                  onPressed: _increaseQuantity,
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(minWidth: 32, minHeight: 32),
                  color: AppTheme.primaryRed,
                ),
              ],
            ),
          ),

          // Remove Button - CORRIGÉ
          IconButton(
            icon: Icon(Icons.delete_outline, size: 20),
            onPressed: widget.onRemove, // ← Plus d'erreur !
            color: Colors.red,
          ),
        ],
      ),
    );
  }

  void _increaseQuantity() {
    setState(() {
      _quantity++;
      _updateQuantity();
    });
  }

  void _decreaseQuantity() {
    setState(() {
      if (_quantity > 1) {
        _quantity--;
        _updateQuantity();
      }
    });
  }

  void _updateQuantity() {
    widget.onQuantityChanged(_quantity);
  }
}
