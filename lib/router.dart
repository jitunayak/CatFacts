import 'package:go_router/go_router.dart';
import 'package:my_flutter_app/main.dart';
import 'package:my_flutter_app/models/router_path.dart';
import 'package:my_flutter_app/pages/appearance_page.dart';
import 'package:my_flutter_app/pages/home_page.dart';
import 'package:my_flutter_app/pages/settings_page.dart';

GoRouter createRouter = GoRouter(
  routes: [
    GoRoute(
      path: RouterPath().root,
      builder: (context, state) => MainScreen(title: "Cat Facts"),
    ),
    GoRoute(
      path: RouterPath().home,
      builder: (context, state) => MyHomePage(title: "cat facts"),
    ),
    GoRoute(
      path: RouterPath().settings,
      builder: (context, state) => SettingsPage(),
    ),
    GoRoute(
      path: RouterPath().appearance,
      builder: (context, state) => AppearancePage(),
    ),
  ],
);
