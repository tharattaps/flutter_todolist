import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../validation_service.dart';

class AddPage extends StatefulWidget {
  const AddPage({super.key, this.onSaved});

  /// Called after a task is saved successfully.
  final VoidCallback? onSaved;

  @override
  State<AddPage> createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _validator = ValidationService();
  bool _saving = false;
  AutovalidateMode _autovalidate = AutovalidateMode.disabled;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      // After the first failed attempt, re-check fields as the user types.
      setState(() => _autovalidate = AutovalidateMode.onUserInteraction);
      return;
    }

    setState(() => _saving = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await FirebaseFirestore.instance.collection('tasks').add({
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      }).timeout(const Duration(seconds: 10));
      _formKey.currentState!.reset();
      _titleController.clear();
      _descriptionController.clear();
      FocusManager.instance.primaryFocus?.unfocus();
      setState(() => _autovalidate = AutovalidateMode.disabled);
      messenger.showSnackBar(
        const SnackBar(content: Text('บันทึกรายการงานเรียบร้อย')),
      );
      widget.onSaved?.call();
    } on TimeoutException {
      messenger.showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text('บันทึกไม่สำเร็จ: เชื่อมต่อ Firestore ไม่ได้ กรุณาลองใหม่'),
        ),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(backgroundColor: Colors.red, content: Text('บันทึกไม่สำเร็จ: $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        autovalidateMode: _autovalidate,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: scheme.primaryContainer,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: scheme.onPrimaryContainer),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'กรอกข้อมูลให้ครบทั้ง 2 ช่อง แล้วกดปุ่ม "บันทึก"',
                      style: TextStyle(color: scheme.onPrimaryContainer),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const _FieldLabel('ชื่อรายการงาน (Title)'),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                hintText: 'เช่น ทำการบ้านวิชาคณิตศาสตร์',
                prefixIcon: Icon(Icons.title),
              ),
              textInputAction: TextInputAction.next,
              validator: (v) => _validator.validateRequired(v, 'ชื่อรายการงาน'),
            ),
            const SizedBox(height: 20),
            const _FieldLabel('รายละเอียด (Description)'),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                hintText: 'เช่น ทำแบบฝึกหัดบทที่ 3 ข้อ 1-10',
                prefixIcon: Padding(
                  padding: EdgeInsets.only(bottom: 60),
                  child: Icon(Icons.description_outlined),
                ),
              ),
              maxLines: 4,
              validator: (v) => _validator.validateRequired(v, 'รายละเอียด'),
            ),
            const SizedBox(height: 28),
            SizedBox(
              height: 52,
              child: FilledButton.icon(
                onPressed: _saving ? null : _save,
                icon: _saving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save),
                label: const Text('บันทึก', style: TextStyle(fontSize: 17)),
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text.rich(
        TextSpan(
          text: text,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          children: const [
            TextSpan(text: ' *', style: TextStyle(color: Colors.red)),
          ],
        ),
      ),
    );
  }
}
