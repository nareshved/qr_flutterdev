import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../providers/providers.dart';

class ManageHomeScreen extends ConsumerStatefulWidget {
  const ManageHomeScreen({super.key});

  @override
  ConsumerState<ManageHomeScreen> createState() => _ManageHomeScreenState();
}

class _ManageHomeScreenState extends ConsumerState<ManageHomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Refresh items on load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(historyProvider.notifier).loadItems();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _clearHistory() async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear History'),
        content: const Text('Are you sure you want to clear your entire history? Favorites will be kept.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref.read(historyProvider.notifier).clearHistory();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage'),
        actions: [
          IconButton(
            icon: const Icon(CupertinoIcons.trash),
            onPressed: _clearHistory,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'History'),
            Tab(text: 'Favorites'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _ItemList(showFavoritesOnly: false),
          _ItemList(showFavoritesOnly: true),
        ],
      ),
    );
  }
}

class _ItemList extends ConsumerWidget {
  final bool showFavoritesOnly;

  const _ItemList({required this.showFavoritesOnly});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(historyProvider);

    return historyAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
      data: (items) {
        final displayItems = showFavoritesOnly 
            ? items.where((item) => item.isFavorite).toList()
            : items;

        if (displayItems.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  showFavoritesOnly ? CupertinoIcons.heart_slash : CupertinoIcons.clock,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  showFavoritesOnly ? 'No favorites yet' : 'History is empty',
                  style: TextStyle(color: Colors.grey[600], fontSize: 16),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          itemCount: displayItems.length,
          separatorBuilder: (context, index) => const Divider(height: 1, indent: 64),
          itemBuilder: (context, index) {
            final item = displayItems[index];
            return Dismissible(
              key: Key(item.id),
              direction: DismissDirection.endToStart,
              background: Container(
                color: Colors.red,
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                child: const Icon(CupertinoIcons.trash, color: Colors.white),
              ),
              onDismissed: (_) {
                ref.read(historyProvider.notifier).deleteItem(item.id);
              },
              child: ListTile(
                leading: _buildIcon(item.category),
                title: Text(
                  item.label?.isNotEmpty == true ? item.label! : (item.isGenerated ? 'Generated ${item.type}' : 'Scanned ${item.type}'),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.content,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat.yMMMd().add_jm().format(item.timestamp),
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                trailing: IconButton(
                  icon: Icon(
                    item.isFavorite ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
                    color: item.isFavorite ? Colors.red : Colors.grey,
                  ),
                  onPressed: () {
                    ref.read(historyProvider.notifier).toggleFavorite(item);
                  },
                ),
                onTap: () {
                  context.go('/manage/item/${item.id}');
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildIcon(String category) {
    IconData icon;
    Color color;
    
    switch (category.toLowerCase()) {
      case 'url':
        icon = CupertinoIcons.link;
        color = Colors.blue;
        break;
      case 'phone':
        icon = CupertinoIcons.phone;
        color = Colors.green;
        break;
      default:
        icon = CupertinoIcons.text_alignleft;
        color = Colors.grey;
    }

    return CircleAvatar(
      backgroundColor: color.withValues(alpha: 0.1),
      child: Icon(icon, color: color),
    );
  }
}
