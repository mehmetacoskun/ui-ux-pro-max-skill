import 'package:flutter/foundation.dart';
import '../models/todo.dart';
import '../services/todo_service.dart';
import '../services/token_manager.dart';
import '../services/api_client.dart';
import '../utils/api_config.dart';

class TodoProvider extends ChangeNotifier {
  final TodoService _todoService = TodoService();

  List<Todo> _todos = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  String? _error;
  bool _isOffline = false;
  int _currentPage = 0;

  List<Todo> get todos => _todos;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => _hasMore;
  String? get error => _error;
  bool get isOffline => _isOffline;

  Future<void> fetchTodos({bool refresh = false}) async {
    if (_isLoading) return;

    if (refresh) {
      _currentPage = 0;
      _todos = [];
      _hasMore = true;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final apiClient = _todoService.client as ApiClient;
      _isOffline = !(await apiClient.isOnline);

      final result = await _todoService.getTodos(
        skip: _currentPage * ApiConfig.defaultPageSize,
        limit: ApiConfig.defaultPageSize,
      );

      if (refresh || _currentPage == 0) {
        _todos = result.todos;
      } else {
        _todos = [..._todos, ...result.todos];
      }

      _hasMore = result.hasMore;
      _currentPage++;

      final cachedJson = _todos.map((t) => t.toJson()).toList();
      await TokenManager.cacheTodos(cachedJson);
    } catch (e) {
      if (_todos.isEmpty) {
        final cached = await TokenManager.getCachedTodos();
        if (cached != null && cached.isNotEmpty) {
          _todos = cached
              .map((json) => Todo.fromJson(json as Map<String, dynamic>))
              .toList();
          _isOffline = true;
        } else {
          _error = e.toString();
        }
      } else {
        _error = e.toString();
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMore() async {
    if (_isLoadingMore || !_hasMore || _isOffline) return;

    _isLoadingMore = true;
    notifyListeners();

    try {
      final result = await _todoService.getTodos(
        skip: _currentPage * ApiConfig.defaultPageSize,
        limit: ApiConfig.defaultPageSize,
      );

      _todos = [..._todos, ...result.todos];
      _hasMore = result.hasMore;
      _currentPage++;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  Future<bool> addTodo(String title, String? description) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newTodo = await _todoService.createTodo(title, description);
      _todos = [newTodo, ..._todos];
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateTodo(int id,
      {String? title, String? description, bool? isCompleted}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedTodo = await _todoService.updateTodo(
        id,
        title: title,
        description: description,
        isCompleted: isCompleted,
      );

      final index = _todos.indexWhere((t) => t.id == id);
      if (index != -1) {
        _todos[index] = updatedTodo;
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteTodo(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _todoService.deleteTodo(id);
      _todos = _todos.where((t) => t.id != id).toList();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void reset() {
    _todos = [];
    _isLoading = false;
    _isLoadingMore = false;
    _hasMore = true;
    _error = null;
    _isOffline = false;
    _currentPage = 0;
    notifyListeners();
  }
}
