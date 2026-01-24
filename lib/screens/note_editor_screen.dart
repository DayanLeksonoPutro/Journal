import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:iconoir_flutter/iconoir_flutter.dart' as iconoir;
import 'package:intl/intl.dart';
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
  bool _isNoteNew = false;
  int _wordCount = 0;

  @override
  void initState() {
    super.initState();
    _isNoteNew = widget.note == null;
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _contentController =
        TextEditingController(text: widget.note?.content ?? '');

    _contentController.addListener(_onContentChanged);
    _onContentChanged(); // Initial count
  }

  void _onContentChanged() {
    final text = _contentController.text.trim();
    setState(() {
      _wordCount = text.isEmpty ? 0 : text.split(RegExp(r'\s+')).length;
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _saveNote() {
    String title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isEmpty && content.isEmpty) {
      if (widget.note != null) {
        Provider.of<NoteProvider>(context, listen: false)
            .deleteNote(widget.note!.id);
      }
      Navigator.pop(context);
      return;
    }

    // Auto-generate title if empty
    if (title.isEmpty && content.isNotEmpty) {
      final words = content.split(RegExp(r'\s+'));
      title = words.take(5).join(' ');
      if (words.length > 5) title += '...';
    }

    final provider = Provider.of<NoteProvider>(context, listen: false);
    if (_isNoteNew) {
      provider.addNote(title, content);
    } else {
      provider.updateNote(widget.note!.id, title, content);
    }
    Navigator.pop(context);
  }

  void _bookmarkNote() {
    if (widget.note != null) {
      Provider.of<NoteProvider>(context, listen: false)
          .toggleBookmark(widget.note!.id);
      setState(() {});
    } else {
      // If it's a new note, we might need to save it first or just show a message.
      // Usually, users expect to pin after saving, but let's just show a snackbar for now
      // or save it implicitly.
      String title = _titleController.text.trim();
      final content = _contentController.text.trim();
      if (title.isEmpty && content.isEmpty) return;

      if (title.isEmpty && content.isNotEmpty) {
        final words = content.split(RegExp(r'\s+'));
        title = words.take(5).join(' ');
        if (words.length > 5) title += '...';
      }

      // We can't easily toggle something that doesn't exist, so we save it first.
      // But let's keep it simple: if widget.note is null, bookmarking will happen
      // when they save if we add a 'pendingBookmark' flag.
      // For now, let's just allow bookmarking existing notes.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Save the note first to pin it.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = widget.note?.updatedAt ?? DateTime.now();
    final timestamp = DateFormat('EEEE, dd MMM yyyy • HH:mm').format(now);

    return PopScope(
      canPop: false,
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
            IconButton(
              icon: iconoir.Bookmark(
                color:
                    (widget.note?.isBookmarked ?? false) ? Colors.amber : null,
              ),
              onPressed: _bookmarkNote,
            ),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  timestamp,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).hintColor.withOpacity(0.5),
                  ),
                ),
              ),
            ),
            Hero(
              tag: 'title_${widget.note?.id ?? 'new'}',
              child: Material(
                color: Colors.transparent,
                child: TextField(
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
              ),
            ),
            Expanded(
              child: Hero(
                tag: 'content_${widget.note?.id ?? 'new'}',
                child: Material(
                  color: Colors.transparent,
                  child: TextField(
                    controller: _contentController,
                    maxLines: null,
                    autofocus: _isNoteNew,
                    style: const TextStyle(fontSize: 18),
                    decoration: const InputDecoration(
                      hintText: 'Note',
                      border: InputBorder.none,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: Theme.of(context).dividerColor.withOpacity(0.1),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Text(
                    '$_wordCount words',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).hintColor,
                    ),
                  ),
                  const Spacer(),
                  if (_wordCount >= 100)
                    _buildBadge('Long thought', Colors.blue)
                  else if (_wordCount > 0)
                    _buildBadge('Quick note', Colors.green),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
