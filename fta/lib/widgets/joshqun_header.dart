import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../core/app_theme.dart';
import '../providers/theme_provider.dart';

import '../providers/auth_provider.dart';

class JoshqunHeader extends StatefulWidget {
  final VoidCallback? onSignInTap;
  final VoidCallback? onProfileTap;

  const JoshqunHeader({super.key, this.onSignInTap, this.onProfileTap});

  @override
  State<JoshqunHeader> createState() => _JoshqunHeaderState();
}

class _JoshqunHeaderState extends State<JoshqunHeader> {
  bool _isSearchVisible = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    double screenWidth = MediaQuery.of(context).size.width;
    bool isSmall = screenWidth < 700;

    return Column(
      children: [
        // Main Header
        Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            border: Border(
              bottom: BorderSide(
                color: AppTheme.jqGray.withOpacity(isDark ? 0.1 : 1.0),
                width: _isSearchVisible ? 0 : 1.0,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween, // Alignment to edges
            children: [
              // Logo
              Flexible(
                child: Text(
                  'JOSHQUN\n& PARTNERS',
                  style: GoogleFonts.rubik(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    height: 1.0,
                    letterSpacing: 1.2,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              
              // Action Icons - Pushed to the right
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _headerButton(
                    icon: _isSearchVisible ? Icons.close : Icons.search,
                    label: 'Search',
                    isDark: isDark,
                    onTap: () {
                      setState(() {
                        _isSearchVisible = !_isSearchVisible;
                      });
                    },
                  ),
                  if (!isSmall) ...[
                    const SizedBox(width: 25),
                    _headerButton(
                      icon: isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                      label: isDark ? 'Light' : 'Dark',
                      isDark: isDark,
                      onTap: () => themeProvider.toggleTheme(),
                    ),
                    const SizedBox(width: 25),
                    if (authProvider.isAuthenticated)
                      _headerButton(
                        icon: Icons.person,
                        label: 'Profile',
                        isDark: isDark,
                        onTap: widget.onProfileTap,
                      )
                    else 
                      _headerButton(
                        icon: Icons.person_outline,
                        label: 'Sign in',
                        isDark: isDark,
                        onTap: widget.onSignInTap,
                      ),
                    const SizedBox(width: 25),
                    _headerButton(
                      icon: Icons.shopping_basket_outlined,
                      label: 'Basket',
                      isDark: isDark,
                    ),
                  ] else ...[
                    const SizedBox(width: 20),
                    // Hamburger Menu Icon
                    _headerButton(
                      icon: Icons.menu,
                      label: 'Menu',
                      isDark: isDark,
                      onTap: () {
                        Scaffold.of(context).openEndDrawer();
                      },
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
        
        // Expandable Search Bar
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          height: _isSearchVisible ? 80 : 0,
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            border: Border(
              bottom: BorderSide(color: AppTheme.jqGray.withOpacity(isDark ? 0.1 : 1.0)),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
                      border: Border.all(color: AppTheme.jqGray),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: TextField(
                      controller: _searchController,
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: 'Search for tasks...',
                        hintStyle: TextStyle(color: Colors.grey[500], fontSize: 13),
                        icon: Icon(Icons.search, color: Colors.grey[600], size: 18),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                if (!isSmall) const SizedBox(width: 15),
                if (!isSmall)
                  ElevatedButton(
                    onPressed: () {
                      setState(() { _isSearchVisible = false; });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.jqBlack,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    ),
                    child: const Text('SEARCH'),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _headerButton({
    required IconData icon, 
    required String label, 
    required bool isDark, 
    VoidCallback? onTap
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 28, color: isDark ? Colors.white : Colors.black),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.nunitoSans(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
