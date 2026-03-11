import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../providers/providers.dart';
import '../../models/qr_item.dart';

class ItemDetailScreen extends ConsumerStatefulWidget {
  final String itemId;
  const ItemDetailScreen({super.key, required this.itemId});

  @override
  ConsumerState<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends ConsumerState<ItemDetailScreen> {
  QrItem? _item;

  @override
  void initState() {
    super.initState();
    // Load item from provider state once
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final items = ref.read(historyProvider).value;
      if (items != null) {
        setState(() {
          _item = items.firstWhere((element) => element.id == widget.itemId);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_item == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Details')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final item = _item!;
    final isQr = item.type == 'QR';

    return Scaffold(
      appBar: AppBar(
        title: Text(item.label?.isNotEmpty == true ? item.label! : 'Item Details'),
        actions: [
          IconButton(
            icon: Icon(
              item.isFavorite ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
              color: item.isFavorite ? Colors.red : null,
            ),
            onPressed: () async {
              await ref.read(historyProvider.notifier).toggleFavorite(item);
              setState(() {
                _item = item.copyWith(isFavorite: !item.isFavorite);
              });
            },
          ),
          IconButton(
            icon: const Icon(CupertinoIcons.trash),
            onPressed: () async {
              await ref.read(historyProvider.notifier).deleteItem(item.id);
              if (mounted) Navigator.pop(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  children: [
                    if (isQr)
                      Container(
                        color: Colors.white,
                        padding: const EdgeInsets.all(16),
                        child: QrImageView(
                          data: item.content,
                          version: QrVersions.auto,
                          size: 200.0,
                        ),
                      )
                    else
                      Container(
                        height: 100,
                        alignment: Alignment.center,
                        child: const Icon(CupertinoIcons.barcode, size: 80, color: Colors.grey),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Icon(isQr ? CupertinoIcons.qrcode : CupertinoIcons.barcode, size: 20, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  '${isQr ? "QR" : "Barcode"} • ${item.category}',
                  style: const TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                Text(
                  DateFormat.yMMMd().format(item.timestamp),
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
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
                item.content,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (item.category == 'URL')
                  _ActionButton(
                    icon: CupertinoIcons.compass,
                    label: 'Open',
                    onTap: () async {
                      final url = Uri.parse(item.content);
                      if (await canLaunchUrl(url)) {
                        await launchUrl(url, mode: LaunchMode.externalApplication);
                      }
                    },
                  ),
                if (item.category == 'Phone')
                  _ActionButton(
                    icon: CupertinoIcons.phone,
                    label: 'Call',
                    onTap: () async {
                      final telUrl = Uri.parse(item.content);
                      if (await canLaunchUrl(telUrl)) {
                        await launchUrl(telUrl);
                      }
                    },
                  ),
                _ActionButton(
                  icon: CupertinoIcons.doc_on_doc,
                  label: 'Copy',
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: item.content));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Copied to clipboard')),
                    );
                  },
                ),
                _ActionButton(
                  icon: CupertinoIcons.share,
                  label: 'Share',
                  onTap: () {
                    Share.share(item.content);
                  },
                ),
              ],
            ),
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
