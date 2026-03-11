import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/qr_item.dart';
import '../services/database_service.dart';
import '../services/settings_service.dart';

final settingsProvider = NotifierProvider<SettingsNotifier, SettingsState>(() {
  return SettingsNotifier();
});

class SettingsState {
  final bool saveHistory;
  final bool confirmBeforeOpenUrl;
  final bool isDarkMode;

  SettingsState({
    this.saveHistory = true,
    this.confirmBeforeOpenUrl = true,
    this.isDarkMode = false,
  });

  SettingsState copyWith({
    bool? saveHistory,
    bool? confirmBeforeOpenUrl,
    bool? isDarkMode,
  }) {
    return SettingsState(
      saveHistory: saveHistory ?? this.saveHistory,
      confirmBeforeOpenUrl: confirmBeforeOpenUrl ?? this.confirmBeforeOpenUrl,
      isDarkMode: isDarkMode ?? this.isDarkMode,
    );
  }
}

class SettingsNotifier extends Notifier<SettingsState> {
  @override
  SettingsState build() {
    final service = SettingsService();
    return SettingsState(
      saveHistory: service.saveHistory,
      confirmBeforeOpenUrl: service.confirmBeforeOpenUrl,
      isDarkMode: service.isDarkMode,
    );
  }

  Future<void> toggleSaveHistory(bool value) async {
    await SettingsService().setSaveHistory(value);
    state = state.copyWith(saveHistory: value);
  }

  Future<void> toggleConfirmBeforeOpenUrl(bool value) async {
    await SettingsService().setConfirmBeforeOpenUrl(value);
    state = state.copyWith(confirmBeforeOpenUrl: value);
  }
  
  Future<void> toggleTheme(bool isDark) async {
    await SettingsService().setIsDarkMode(isDark);
    state = state.copyWith(isDarkMode: isDark);
  }
}

final historyProvider = AsyncNotifierProvider<HistoryNotifier, List<QrItem>>(() {
  return HistoryNotifier();
});

class HistoryNotifier extends AsyncNotifier<List<QrItem>> {
  final _db = DatabaseService();

  @override
  Future<List<QrItem>> build() async {
    return await _db.getItems();
  }

  Future<void> loadItems() async {
    state = const AsyncValue.loading();
    try {
      final items = await _db.getItems();
      state = AsyncValue.data(items);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addItem(QrItem item) async {
    await _db.insertItem(item);
    await loadItems();
  }

  Future<void> toggleFavorite(QrItem item) async {
    final updated = item.copyWith(isFavorite: !item.isFavorite);
    await _db.updateItem(updated);
    await loadItems();
  }

  Future<void> deleteItem(String id) async {
    await _db.deleteItem(id);
    await loadItems();
  }

  Future<void> clearHistory() async {
    await _db.clearHistory();
    await loadItems();
  }
}
