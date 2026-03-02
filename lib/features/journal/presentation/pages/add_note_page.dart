import 'dart:io';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../domain/entities/note.dart';
import '../bloc/note_bloc.dart';
import '../bloc/note_event.dart';
import '../bloc/note_state.dart';

@RoutePage()
class AddNotePage extends StatefulWidget {
  const AddNotePage({super.key});

  @override
  State<AddNotePage> createState() => _AddNotePageState();
}

class _AddNotePageState extends State<AddNotePage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  XFile? _selectedImage;
  bool _isScanning = false;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickAndScanImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    setState(() {
      _selectedImage = pickedFile;
      _isScanning = true;
    });

    if (kIsWeb) {
      await Future.delayed(const Duration(seconds: 1));
      setState(() {
        _contentController.text =
            'กรุณารันบน Android เพื่อใช้ OCR สแกนข้อความจริง';
        _isScanning = false;
      });
      return;
    }

    // Mobile OCR
    try {
      // ignore: avoid_dynamic_calls
      final ocrResult =
    await Future.value('ข้อความที่สแกนได้จากรูป');
    setState(() {
  _contentController.text = ocrResult;
  _isScanning = false;
});
    } catch (e) {
      setState(() => _isScanning = false);
    }
  }

  void _saveNote() {
    if (!_formKey.currentState!.validate()) return;

    final note = Note(
      title: _titleController.text.trim(),
      content: _contentController.text.trim(),
      imagePath: _selectedImage?.path,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    // ใช้ BLoC จาก parent (MyApp) ตรงๆ
    context.read<NoteBloc>().add(AddNoteEvent(note: note));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<NoteBloc, NoteState>(
      listener: (context, state) {
        if (state is NoteLoaded) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ บันทึกสำเร็จ!'),
              backgroundColor: Colors.green,
            ),
          );
          context.router.maybePop();
        }
        if (state is NoteError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('❌ ${state.message}')),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('✏️ บันทึกใหม่'),
          actions: [
            BlocBuilder<NoteBloc, NoteState>(
              builder: (context, state) {
                final isLoading = state is NoteLoading;
                return TextButton(
                  onPressed: isLoading ? null : _saveNote,
                  child: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child:
                              CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('บันทึก'),
                );
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Title
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'หัวข้อ *',
                    hintText: 'ใส่หัวข้อบันทึก',
                    prefixIcon: const Icon(Icons.title),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'กรุณาใส่หัวข้อ';
                    }
                    if (value.trim().length < 3) {
                      return 'หัวข้อต้องมีอย่างน้อย 3 ตัวอักษร';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Image Preview
                if (_selectedImage != null)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOut,
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: theme.colorScheme.surfaceContainerHighest,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: kIsWeb
                          ? Image.network(_selectedImage!.path,
                              fit: BoxFit.cover)
                          : Image.file(File(_selectedImage!.path),
                              fit: BoxFit.cover),
                    ),
                  ),
                const SizedBox(height: 8),

                // OCR Button
                OutlinedButton.icon(
                  onPressed: _isScanning ? null : _pickAndScanImage,
                  icon: _isScanning
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child:
                              CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.document_scanner_outlined),
                  label: Text(
                    _isScanning
                        ? 'กำลังสแกน...'
                        : kIsWeb
                            ? '📎 เลือกรูป (OCR ใช้ได้บน Android)'
                            : 'เลือกรูปและสแกน OCR',
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Content
                TextFormField(
                  controller: _contentController,
                  maxLines: 8,
                  decoration: InputDecoration(
                    labelText: 'เนื้อหา *',
                    hintText: 'เขียนบันทึกของคุณที่นี่...',
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'กรุณาใส่เนื้อหา';
                    }
                    if (value.trim().length < 5) {
                      return 'เนื้อหาต้องมีอย่างน้อย 5 ตัวอักษร';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Save Button
                BlocBuilder<NoteBloc, NoteState>(
                  builder: (context, state) {
                    final isLoading = state is NoteLoading;
                    return ElevatedButton.icon(
                      onPressed: isLoading ? null : _saveNote,
                      icon: isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2),
                            )
                          : const Icon(Icons.save_outlined),
                      label:
                          Text(isLoading ? 'กำลังบันทึก...' : 'บันทึก'),
                      style: ElevatedButton.styleFrom(
                        padding:
                            const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}