class TodoModel {
  final String id;
  final String title;
  final String? description;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? dueDate;
  final String category;
  
  // Sync related fields
  final String? userId; // Future auth integration
  final bool isDeleted; // Soft delete for sync
  final int version;    // For conflict resolution

  TodoModel({
    required this.id,
    required this.title,
    this.description,
    this.isCompleted = false,
    required this.createdAt,
    required this.updatedAt,
    this.dueDate,
    this.category = 'General',
    this.userId,
    this.isDeleted = false,
    this.version = 1,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'isCompleted': isCompleted,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'dueDate': dueDate?.toIso8601String(),
    'category': category,
    'userId': userId,
    'isDeleted': isDeleted,
    'version': version,
  };

  factory TodoModel.fromJson(Map<String, dynamic> json) => TodoModel(
    id: json['id'],
    title: json['title'],
    description: json['description'],
    isCompleted: json['isCompleted'] ?? false,
    createdAt: DateTime.parse(json['createdAt']),
    updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : DateTime.parse(json['createdAt']),
    dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
    category: json['category'] ?? 'General',
    userId: json['userId'],
    isDeleted: json['isDeleted'] ?? false,
    version: json['version'] ?? 1,
  );

  TodoModel copyWith({
    String? id,
    String? title,
    String? description,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? dueDate,
    String? category,
    String? userId,
    bool? isDeleted,
    int? version,
  }) {
    return TodoModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      dueDate: dueDate ?? this.dueDate,
      category: category ?? this.category,
      userId: userId ?? this.userId,
      isDeleted: isDeleted ?? this.isDeleted,
      version: version ?? this.version,
    );
  }
}
