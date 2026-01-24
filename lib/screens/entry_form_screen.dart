import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:iconoir_flutter/iconoir_flutter.dart' as iconoir;
import 'package:uuid/uuid.dart';
import '../providers/journal_provider.dart';
import '../models/category.dart';
import '../models/entry.dart';

class EntryFormScreen extends StatefulWidget {
  final String categoryId;
  final JournalEntry? entry;

  const EntryFormScreen({super.key, required this.categoryId, this.entry});

  @override
  State<EntryFormScreen> createState() => _EntryFormScreenState();
}

class _EntryFormScreenState extends State<EntryFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> _values = {};
  late JournalCategory _category;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<JournalProvider>(context, listen: false);
    _category =
        provider.categories.firstWhere((c) => c.id == widget.categoryId);

    if (widget.entry != null) {
      _values.addAll(widget.entry!.values);
    } else {
      // Initialize default values
      for (var field in _category.fields) {
        if (field.type == FieldType.checkbox) {
          _values[field.id] = false;
        } else if (field.type == FieldType.number) {
          _values[field.id] = 0.0;
        } else {
          _values[field.id] = '';
        }
      }
    }
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Determine overall success
      bool isSuccess = true;
      final successFields = _category.fields.where((f) => f.isSuccessIndicator);

      if (successFields.isNotEmpty) {
        for (var field in successFields) {
          if (field.type == FieldType.checkbox) {
            if (_values[field.id] != true) {
              isSuccess = false;
              break;
            }
          }
          // Add other success logic if needed
        }
      }

      final newEntry = JournalEntry(
        id: widget.entry?.id ?? const Uuid().v4(),
        categoryId: widget.categoryId,
        timestamp: widget.entry?.timestamp ?? DateTime.now(),
        values: _values,
        isSuccess: isSuccess,
      );

      final provider = Provider.of<JournalProvider>(context, listen: false);
      if (widget.entry == null) {
        provider.addEntry(newEntry);
      } else {
        provider.updateEntry(newEntry);
      }

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.entry == null ? 'New' : 'Edit'} Entry'),
        actions: [
          IconButton(
            icon: const iconoir.Check(),
            onPressed: _save,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: _category.fields.map((field) {
            return _buildField(field);
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildField(FieldDefinition field) {
    switch (field.type) {
      case FieldType.text:
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: TextFormField(
            initialValue: _values[field.id]?.toString(),
            decoration: InputDecoration(
              labelText: field.label,
              border: const OutlineInputBorder(),
            ),
            onSaved: (val) => _values[field.id] = val,
          ),
        );
      case FieldType.number:
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: TextFormField(
            initialValue: _values[field.id]?.toString(),
            decoration: InputDecoration(
              labelText: field.label,
              border: const OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            onSaved: (val) =>
                _values[field.id] = double.tryParse(val ?? '0') ?? 0,
          ),
        );
      case FieldType.checkbox:
        return CheckboxListTile(
          title: Text(field.label),
          value: _values[field.id] ?? false,
          onChanged: (val) {
            setState(() {
              _values[field.id] = val;
            });
          },
          controlAffinity: ListTileControlAffinity.leading,
        );
      case FieldType.imagePair:
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                field.label,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildImagePlaceholder('Before'),
                  const SizedBox(width: 8),
                  _buildImagePlaceholder('After'),
                ],
              ),
            ],
          ),
        );
    }
  }

  Widget _buildImagePlaceholder(String label) {
    return Expanded(
      child: AspectRatio(
        aspectRatio: 1,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[400]!),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const iconoir.MediaImage(color: Colors.grey),
              const SizedBox(height: 4),
              Text(label,
                  style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}
