import 'dart:io';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/note.dart';
import '../bloc/note_bloc.dart';
import '../bloc/note_event.dart';
import '../bloc/note_state.dart';

@RoutePage()
class NoteDetailPage extends StatefulWidget {
  final Note note;
  const NoteDetailPage({super.key, required this.note});

  @override
  State<NoteDetailPage> createState() => _NoteDetailPageState();
}

class _NoteDetailPageState extends State<NoteDetailPage> {
  bool _showSummary = false;
  String? _currentSummary;

  @override
  void initState() {
    super.initState();
    _currentSummary = widget.note.aiSummary;
    if (_currentSummary != null) _showSummary = true;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<NoteBloc, NoteState>(
      listener: (context, state) {
        if (state is NoteSummarized) {
          setState(() {
            _currentSummary = state.summary;
            _showSummary = true;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ AI สรุปสำเร็จ!'),
              backgroundColor: Colors.green,
            ),
          );
        }
        if (state is NoteError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('❌ ${state.message}')),
          );
        }
        if (state is NoteLoaded) {
          context.router.maybePop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('รายละเอียด'),
          actions: [
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _confirmDelete(context),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Hero + Title
              Row(
                children: [
                  Hero(
                    tag: 'note_icon_${widget.note.id}',
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.note_outlined,
                        color: theme.colorScheme.primary,
                        size: 28,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.note.title,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                _formatDate(widget.note.createdAt),
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
              const Divider(height: 32),

              // Image
              if (widget.note.imagePath != null) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: kIsWeb
                      ? Image.network(widget.note.imagePath!,
                          fit: BoxFit.cover)
                      : Image.file(File(widget.note.imagePath!),
                          fit: BoxFit.cover),
                ),
                const SizedBox(height: 16),
              ],

              // Content
              Text(
                'เนื้อหา',
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  widget.note.content,
                  style: theme.textTheme.bodyLarge,
                ),
              ),
              const SizedBox(height: 24),

              // AI Summarize Button
              BlocBuilder<NoteBloc, NoteState>(
                builder: (context, state) {
                  final isSummarizing = state is NoteSummarizing;
                  return ElevatedButton.icon(
                    onPressed: isSummarizing
                        ? null
                        : () {
                            if (widget.note.id == null) return;
                            context.read<NoteBloc>().add(
                                  SummarizeNoteEvent(
                                    noteId: widget.note.id!,
                                    content: widget.note.content,
                                  ),
                                );
                          },
                    icon: isSummarizing
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child:
                                CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.auto_awesome),
                    label: Text(isSummarizing
                        ? 'กำลังสรุปด้วย AI...'
                        : '✨ สรุปด้วย Gemini AI'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                },
              ),

              // AI Summary Result
              AnimatedOpacity(
                duration: const Duration(milliseconds: 500),
                opacity: _showSummary && _currentSummary != null ? 1.0 : 0.0,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOut,
                  margin: EdgeInsets.only(
                    top: _showSummary && _currentSummary != null ? 16 : 0,
                  ),
                  child: _showSummary && _currentSummary != null
                      ? Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.secondaryContainer,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: theme.colorScheme.secondary
                                  .withValues(alpha: 0.3),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.auto_awesome,
                                      color: theme.colorScheme.secondary,
                                      size: 18),
                                  const SizedBox(width: 8),
                                  Text(
                                    'สรุปโดย Gemini AI',
                                    style: theme.textTheme.titleSmall
                                        ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: theme.colorScheme.secondary,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _currentSummary!,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme
                                      .onSecondaryContainer,
                                ),
                              ),
                            ],
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('ลบบันทึก?'),
        content: const Text('ต้องการลบบันทึกนี้หรือไม่?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('ยกเลิก'),
          ),
          ElevatedButton(
            style:
                ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(ctx);
              if (widget.note.id != null) {
                context
                    .read<NoteBloc>()
                    .add(DeleteNoteEvent(id: widget.note.id!));
              }
            },
            child: const Text('ลบ',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} '
        '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}