import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/todo.dart';
import '../utils/api_config.dart';
import 'api_client.dart';

class TodoService {
  final http.Client _client;

  TodoService({http.Client? client}) : _client = client ?? ApiClient();

  http.Client get client => _client;

  dynamic _safeDecode(http.Response response) {
    try {
      return jsonDecode(response.body);
    } catch (e) {
      throw TodoException('Invalid server response');
    }
  }

  Future<Todo> createTodo(String title, String? description) async {
    try {
      final response = await _client.post(
        Uri.parse(ApiConfig.baseUrl + ApiConfig.todos),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'title': title,
          'description': description,
          'is_completed': false,
        }),
      );

      if (response.statusCode != 201) {
        final data = _safeDecode(response);
        throw TodoException(data['detail'] ?? 'Failed to create todo');
      }

      return Todo.fromJson(_safeDecode(response) as Map<String, dynamic>);
    } catch (e) {
      if (e is TodoException) rethrow;
      throw TodoException('Network error while creating todo');
    }
  }

  Future<TodoPaginationResult> getTodos({int skip = 0, int limit = 20}) async {
    limit = limit.clamp(1, ApiConfig.maxPageSize);

    try {
      final response = await _client.get(
        Uri.parse(
            '${ApiConfig.baseUrl}${ApiConfig.todos}?skip=$skip&limit=$limit'),
      );

      if (response.statusCode != 200) {
        final data = _safeDecode(response);
        throw TodoException(data['detail'] ?? 'Failed to fetch todos');
      }

      final Map<String, dynamic> responseData =
          _safeDecode(response) as Map<String, dynamic>;
      final List<dynamic> data = responseData['data'] as List<dynamic>;
      final total = responseData['total'] as int? ?? data.length;

      final todos = data
          .map((json) => Todo.fromJson(json as Map<String, dynamic>))
          .toList();
      final hasMore = (skip + limit) < total;

      return TodoPaginationResult(
        todos: todos,
        total: total,
        hasMore: hasMore,
      );
    } catch (e) {
      if (e is TodoException) rethrow;
      throw TodoException('Network error while fetching todos');
    }
  }

  Future<Todo> updateTodo(int id,
      {String? title, String? description, bool? isCompleted}) async {
    try {
      final body = <String, dynamic>{};
      if (title != null) body['title'] = title;
      if (description != null) body['description'] = description;
      if (isCompleted != null) body['is_completed'] = isCompleted;

      final response = await _client.put(
        Uri.parse(ApiConfig.baseUrl + ApiConfig.todoById(id)),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode != 200) {
        final data = _safeDecode(response);
        throw TodoException(data['detail'] ?? 'Failed to update todo');
      }

      return Todo.fromJson(_safeDecode(response) as Map<String, dynamic>);
    } catch (e) {
      if (e is TodoException) rethrow;
      throw TodoException('Network error while updating todo');
    }
  }

  Future<void> deleteTodo(int id) async {
    try {
      final response = await _client.delete(
        Uri.parse(ApiConfig.baseUrl + ApiConfig.todoById(id)),
      );

      if (response.statusCode != 204) {
        final data = _safeDecode(response);
        throw TodoException(data['detail'] ?? 'Failed to delete todo');
      }
    } catch (e) {
      if (e is TodoException) rethrow;
      throw TodoException('Network error while deleting todo');
    }
  }
}

class TodoPaginationResult {
  final List<Todo> todos;
  final int total;
  final bool hasMore;

  TodoPaginationResult({
    required this.todos,
    required this.total,
    required this.hasMore,
  });
}

class TodoException implements Exception {
  final String message;
  TodoException(this.message);

  @override
  String toString() => message;
}
