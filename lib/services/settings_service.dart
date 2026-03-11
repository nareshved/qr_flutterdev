import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static final SettingsService _instance = SettingsService._internal();
  factory SettingsService() => _instance;
  SettingsService._internal();

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  bool get saveHistory => _prefs?.getBool('saveHistory') ?? true;
  Future<void> setSaveHistory(bool value) async {
    await _prefs?.setBool('saveHistory', value);
  }

  bool get confirmBeforeOpenUrl => _prefs?.getBool('confirmBeforeOpenUrl') ?? true;
  Future<void> setConfirmBeforeOpenUrl(bool value) async {
    await _prefs?.setBool('confirmBeforeOpenUrl', value);
  }

  bool get isDarkMode => _prefs?.getBool('isDarkMode') ?? false;
  Future<void> setIsDarkMode(bool value) async {
    await _prefs?.setBool('isDarkMode', value);
  }
}
