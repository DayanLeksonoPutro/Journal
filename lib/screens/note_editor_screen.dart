import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:iconoir_flutter/iconoir_flutter.dart' as iconoir;
import '../providers/note_provider.dart';

class NoteEditorScreen extends StatefulWidget {
  final NoteItem? note;
  const NoteEditorScreen({super.key, this.note});

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  bool _isChanged = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _contentController =
        TextEditingController(text: widget.note?.content ?? '');

    _titleController.addListener(_onChanged);
    _contentController.addListener(_onChanged);
  }

  void _onChanged() {
    if (!_isChanged) {
      setState(() {
        _isChanged = true;
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _saveNote() {
    if (_titleController.text.isEmpty && _contentController.text.isEmpty) {
      if (widget.note != null) {
        Provider.of<NoteProvider>(context, listen: false)
            .deleteNote(widget.note!.id);
      }
      Navigator.pop(context);
      return;
    }

    final provider = Provider.of<NoteProvider>(context, listen: false);
    if (widget.note == null) {
      provider.addNote(_titleController.text, _contentController.text);
    } else {
      provider.updateNote(
          widget.note!.id, _titleController.text, _contentController.text);
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _saveNote();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const iconoir.NavArrowLeft(),
            onPressed: _saveNote,
          ),
          actions: [
            if (widget.note != null)
              IconButton(
                icon: const iconoir.Bin(),
                onPressed: () {
                  Provider.of<NoteProvider>(context, listen: false)
                      .deleteNote(widget.note!.id);
                  Navigator.pop(context);
                },
              ),
            IconButton(
              icon: const iconoir.Check(),
              onPressed: _saveNote,
            ),
          ],
        ),
        body: Column(
          children: [
            TextField(
              controller: _titleController,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
              decoration: const InputDecoration(
                hintText: 'Title',
                border: InputBorder.none,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
            ),
            Expanded(
              child: TextField(
                controller: _contentController,
                maxLines: null,
                style: const TextStyle(fontSize: 18),
                decoration: const InputDecoration(
                  hintText: 'Note',
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
