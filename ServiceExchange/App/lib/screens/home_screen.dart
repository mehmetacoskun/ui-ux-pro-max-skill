import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../core/app_theme.dart';
import '../providers/theme_provider.dart';
import '../widgets/joshqun_header.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      // Hamburger Menu Drawer (same as FTA)
      endDrawer: Drawer(
        backgroundColor: isDark ? AppTheme.jqDarkBg : Colors.white,
        child: Column(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: AppTheme.jqGray.withOpacity(0.2))),
              ),
              child: Center(
                child: Text(
                  'JOSHQUN\n& PARTNERS',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.rubik(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
              ),
            ),
            ListTile(
              leading: Icon(isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined),
              title: Text(isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode'),
              onTap: () {
                themeProvider.toggleTheme();
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text('Sign in'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.shopping_basket_outlined),
              title: const Text('Basket'),
              onTap: () => Navigator.pop(context),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.help_outline),
              title: const Text('Help & Support'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header (copied from FTA)
            const JoshqunHeader(),
            
            // Welcome Content
            const SizedBox(height: 80),
            Container(
              constraints: const BoxConstraints(maxWidth: 900),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Welcome',
                    style: GoogleFonts.rubik(
                      fontSize: 48,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Your journey starts here.',
                    style: GoogleFonts.nunitoSans(
                      fontSize: 18,
                      color: isDark ? Colors.white70 : Colors.grey[600],
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 60),
                  // Decorative divider
                  Container(
                    width: 60,
                    height: 3,
                    decoration: BoxDecoration(
                      color: AppTheme.jqPrimaryRed,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 200),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
