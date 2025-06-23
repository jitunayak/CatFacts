import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_flutter_app/bloc/theme_cubit.dart';
import 'package:my_flutter_app/widgets/tick.dart';

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
        child: BlocBuilder<ThemeCubit, Themes>(
          builder: (context, state) => ListView(
            children: [
              CupertinoListSection.insetGrouped(
                hasLeading: true,
                header: const Text(
                  "THEME",
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                ),
                children: [
                  CupertinoListTile(
                    title: const Text("Light"),
                    leading: Icon(CupertinoIcons.sun_dust),
                    trailing: Tick(isSelected: state == Themes.light),
                    onTap: () {
                      BlocProvider.of<ThemeCubit>(context).toggleToLightTheme();
                    },
                  ),

                  CupertinoListTile(
                    title: const Text("Dark"),
                    leading: Icon(CupertinoIcons.moon_stars),
                    trailing: Tick(isSelected: state == Themes.dark),
                    onTap: () {
                      BlocProvider.of<ThemeCubit>(context).toggleToDarkTheme();
                    },
                  ),

                  CupertinoListTile(
                    title: const Text("System"),
                    leading: Icon(CupertinoIcons.device_phone_portrait),
                    trailing: Tick(isSelected: state == Themes.system),
                    onTap: () {
                      BlocProvider.of<ThemeCubit>(context).toggleSystemTheme();
                    },
                  ),
                ],
              ),

              CupertinoListSection.insetGrouped(
                header: const Text(
                  "APP LOGO",
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                ),
                children: [IconListTile()],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class IconListTile extends StatelessWidget {
  const IconListTile({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoFormRow(
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          ClipRSuperellipse(
            borderRadius: BorderRadiusGeometry.all(Radius.circular(12)),
            child: Image.asset("assets/icon/app_icon.png", height: 60),
          ),
          SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Original",
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const Text(
                "Simplicity at its best",
                style: TextStyle(
                  color: CupertinoDynamicColor.withBrightness(
                    color: CupertinoColors.inactiveGray,
                    darkColor: CupertinoColors.extraLightBackgroundGray,
                  ),
                ),
              ),
            ],
          ),
          Spacer(),
          Tick(isSelected: true),
        ],
      ),
    );
  }
}
