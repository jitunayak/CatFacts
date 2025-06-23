import 'package:go_router/go_router.dart';
import 'package:my_flutter_app/constants/app_config.dart';
import 'package:my_flutter_app/main.dart';
import 'package:my_flutter_app/pages/appearance_page.dart';
import 'package:my_flutter_app/pages/home_page.dart';
import 'package:my_flutter_app/pages/settings_page.dart';

GoRouter createRouter = GoRouter(
  routes: [
    GoRoute(
      path: Config.path.root,
      builder: (context, state) => MainScreen(title: "Cat Facts"),
    ),
    GoRoute(
      path: Config.path.home,
      builder: (context, state) => MyHomePage(title: "cat facts"),
    ),
    GoRoute(
      path: Config.path.settings,
      builder: (context, state) => SettingsPage(),
    ),
    GoRoute(
      path: Config.path.appearance,
      builder: (context, state) => AppearancePage(),
    ),
  ],
);
