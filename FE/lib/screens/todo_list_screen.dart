import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/todo.dart';
import '../utils/todo_provider.dart';
import '../widgets/app_drawer.dart';

class TodoListScreen extends StatefulWidget {
  const TodoListScreen({super.key});

  @override
  State<TodoListScreen> createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TodoProvider>().fetchTodos();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.9) {
      context.read<TodoProvider>().loadMore();
    }
  }

  Future<void> _createTodo() async {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Todo'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Create'),
          ),
        ],
      ),
    );

    if (result == true && titleController.text.isNotEmpty && mounted) {
      HapticFeedback.lightImpact();
      final todoProvider = context.read<TodoProvider>();
      final success = await todoProvider.addTodo(
            titleController.text.trim(),
            descriptionController.text.isEmpty
                ? null
                : descriptionController.text.trim(),
          );
      if (success && mounted) {
        HapticFeedback.mediumImpact();
        _showSuccess('Todo created successfully');
      } else if (mounted) {
        _showError(
            todoProvider.error ?? 'Failed to create todo');
      }
    }
  }

  Future<void> _updateTodo(Todo todo) async {
    final titleController = TextEditingController(text: todo.title);
    final descriptionController =
        TextEditingController(text: todo.description ?? '');

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Todo'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result == true && titleController.text.isNotEmpty && mounted) {
      final todoProvider = context.read<TodoProvider>();
      final success = await todoProvider.updateTodo(
            todo.id,
            title: titleController.text.trim(),
            description: descriptionController.text.isEmpty
                ? null
                : descriptionController.text.trim(),
          );
      if (!success && mounted) {
        _showError(
            todoProvider.error ?? 'Failed to update todo');
      }
    }
  }

  Future<void> _toggleComplete(Todo todo) async {
    HapticFeedback.selectionClick();
    final todoProvider = context.read<TodoProvider>();
    final success = await todoProvider.updateTodo(
          todo.id,
          isCompleted: !todo.isCompleted,
        );
    if (!success && mounted) {
      _showError(
          todoProvider.error ?? 'Failed to update status');
    }
  }

  Future<void> _deleteTodo(Todo todo) async {
    HapticFeedback.mediumImpact();
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Todo'),
        content: Text('Are you sure you want to delete "${todo.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (result == true && mounted) {
      final todoProvider = context.read<TodoProvider>();
      final success = await todoProvider.deleteTodo(todo.id);
      if (success && mounted) {
        HapticFeedback.heavyImpact();
        _showSuccess('Todo deleted');
      } else if (mounted) {
        _showError(
            todoProvider.error ?? 'Failed to delete todo');
      }
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showSuccess(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green.shade600,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'AstroTodo',
          style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: -0.5),
        ),
        actions: [
          Consumer<TodoProvider>(
            builder: (context, provider, _) {
              if (provider.isOffline) {
                return Container(
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.orange.withOpacity(0.2)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.cloud_off_rounded, size: 14, color: Colors.orange),
                      SizedBox(width: 6),
                      Text(
                        'Offline',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              }
              return IconButton(
                icon: const Icon(Icons.refresh_rounded),
                onPressed: () => provider.fetchTodos(refresh: true),
                tooltip: 'Refresh',
              );
            },
          ),
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.dashboard_customize_rounded),
              onPressed: () => Scaffold.of(context).openEndDrawer(),
              tooltip: 'Menu',
            ),
          ),
        ],
      ),
      endDrawer: const AppDrawer(),
      body: Consumer<TodoProvider>(
        builder: (context, todoProvider, child) {
          if (todoProvider.isLoading && todoProvider.todos.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF22C55E)),
            );
          }

          if (todoProvider.error != null && todoProvider.todos.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.05),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.error_outline_rounded, size: 48, color: Colors.redAccent),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      todoProvider.error!,
                      style: const TextStyle(color: Colors.redAccent, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton.icon(
                      onPressed: () => todoProvider.fetchTodos(refresh: true),
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Try Again'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (todoProvider.todos.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withOpacity(0.03)),
                    ),
                    child: Icon(Icons.task_alt_rounded, size: 64, color: Colors.white.withOpacity(0.1)),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'No tasks yet',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFF8FAFC),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Ready to start your productive day?',
                    style: TextStyle(color: Color(0xFF94A3B8)),
                  ),
                  const SizedBox(height: 32),
                  OutlinedButton.icon(
                    onPressed: _createTodo,
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Add Task'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      side: const BorderSide(color: Color(0xFF22C55E)),
                      foregroundColor: const Color(0xFF22C55E),
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => todoProvider.fetchTodos(refresh: true),
            color: const Color(0xFF22C55E),
            backgroundColor: const Color(0xFF0F172A),
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              itemCount: todoProvider.todos.length + (todoProvider.hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == todoProvider.todos.length) {
                  return const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: CircularProgressIndicator(color: Color(0xFF22C55E), strokeWidth: 2)),
                  );
                }

                final todo = todoProvider.todos[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Dismissible(
                    key: Key(todo.id.toString()),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      decoration: BoxDecoration(
                        color: Colors.redAccent.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
                    ),
                    confirmDismiss: (direction) async {
                      await _deleteTodo(todo);
                      return false;
                    },
                    child: Card(
                      margin: EdgeInsets.zero,
                      child: InkWell(
                        onTap: () => _updateTodo(todo),
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: ListTile(
                            leading: Transform.scale(
                              scale: 1.1,
                              child: Checkbox(
                                value: todo.isCompleted,
                                onChanged: (value) => _toggleComplete(todo),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                              ),
                            ),
                            title: Text(
                              todo.title,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: todo.isCompleted ? const Color(0xFF64748B) : const Color(0xFFF8FAFC),
                                decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
                              ),
                            ),
                            subtitle: todo.description != null && todo.description!.isNotEmpty
                                ? Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(
                                      todo.description!,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: todo.isCompleted ? const Color(0xFF475569) : const Color(0xFF94A3B8),
                                      ),
                                    ),
                                  )
                                : null,
                            trailing: IconButton(
                              icon: const Icon(Icons.chevron_right_rounded, color: Color(0xFF475569)),
                              onPressed: () => _updateTodo(todo),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createTodo,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('New Task', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF22C55E),
      ),
    );
  }
}
