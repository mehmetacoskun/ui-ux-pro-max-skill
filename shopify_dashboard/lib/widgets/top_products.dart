import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import 'glass_card.dart';

class TopProducts extends StatelessWidget {
  const TopProducts({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Top Selling Products",
            style: TextStyle(
              color: AppColors.textBody,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Table(
            columnWidths: const {
              0: FlexColumnWidth(3),
              1: FlexColumnWidth(1),
              2: FlexColumnWidth(1),
              3: FlexColumnWidth(1),
            },
            children: [
              TableRow(
                children: [
                  _TableHeader("Product"),
                  _TableHeader("Sales"),
                  _TableHeader("Revenue"),
                  _TableHeader("Status"),
                ],
              ),
              _TableRowData("Premium Wireless Headphones", "1.2k", "\$12,000", "In Stock", Colors.greenAccent),
              _TableRowData("Ergonomic Gaming Chair", "850", "\$25,500", "Low Stock", Colors.orangeAccent),
              _TableRowData("Smartphone 14 Pro Max", "420", "\$420,000", "In Stock", Colors.greenAccent),
              _TableRowData("Mechanical Keyboard K2", "310", "\$5,800", "Out of Stock", Colors.redAccent),
            ],
          ),
        ],
      ),
    );
  }

  Widget _TableHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        title,
        style: const TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.w600, fontSize: 13),
      ),
    );
  }

  TableRow _TableRowData(String name, String sales, String revenue, String status, Color statusColor) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text(name, style: const TextStyle(color: AppColors.textBody, fontSize: 14)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text(sales, style: const TextStyle(color: AppColors.textBody, fontSize: 14)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text(revenue, style: const TextStyle(color: AppColors.textBody, fontSize: 14)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              status,
              style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }
}
