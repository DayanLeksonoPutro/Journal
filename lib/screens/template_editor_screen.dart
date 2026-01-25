import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:iconoir_flutter/iconoir_flutter.dart' as iconoir;
import 'package:uuid/uuid.dart';
import '../providers/journal_provider.dart';
import '../models/category.dart';

class TemplateEditorScreen extends StatefulWidget {
  final JournalCategory? category;

  const TemplateEditorScreen({super.key, this.category});

  @override
  State<TemplateEditorScreen> createState() => _TemplateEditorScreenState();
}

class _TemplateEditorScreenState extends State<TemplateEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late String _iconName;
  late List<FieldDefinition> _fields;

  @override
  void initState() {
    super.initState();
    _name = widget.category?.name ?? '';
    _iconName = widget.category?.iconName ?? 'book';
    _fields = widget.category?.fields != null
        ? List.from(widget.category!.fields)
        : [FieldDefinition(id: 'f1', label: 'Field 1', type: FieldType.text)];
  }

  void _addField() {
    setState(() {
      final id =
          'f${_fields.length + 1}_${DateTime.now().millisecondsSinceEpoch}';
      _fields.add(
          FieldDefinition(id: id, label: 'New Field', type: FieldType.text));
    });
  }

  void _removeField(int index) {
    setState(() {
      _fields.removeAt(index);
    });
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final category = JournalCategory(
        id: widget.category?.id ?? const Uuid().v4(),
        name: _name,
        iconName: _iconName,
        fields: _fields,
      );

      final provider = Provider.of<JournalProvider>(context, listen: false);
      if (widget.category == null) {
        provider.addCategory(category);
      } else {
        provider.updateCategory(category);
      }

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.category == null ? 'Create' : 'Edit'} Template'),
        actions: [
          IconButton(
            icon: iconoir.Check(
              color: Theme.of(context).colorScheme.primary,
            ),
            onPressed: _save,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              initialValue: _name,
              decoration: const InputDecoration(
                labelText: 'Category Name',
                border: OutlineInputBorder(),
              ),
              onSaved: (val) => _name = val ?? '',
              validator: (val) =>
                  val == null || val.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Fields',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                TextButton.icon(
                  onPressed: _addField,
                  icon: iconoir.Plus(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  label: const Text('Add Field'),
                ),
              ],
            ),
            const Divider(),
            ..._fields.asMap().entries.map((entry) {
              final index = entry.key;
              final field = entry.value;
              return _buildFieldEditor(index, field);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldEditor(int index, FieldDefinition field) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: field.label,
                    decoration: const InputDecoration(labelText: 'Label'),
                    onChanged: (val) {
                      _fields[index] = FieldDefinition(
                        id: field.id,
                        label: val,
                        type: field.type,
                        isSuccessIndicator: field.isSuccessIndicator,
                      );
                    },
                  ),
                ),
                IconButton(
                  icon: const iconoir.Bin(color: Colors.red),
                  onPressed: () => _removeField(index),
                ),
              ],
            ),
            Row(
              children: [
                const Text('Type: '),
                DropdownButton<FieldType>(
                  value: field.type,
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _fields[index] = FieldDefinition(
                          id: field.id,
                          label: field.label,
                          type: val,
                          isSuccessIndicator: field.isSuccessIndicator,
                        );
                      });
                    }
                  },
                  items: FieldType.values.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(type.name.toUpperCase()),
                    );
                  }).toList(),
                ),
                const Spacer(),
                const Text('Succ. KPI: '),
                Switch(
                  value: field.isSuccessIndicator,
                  onChanged: (val) {
                    setState(() {
                      _fields[index] = FieldDefinition(
                        id: field.id,
                        label: field.label,
                        type: field.type,
                        isSuccessIndicator: val,
                      );
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
