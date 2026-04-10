import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/todo_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/joshqun_header.dart';
import '../core/app_theme.dart';
import '../models/todo_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _todoController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  DateTime? _selectedDate;
  String _selectedCategory = 'Personal';
  
  final List<String> _categories = ['Home', 'Work', 'Shopping', 'Personal', 'Other'];

  @override
  void dispose() {
    _todoController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(BuildContext context, {DateTime? initialDate}) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppTheme.jqBlack,
              onPrimary: Colors.white,
              onSurface: AppTheme.jqBlack,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _submitTodo() {
    if (_todoController.text.trim().isEmpty) return;
    context.read<TodoProvider>().addTodo(
      _todoController.text.trim(),
      description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
      dueDate: _selectedDate,
      category: _selectedCategory,
    );
    _todoController.clear();
    _descriptionController.clear();
    setState(() {
      _selectedDate = null;
      _selectedCategory = 'Personal'; // Reset to default
    });
  }

  void _showAddTodoModal(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Scaffold(
            backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Add New Task', style: GoogleFonts.rubik(fontSize: 24, fontWeight: FontWeight.bold)),
                      IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _todoController,
                    style: GoogleFonts.nunitoSans(fontSize: 18),
                    decoration: InputDecoration(
                      hintText: 'What needs to be done?',
                      border: InputBorder.none,
                      hintStyle: TextStyle(color: Colors.grey[400]),
                    ),
                  ),
                  TextField(
                    controller: _descriptionController,
                    style: GoogleFonts.nunitoSans(fontSize: 14),
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Description (optional)',
                      border: InputBorder.none,
                      hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
                    ),
                  ),
                  const Divider(height: 40),
                  Wrap(
                    spacing: 15,
                    runSpacing: 15,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: AppTheme.jqGray),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedCategory,
                            icon: const Icon(Icons.keyboard_arrow_down, size: 20),
                            style: GoogleFonts.nunitoSans(
                              color: isDark ? Colors.white : Colors.black,
                              fontSize: 14,
                            ),
                            onChanged: (String? val) {
                              setModalState(() => _selectedCategory = val!);
                            },
                            items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                          ),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () async {
                           final DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: _selectedDate ?? DateTime.now(),
                            firstDate: DateTime.now().subtract(const Duration(days: 365)),
                            lastDate: DateTime(2101),
                          );
                          if (picked != null) {
                            setModalState(() => _selectedDate = picked);
                          }
                        },
                        icon: Icon(Icons.calendar_today, size: 18, color: AppTheme.jqPrimaryRed),
                        label: Text(
                          _selectedDate == null ? 'Set Due Date' : DateFormat('MMM d').format(_selectedDate!),
                          style: GoogleFonts.nunitoSans(color: isDark ? Colors.white : Colors.black),
                        ),
                        style: TextButton.styleFrom(
                          side: BorderSide(color: AppTheme.jqGray),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () {
                          _submitTodo();
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.jqBlack,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        ),
                        child: const Text('ADD TO LIST', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.0)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      }
      ),
    );
  }

  // EDIT DIALOG
  Future<void> _showEditDialog(BuildContext context, TodoModel todo) async {
    final TextEditingController editController = TextEditingController(text: todo.title);
    final TextEditingController editDescController = TextEditingController(text: todo.description ?? '');
    DateTime? editDate = todo.dueDate;
    String editCategory = todo.category;
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Scaffold(
              backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              body: SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Edit Task', style: GoogleFonts.rubik(fontSize: 24, fontWeight: FontWeight.bold)),
                          IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
                        ],
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: editController,
                        style: GoogleFonts.nunitoSans(fontSize: 18),
                        decoration: InputDecoration(
                          hintText: 'Task Title',
                          border: InputBorder.none,
                          hintStyle: TextStyle(color: Colors.grey[400]),
                        ),
                      ),
                      TextField(
                        controller: editDescController,
                        style: GoogleFonts.nunitoSans(fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'Description (optional)',
                          border: InputBorder.none,
                          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
                        ),
                        maxLines: 3,
                      ),
                      const Divider(height: 40),
                      Wrap(
                        spacing: 15,
                        runSpacing: 15,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: AppTheme.jqGray),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: editCategory,
                                icon: const Icon(Icons.keyboard_arrow_down, size: 20),
                                style: GoogleFonts.nunitoSans(
                                  color: isDark ? Colors.white : Colors.black,
                                  fontSize: 14,
                                ),
                                onChanged: (String? val) {
                                  setDialogState(() => editCategory = val!);
                                },
                                items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                              ),
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () async {
                              final DateTime? picked = await showDatePicker(
                                context: context,
                                initialDate: editDate ?? DateTime.now(),
                                firstDate: DateTime.now().subtract(const Duration(days: 365)),
                                lastDate: DateTime(2101),
                              );
                              if (picked != null) setDialogState(() => editDate = picked);
                            },
                            icon: Icon(Icons.calendar_today, size: 18, color: AppTheme.jqPrimaryRed),
                            label: Text(
                              editDate == null ? 'Set Due Date' : DateFormat('MMM d, yyyy').format(editDate!),
                              style: GoogleFonts.nunitoSans(color: isDark ? Colors.white : Colors.black),
                            ),
                            style: TextButton.styleFrom(
                              side: BorderSide(color: AppTheme.jqGray),
                            ),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: () {
                              final updatedTodo = todo.copyWith(
                                title: editController.text,
                                description: editDescController.text.trim().isEmpty ? null : editDescController.text.trim(),
                                dueDate: editDate,
                                category: editCategory,
                              );
                              context.read<TodoProvider>().updateTodo(updatedTodo);
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.jqBlack,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                            ),
                            child: const Text('SAVE CHANGES', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.0)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
        );
      },
    );
  }

  void _showSignInModal(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    bool otpSent = false;
    final emailController = TextEditingController();
    final codeController = TextEditingController();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final authProvider = Provider.of<AuthProvider>(context);
            
            return Scaffold(
              backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              body: SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Sign In', style: GoogleFonts.rubik(fontSize: 24, fontWeight: FontWeight.bold)),
                          IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
                        ],
                      ),
                      const SizedBox(height: 20),
                      if (!otpSent) ...[
                        TextField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          style: GoogleFonts.nunitoSans(fontSize: 18),
                          decoration: InputDecoration(
                            hintText: 'Email Address',
                            border: const OutlineInputBorder(),
                            hintStyle: TextStyle(color: Colors.grey[400]),
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: authProvider.isLoading ? null : () async {
                              if (emailController.text.trim().isEmpty) return;
                              final success = await authProvider.requestOtp(emailController.text.trim());
                              if (success && context.mounted) {
                                setModalState(() => otpSent = true);
                              } else {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Failed to send OTP')),
                                  );
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.jqBlack,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                            ),
                            child: authProvider.isLoading 
                              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                              : const Text('Send Verification Code', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.0)),
                          ),
                        ),
                      ] else ...[
                        Text('We sent a code to ${emailController.text}', style: GoogleFonts.nunitoSans(fontSize: 16)),
                        const SizedBox(height: 20),
                        TextField(
                          controller: codeController,
                          keyboardType: TextInputType.number,
                          maxLength: 6,
                          style: GoogleFonts.nunitoSans(fontSize: 18, letterSpacing: 8.0),
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                            hintText: '000000',
                            border: const OutlineInputBorder(),
                            hintStyle: TextStyle(color: Colors.grey[400], letterSpacing: 8.0),
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: authProvider.isLoading ? null : () async {
                              if (codeController.text.trim().length != 6) return;
                              final success = await authProvider.verifyOtp(emailController.text.trim(), codeController.text.trim());
                              if (success && context.mounted) {
                                Navigator.pop(context); // Close modal
                              } else {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Invalid code')),
                                  );
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.jqBlack,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                            ),
                            child: authProvider.isLoading 
                              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                              : const Text('Verify and Sign In', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.0)),
                          ),
                        ),
                        TextButton(
                          onPressed: () => setModalState(() => otpSent = false),
                          child: const Text('Use a different email'),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          }
        );
      },
    );
  }

  void _showProfileModal(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final authProvider = Provider.of<AuthProvider>(context);
        return Scaffold(
          backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Profile Insight', style: GoogleFonts.rubik(fontSize: 24, fontWeight: FontWeight.bold)),
                      IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
                    ],
                  ),
                  const SizedBox(height: 40),
                  Center(
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: AppTheme.jqPrimaryRed,
                      child: Text(
                        authProvider.userEmail != null && authProvider.userEmail!.isNotEmpty 
                          ? authProvider.userEmail![0].toUpperCase() 
                          : 'U',
                        style: const TextStyle(fontSize: 40, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: Text(
                      authProvider.userEmail ?? 'Unknown User',
                      style: GoogleFonts.nunitoSans(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 40),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.email_outlined),
                    title: const Text('Email Address'),
                    subtitle: Text(authProvider.userEmail ?? ''),
                  ),
                  ListTile(
                    leading: const Icon(Icons.security),
                    title: const Text('Authentication'),
                    subtitle: const Text('OTP Verified'),
                  ),
                  const Divider(),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        authProvider.signOut();
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.logout),
                      label: const Text('SIGN OUT', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.0)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.jqBlack,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    final todoProvider = Provider.of<TodoProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);


    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTodoModal(context),
        backgroundColor: AppTheme.jqBlack,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
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
            if (authProvider.isAuthenticated)
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('Profile'),
                onTap: () {
                  Navigator.pop(context);
                  _showProfileModal(context);
                },
              )
            else
              ListTile(
                leading: const Icon(Icons.person_outline),
                title: const Text('Sign in'),
                onTap: () {
                  Navigator.pop(context);
                  _showSignInModal(context);
                },
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
            JoshqunHeader(
              onSignInTap: () => _showSignInModal(context),
              onProfileTap: () => _showProfileModal(context),
            ),
            const SizedBox(height: 50),
            
            Container(
              constraints: const BoxConstraints(maxWidth: 900),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your Personal Planner',
                    style: GoogleFonts.rubik(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Organize your day with elegance and precision.',
                    style: GoogleFonts.nunitoSans(
                      fontSize: 16,
                      color: isDark ? Colors.white70 : Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 40),
                  
                  const SizedBox(height: 20),
                  
                  const SizedBox(height: 40),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Active Tasks', style: GoogleFonts.rubik(fontSize: 20, fontWeight: FontWeight.bold)),
                      PopupMenuButton<String>(
                        onSelected: (_) {},
                        offset: const Offset(0, 40),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        itemBuilder: (context) {
                          return todoProvider.allCategories.map((cat) {
                            bool isSelected = todoProvider.selectedFilterCategories.contains(cat);
                            return PopupMenuItem(
                              value: cat,
                              onTap: () => todoProvider.toggleFilterCategory(cat),
                              child: Row(
                                children: [
                                  Checkbox(
                                    value: isSelected,
                                    activeColor: AppTheme.jqPrimaryRed,
                                    onChanged: (_) => todoProvider.toggleFilterCategory(cat),
                                  ),
                                  Text(cat, style: GoogleFonts.nunitoSans(fontSize: 14)),
                                ],
                              ),
                            );
                          }).toList();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                          decoration: BoxDecoration(border: Border.all(color: AppTheme.jqPrimaryRed), borderRadius: BorderRadius.circular(20)),
                          child: Row(
                            children: [
                              Icon(Icons.filter_list, size: 18, color: AppTheme.jqPrimaryRed),
                              const SizedBox(width: 8),
                              Text('Filter By Category', style: TextStyle(color: AppTheme.jqPrimaryRed, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  Consumer<TodoProvider>(
                    builder: (context, provider, child) {
                      if (provider.isLoading) return const Center(child: CircularProgressIndicator());
                      final filteredList = provider.filteredTodos;
                      if (filteredList.isEmpty) {
                        return Center(
                          child: Column(
                            children: [
                              const SizedBox(height: 60),
                              Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey[200]),
                              const SizedBox(height: 15),
                              Text(provider.todos.isEmpty ? 'Your list is looking clear.' : 'No tasks match your selection.', style: GoogleFonts.nunitoSans(fontSize: 18, color: Colors.grey[400])),
                              if (provider.todos.isNotEmpty)
                                TextButton(onPressed: () => provider.selectAllCategories(), child: const Text('Clear All Filters')),
                            ],
                          ),
                        );
                      }
                      return ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: filteredList.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 15),
                        itemBuilder: (context, index) => _buildTodoCard(context, filteredList[index], isDark),
                      );
                    },
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodoCard(BuildContext context, TodoModel todo, bool isDark) {
    String formattedCreated = DateFormat('MMM d, HH:mm').format(todo.createdAt);
    String? formattedDue = todo.dueDate != null ? DateFormat('MMM d').format(todo.dueDate!) : null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF252525) : Colors.white,
        border: Border.all(color: AppTheme.jqGray.withOpacity(isDark ? 0.2 : 0.8)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Checkbox(
              value: todo.isCompleted,
              activeColor: AppTheme.jqPrimaryRed,
              onChanged: (val) => context.read<TodoProvider>().toggleTodo(todo.id),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    todo.title,
                    style: GoogleFonts.nunitoSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
                      color: todo.isCompleted ? Colors.grey : (isDark ? Colors.white : Colors.black),
                    ),
                  ),
                  if (todo.description != null && todo.description!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      todo.description!,
                      style: GoogleFonts.nunitoSans(
                        fontSize: 12,
                        color: isDark ? Colors.white54 : Colors.black54,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Wrap(
                          spacing: 12,
                          runSpacing: 8,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            _badge(todo.category, Colors.blueGrey, isDark),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.access_time, size: 12, color: Colors.grey[500]),
                                const SizedBox(width: 4),
                                Text(formattedCreated, style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                              ],
                            ),
                            if (formattedDue != null)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppTheme.jqPrimaryRed.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.event, size: 12, color: AppTheme.jqPrimaryRed),
                                    const SizedBox(width: 4),
                                    Text(
                                      formattedDue,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: AppTheme.jqPrimaryRed,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Actions
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  visualDensity: VisualDensity.compact,
                  icon: Icon(Icons.edit_outlined, color: Colors.blueGrey[300], size: 18),
                  onPressed: () => _showEditDialog(context, todo),
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  icon: Icon(Icons.delete_outline, color: Colors.grey[400], size: 18),
                  onPressed: () => context.read<TodoProvider>().deleteTodo(todo.id),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _badge(String text, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: color.withOpacity(isDark ? 0.2 : 0.1), borderRadius: BorderRadius.circular(4), border: Border.all(color: color.withOpacity(0.3))),
      child: Text(text.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isDark ? color.withOpacity(0.8) : color, letterSpacing: 0.5)),
    );
  }
}
