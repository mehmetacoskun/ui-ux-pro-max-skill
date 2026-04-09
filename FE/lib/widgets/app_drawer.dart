import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/auth_provider.dart';
import '../utils/todo_provider.dart';
import '../screens/profile_screen.dart';
import '../screens/todo_list_screen.dart';
import '../utils/api_config.dart';
import '../main.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final currentRoute = ModalRoute.of(context)?.settings.name;

    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        final user = auth.user;
        String? fullAvatarUrl;
        if (user?.avatarUrl != null) {
          final path = user!.avatarUrl!;
          fullAvatarUrl = path.startsWith('/')
              ? '${ApiConfig.localUrl}$path'
              : '${ApiConfig.localUrl}/$path';
        }

        return Drawer(
          backgroundColor: const Color(0xFF0F172A),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(24, 60, 24, 32),
                color: const Color(0xFF020617),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 72,
                      width: 72,
                      decoration: BoxDecoration(
                        color: const Color(0xFF22C55E).withOpacity(0.1),
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFF22C55E).withOpacity(0.2), width: 2),
                        image: fullAvatarUrl != null
                            ? DecorationImage(
                                image: NetworkImage(fullAvatarUrl),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: fullAvatarUrl == null
                          ? const Icon(Icons.person_rounded, color: Color(0xFF22C55E), size: 36)
                          : null,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      user?.adiSoyadi ?? 'Explorer',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFFF8FAFC),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user?.email ?? 'Join the journey',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _DrawerItem(
                icon: Icons.grid_view_rounded,
                title: 'Daily Tasks',
                isSelected: currentRoute == '/todos' || currentRoute == null,
                onTap: () {
                  Navigator.pop(context);
                  if (currentRoute != '/todos' && currentRoute != null) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const TodoListScreen(),
                        settings: const RouteSettings(name: '/todos'),
                      ),
                    );
                  }
                },
              ),
              _DrawerItem(
                icon: Icons.person_outline_rounded,
                title: 'Account Settings',
                isSelected: currentRoute == '/profile',
                onTap: () {
                  Navigator.pop(context);
                  if (currentRoute != '/profile') {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ProfileScreen(),
                        settings: const RouteSettings(name: '/profile'),
                      ),
                    );
                  }
                },
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.logout_rounded, color: Colors.redAccent),
                    title: const Text(
                      'Sign Out',
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    onTap: () async {
                      final result = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          backgroundColor: const Color(0xFF0F172A),
                          title: const Text('Sign Out', style: TextStyle(color: Colors.white)),
                          content: const Text(
                            'Are you sure you want to end your current session?',
                            style: TextStyle(color: Color(0xFF94A3B8)),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Back', style: TextStyle(color: Color(0xFF64748B))),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.pop(context, true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.redAccent,
                              ),
                              child: const Text('Sign Out'),
                            ),
                          ],
                        ),
                      );

                      if (result == true) {
                        context.read<TodoProvider>().reset();
                        await auth.logout();
                        navigatorKey.currentState?.pushNamedAndRemoveUntil('/', (route) => false);
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        onTap: onTap,
        dense: true,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        tileColor: isSelected ? const Color(0xFF22C55E).withOpacity(0.08) : Colors.transparent,
        leading: Icon(
          icon,
          color: isSelected ? const Color(0xFF22C55E) : const Color(0xFF64748B),
          size: 22,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? const Color(0xFFF8FAFC) : const Color(0xFF94A3B8),
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}
