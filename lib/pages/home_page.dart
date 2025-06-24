import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_flutter_app/bloc/preference_cubit.dart';
import 'package:my_flutter_app/bloc/theme_cubit.dart';
import 'package:my_flutter_app/service/cat_service.dart';
import 'package:my_flutter_app/service/speech_service.dart';
import 'package:my_flutter_app/store/SettingsStore.dart';
import 'package:my_flutter_app/widgets/shimmer_text.dart';
import 'package:video_player/video_player.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _catFact = "Press the button to get a cat fact";
  Uint8List? _catImage;

  late final SpeechService _speechService;
  final CatService _catService = CatService();
  final SettingsService _settingsService = SettingsService();
  final AudioPlayer _audioPlayer = AudioPlayer();

  late VideoPlayerController _controller;
  late PreferenceCubit preferenceCubit;

  void _initializeVideoPlayer() async {
    _controller = VideoPlayerController.asset('assets/videos/cat.mp4');
    await _controller.initialize();
    _controller.setLooping(true);
    _controller.play();
  }

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer();
    preferenceCubit = BlocProvider.of<PreferenceCubit>(context);
    _speechService = SpeechService(_settingsService, _audioPlayer, context);
    _catService.fetchAndCacheImage().then((value) {
      setState(() {
        _catImage = value;
      });
    });
    _fetchCatFact(); // Fetch a fact when the screen is loaded
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _speak() async {
    try {
      await _speechService.play(_catFact);
    } catch (e) {
      _showErrorDialog("Error", e.toString());
    }
  }

  Future<void> _showErrorDialog(String title, String content) {
    return showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            child: const Text('OK'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Future<void> _fetchCatFact() async {
    HapticFeedback.mediumImpact();
    final shoudlAutoPlay = preferenceCubit.state.shoudlAutoPlay;
    final String catFact = await _catService.getFact();
    setState(() {
      _catFact = catFact;
    });
    final catImage = _catService.getImageBytes();
    setState(() {
      _catImage = catImage;
    });
    _catService.fetchAndCacheImage();

    if (_speechService.isSpeaking) await _speechService.stop();
    if (shoudlAutoPlay) {
      await _speak();
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(widget.title),
        transitionBetweenRoutes: false,
      ),
      child: Center(
        child: BlocBuilder<ThemeCubit, Themes>(
          builder: (context, state) =>
              state == Themes.light && _catImage == null
              ? AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: VideoPlayer(_controller),
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    // Circular cat photo with shadow
                    ClipOval(
                      child: Transform(
                        transform: Matrix4.identity(),
                        alignment: FractionalOffset.center,
                        child: _catImage == null
                            ? const CupertinoActivityIndicator()
                            : Image.memory(
                                height: 160,
                                width: 160,
                                _catImage!,
                                key: ValueKey(_catFact), // Force reload
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
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
                      child: BlocBuilder<ThemeCubit, Themes>(
                        builder: (context, state) => state == Themes.dark
                            ? ShimmerText(text: _catFact)
                            : Text(
                                _catFact,
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 18),
                              ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CupertinoButton(
                          color: CupertinoTheme.of(
                            context,
                          ).primaryColor, // Background color
                          padding: EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 8,
                          ), // Padding
                          borderRadius: BorderRadius.circular(
                            28,
                          ), // Minimum size
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

                        StreamBuilder<bool>(
                          stream: _speechService.speakingStateStream,
                          initialData: _speechService.isSpeaking,
                          builder: (context, snapshot) {
                            final isSpeaking = snapshot.data ?? false;
                            return CupertinoButton(
                              color: CupertinoColors.systemGrey3,
                              padding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              borderRadius: BorderRadius.circular(28),
                              pressedOpacity: 0.5,
                              onPressed: isSpeaking
                                  ? _speechService.stop
                                  : _speak,
                              minimumSize: Size(50, 50),
                              child: isSpeaking
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
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
