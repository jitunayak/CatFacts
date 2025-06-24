import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';
import 'package:my_flutter_app/bloc/preference_cubit.dart';
import 'package:my_flutter_app/constants/router_path.dart';
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
  bool _buyMeCoffee = false;
  Map<String, String> _selectedVoiceId = {};

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
    var preferenceCubit = BlocProvider.of<PreferenceCubit>(context);
    return BlocProvider(
      create: (context) => preferenceCubit,
      child: CupertinoPageScaffold(
        navigationBar: const CupertinoNavigationBar(
          middle: Text('Settings'),
          transitionBetweenRoutes: false,
        ),
        child: SafeArea(
          child: BlocBuilder<PreferenceCubit, Preferences>(
            builder: (context, state) => ListView(
              children: [
                CupertinoFormSection.insetGrouped(
                  header: const Text('Preferences'),
                  footer: const Text(
                    'You agree with terms and conditions of the app',
                  ),
                  children: [
                    CupertinoListTile(
                      leading: Icon(CupertinoIcons.bell),
                      title: const Text('Notifications'),
                      trailing: CupertinoSwitch(
                        value: preferenceCubit.state.isNotificationEnabled,
                        onChanged: (bool value) {
                          preferenceCubit.saveIsNotificationEnabled(value);
                          _showNotification();
                        },
                      ),
                    ),
                    CupertinoListTile(
                      leading: Icon(CupertinoIcons.gift),
                      title: const Text('Buy Me Coffee'),
                      trailing: CupertinoSwitch(
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
                                      onPressed: () =>
                                          Navigator.of(context).pop(),
                                    ),
                                  ],
                                ),
                              );
                            }
                          });
                        },
                      ),
                    ),
                    CupertinoListTile(
                      leading: Icon(CupertinoIcons.settings),
                      title: const Text("Appearance"),
                      padding: EdgeInsetsDirectional.fromSTEB(20, 12, 16, 12),
                      onTap: () => context.push(RouterPath().appearance),
                      trailing: CupertinoListTileChevron(),
                    ),
                  ],
                ),

                CupertinoFormSection.insetGrouped(
                  header: const Text('Voice Settings (Pro) ✨'),
                  footer: const Text('You can choose your preferred voice'),
                  children: [
                    CupertinoListTile(
                      leading: Icon(CupertinoIcons.waveform),
                      title: const Text('AI Voices'),
                      trailing: CupertinoButton(
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
                  ],
                ),

                CupertinoFormSection.insetGrouped(
                  header: const Text("System TTS Engine"),
                  footer: const Text(
                    "This is the fallback engine if you exhaust your quota or under a free plan. Try considering to opt for paid plan.",
                  ),
                  children: [
                    CupertinoListTile(
                      leading: Icon(CupertinoIcons.speaker_2),
                      title: const Text('Default TTS (Free)'),
                      trailing: CupertinoSwitch(
                        value: preferenceCubit.state.isSystemTTSEnabled,
                        onChanged: (value) => {
                          preferenceCubit.saveIsSystemTTSEnabled(value),
                        },
                      ),
                    ),
                    CupertinoListTile(
                      leading: Icon(CupertinoIcons.play),
                      title: const Text('Auto Play'),
                      trailing: CupertinoSwitch(
                        value: preferenceCubit.state.shoudlAutoPlay,
                        onChanged: (value) => {
                          preferenceCubit.saveShouldAutoPlay(value),
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
