import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:my_flutter_app/models/env_keys.dart';
import 'package:my_flutter_app/service/eleven_labs.dart';
import 'package:my_flutter_app/store/SettingsStore.dart';
import 'package:path_provider/path_provider.dart';

class SpeechService {
  bool _isSpeaking = false;

  SpeechService(this._settingsService, this._audioPlayer);
  final SettingsService _settingsService;
  final AudioPlayer _audioPlayer;

  get isSpeaking => _isSpeaking;

  Future<void> play(catFact) async {
    _audioPlayer.onPlayerComplete.listen((event) {
      _isSpeaking = false;
    });
    if (_audioPlayer.state == PlayerState.playing) {
      await _audioPlayer.stop();
      _isSpeaking = false;
    }
    _isSpeaking = true;
    bool isDefaultTTS = await _settingsService.loadTTS();

    if (isDefaultTTS) {
      await flutterTTS(catFact);
    } else {
      await elevenLabsSynthesizer(catFact);
    }
  }

  Future<void> flutterTTS(catFact) async {
    FlutterTts flutterTts = FlutterTts();
    await flutterTts.setLanguage("en-US");
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.setVolume(1.0);
    await flutterTts.speak(catFact);
  }

  Future<void> elevenLabsSynthesizer(catFact) async {
    final voiceId = await _settingsService.loadVoice();
    final ElevenLabsTTS tts = ElevenLabsTTS(
      apiKey: dotenv.get(EnvKeys.elevenLabsApiKey),
      voiceId: voiceId,
    );
    final ttsResponse = await tts.synthesize(catFact);

    if (ttsResponse.success) {
      final audioBytes = ttsResponse.data!;
      try {
        final tempDir = await getTemporaryDirectory();
        final tempFile = File('${tempDir.path}/temp_audio.mp3');
        await tempFile.writeAsBytes(audioBytes, flush: true);
        await _audioPlayer.play(DeviceFileSource(tempFile.path));
      } catch (e) {
        _isSpeaking = false;
      }
    } else {
      final errorMessage =
          ttsResponse.errorMessage ?? 'An unknown error occurred.';
      // _showErrorDialog('Synthesis Failed', errorMessage);
      _isSpeaking = false;
      throw Exception(errorMessage);
    }
  }
}
