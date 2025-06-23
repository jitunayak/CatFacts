// settings_service.dart
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  // voice id
  Future<void> saveVoice(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("voiceId", value);
  }

  Future<String> loadVoice() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("voiceId") ?? 'Sm1seazb4gs7RSlUVw7c';
  }

  // auto play
  Future<bool> toggleAutoPlay() async {
    final prefs = await SharedPreferences.getInstance();
    bool shoudlAutoPlay = prefs.getBool('autoPlay') ?? false;
    await prefs.setBool('autoPlay', !shoudlAutoPlay);
    return !shoudlAutoPlay;
  }

  Future<bool> loadAutoPlay() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('autoPlay') ?? false;
  }

  Future<void> saveTTS<bool>(value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("tts", value);
  }

  Future<bool> loadTTS() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool("tts") ?? false;
  }

  // Future<ThemeState> loadTheme() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   var theme = prefs.getString('theme');
  //   if (theme == Themes.dark.toString()) {
  //     return DarkThemeState();
  //   } else if (theme == Themes.light.toString()) {
  //     return LightThemeState();
  //   }
  //   return SystemThemeState();
  // }

  // Future<void> saveTheme(Themes theme) async {
  //   final prefs = await SharedPreferences.getInstance();
  //   await prefs.setString('theme', theme.toString());
  // }
}
