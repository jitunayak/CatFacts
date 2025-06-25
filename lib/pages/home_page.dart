import 'dart:math' as math;
import 'dart:ui';

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

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  String _catFact = "Press the button to get a cat fact";
  Uint8List? _catImage;

  late final SpeechService _speechService;
  final CatService _catService = CatService();
  final SettingsService _settingsService = SettingsService();
  final AudioPlayer _audioPlayer = AudioPlayer();

  late VideoPlayerController _controller;
  late PreferenceCubit preferenceCubit;

  late AnimationController _animationController;
  late Animation<double> _blurAnimation;
  late Animation<double> _rotationAnimation;

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

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _blurAnimation = Tween<double>(begin: 30.0, end: 50.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * math.pi,
    ).animate(_animationController);

    preferenceCubit = BlocProvider.of<PreferenceCubit>(context);
    _speechService = SpeechService(_settingsService, _audioPlayer, context);
    _catService.fetchAndCacheImage().then((value) {
      if (!mounted) return;
      setState(() {
        _catImage = value;
      });
    });
    _fetchCatFact(); // Fetch a fact when the screen is loaded
  }

  @override
  void dispose() {
    _controller.dispose();
    _animationController.dispose();
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
    final catImage = _catService.getImageBytes();
    if (!mounted) return;
    setState(() {
      _catFact = catFact;
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
    final isDarkMode =
        MediaQuery.of(context).platformBrightness == Brightness.dark;

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(widget.title),
        transitionBetweenRoutes: false,
      ),
      child: SafeArea(
        child: BlocBuilder<ThemeCubit, Themes>(
          builder: (context, state) =>
              state == Themes.light && _catImage == null
              ? AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: VideoPlayer(_controller),
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        AnimatedBuilder(
                          animation: _animationController,
                          builder: (context, child) {
                            return ImageFiltered(
                              imageFilter: ImageFilter.blur(
                                sigmaX: _blurAnimation.value,
                                sigmaY: _blurAnimation.value + 20,
                              ),
                              child: Transform.rotate(
                                angle: _rotationAnimation.value,
                                child: child,
                              ),
                            );
                          },
                          child: Container(
                            width: 300,
                            height: 300,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [
                                  CupertinoTheme.of(context).primaryColor,
                                  isDarkMode || state == Themes.dark
                                      ? CupertinoColors.systemPink
                                      : CupertinoColors.activeGreen,
                                  isDarkMode || state == Themes.dark
                                      ? CupertinoColors.white
                                      : CupertinoColors.white,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                          ),
                        ),
                        // Circular cat photo with shadow
                        Transform.translate(
                          offset: Offset(0, 0), // Adjust this offset to overlap
                          child: ClipOval(
                            child: _catImage == null
                                ? null
                                : Image.memory(
                                    height: 260,
                                    width: 260,
                                    _catImage!,
                                    key: ValueKey(_catFact), // Force reload
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (
                                          context,
                                          error,
                                          stackTrace,
                                        ) => Container(
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
                      ],
                    ),
                    // const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: BlocBuilder<ThemeCubit, Themes>(
                        builder: (context, state) =>
                            ShimmerText(text: _catFact),
                      ),
                    ),
                    // const SizedBox(height: 24),
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
