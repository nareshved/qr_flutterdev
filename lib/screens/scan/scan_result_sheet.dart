import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';
import '../../../models/qr_item.dart';
import '../../../providers/providers.dart';
import 'package:uuid/uuid.dart';

class ScanResultSheet extends ConsumerStatefulWidget {
  final Barcode barcode;

  const ScanResultSheet({super.key, required this.barcode});

  @override
  ConsumerState<ScanResultSheet> createState() => _ScanResultSheetState();
}

class _ScanResultSheetState extends ConsumerState<ScanResultSheet> {
  late String _uuid;

  @override
  void initState() {
    super.initState();
    _uuid = const Uuid().v4();
    _saveToHistory();
  }

  Future<void> _saveToHistory() async {
    final settings = ref.read(settingsProvider);
    if (!settings.saveHistory) return;

    final format = widget.barcode.format;
    final type = (format == BarcodeFormat.qrCode) ? 'QR' : 'Barcode';
    final content = widget.barcode.rawValue ?? '';
    
    String category = 'Text';
    if (content.startsWith('http://') || content.startsWith('https://')) {
      category = 'URL';
    } else if (content.startsWith('tel:')) {
      category = 'Phone';
    }

    final item = QrItem(
      id: _uuid,
      isGenerated: false,
      type: type,
      category: category,
      content: content,
      isFavorite: false,
      timestamp: DateTime.now(),
    );

    await ref.read(historyProvider.notifier).addItem(item);
  }

  @override
  Widget build(BuildContext context) {
    final content = widget.barcode.rawValue ?? 'Unknown';
    final format = widget.barcode.format;
    final isQr = format == BarcodeFormat.qrCode;
    
    String category = 'Text';
    
    if (content.startsWith('http://') || content.startsWith('https://')) {
      category = 'URL';
    } else if (content.startsWith('tel:')) {
      category = 'Phone';
    }

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(20),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 5,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            Row(
              children: [
                Icon(isQr ? CupertinoIcons.qrcode : CupertinoIcons.barcode, size: 20, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  '${isQr ? "QR" : "Barcode"} • $category',
                  style: const TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: SelectableText(
                content,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (category == 'URL')
                  _ActionButton(
                    icon: CupertinoIcons.compass,
                    label: 'Open',
                    onTap: () async {
                      final url = Uri.parse(content);
                      if (await canLaunchUrl(url)) {
                        await launchUrl(url, mode: LaunchMode.externalApplication);
                      }
                    },
                  ),
                if (category == 'Phone')
                  _ActionButton(
                    icon: CupertinoIcons.phone,
                    label: 'Call',
                    onTap: () async {
                      final telUrl = Uri.parse('tel:${content.replaceAll("tel:", "")}');
                      if (await canLaunchUrl(telUrl)) {
                        await launchUrl(telUrl);
                      }
                    },
                  ),
                _ActionButton(
                  icon: CupertinoIcons.doc_on_doc,
                  label: 'Copy',
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: content));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Copied to clipboard')),
                    );
                  },
                ),
                _ActionButton(
                  icon: CupertinoIcons.share,
                  label: 'Share',
                  onTap: () {
                    Share.share(content);
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
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
            radius: 28,
            backgroundColor: Colors.blueAccent.withValues(alpha: 0.1),
            child: Icon(icon, color: Colors.blueAccent, size: 26),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
