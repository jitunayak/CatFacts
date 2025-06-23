import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_flutter_app/bloc/theme_cubit.dart';

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
  Themes _theme = Themes.system;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Appearance'),
        transitionBetweenRoutes: false,
        previousPageTitle: "Settings",
      ),
      child: SafeArea(
        child: ListView(
          children: [
            CupertinoListSection.insetGrouped(
              children: [
                CupertinoListTile(
                  title: const Text("Light"),
                  trailing: Tick(isSelected: _theme == Themes.light),
                  onTap: () {
                    BlocProvider.of<ThemeCubit>(context).toggleToLightTheme();
                    setState(() {
                      _theme = Themes.light;
                    });
                  },
                ),

                CupertinoListTile(
                  title: const Text("Dark"),
                  trailing: Tick(isSelected: _theme == Themes.dark),
                  onTap: () {
                    BlocProvider.of<ThemeCubit>(context).toggleToDarkTheme();
                    setState(() {
                      _theme = Themes.dark;
                    });
                  },
                ),

                CupertinoListTile(
                  title: const Text("System"),
                  trailing: Tick(isSelected: _theme == Themes.system),
                  onTap: () {
                    setState(() {
                      _theme = Themes.system;
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
