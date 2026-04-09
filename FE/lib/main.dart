import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'utils/auth_provider.dart';
import 'utils/todo_provider.dart';
import 'screens/login_screen.dart';
import 'screens/todo_list_screen.dart';
import 'widgets/responsive_wrapper.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() {
  runApp(const TodoOtpApp());
}

class TodoOtpApp extends StatelessWidget {
  const TodoOtpApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..checkAuth()),
        ChangeNotifierProvider(create: (_) => TodoProvider()),
      ],
      child: MaterialApp(
        title: 'AstroTodo',
        navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF22C55E), // CTA Green
            secondary: Color(0xFF1E293B), // Secondary
            surface: Color(0xFF0F172A), // Primary/Surface
            background: Color(0xFF020617), // Background
            onPrimary: Colors.white,
            onSecondary: Color(0xFFF8FAFC),
            onSurface: Color(0xFFF8FAFC),
            onBackground: Color(0xFFF8FAFC),
          ),
          scaffoldBackgroundColor: const Color(0xFF020617),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF0F172A),
            foregroundColor: Color(0xFFF8FAFC),
            centerTitle: true,
            elevation: 0,
          ),
          cardTheme: CardTheme(
            color: const Color(0xFF0F172A),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.white.withOpacity(0.05)),
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF22C55E),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: const Color(0xFF0F172A),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF22C55E)),
            ),
            labelStyle: const TextStyle(color: Color(0xFF94A3B8)),
          ),
        ),
        home: const ResponsiveWrapper(
          child: AuthWrapper(),
        ),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, child) {
        if (auth.isInitializing) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator(color: Color(0xFF22C55E))),
          );
        }

        if (auth.isAuthenticated) {
          return const TodoListScreen();
        }

        return const LoginScreen();
      },
    );
  }
}