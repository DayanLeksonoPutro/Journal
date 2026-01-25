enum FieldType { text, number, checkbox, imagePair, habitCheckbox }

class FieldDefinition {
  final String id;
  final String label;
  final FieldType type;
  final bool isSuccessIndicator;
  final dynamic successTarget; // used for comparing value to determine success

  FieldDefinition({
    required this.id,
    required this.label,
    required this.type,
    this.isSuccessIndicator = false,
    this.successTarget,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'type': type.name,
        'isSuccessIndicator': isSuccessIndicator,
        'successTarget': successTarget,
      };

  factory FieldDefinition.fromJson(Map<String, dynamic> json) =>
      FieldDefinition(
        id: json['id'],
        label: json['label'],
        type: FieldType.values.byName(json['type']),
        isSuccessIndicator: json['isSuccessIndicator'] ?? false,
        successTarget: json['successTarget'],
      );
}

class JournalCategory {
  final String id;
  final String name;
  final String iconName;
  final List<FieldDefinition> fields;

  JournalCategory({
    required this.id,
    required this.name,
    required this.iconName,
    required this.fields,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'iconName': iconName,
        'fields': fields.map((f) => f.toJson()).toList(),
      };

  factory JournalCategory.fromJson(Map<String, dynamic> json) =>
      JournalCategory(
        id: json['id'],
        name: json['name'],
        iconName: json['iconName'],
        fields: (json['fields'] as List)
            .map((f) => FieldDefinition.fromJson(f))
            .toList(),
      );
}
