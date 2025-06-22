import 'package:go_router/go_router.dart';
import 'package:my_flutter_app/appearance.dart';
import 'package:my_flutter_app/home_page.dart';
import 'package:my_flutter_app/main.dart';
import 'package:my_flutter_app/settings_page.dart';

GoRouter createRouter = GoRouter(
  routes: [
    GoRoute(
      path: "/",
      builder: (context, state) => MainScreen(title: "Cat Facts"),
    ),
    GoRoute(
      path: "/home",
      builder: (context, state) => MyHomePage(title: "cat facts"),
    ),
    GoRoute(path: "/settings", builder: (context, state) => SettingsPage()),
    GoRoute(
      path: "/settings/appearance",
      builder: (context, state) => AppearancePage(),
    ),
  ],
);
