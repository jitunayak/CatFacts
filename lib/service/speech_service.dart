import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:my_flutter_app/models/env_keys.dart';
import 'package:my_flutter_app/service/eleven_labs.dart';
import 'package:my_flutter_app/store/SettingsStore.dart';
import 'package:path_provider/path_provider.dart';

class SpeechService {
  final bool _isSpeaking = false;
  bool _disposed = false;

  final StreamController<bool> _speakingStateController =
      StreamController<bool>.broadcast();

  SpeechService(this._settingsService, this._audioPlayer) {
    _initializeHandlers();
  }

  final SettingsService _settingsService;
  final AudioPlayer _audioPlayer;
  final FlutterTts flutterTts = FlutterTts();

  Stream<bool> get speakingStateStream => _speakingStateController.stream;

  bool get isSpeaking => _isSpeaking;

  void _initializeHandlers() {
    // FlutterTts handlers
    flutterTts.setStartHandler(() {
      if (!_disposed) _speakingStateController.add(true);
    });

    flutterTts.setCompletionHandler(() {
      if (!_disposed) _speakingStateController.add(false);
    });

    flutterTts.setCancelHandler(() {
      if (!_disposed) _speakingStateController.add(false);
    });

    flutterTts.setErrorHandler((message) {
      if (!_disposed) _speakingStateController.add(false);
    });

    // AudioPlayer handlers
    _audioPlayer.onPlayerComplete.listen((event) {
      if (!_disposed) _speakingStateController.add(false);
    });

    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (!_disposed && state != PlayerState.playing) {
        _speakingStateController.add(false);
      }
    });
  }

  Future<void> play(String text) async {
    if (_disposed) return;

    try {
      // Stop any current playback
      await stop();

      // Load TTS preference
      final isDefaultTTS = await _settingsService.loadTTS();

      if (isDefaultTTS) {
        await _playWithFlutterTTS(text);
      } else {
        await _playWithElevenLabs(text);
      }
    } catch (e) {
      _speakingStateController.add(false);
      rethrow;
    }
  }

  Future<void> stop() async {
    if (_disposed) return;

    try {
      // Stop both TTS engines
      await Future.wait([flutterTts.stop(), _audioPlayer.stop()]);
    } catch (e) {
      // Log error if needed, but don't rethrow
    } finally {
      _speakingStateController.add(false);
    }
  }

  Future<void> _playWithFlutterTTS(String text) async {
    if (_disposed) return;

    try {
      await flutterTts.setLanguage("en-US");
      await flutterTts.setSpeechRate(0.5);
      await flutterTts.setVolume(1.0);

      // _speakingStateController.add(ill) be set by the start handler
      await flutterTts.speak(text);
    } catch (e) {
      _speakingStateController.add(false);
      rethrow;
    }
  }

  Future<void> _playWithElevenLabs(String text) async {
    if (_disposed) return;

    try {
      _speakingStateController.add(true);

      final voiceId = await _settingsService.loadVoice();
      final ElevenLabsTTS tts = ElevenLabsTTS(
        apiKey: dotenv.get(EnvKeys.elevenLabsApiKey),
        voiceId: voiceId,
      );

      final ttsResponse = await tts.synthesize(text);

      if (!ttsResponse.success) {
        final errorMessage =
            ttsResponse.errorMessage ?? 'An unknown error occurred.';
        throw Exception('TTS Synthesis failed: $errorMessage');
      }

      final audioBytes = ttsResponse.data!;
      final tempDir = await getTemporaryDirectory();
      final tempFile = File(
        '${tempDir.path}/temp_audio_${DateTime.now().millisecondsSinceEpoch}.mp3',
      );

      await tempFile.writeAsBytes(audioBytes, flush: true);

      await _audioPlayer.play(DeviceFileSource(tempFile.path));

      // Clean up temp file after a delay (optional)
      Future.delayed(const Duration(seconds: 30), () {
        tempFile.delete().catchError((_) {});
      });
    } catch (e) {
      _speakingStateController.add(false);
      rethrow;
    }
  }

  Future<void> dispose() async {
    _disposed = true;
    await stop();
    await flutterTts.stop();
    // Note: Don't dispose _audioPlayer here if it's shared across the app
    // await _audioPlayer.dispose();
  }
}
