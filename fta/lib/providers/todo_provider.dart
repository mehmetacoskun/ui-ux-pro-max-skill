import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/todo_model.dart';
import 'package:uuid/uuid.dart';

class TodoProvider with ChangeNotifier {
  List<TodoModel> _todos = [];
  final String _storageKey = 'fta_todos';
  bool _isLoading = true;

  final List<String> allCategories = ['Home', 'Work', 'Shopping', 'Personal', 'Other'];
  List<String> _selectedFilterCategories = ['Home', 'Work', 'Shopping', 'Personal', 'Other'];

  List<TodoModel> get todos => _todos.where((t) => !t.isDeleted).toList();
  bool get isLoading => _isLoading;
  List<String> get selectedFilterCategories => _selectedFilterCategories;

  // SORTED & FILTERED TODOS
  List<TodoModel> get filteredTodos {
    // 1. Filter by category and isDeleted (already handled by get todos)
    List<TodoModel> list = todos.where((todo) => _selectedFilterCategories.contains(todo.category)).toList();

    // 2. Sort Logic:
    // Primary: isCompleted (Uncompleted first)
    // Secondary: updatedAt (Newest first)
    list.sort((a, b) {
      if (a.isCompleted != b.isCompleted) {
        return a.isCompleted ? 1 : -1; // false (0) comes before true (1)
      }
      return b.updatedAt.compareTo(a.updatedAt); // Newest first
    });

    return list;
  }

  TodoProvider() {
    _loadTodos();
  }

  Future<void> _loadTodos() async {
    _isLoading = true;
    notifyListeners();
    
    final prefs = await SharedPreferences.getInstance();
    final String? todosJson = prefs.getString(_storageKey);
    
    if (todosJson != null) {
      final List<dynamic> decoded = jsonDecode(todosJson);
      _todos = decoded.map((item) => TodoModel.fromJson(item)).toList();
    }
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> _saveTodos() async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(_todos.map((todo) => todo.toJson()).toList());
    await prefs.setString(_storageKey, encoded);
  }

  void addTodo(String title, {String? description, DateTime? dueDate, String category = 'General'}) {
    if (title.trim().isEmpty) return;
    
    final now = DateTime.now();
    final newTodo = TodoModel(
      id: const Uuid().v4(),
      title: title,
      description: description,
      createdAt: now,
      updatedAt: now,
      dueDate: dueDate,
      category: category,
      version: 1,
    );
    
    _todos.insert(0, newTodo);
    _saveTodos();
    notifyListeners();
  }

  void updateTodo(TodoModel updatedTodo) {
    final index = _todos.indexWhere((todo) => todo.id == updatedTodo.id);
    if (index != -1) {
      _todos[index] = updatedTodo.copyWith(
        updatedAt: DateTime.now(),
        version: updatedTodo.version + 1,
      );
      _saveTodos();
      notifyListeners();
    }
  }

  void toggleTodo(String id) {
    final index = _todos.indexWhere((todo) => todo.id == id);
    if (index != -1) {
      _todos[index] = _todos[index].copyWith(
        isCompleted: !_todos[index].isCompleted,
        updatedAt: DateTime.now(),
        version: _todos[index].version + 1,
      );
      _saveTodos();
      notifyListeners();
    }
  }

  void deleteTodo(String id) {
    final index = _todos.indexWhere((todo) => todo.id == id);
    if (index != -1) {
      _todos[index] = _todos[index].copyWith(
        isDeleted: true,
        updatedAt: DateTime.now(),
        version: _todos[index].version + 1,
      );
      _saveTodos();
      notifyListeners();
    }
  }

  void toggleFilterCategory(String category) {
    if (_selectedFilterCategories.contains(category)) {
      if (_selectedFilterCategories.length > 1) {
        _selectedFilterCategories.remove(category);
      }
    } else {
      _selectedFilterCategories.add(category);
    }
    notifyListeners();
  }

  void selectAllCategories() {
    _selectedFilterCategories = List.from(allCategories);
    notifyListeners();
  }
}
