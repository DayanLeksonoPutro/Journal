class JournalEntry {
  final String id;
  final String categoryId;
  final DateTime timestamp;
  final Map<String, dynamic> values; // key is FieldDefinition.id
  final bool isSuccess;

  JournalEntry({
    required this.id,
    required this.categoryId,
    required this.timestamp,
    required this.values,
    required this.isSuccess,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'categoryId': categoryId,
    'timestamp': timestamp.toIso8601String(),
    'values': values,
    'isSuccess': isSuccess,
  };

  factory JournalEntry.fromJson(Map<String, dynamic> json) => JournalEntry(
    id: json['id'],
    categoryId: json['categoryId'],
    timestamp: DateTime.parse(json['timestamp']),
    values: json['values'],
    isSuccess: json['isSuccess'] ?? false,
  );
}
