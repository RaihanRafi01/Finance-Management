import 'package:flutter/material.dart';

Widget BuildCard(String title, double? amount, Color color, IconData icon) {
  return Expanded(
    child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 40),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text(
                  '\$${(amount ?? 0.0).toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 16, color: color),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}