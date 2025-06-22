import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:my_flutter_app/home_page.dart';
import 'package:my_flutter_app/router.dart';
import 'package:my_flutter_app/settings_page.dart';

Future<void> main() async {
  await dotenv.load();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return CupertinoApp.router(
      title: 'Flutter Demo',
      theme: CupertinoThemeData(primaryColor: CupertinoColors.systemBlue),
      debugShowCheckedModeBanner: false,
      routerConfig: createRouter,
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key, required this.title});
  final String title;

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        onTap: (index) {
          HapticFeedback.mediumImpact();
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.paw),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.settings),
            label: 'Settings',
          ),
        ],
      ),
      tabBuilder: (context, index) {
        switch (index) {
          case 0:
            return Center(child: MyHomePage(title: widget.title));
          case 1:
            return SettingsPage();
          default:
            return Center(child: Text('Unknown'));
        }
      },
    );
  }
}
