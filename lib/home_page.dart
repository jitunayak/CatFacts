import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:my_flutter_app/service/cat_service.dart';
import 'package:my_flutter_app/service/text_to_speech.dart';
import 'package:my_flutter_app/store/SettingsStore.dart';
import 'package:my_flutter_app/widgets/shimmer_text.dart';
import 'package:path_provider/path_provider.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _catFact = "Press the button to get a cat fact";
  String _catImageUrl = '';
  bool _isSpeaking = false;

  final SettingsService _settingsService = SettingsService();
  final AudioPlayer _audioPlayer = AudioPlayer();
  final CatService _catService = CatService();

  Future<void> _speak() async {
    _audioPlayer.onPlayerComplete.listen((event) {
      setState(() {
        _isSpeaking = false;
      });
    });
    if (_audioPlayer.state == PlayerState.playing) {
      await _audioPlayer.stop();
      setState(() {
        _isSpeaking = false;
      });
      return;
    }
    setState(() {
      _isSpeaking = true;
    });

    final voiceId = await _settingsService.loadVoice();
    final ElevenLabsTTS tts = ElevenLabsTTS(
      apiKey: dotenv.get("ELEVEN_LABS_API_KEY"),
      voiceId: voiceId,
    );
    final audioBytes = await tts.synthesize(_catFact);
    if (audioBytes != null) {
      try {
        final tempDir = await getTemporaryDirectory();
        final tempFile = File('${tempDir.path}/temp_audio.mp3');
        await tempFile.writeAsBytes(audioBytes, flush: true);
        await _audioPlayer.play(DeviceFileSource(tempFile.path));
      } catch (e) {
        // ("Error playing audio: $e");
      }
    }
  }

  Future<void> _fetchCatFact() async {
    HapticFeedback.mediumImpact();
    final String catFact = await _catService.getFact();
    setState(() {
      _catFact = catFact;
      _catImageUrl = _catService.getImage();
    });
    if (await _settingsService.loadAutoPlay()) {
      await _speak();
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchCatFact(); // Fetch a fact when the screen is loaded
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode =
        MediaQuery.of(context).platformBrightness == Brightness.dark;

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(middle: Text(widget.title)),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Circular cat photo with shadow
            ClipOval(
              child: Transform(
                transform: Matrix4.identity(),
                alignment: FractionalOffset.center,
                child: Image.network(
                  height: 160,
                  width: 160,
                  _catImageUrl,
                  key: ValueKey(_catFact), // Force reload
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: CupertinoColors.systemGrey4,
                    child: Icon(
                      CupertinoIcons.photo,
                      size: 60,
                      color: CupertinoColors.systemGrey,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: isDarkMode
                  ? ShimmerText(text: _catFact)
                  : Text(
                      _catFact,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18),
                    ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CupertinoButton(
                  color: CupertinoColors.activeBlue, // Background color
                  padding: EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 8,
                  ), // Padding
                  borderRadius: BorderRadius.circular(28), // Minimum size
                  pressedOpacity: 0.5, // Opacity when pressed
                  onPressed: () {
                    _fetchCatFact();
                  },
                  minimumSize: Size(50, 50),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        CupertinoIcons.refresh,
                        color: CupertinoColors.white,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Refresh',
                        style: TextStyle(
                          color: CupertinoColors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 16),

                CupertinoButton(
                  color: CupertinoColors.systemGrey3,
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  borderRadius: BorderRadius.circular(28),
                  pressedOpacity: 0.5,
                  onPressed: _speak,
                  minimumSize: Size(50, 50),
                  child: _isSpeaking
                      ? const Icon(
                          CupertinoIcons.stop_fill,
                          size: 24,
                          color: CupertinoColors.white,
                        )
                      : const Icon(
                          CupertinoIcons.volume_up,
                          size: 24,
                          color: CupertinoColors.white,
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
