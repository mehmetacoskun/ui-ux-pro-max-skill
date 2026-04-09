import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../core/app_colors.dart';

class Sidebar extends StatelessWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.5),
        border: const Border(
          right: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(LucideIcons.shoppingBag, color: Colors.white),
                ),
                const SizedBox(width: 12),
                const Text(
                  "ShopifyPro",
                  style: TextStyle(
                    color: AppColors.textBody,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          _SidebarItem(icon: LucideIcons.layoutDashboard, title: "Dashboard", isActive: true),
          _SidebarItem(icon: LucideIcons.shoppingCart, title: "Orders"),
          _SidebarItem(icon: LucideIcons.package, title: "Products"),
          _SidebarItem(icon: LucideIcons.users, title: "Customers"),
          _SidebarItem(icon: LucideIcons.barChart3, title: "Analytics"),
          _SidebarItem(icon: LucideIcons.megaphone, title: "Marketing"),
          const Spacer(),
          _SidebarItem(icon: LucideIcons.settings, title: "Settings"),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isActive;

  const _SidebarItem({
    required this.icon,
    required this.title,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Container(
        decoration: BoxDecoration(
          color: isActive ? AppColors.accent.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          leading: Icon(
            icon,
            color: isActive ? AppColors.accent : AppColors.textMuted,
            size: 20,
          ),
          title: Text(
            title,
            style: TextStyle(
              color: isActive ? AppColors.textBody : AppColors.textMuted,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          onTap: () {},
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
