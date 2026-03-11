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

class GenerateUrlScreen extends ConsumerStatefulWidget {
  const GenerateUrlScreen({super.key});

  @override
  ConsumerState<GenerateUrlScreen> createState() => _GenerateUrlScreenState();
}

class _GenerateUrlScreenState extends ConsumerState<GenerateUrlScreen> {
  final _formKey = GlobalKey<FormState>();
  final _urlController = TextEditingController();
  final GlobalKey _qrKey = GlobalKey();
  
  String? _generatedUrl;
  bool _isSaved = false;
  late String _uuid;

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  void _generateQr() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _generatedUrl = _urlController.text.trim();
        _uuid = const Uuid().v4();
        _isSaved = false;
      });
      FocusScope.of(context).unfocus();
      _saveToHistory();
    }
  }

  Future<void> _saveToHistory() async {
    final settings = ref.read(settingsProvider);
    if (!settings.saveHistory || _generatedUrl == null) return;

    final item = QrItem(
      id: _uuid,
      isGenerated: true,
      type: 'QR',
      category: 'URL',
      content: _generatedUrl!,
      isFavorite: false,
      timestamp: DateTime.now(),
    );

    await ref.read(historyProvider.notifier).addItem(item);
    setState(() => _isSaved = true);
  }

  Future<void> _shareQr() async {
    if (_generatedUrl == null) return;
    try {
      final boundary = _qrKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final imagePath = await QrExportService.captureAndSave(boundary, 'qr_$_uuid');
      if (imagePath != null) {
        await Share.shareXFiles([XFile(imagePath)], text: 'Scan this QR code: $_generatedUrl');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error sharing QR: $e')));
      }
    }
  }

  Future<void> _saveQrToGallery() async {
    if (_generatedUrl == null) return;
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
      appBar: AppBar(title: const Text('URL QR Code')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: TextFormField(
                controller: _urlController,
                decoration: InputDecoration(
                  labelText: 'Website URL',
                  hintText: 'https://example.com',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.link),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.paste),
                    onPressed: () async {
                      final data = await Clipboard.getData(Clipboard.kTextPlain);
                      if (data?.text != null) {
                        _urlController.text = data!.text!;
                      }
                    },
                  ),
                ),
                keyboardType: TextInputType.url,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a URL';
                  }
                  final uri = Uri.tryParse(value);
                  if (uri == null || !uri.hasScheme || !uri.hasAuthority) {
                    return 'Enter a valid URL (e.g. https://...)';
                  }
                  return null;
                },
                onFieldSubmitted: (_) => _generateQr(),
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
            
            if (_generatedUrl != null) ...[
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    children: [
                      RepaintBoundary(
                        key: _qrKey,
                        child: Container(
                          color: Colors.white, // Ensure white background for QR
                          padding: const EdgeInsets.all(16),
                          child: QrImageView(
                            data: _generatedUrl!,
                            version: QrVersions.auto,
                            size: 200.0,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        _generatedUrl!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 14, color: Colors.grey),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
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
                    label: 'Copy URL',
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: _generatedUrl!));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('URL copied')),
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
