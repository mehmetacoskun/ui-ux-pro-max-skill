import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../widgets/sidebar.dart';
import '../widgets/stat_card.dart';
import '../widgets/sales_chart.dart';
import '../widgets/glass_card.dart';
import '../widgets/top_products.dart';
import '../core/app_colors.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          const Sidebar(),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(32),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 32),
                    _buildStatsGrid(),
                    const SizedBox(height: 32),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Expanded(flex: 2, child: SalesChart()),
                        const SizedBox(width: 32),
                        const Expanded(flex: 1, child: RecentOrders()),
                      ],
                    ),
                    const SizedBox(height: 32),
                    const TopProducts(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Welcome back, Josh!",
              style: TextStyle(
                color: AppColors.textBody,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Here's what's happening with your store today.",
              style: TextStyle(color: AppColors.textMuted, fontSize: 16),
            ),
          ],
        ),
        Row(
          children: [
            _IconButton(icon: LucideIcons.search),
            const SizedBox(width: 12),
            _IconButton(icon: LucideIcons.bell),
            const SizedBox(width: 24),
            CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.accent,
              child: const Text("JQ", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 4,
      crossAxisSpacing: 24,
      mainAxisSpacing: 24,
      childAspectRatio: 1.5,
      children: const [
        StatCard(
          title: "Total Revenue",
          value: "\$45,231.89",
          trend: "+20.1%",
          icon: LucideIcons.dollarSign,
        ),
        StatCard(
          title: "Orders",
          value: "+2350",
          trend: "+180.1%",
          icon: LucideIcons.shoppingCart,
        ),
        StatCard(
          title: "Conversion Rate",
          value: "3.24%",
          trend: "+19%",
          icon: LucideIcons.activity,
        ),
        StatCard(
          title: "Active Now",
          value: "+573",
          trend: "+201",
          icon: LucideIcons.userPlus,
        ),
      ],
    );
  }
}

class RecentOrders extends StatelessWidget {
  const RecentOrders({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      height: 350,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Recent Orders",
            style: TextStyle(
              color: AppColors.textBody,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.separated(
              itemCount: 5,
              separatorBuilder: (_, __) => Divider(color: Colors.white.withOpacity(0.05)),
              itemBuilder: (context, index) {
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: Colors.white.withOpacity(0.1),
                    child: Text("${index + 1}", style: const TextStyle(color: Colors.white)),
                  ),
                  title: Text("Order #123$index", style: const TextStyle(color: AppColors.textBody)),
                  subtitle: Text("2 mins ago", style: const TextStyle(color: AppColors.textMuted)),
                  trailing: const Text("\$120.00", style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold)),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _IconButton extends StatelessWidget {
  final IconData icon;
  const _IconButton({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Icon(icon, color: AppColors.textBody, size: 20),
    );
  }
}
