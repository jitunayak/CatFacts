// settings_service.dart
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  Future<void> saveVoice(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("voiceId", value);
  }

  Future<String> loadVoice() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("voiceId") ?? 'Sm1seazb4gs7RSlUVw7c';
  }

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
}
