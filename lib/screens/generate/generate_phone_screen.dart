import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/qr_item.dart';
import '../../providers/providers.dart';
import '../../services/qr_export_service.dart';

class GeneratePhoneScreen extends ConsumerStatefulWidget {
  const GeneratePhoneScreen({super.key});

  @override
  ConsumerState<GeneratePhoneScreen> createState() => _GeneratePhoneScreenState();
}

class _GeneratePhoneScreenState extends ConsumerState<GeneratePhoneScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final GlobalKey _qrKey = GlobalKey();
  
  String? _generatedPhone;
  bool _isSaved = false;
  late String _uuid;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _generateQr() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _generatedPhone = _phoneController.text.trim();
        _uuid = const Uuid().v4();
        _isSaved = false;
      });
      FocusScope.of(context).unfocus();
      _saveToHistory();
    }
  }

  Future<void> _saveToHistory() async {
    final settings = ref.read(settingsProvider);
    if (!settings.saveHistory || _generatedPhone == null) return;

    final item = QrItem(
      id: _uuid,
      isGenerated: true,
      type: 'QR',
      category: 'Phone',
      content: 'tel:$_generatedPhone',
      isFavorite: false,
      timestamp: DateTime.now(),
    );

    await ref.read(historyProvider.notifier).addItem(item);
    setState(() => _isSaved = true);
  }

  Future<void> _shareQr() async {
    if (_generatedPhone == null) return;
    try {
      final boundary = _qrKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final imagePath = await QrExportService.captureAndSave(boundary, 'qr_$_uuid');
      if (imagePath != null) {
        await Share.shareXFiles([XFile(imagePath)], text: 'Scan to call: $_generatedPhone');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error sharing QR: $e')));
      }
    }
  }

  Future<void> _saveQrToGallery() async {
    if (_generatedPhone == null) return;
    try {
      final boundary = _qrKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final imagePath = await QrExportService.captureAndSave(boundary, 'qr_$_uuid');
      if (imagePath != null) {
        final success = await QrExportService.saveToGallery(imagePath);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(success ? 'Saved to Photos' : 'Failed to save')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error saving QR: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Phone QR Code')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Form(
              key: _formKey,
              child: TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  hintText: '+1 234 567 8900',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a phone number';
                  }
                  if (value.length < 5) {
                    return 'Number is too short';
                  }
                  return null;
                },
                onFieldSubmitted: (_) => _generateQr(),
              ),
            ),
            const SizedBox(height: 12),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                'Scanning this QR will prompt a call to this number.',
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: FilledButton(
                onPressed: _generateQr,
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Generate QR Code', style: TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(height: 40),
            
            if (_generatedPhone != null) ...[
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    children: [
                      RepaintBoundary(
                        key: _qrKey,
                        child: Container(
                          color: Colors.white,
                          padding: const EdgeInsets.all(16),
                          child: QrImageView(
                            data: 'tel:$_generatedPhone',
                            version: QrVersions.auto,
                            size: 200.0,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        _generatedPhone!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _ActionButton(
                    icon: Icons.save_alt,
                    label: 'Save',
                    onTap: _saveQrToGallery,
                  ),
                  _ActionButton(
                    icon: Icons.share,
                    label: 'Share',
                    onTap: _shareQr,
                  ),
                  _ActionButton(
                    icon: Icons.copy,
                    label: 'Copy Num',
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: _generatedPhone!));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Phone number copied')),
                      );
                    },
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: Colors.blueAccent.withValues(alpha: 0.1),
            child: Icon(icon, color: Colors.blueAccent, size: 24),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
