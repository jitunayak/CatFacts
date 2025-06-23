import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_flutter_app/bloc/theme_cubit.dart';
import 'package:my_flutter_app/bloc/theme_state.dart';

enum Themes { light, dark, system }

class Tick extends StatelessWidget {
  final bool isSelected;
  const Tick({super.key, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      onPressed: () {},
      child: isSelected
          ? const Icon(
              CupertinoIcons.check_mark,
              color: CupertinoColors.activeGreen,
            )
          : const SizedBox(height: 20),
    );
  }
}

class AppearancePage extends StatefulWidget {
  const AppearancePage({super.key});

  @override
  State<AppearancePage> createState() => _AppearancePageState();
}

class _AppearancePageState extends State<AppearancePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Appearance'),
        transitionBetweenRoutes: false,
        previousPageTitle: "Settings",
      ),
      child: SafeArea(
        child: BlocBuilder<ThemeCubit, ThemeState>(
          builder: (context, state) => ListView(
            children: [
              CupertinoListSection.insetGrouped(
                children: [
                  CupertinoListTile(
                    title: const Text("Light"),
                    leading: Icon(CupertinoIcons.sun_dust),
                    trailing: Tick(isSelected: state is LightThemeState),
                    onTap: () {
                      BlocProvider.of<ThemeCubit>(context).toggleToLightTheme();
                    },
                  ),

                  CupertinoListTile(
                    title: const Text("Dark"),
                    leading: Icon(CupertinoIcons.moon_stars),
                    trailing: Tick(isSelected: state is DarkThemeState),
                    onTap: () {
                      BlocProvider.of<ThemeCubit>(context).toggleToDarkTheme();
                    },
                  ),

                  CupertinoListTile(
                    title: const Text("System"),
                    leading: Icon(CupertinoIcons.device_phone_portrait),
                    trailing: Tick(isSelected: state is SystemThemeState),
                    onTap: () {
                      BlocProvider.of<ThemeCubit>(context).toggleSystemTheme();
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
