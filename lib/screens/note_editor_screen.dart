import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:iconoir_flutter/iconoir_flutter.dart' as iconoir;
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../providers/note_provider.dart';
import '../main.dart';

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
  int _colorIndex = 0;

  // Checklist state
  bool _isChecklist = false;
  List<ChecklistItem> _checklistItems = [];
  final List<TextEditingController> _checklistControllers = [];
  final _uuid = const Uuid();

  @override
  void initState() {
    super.initState();
    _isNoteNew = widget.note == null;
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _contentController =
        TextEditingController(text: widget.note?.content ?? '');

    // Initialize checklist state
    _colorIndex = widget.note?.colorIndex ?? 0;
    _isChecklist = widget.note?.isChecklist ?? false;
    if (_isChecklist) {
      // If loading existing checklist, deep copy items
      if (widget.note?.checklistItems != null) {
        for (var item in widget.note!.checklistItems) {
          _checklistItems.add(ChecklistItem(
            id: item.id,
            text: item.text,
            isDone: item.isDone,
          ));
          _checklistControllers.add(TextEditingController(text: item.text));
        }
      }
      // Ensure at least one item if empty
      if (_checklistItems.isEmpty) {
        _addChecklistItem();
      }
    }

    _contentController.addListener(_onContentChanged);
    _onContentChanged(); // Initial count
  }

  void _onContentChanged() {
    if (_isChecklist) return; // Word count logic different for checklist
    final text = _contentController.text.trim();
    setState(() {
      _wordCount = text.isEmpty ? 0 : text.split(RegExp(r'\s+')).length;
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    for (var controller in _checklistControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _toggleMode() {
    setState(() {
      if (_isChecklist) {
        // Convert Checklist -> Text
        // Join all items with newline
        final buffer = StringBuffer();
        for (int i = 0; i < _checklistItems.length; i++) {
          // Update text from controller first to be sure
          _checklistItems[i].text = _checklistControllers[i].text;

          if (_checklistItems[i].text.isNotEmpty) {
            // Optional: Add [x] for done items if desired, but clean text is usually better
            buffer.writeln(_checklistItems[i].text);
          }
        }
        _contentController.text = buffer.toString().trim();
        _isChecklist = false;

        // Cleanup checklist resources
        for (var c in _checklistControllers) c.dispose();
        _checklistControllers.clear();
        _checklistItems.clear();

        _onContentChanged(); // Update word count
      } else {
        // Convert Text -> Checklist
        _isChecklist = true;
        _checklistItems.clear();
        _checklistControllers.clear(); // Should be empty anyway

        final lines = _contentController.text.split('\n');
        for (var line in lines) {
          if (line.trim().isNotEmpty) {
            final item = ChecklistItem(
              id: _uuid.v4(),
              text: line.trim(),
              isDone: false,
            );
            _checklistItems.add(item);
            _checklistControllers.add(TextEditingController(text: item.text));
          }
        }

        // If empty, add one empty item
        if (_checklistItems.isEmpty) {
          _addChecklistItem();
        }
      }
    });
  }

  void _addChecklistItem() {
    setState(() {
      final item = ChecklistItem(id: _uuid.v4(), text: '');
      _checklistItems.add(item);
      _checklistControllers.add(TextEditingController(text: ''));
    });
  }

  void _removeChecklistItem(int index) {
    setState(() {
      _checklistItems.removeAt(index);
      _checklistControllers[index].dispose();
      _checklistControllers.removeAt(index);
    });
  }

  void _saveNote() {
    String title = _titleController.text.trim();

    // Sync checklist text before saving
    if (_isChecklist) {
      for (int i = 0; i < _checklistItems.length; i++) {
        _checklistItems[i].text = _checklistControllers[i].text.trim();
      }
      // Filter out empty items if desired, or keep them
      // Let's remove completely empty items to keep it clean
      for (int i = _checklistItems.length - 1; i >= 0; i--) {
        if (_checklistItems[i].text.isEmpty) {
          _checklistItems.removeAt(i);
          _checklistControllers[i].dispose();
          _checklistControllers.removeAt(i);
        }
      }

      // Update content string for preview in list view
      // We'll store a representation of the list in content field for fallback/preview
      _contentController.text = _checklistItems.map((e) => e.text).join('\n');
    }

    final content = _contentController.text.trim();

    // Check if empty
    bool isEmpty = title.isEmpty && content.isEmpty;
    if (_isChecklist && _checklistItems.isNotEmpty) isEmpty = false;

    if (isEmpty) {
      if (widget.note != null) {
        Provider.of<NoteProvider>(context, listen: false)
            .deleteNote(widget.note!.id);
      }
      Navigator.pop(context);
      return;
    }

    // Auto-generate title if empty
    if (title.isEmpty) {
      if (_isChecklist && _checklistItems.isNotEmpty) {
        title = _checklistItems.first.text;
        if (title.isEmpty) title = 'Checklist';
      } else if (content.isNotEmpty) {
        final words = content.split(RegExp(r'\s+'));
        title = words.take(5).join(' ');
        if (words.length > 5) title += '...';
      }
    }

    final provider = Provider.of<NoteProvider>(context, listen: false);
    if (_isNoteNew) {
      provider.addNote(
        title,
        content,
        isChecklist: _isChecklist,
        checklistItems: _isChecklist ? _checklistItems : null,
        colorIndex: _colorIndex,
      );
    } else {
      provider.updateNote(
        widget.note!.id,
        title,
        content,
        isChecklist: _isChecklist,
        checklistItems: _isChecklist ? _checklistItems : null,
        colorIndex: _colorIndex,
      );
    }
    Navigator.pop(context);
  }

  void _bookmarkNote() {
    if (widget.note != null) {
      Provider.of<NoteProvider>(context, listen: false)
          .toggleBookmark(widget.note!.id);
      setState(() {}); // Rebuild to update icon color
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Save the note first to pin it.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = widget.note?.updatedAt ?? DateTime.now();
    final timestamp = DateFormat('EEEE, dd MMM yyyy • HH:mm').format(now);

    Color backgroundColor = Theme.of(context).scaffoldBackgroundColor;
    if (_colorIndex > 0) {
      final color = SettingsProvider.themeColors[_colorIndex];
      final isDark = Theme.of(context).brightness == Brightness.dark;
      backgroundColor = isDark
          ? Color.lerp(Theme.of(context).cardColor, color, 0.2)!
          : Color.lerp(Theme.of(context).colorScheme.surface, color, 0.15)!;
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _saveNote();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: iconoir.NavArrowLeft(
              color: Theme.of(context).colorScheme.primary,
            ),
            onPressed: _saveNote,
          ),
          actions: [
            IconButton(
              tooltip: _isChecklist ? 'Switch to Text' : 'Switch to Checklist',
              icon: _isChecklist
                  ? iconoir.PageFlip(
                      color: Theme.of(context).colorScheme.primary)
                  : iconoir.TaskList(
                      color: Theme.of(context).colorScheme.primary,
                    ),
              onPressed: _toggleMode,
            ),
            if (widget.note != null)
              IconButton(
                icon: iconoir.Bin(
                  color: Theme.of(context).colorScheme.primary,
                ),
                onPressed: () {
                  Provider.of<NoteProvider>(context, listen: false)
                      .deleteNote(widget.note!.id);
                  Navigator.pop(context);
                },
              ),
            IconButton(
              icon: (widget.note?.isBookmarked ?? false)
                  ? iconoir.BookmarkSolid(
                      color: Theme.of(context).colorScheme.primary,
                    )
                  : iconoir.Bookmark(
                      color: Theme.of(context).colorScheme.primary,
                    ),
              onPressed: _bookmarkNote,
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        body: Column(
          children: [
            // Metadata
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

            // Title Input
            Hero(
              tag: 'title_${widget.note?.id ?? 'new'}',
              child: Material(
                color: Colors.transparent,
                child: TextField(
                  controller: _titleController,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
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

            // Content (Text or Checklist)
            Expanded(
              child:
                  _isChecklist ? _buildChecklistEditor() : _buildTextEditor(),
            ),

            // Bottom Bar status
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: Theme.of(context).dividerColor.withOpacity(0.1),
                  ),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        _isChecklist
                            ? '${_checklistItems.length} items'
                            : '$_wordCount words',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                      const Spacer(),
                      if (_isChecklist)
                        _buildBadge('Checklist', Colors.orange)
                      else if (_wordCount >= 100)
                        _buildBadge('Long thought',
                            Theme.of(context).colorScheme.primary)
                      else if (_wordCount > 0)
                        _buildBadge('Quick note', Colors.green),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 40,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: SettingsProvider.themeColors.length,
                      itemBuilder: (context, index) {
                        final color = SettingsProvider.themeColors[index];
                        final isSelected = _colorIndex == index;
                        return GestureDetector(
                          onTap: () => setState(() => _colorIndex = index),
                          child: Container(
                            margin: const EdgeInsets.only(right: 8),
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected
                                    ? (Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                        : Theme.of(context)
                                            .colorScheme
                                            .onInverseSurface)
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: isSelected
                                ? iconoir.Check(
                                    width: 16,
                                    height: 16,
                                    color: color.computeLuminance() > 0.5
                                        ? Colors.black
                                        : Colors.white,
                                  )
                                : null,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextEditor() {
    return Hero(
      tag: 'content_${widget.note?.id ?? 'new'}',
      child: Material(
        color: Colors.transparent,
        child: TextField(
          controller: _contentController,
          maxLines: null,
          autofocus: _isNoteNew && !_isChecklist,
          style: TextStyle(
            fontSize: 18,
            color: Theme.of(context).colorScheme.secondary,
          ),
          decoration: const InputDecoration(
            hintText: 'Note',
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          ),
        ),
      ),
    );
  }

  Widget _buildChecklistEditor() {
    return ReorderableListView.builder(
      padding: const EdgeInsets.only(
          bottom: 80), // Space for fab usually, here just padding
      itemCount: _checklistItems.length + 1, // +1 for "Add Item" button
      onReorder: (oldIndex, newIndex) {
        setState(() {
          if (oldIndex < _checklistItems.length &&
              newIndex <= _checklistItems.length) {
            if (newIndex > oldIndex) newIndex -= 1;
            final item = _checklistItems.removeAt(oldIndex);
            _checklistItems.insert(newIndex, item);

            final controller = _checklistControllers.removeAt(oldIndex);
            _checklistControllers.insert(newIndex, controller);
          }
        });
      },
      proxyDecorator: (child, index, animation) {
        return Material(
          elevation: 2,
          color: Theme.of(context).cardColor,
          child: child,
        );
      },
      itemBuilder: (context, index) {
        // "Add Item" button at the end
        if (index == _checklistItems.length) {
          return ListTile(
            key: const ValueKey('add_button'),
            leading: Icon(Icons.add,
                color: Theme.of(context).colorScheme.onSurfaceVariant),
            title: Text(
              'List Item',
              style: TextStyle(color: Theme.of(context).hintColor),
            ),
            onTap: _addChecklistItem,
          );
        }

        final item = _checklistItems[index];
        final controller = _checklistControllers[index];

        return Material(
          key: ValueKey(item.id),
          color: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                const SizedBox(width: 8),
                Icon(Icons.drag_indicator,
                    color: Theme.of(context).colorScheme.outlineVariant,
                    size: 20),
                Checkbox(
                  value: item.isDone,
                  onChanged: (val) {
                    setState(() {
                      item.isDone = val ?? false;
                    });
                  },
                  activeColor: Theme.of(context).colorScheme.primary,
                  side: BorderSide(
                      color: Theme.of(context).colorScheme.outline, width: 2),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4)),
                ),
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                    ),
                    style: TextStyle(
                      fontSize: 18,
                      decoration:
                          item.isDone ? TextDecoration.lineThrough : null,
                      color: item.isDone
                          ? Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.5)
                          : null,
                    ),
                    onSubmitted: (_) => _addChecklistItem(),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close,
                      size: 18,
                      color: Theme.of(context).colorScheme.onSurfaceVariant),
                  onPressed: () => _removeChecklistItem(index),
                ),
              ],
            ),
          ),
        );
      },
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
