import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:my_flutter_app/bloc/preference_cubit.dart';
import 'package:my_flutter_app/bloc/theme_cubit.dart';
import 'package:my_flutter_app/constants/app_theme.dart';
import 'package:my_flutter_app/pages/home_page.dart';
import 'package:my_flutter_app/pages/settings_page.dart';
import 'package:my_flutter_app/router.dart';
import 'package:path_provider/path_provider.dart';

Future<void> main() async {
  await dotenv.load();
  WidgetsFlutterBinding.ensureInitialized();
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: kIsWeb
        ? HydratedStorageDirectory.web
        : HydratedStorageDirectory((await getTemporaryDirectory()).path),
  );
  runApp(
    BlocProvider(
      create: (BuildContext context) => PreferenceCubit(),
      child: BlocProvider(
        create: (BuildContext context) => ThemeCubit(),
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, Themes>(
      builder: (context, state) => CupertinoApp.router(
        theme: {
          if (state == Themes.light)
            AppTheme.lightTheme
          else if (state == Themes.dark)
            AppTheme.darkTheme
          else
            CupertinoThemeData(),
        }.first, // Access the first element of the set
        title: 'Flutter Demo',
        debugShowCheckedModeBanner: false,
        routerConfig: createRouter,
      ),
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
