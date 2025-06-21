import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:my_flutter_app/service/cat_service.dart';
import 'package:my_flutter_app/store/SettingsStore.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

final List<Map<String, String>> _voices = [
  {"name": "Anika - Friendly", "identifier": "Sm1seazb4gs7RSlUVw7c"},
  {"name": "Aahir - Expressive", "identifier": "82hBsVN6GRUwWKT8d1Kz"},
  {"name": "Sarah - Confident", "indentifier": "EXAVITQu4vr4xnSDxMaL"},
];

class _SettingsPageState extends State<SettingsPage> {
  bool _notificationsEnabled = false;
  bool _buyMeCoffee = false;
  bool _autoPlay = false;
  Map<String, String> _selectedVoiceId = {};
  bool _tts = false;

  final SettingsService _settingsService = SettingsService();
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    initializeNoitification();
    super.initState();
    _settingsService.loadVoice().then((value) {
      Map<String, String> voice = _voices.firstWhere(
        (e) => e['identifier'] == value,
      );
      setState(() {
        _selectedVoiceId = voice;
      });
    });

    _settingsService.loadAutoPlay().then((value) {
      setState(() {
        _autoPlay = value;
      });
    });

    _settingsService.loadTTS().then((value) {
      setState(() {
        _tts = value;
      });
    });
  }

  Future<void> initializeNoitification() async {
    // Android initialization
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );

    await _notificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _toggleAutoPlay() async {
    bool value = await _settingsService.toggleAutoPlay();
    setState(() {
      _autoPlay = value;
    });
  }

  void _showNotification() async {
    CatService catService = CatService();
    String catFact = await catService.getFact();
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'default_channel',
          'Default Channel',
          channelDescription: 'Default notification channel',
          importance: Importance.max,
          priority: Priority.high,
          showWhen: false,
        );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );
    await _notificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      "🐾 Your daily dose of cat fact 🐈",
      catFact,
      platformChannelSpecifics,
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('Settings')),
      child: SafeArea(
        child: ListView(
          children: [
            CupertinoFormSection.insetGrouped(
              header: const Text('Preferences'),
              footer: const Text(
                'You agree with terms and conditions of the app',
              ),
              children: [
                CupertinoFormRow(
                  prefix: const Text('Notifications'),
                  child: CupertinoSwitch(
                    value: _notificationsEnabled,
                    onChanged: (bool value) {
                      if (value) {
                        _showNotification();
                      }
                      setState(() {
                        _notificationsEnabled = value;
                      });
                    },
                  ),
                ),

                CupertinoFormRow(
                  prefix: const Text('Buy Me Coffee'),
                  child: CupertinoSwitch(
                    value: _buyMeCoffee,
                    onChanged: (bool value) {
                      setState(() {
                        _buyMeCoffee = value;
                        if (value) {
                          showCupertinoDialog(
                            context: context,
                            builder: (context) => CupertinoAlertDialog(
                              title: const Text('Thank you!'),
                              content: const Text(
                                'Thanks for your support! ☕️',
                              ),
                              actions: [
                                CupertinoDialogAction(
                                  child: const Text('Close'),
                                  onPressed: () => Navigator.of(context).pop(),
                                ),
                              ],
                            ),
                          );
                        }
                      });
                    },
                  ),
                ),
              ],
            ),

            CupertinoFormSection.insetGrouped(
              header: const Text('Voice Settings (Pro) ✨'),
              footer: const Text('You can choose your preferred voice'),
              children: [
                CupertinoFormRow(
                  prefix: const Text('AI Voices'),
                  child: CupertinoButton(
                    onPressed: () {
                      showCupertinoModalPopup(
                        context: context,
                        builder: (context) {
                          return CupertinoActionSheet(
                            title: const Text('AI Voices'),
                            actions: _voices.map((voice) {
                              return CupertinoActionSheetAction(
                                child: Text(voice['name'] ?? 'Unknown'),
                                onPressed: () {
                                  // Use voice as Map<String, String>
                                  setState(() {
                                    _selectedVoiceId = voice;
                                  });
                                  _settingsService.saveVoice(
                                    voice['identifier'] ?? '',
                                  );
                                  Navigator.of(context).pop();
                                },
                              );
                            }).toList(),
                          );
                        },
                      );
                    },
                    child: Text(_selectedVoiceId['name'] ?? 'Select Voice'),
                  ),
                ),
                CupertinoFormRow(
                  prefix: const Text('Auto Play'),
                  child: CupertinoSwitch(
                    value: _autoPlay,
                    onChanged: (value) => {_toggleAutoPlay()},
                  ),
                ),
                CupertinoFormRow(
                  prefix: const Text('Default TTS'),
                  child: CupertinoSwitch(
                    value: _tts,
                    onChanged: (value) {
                      _settingsService.saveTTS(value);
                      setState(() {
                        _tts = value;
                      });
                    },
                  ),
                ),
              ],
            ),

            CupertinoFormSection.insetGrouped(
              header: const Text("System TTS Engine"),
              footer: const Text(
                "This is the fallback engine if you exhaust your quota or under a free plan. Try considering to opt for paid plan.",
              ),
              children: [
                CupertinoFormRow(
                  prefix: const Text('Default TTS (Free)'),
                  child: CupertinoSwitch(
                    value: _tts,
                    onChanged: (value) {
                      _settingsService.saveTTS(value);
                      setState(() {
                        _tts = value;
                      });
                    },
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
